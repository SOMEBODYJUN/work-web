#!/usr/bin/env python3
"""Q2 robust second-station design with D, MEC radius R, and area A.

The solver uses only bounded-error geometry.  It does not assign a probability
distribution to bearing errors and does not average repeated measurements.
All disk boundaries are represented by circumscribed tangent polygons, so the
reported feasible polygons and their D/R/A values are conservative outer
approximations for each evaluated report.  The maximum over finitely sampled
reports is a reproducible numerical approximation, not a certified continuous
worst-case bound.  Units are metres, seconds, and degrees.
"""
from __future__ import annotations

from dataclasses import asdict, dataclass
import argparse
import csv
import json
import math
from pathlib import Path
import random
import time
from typing import Iterable, Sequence


Point = tuple[float, float]
DELTA_DEG = 1.0
R_MIN = 1000.0
R_MAX = 1500.0
ARENA_R = 1800.0
EPS = 1e-9


def add(a: Point, b: Point) -> Point:
    return a[0] + b[0], a[1] + b[1]


def sub(a: Point, b: Point) -> Point:
    return a[0] - b[0], a[1] - b[1]


def mul(a: Point, k: float) -> Point:
    return a[0] * k, a[1] * k


def dot(a: Point, b: Point) -> float:
    return a[0] * b[0] + a[1] * b[1]


def cross(a: Point, b: Point) -> float:
    return a[0] * b[1] - a[1] * b[0]


def dist(a: Point, b: Point) -> float:
    return math.hypot(a[0] - b[0], a[1] - b[1])


def local_to_world(first: Point, bearing_deg: float, a: float, b: float) -> Point:
    t = math.radians(bearing_deg)
    return (first[0] + a * math.cos(t) - b * math.sin(t),
            first[1] + a * math.sin(t) + b * math.cos(t))


def _sector_max_distance_sq(s: Point, radius: float, delta_deg: float) -> float:
    """max ||s-r*u(eta)||^2 for 0<=r<=radius, |eta|<=delta."""
    a, b = s
    length2 = a * a + b * b
    delta = math.radians(delta_deg)
    psi = math.atan2(b, a)
    candidates = [a * math.cos(-delta) + b * math.sin(-delta),
                  a * math.cos(delta) + b * math.sin(delta)]
    # An interior antipodal direction can be the minimum dot product.
    for k in (-1, 0, 1):
        eta = psi + math.pi + 2 * math.pi * k
        if -delta <= eta <= delta:
            candidates.append(-math.sqrt(length2))
    min_projection = min(candidates)
    return max(length2, length2 + radius * radius - 2 * radius * min_projection)


def safe_full_information(s: Point, delta_deg: float = DELTA_DEG,
                          rmin: float = R_MIN) -> bool:
    """Exact robust domain using the fact that station 1 already received.

    For a possible source at first-station distance r, the smallest compatible
    receiving radius is max(rmin,r).  The condition reduces to covering the
    first-bearing sector truncated at rmin by rmin-disks.
    """
    return _sector_max_distance_sq(s, rmin, delta_deg) <= rmin * rmin + 1e-7


def safe_uniform_1000(s: Point, delta_deg: float = DELTA_DEG,
                      rmin: float = R_MIN, rmax: float = R_MAX) -> bool:
    """Conservative domain max_{g in F1} ||s-g|| <= rmin."""
    return _sector_max_distance_sq(s, rmax, delta_deg) <= rmin * rmin + 1e-7


def safe_angle_limit(baseline: float, domain: str = "uniform1000",
                     delta_deg: float = DELTA_DEG,
                     rmin: float = R_MIN, rmax: float = R_MAX) -> float | None:
    """Maximum |psi| in degrees on a fixed-baseline safe arc."""
    if not 0 < baseline <= rmin:
        return None
    if domain == "full_information":
        ratio = baseline / (2 * rmin)
    elif domain == "uniform1000":
        ratio = (baseline * baseline + rmax * rmax - rmin * rmin) / (2 * baseline * rmax)
    else:
        raise ValueError("unknown safety domain")
    if ratio > 1:
        return None
    return max(0.0, math.degrees(math.acos(max(-1.0, ratio))) - delta_deg)


def circle_outer_polygon(center: Point, radius: float, sides: int) -> list[Point]:
    """Regular circumscribed polygon whose sides are tangent to the disk."""
    if sides < 24:
        raise ValueError("circle approximation needs at least 24 sides")
    rv = radius / math.cos(math.pi / sides)
    return [add(center, (rv * math.cos((2 * k + 1) * math.pi / sides),
                         rv * math.sin((2 * k + 1) * math.pi / sides)))
            for k in range(sides)]


def clip_halfplane(poly: list[Point], normal: Point, offset: float) -> list[Point]:
    if not poly:
        return []
    out: list[Point] = []
    a = poly[-1]
    fa = dot(normal, a) - offset
    for b in poly:
        fb = dot(normal, b) - offset
        if (fa <= EPS) != (fb <= EPS):
            t = fa / (fa - fb)
            out.append(add(a, mul(sub(b, a), t)))
        if fb <= EPS:
            out.append(b)
        a, fa = b, fb
    clean: list[Point] = []
    for p in out:
        if not clean or dist(p, clean[-1]) > 1e-8:
            clean.append(p)
    if len(clean) > 1 and dist(clean[0], clean[-1]) <= 1e-8:
        clean.pop()
    return clean


def clip_disk_outer(poly: list[Point], center: Point, radius: float, sides: int) -> list[Point]:
    for k in range(sides):
        angle = 2 * math.pi * k / sides
        n = math.cos(angle), math.sin(angle)
        poly = clip_halfplane(poly, n, dot(n, center) + radius)
        if not poly:
            break
    return poly


def clip_wedge(poly: list[Point], station: Point, bearing_deg: float,
               delta_deg: float = DELTA_DEG) -> list[Point]:
    lo = math.radians(bearing_deg - delta_deg)
    hi = math.radians(bearing_deg + delta_deg)
    lower = math.cos(lo), math.sin(lo)
    upper = math.cos(hi), math.sin(hi)
    poly = clip_halfplane(poly, (lower[1], -lower[0]),
                          dot((lower[1], -lower[0]), station))
    return clip_halfplane(poly, (-upper[1], upper[0]),
                          dot((-upper[1], upper[0]), station))


def first_feasible_polygon(first: Point = (0.0, 0.0), bearing_deg: float = 0.0,
                           delta_deg: float = DELTA_DEG, sides: int = 180) -> list[Point]:
    """Outer approximation of F1 = Omega intersect B(S1,1500) intersect W1.

    The direction result also implies distance >5 m.  Omitting that tiny inner
    hole keeps the set convex and is conservative for worst-case uncertainty.
    """
    poly = circle_outer_polygon((0.0, 0.0), ARENA_R, sides)
    poly = clip_disk_outer(poly, first, R_MAX, sides)
    return clip_wedge(poly, first, bearing_deg, delta_deg)


def polygon_area(poly: Sequence[Point]) -> float:
    return abs(sum(cross(poly[i], poly[(i + 1) % len(poly)])
                   for i in range(len(poly)))) / 2 if len(poly) >= 3 else 0.0


def _diameter_circle(a: Point, b: Point) -> tuple[Point, float]:
    c = mul(add(a, b), 0.5)
    return c, dist(a, b) / 2


def _circumcircle(a: Point, b: Point, c: Point) -> tuple[Point, float] | None:
    u, v = sub(b, a), sub(c, a)
    den = 2 * cross(u, v)
    if abs(den) < 1e-14:
        return None
    uu, vv = dot(u, u), dot(v, v)
    center = add(a, ((v[1] * uu - u[1] * vv) / den,
                     (u[0] * vv - v[0] * uu) / den))
    return center, dist(center, a)


def minimum_enclosing_circle(points: Sequence[Point]) -> tuple[Point, float]:
    """Deterministic-seed incremental MEC with a final covering audit."""
    if not points:
        raise ValueError("empty point set")
    pts = list(points)
    random.Random(20260911).shuffle(pts)
    circle: tuple[Point, float] | None = None
    for i, p in enumerate(pts):
        if circle is not None and dist(circle[0], p) <= circle[1] + 1e-8:
            continue
        circle = p, 0.0
        for j, q in enumerate(pts[:i]):
            if dist(circle[0], q) <= circle[1] + 1e-8:
                continue
            circle = _diameter_circle(p, q)
            pq = sub(q, p)
            left = right = None
            for r in pts[:j]:
                if dist(circle[0], r) <= circle[1] + 1e-8:
                    continue
                cc = _circumcircle(p, q, r)
                if cc is None:
                    continue
                side = cross(pq, sub(r, p))
                signed = cross(pq, sub(cc[0], p))
                if side > 0 and (left is None or signed > left[0]):
                    left = signed, cc
                if side < 0 and (right is None or signed < right[0]):
                    right = signed, cc
            options = [item[1] for item in (left, right) if item is not None]
            if options:
                circle = min(options, key=lambda item: item[1])
    assert circle is not None
    return circle[0], max(dist(circle[0], p) for p in points) + 1e-7


@dataclass(frozen=True)
class Metrics:
    diameter_m: float
    mec_radius_m: float
    area_m2: float
    vertex_count: int


def _hull(points: Sequence[Point]) -> list[Point]:
    pts=sorted(set(points))
    if len(pts)<=2:return list(pts)
    def chain(seq):
        out=[]
        for p in seq:
            while len(out)>=2 and cross(sub(out[-1],out[-2]),sub(p,out[-1]))<=1e-10:out.pop()
            out.append(p)
        return out
    return chain(pts)[:-1]+chain(reversed(pts))[:-1]

def polygon_diameter(points: Sequence[Point]):
    pts=_hull(points);n=len(pts)
    if n==0:return 0.0,None
    if n==1:return 0.0,(pts[0],pts[0])
    if n==2:return dist(pts[0],pts[1]),(pts[0],pts[1])
    j=1;best=-1.0;pair=None
    for i in range(n):
        ni=(i+1)%n;edge=sub(pts[ni],pts[i])
        while cross(edge,sub(pts[(j+1)%n],pts[i]))>cross(edge,sub(pts[j],pts[i]))+1e-10:
            j=(j+1)%n
        for a in (i,ni):
            d=dist(pts[a],pts[j])
            if d>best:best=d;pair=(pts[a],pts[j])
    return best,pair

def polygon_metrics(poly: list[Point]) -> Metrics:
    diameter, _ = polygon_diameter(poly)
    _, radius = minimum_enclosing_circle(poly)
    return Metrics(float(diameter), radius, polygon_area(poly), len(poly))


def physical_base(first_poly: list[Point], second: Point, sides: int) -> list[Point]:
    return clip_disk_outer(list(first_poly), second, R_MAX, sides)


def post_region(base: list[Point], second: Point, reported_second_deg: float,
                delta_deg: float = DELTA_DEG) -> list[Point]:
    return clip_wedge(list(base), second, reported_second_deg, delta_deg)


@dataclass
class RobustQuality:
    worst_R_m: float
    worst_D_m: float
    worst_A_m2: float
    report_at_worst_R_deg: float
    report_at_worst_D_deg: float
    report_at_worst_A_deg: float
    metrics_at_worst_R: Metrics
    feasible_report_count: int
    report_evaluations: int
    disk_sides: int
    report_step_deg: float

    def as_dict(self) -> dict:
        out = asdict(self)
        out["continuous_report_maximum_certified"] = False
        return out


def robust_quality(second: Point, *, first: Point = (0.0, 0.0),
                   first_bearing_deg: float = 0.0, delta_deg: float = DELTA_DEG,
                   disk_sides: int = 120, report_step_deg: float = 0.5,
                   refine_step_deg: float = 0.05) -> RobustQuality:
    """Numerically approximate worst D/R/A over feasible second reports.

    A report z is feasible exactly when P2(z) is nonempty: any point in P2 has
    a true bearing within delta of z, so a compatible source/error pair exists.
    Thus this report-domain maximization avoids combining an impossible source
    location with an unrelated second reading.
    """
    first_poly = first_feasible_polygon(first, first_bearing_deg, delta_deg, disk_sides)
    base = physical_base(first_poly, second, disk_sides)
    cache: dict[float, tuple[Metrics, list[Point]]] = {}

    def evaluate(z: float) -> tuple[Metrics, list[Point]] | None:
        key = round(z % 360.0, 10)
        if key in cache:
            return cache[key]
        poly = post_region(base, second, key, delta_deg)
        if not poly:
            return None
        result = polygon_metrics(poly), poly
        cache[key] = result
        return result

    records: list[tuple[float, Metrics]] = []
    count = max(1, int(math.ceil(360.0 / report_step_deg)))
    coarse: list[tuple[float, Metrics] | None] = []
    for i in range(count):
        z = i * 360.0 / count
        value = evaluate(z)
        if value is not None:
            row = (z, value[0])
            records.append(row)
            coarse.append(row)
        else:
            coarse.append(None)
    if not records:
        raise RuntimeError("no feasible second report")

    # Refine competitive coarse local maxima by bounded scalar searches.  The
    # finite search is reproducible and convergence-checkable, but is not a
    # formal interval certificate for the continuous report domain.
    golden = (math.sqrt(5.0) - 1.0) / 2.0
    for field in ("mec_radius_m", "diameter_m", "area_m2"):
        candidates: list[tuple[float, int]] = []
        for i, row in enumerate(coarse):
            if row is None:
                continue
            value = getattr(row[1], field)
            before = coarse[(i - 1) % count]
            after = coarse[(i + 1) % count]
            vb = getattr(before[1], field) if before is not None else -math.inf
            va = getattr(after[1], field) if after is not None else -math.inf
            if value >= vb and value >= va:
                candidates.append((value, i))
        if not candidates:
            candidates = [(getattr(max(records, key=lambda row: getattr(row[1], field))[1], field),
                           int(round(max(records, key=lambda row: getattr(row[1], field))[0]
                                     / (360.0 / count))) % count)]
        for _, i in sorted(candidates, reverse=True)[:8]:
            center = i * 360.0 / count
            left, right = center - 360.0 / count, center + 360.0 / count

            def field_value(z: float) -> float:
                item = evaluate(z)
                return getattr(item[0], field) if item is not None else -math.inf

            c = right - golden * (right - left)
            d = left + golden * (right - left)
            fc, fd = field_value(c), field_value(d)
            for _ in range(34):
                if fc >= fd:
                    right, d, fd = d, c, fc
                    c = right - golden * (right - left)
                    fc = field_value(c)
                else:
                    left, c, fc = c, d, fd
                    d = left + golden * (right - left)
                    fd = field_value(d)
            for z in (left, c, (left + right) / 2, d, right):
                value = evaluate(z)
                if value is not None:
                    records.append((z % 360.0, value[0]))

    row_R = max(records, key=lambda row: row[1].mec_radius_m)
    row_D = max(records, key=lambda row: row[1].diameter_m)
    row_A = max(records, key=lambda row: row[1].area_m2)
    return RobustQuality(row_R[1].mec_radius_m, row_D[1].diameter_m,
                         row_A[1].area_m2, row_R[0] % 360.0,
                         row_D[0] % 360.0, row_A[0] % 360.0,
                         row_R[1], len(records), len(cache), disk_sides,
                         report_step_deg)


def candidate(baseline: float, psi_deg: float, side: int = 1) -> Point:
    psi = math.radians(psi_deg)
    return baseline * math.cos(psi), side * baseline * math.sin(psi)


def optimize_fixed_baseline(metric: str, baseline: float, *,
                            first: Point=(0.0,0.0), first_bearing_deg: float=0.0,
                            domain: str = "uniform1000",
                            delta_deg: float = DELTA_DEG,
                            coarse_psi_deg: float = 1.0,
                            fine_psi_deg: float = 0.1,
                            disk_sides: int = 96,
                            report_step_deg: float = 1.0) -> dict:
    if metric not in {"R", "D", "A"}:
        raise ValueError("metric must be R, D, or A")
    limit = safe_angle_limit(baseline, domain, delta_deg)
    if limit is None or limit <= 0:
        raise ValueError("fixed baseline has no noncollinear safe candidate")
    safety = safe_uniform_1000 if domain == "uniform1000" else safe_full_information
    values: list[tuple[float, float, RobustQuality]] = []

    def score(q: RobustQuality) -> float:
        return {"R": q.worst_R_m, "D": q.worst_D_m, "A": q.worst_A_m2}[metric]

    # Search both sides of the first bearing.  They are equivalent only in the
    # centred, untruncated standard geometry; the arena boundary generally
    # breaks that symmetry for an arbitrary first station.
    for side in (-1.0,1.0):
        side_values: list[tuple[float,float,RobustQuality]]=[]
        magnitude=max(0.2,coarse_psi_deg)
        while magnitude<=limit+1e-12:
            psi=side*magnitude;local_point=candidate(baseline,psi)
            if safety(local_point,delta_deg):
                point=local_to_world(first,first_bearing_deg,local_point[0],local_point[1])
                q=robust_quality(point,first=first,first_bearing_deg=first_bearing_deg,delta_deg=delta_deg,disk_sides=disk_sides,
                                 report_step_deg=report_step_deg,
                                 refine_step_deg=report_step_deg/5)
                row=(score(q),psi,q);values.append(row);side_values.append(row)
            magnitude+=coarse_psi_deg
        if not side_values:continue
        _,side_best_psi,_=min(side_values,key=lambda row:row[0])
        lo=max(-limit,side_best_psi-coarse_psi_deg);hi=min(limit,side_best_psi+coarse_psi_deg)
        if side<0:hi=min(hi,-0.05)
        else:lo=max(lo,0.05)
        psi=lo
        while psi<=hi+1e-12:
            local_point=candidate(baseline,psi)
            if safety(local_point,delta_deg):
                point=local_to_world(first,first_bearing_deg,local_point[0],local_point[1])
                q=robust_quality(point,first=first,first_bearing_deg=first_bearing_deg,delta_deg=delta_deg,disk_sides=disk_sides,
                                 report_step_deg=report_step_deg,
                                 refine_step_deg=report_step_deg/5)
                values.append((score(q),psi,q))
            psi+=fine_psi_deg
    if not values:
        raise ValueError("no evaluated safe candidate")
    best_score, best_psi, best_q = min(values, key=lambda row: row[0])
    local_point = candidate(baseline, best_psi)
    point = local_to_world(first, first_bearing_deg, local_point[0], local_point[1])
    return {"objective": metric, "safety_domain": domain,
            "baseline_m": baseline, "psi_deg": best_psi,
            "a_m": local_point[0], "b_m": local_point[1], "second_station_m": [point[0],point[1]], "objective_value": best_score,
            "safe_angle_limit_deg": limit, "quality_search": best_q.as_dict(),
            "candidate_evaluations": len(values),
            "continuous_global_optimum_claimed": False,
            "search_method": "two-sided fixed-baseline one-dimensional coarse-to-fine search",
            "numerical_scope": "finite angular sampling with local refinement; no continuous global optimum certificate"}


def final_quality(second: Point, *, first: Point=(0.0,0.0), first_bearing_deg: float=0.0, disk_sides: int = 360,
                  report_step_deg: float = 0.1) -> dict:
    q = robust_quality(second, first=first, first_bearing_deg=first_bearing_deg, disk_sides=disk_sides,
                       report_step_deg=report_step_deg,
                       refine_step_deg=report_step_deg / 5)
    return q.as_dict()



def solve_case(payload: dict, quick: bool=False) -> dict:
    first_raw=payload.get("first_station_m",[0.0,0.0])
    first=(float(first_raw[0]),float(first_raw[1]))
    bearing=float(payload["first_bearing_deg"])%360.0
    baselines=[float(x) for x in payload.get("baselines_m",[600,700,800,900,1000])]
    search_sides=72 if quick else 96
    report_step=2.0 if quick else 1.0
    coarse=2.0 if quick else 1.0
    fine=0.25 if quick else 0.1
    all_rows=[]
    for metric in ("D","R"):
        for L in baselines:
            try:
                row=optimize_fixed_baseline(metric,L,first=first,first_bearing_deg=bearing,
                    coarse_psi_deg=coarse,fine_psi_deg=fine,disk_sides=search_sides,
                    report_step_deg=report_step)
            except ValueError:
                continue
            all_rows.append(row)
    if not all_rows:raise RuntimeError("没有可用的安全第二检测点")
    best_D=min((r for r in all_rows if r["objective"]=="D"),key=lambda r:r["objective_value"])
    best_R=min((r for r in all_rows if r["objective"]=="R"),key=lambda r:r["objective_value"])
    final_sides=180 if quick else 360
    final_report=.5 if quick else .2
    comparison=[]
    for label,row in (("Q1直径方法",best_D),("Q2最小包围圆方法",best_R)):
        p=tuple(row["second_station_m"])
        q=final_quality(p,first=first,first_bearing_deg=bearing,disk_sides=final_sides,report_step_deg=final_report)
        comparison.append({"method":label,"baseline_m":row["baseline_m"],"psi_deg":row["psi_deg"],
            "a_m":row["a_m"],"b_m":row["b_m"],"second_station_m":row["second_station_m"],
            "worst_R_m":q["worst_R_m"],"worst_D_m":q["worst_D_m"],"worst_A_m2":q["worst_A_m2"],
            "report_at_worst_R_deg":q["report_at_worst_R_deg"],
            "meets_20m_on_evaluated_reports":q["worst_R_m"]<=20.0})
    return {"case_id":payload.get("case_id","Q2"),"first_station_m":list(first),"first_bearing_deg":bearing,
        "error_half_width_deg":DELTA_DEG,"safety_domain":"uniform1000",
        "main_method":"Q2最小包围圆方法","comparison":comparison,
        "baseline_search":[{"objective":r["objective"],"baseline_m":r["baseline_m"],"psi_deg":r["psi_deg"],
            "objective_value":r["objective_value"]} for r in all_rows],
        "note":"Q1对照会独立按最坏直径重新选点；内层连续示向度最坏值由有限网格和局部细化数值近似。"}

def main(argv=None):
    ap=argparse.ArgumentParser(description="问题二：安全第二检测点与Q1直径方法对比")
    ap.add_argument("--input",type=Path,default=Path("q2_input.json"))
    ap.add_argument("--output",type=Path,default=Path("q2_result.json"))
    ap.add_argument("--quick",action="store_true",help="缩短本地试跑时间")
    args=ap.parse_args(argv)
    payload=json.loads(args.input.read_text(encoding="utf-8"))
    result=solve_case(payload,args.quick)
    args.output.parent.mkdir(parents=True,exist_ok=True)
    args.output.write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding="utf-8")
    print("========== 问题二结果 ==========")
    for row in result["comparison"]:
        print(f"{row['method']}：L={row['baseline_m']:.1f} m，ψ={row['psi_deg']:.2f}°，最坏R={row['worst_R_m']:.3f} m，最坏D={row['worst_D_m']:.3f} m，面积={row['worst_A_m2']:.3f} m²")
        print(f"  第二检测点：({row['second_station_m'][0]:.3f}, {row['second_station_m'][1]:.3f})")
    print(f"结果已保存：{args.output}")
    return 0

if __name__=="__main__":raise SystemExit(main())
