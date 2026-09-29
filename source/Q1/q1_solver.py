#!/usr/bin/env python3
"""问题一：有界误差 AOA 半平面交与凸多边形直径；只求解，不绘图。"""
from __future__ import annotations

import argparse
from collections import deque
from dataclasses import dataclass
import json
import math
from pathlib import Path
from typing import Iterable

Point = tuple[float, float]
EPS = 1.0e-10
PARALLEL_EPS = 1.0e-12
NUMERICAL_ANGLE_GUARD_DEG = 0.0


@dataclass(frozen=True)
class HalfPlane:
    """闭半平面 ``normal · X <= offset``。"""

    normal: Point
    offset: float

    def residual(self, point: Point) -> float:
        return self.normal[0] * point[0] + self.normal[1] * point[1] - self.offset


def _cross(a: Point, b: Point) -> float:
    return a[0] * b[1] - a[1] * b[0]


def _sub(a: Point, b: Point) -> Point:
    return a[0] - b[0], a[1] - b[1]


def _distance2(a: Point, b: Point) -> float:
    dx, dy = a[0] - b[0], a[1] - b[1]
    return dx * dx + dy * dy


def _normalise(raw) -> HalfPlane:
    if isinstance(raw, HalfPlane):
        a, b = raw.normal
        c = raw.offset
    elif len(raw) == 2:
        (a, b), c = raw
    elif len(raw) == 3:
        a, b, c = raw
    else:
        raise ValueError("半平面应写为 HalfPlane、((a,b),c) 或 (a,b,c)")
    a, b, c = float(a), float(b), float(c)
    if not all(math.isfinite(v) for v in (a, b, c)):
        raise ValueError("半平面系数必须为有限数")
    length = math.hypot(a, b)
    if length == 0.0:
        raise ValueError("半平面法向量不能为零")
    return HalfPlane((a / length, b / length), c / length)


def _direction(hp: HalfPlane) -> Point:
    # 沿该方向前进时，可行域位于有向边界左侧。
    a, b = hp.normal
    return -b, a


def _same_direction(a: HalfPlane, b: HalfPlane) -> bool:
    da, db = _direction(a), _direction(b)
    return abs(_cross(da, db)) <= PARALLEL_EPS and da[0] * db[0] + da[1] * db[1] > 0


def _ordered(halfplanes: Iterable[HalfPlane]) -> list[HalfPlane]:
    planes = [_normalise(hp) for hp in halfplanes]
    planes.sort(key=lambda hp: math.atan2(_direction(hp)[1], _direction(hp)[0]) % math.tau)
    merged: list[HalfPlane] = []
    for hp in planes:
        if merged and _same_direction(merged[-1], hp):
            if hp.offset < merged[-1].offset:
                merged[-1] = hp
        else:
            merged.append(hp)
    if len(merged) > 1 and _same_direction(merged[0], merged[-1]):
        if merged[-1].offset < merged[0].offset:
            merged[0] = merged[-1]
        merged.pop()
    return merged


def _intersection(a: HalfPlane, b: HalfPlane) -> Point | None:
    ax, ay = a.normal
    bx, by = b.normal
    determinant = ax * by - ay * bx
    if abs(determinant) <= PARALLEL_EPS:
        return None
    return ((a.offset * by - ay * b.offset) / determinant,
            (ax * b.offset - a.offset * bx) / determinant)


def _outside(hp: HalfPlane, point: Point) -> bool:
    scale = max(1.0, abs(hp.offset), abs(point[0]), abs(point[1]))
    return hp.residual(point) > EPS * scale


def _cuts(hp: HalfPlane, a: HalfPlane, b: HalfPlane) -> bool:
    point = _intersection(a, b)
    return point is not None and _outside(hp, point)


def _feasible_point(planes: list[HalfPlane]) -> Point | None:
    """二维线性约束可行性；只用于区分空集与无界集。"""
    point = (0.0, 0.0)
    for i, hp in enumerate(planes):
        if not _outside(hp, point):
            continue
        nx, ny = hp.normal
        base, tangent = (nx * hp.offset, ny * hp.offset), (-ny, nx)
        lower, upper = -math.inf, math.inf
        for previous in planes[:i]:
            coefficient = previous.normal[0] * tangent[0] + previous.normal[1] * tangent[1]
            bound = previous.offset - (previous.normal[0] * base[0] + previous.normal[1] * base[1])
            if coefficient > PARALLEL_EPS:
                upper = min(upper, bound / coefficient)
            elif coefficient < -PARALLEL_EPS:
                lower = max(lower, bound / coefficient)
            elif bound < -EPS * max(1.0, abs(previous.offset)):
                return None
        if lower > upper + EPS * max(1.0, abs(lower), abs(upper)):
            return None
        parameter = min(max(0.0, lower), upper)
        point = (base[0] + parameter * tangent[0], base[1] + parameter * tangent[1])
    return point


def _is_bounded(planes: list[HalfPlane]) -> bool:
    if len(planes) < 3:
        return False
    angles = sorted(math.atan2(hp.normal[1], hp.normal[0]) % math.tau for hp in planes)
    gaps = [angles[i + 1] - angles[i] for i in range(len(angles) - 1)]
    gaps.append(angles[0] + math.tau - angles[-1])
    return max(gaps) < math.pi - PARALLEL_EPS


def _convex_hull(points: Iterable[Point]) -> list[Point]:
    rows = sorted(set((float(x), float(y)) for x, y in points))
    if len(rows) <= 1:
        return rows

    def chain(sequence):
        result: list[Point] = []
        for point in sequence:
            while len(result) >= 2 and _cross(_sub(result[-1], result[-2]), _sub(point, result[-1])) <= EPS:
                result.pop()
            result.append(point)
        return result

    return chain(rows)[:-1] + chain(reversed(rows))[:-1]


def polygon_diameter(vertices: Iterable[Point]):
    """用旋转卡壳返回 ``(直径, 最远点对)``。"""
    points = _convex_hull(vertices)
    count = len(points)
    if count == 0:
        return None, None
    if count == 1:
        return 0.0, (points[0], points[0])
    if count == 2:
        return math.dist(*points), (points[0], points[1])
    best2, best_pair, j = 0.0, (points[0], points[0]), 1
    for i in range(count):
        following = (i + 1) % count
        edge = _sub(points[following], points[i])
        while (_cross(edge, _sub(points[(j + 1) % count], points[i]))
               > _cross(edge, _sub(points[j], points[i])) + EPS):
            j = (j + 1) % count
        for first in (i, following):
            candidate = _distance2(points[first], points[j])
            if candidate > best2:
                best2, best_pair = candidate, (points[first], points[j])
    return math.sqrt(best2), best_pair


def _finite_result(vertices: list[Point]) -> dict:
    vertices = _convex_hull(vertices)
    if len(vertices) == 2 and _distance2(vertices[0], vertices[1]) <= EPS * EPS:
        vertices = vertices[:1]
    status = "point" if len(vertices) == 1 else "segment" if len(vertices) == 2 else "polygon"
    diameter, pair = polygon_diameter(vertices)
    area = abs(sum(_cross(vertices[i], vertices[(i + 1) % len(vertices)])
                   for i in range(len(vertices)))) / 2.0
    midpoint = ((pair[0][0] + pair[1][0]) / 2.0, (pair[0][1] + pair[1][1]) / 2.0)
    radius = diameter / 2.0
    farthest = max(math.dist(midpoint, point) for point in vertices)
    return {"status": status, "vertices_m": [list(p) for p in vertices],
            "diameter_m": diameter, "diameter_pair_m": [list(p) for p in pair],
            "area_m2": area, "diameter_circle_covers": farthest <= radius + EPS,
            "diameter_circle_cover_margin_m": radius - farthest}


def intersect_halfplanes(halfplanes: Iterable[HalfPlane], *, include_circle=True) -> dict:
    """用按方向排序的双端队列计算半平面交。"""
    del include_circle  # 仅保留该参数以兼容第二问的调用接口。
    planes = _ordered(halfplanes)
    active: deque[HalfPlane] = deque()
    for hp in planes:
        while len(active) >= 2 and _cuts(hp, active[-2], active[-1]):
            active.pop()
        while len(active) >= 2 and _cuts(hp, active[0], active[1]):
            active.popleft()
        active.append(hp)
    while len(active) >= 3 and _cuts(active[0], active[-2], active[-1]):
        active.pop()
    while len(active) >= 3 and _cuts(active[-1], active[0], active[1]):
        active.popleft()

    ring = list(active)
    vertices = [_intersection(ring[i], ring[(i + 1) % len(ring)]) for i in range(len(ring))]
    if ring and all(point is not None for point in vertices):
        polygon = _convex_hull(vertices)
        # A bounded intersection may legitimately degenerate to one point or a
        # line segment.  Accept those only when the recession cone is bounded;
        # otherwise two adjacent half-planes could be mistaken for a point.
        finite_shape = len(polygon) >= 3 or (polygon and _is_bounded(planes))
        if finite_shape and all(not _outside(hp, point) for hp in planes for point in polygon):
            return _finite_result(polygon)

    witness = _feasible_point(planes)
    if witness is None:
        return {"status": "empty", "vertices_m": [], "diameter_m": None,
                "diameter_pair_m": None, "area_m2": None}
    if not _is_bounded(planes):
        return {"status": "unbounded", "vertices_m": [], "diameter_m": None,
                "diameter_pair_m": None, "area_m2": None,
                "feasible_point_m": list(witness)}
    return {"status": "uncertain", "vertices_m": [], "diameter_m": None,
            "diameter_pair_m": None, "area_m2": None}


def _observation(row) -> tuple[float, float, float]:
    if isinstance(row, dict):
        position = row.get("position_m", row.get("position"))
        if isinstance(position, dict):
            position = (position["x"], position["y"])
        bearing = row.get("bearing_deg", row.get("svd_deg"))
        x, y = position
    else:
        if len(row) != 3:
            raise ValueError("每条观测必须包含 x、y 和示向度")
        x, y, bearing = row
    x, y, bearing = float(x), float(y), float(bearing)
    if not all(math.isfinite(v) for v in (x, y, bearing)):
        raise ValueError("观测数据必须为有限数")
    return x, y, bearing % 360.0


def _wedge(position: Point, bearing_deg: float, epsilon_deg: float) -> list[HalfPlane]:
    x, y = position
    lower, upper = map(math.radians, (bearing_deg - epsilon_deg, bearing_deg + epsilon_deg))
    normals = [(math.sin(lower), -math.cos(lower)),
               (-math.sin(upper), math.cos(upper))]
    if epsilon_deg == 0.0:
        angle = math.radians(bearing_deg)
        normals.append((-math.cos(angle), -math.sin(angle)))
    return [HalfPlane(normal, normal[0] * x + normal[1] * y) for normal in normals]


def solve_localization(observations, epsilon_deg=1.0, *, include_circle=True) -> dict:
    epsilon_deg = float(epsilon_deg)
    if not 0.0 <= epsilon_deg < 90.0:
        raise ValueError("epsilon_deg 必须位于 [0,90) 内")
    rows = [_observation(row) for row in observations]
    if not rows:
        raise ValueError("至少需要一条观测")
    planes = [hp for x, y, angle in rows for hp in _wedge((x, y), angle, epsilon_deg)]
    result = intersect_halfplanes(planes, include_circle=include_circle)
    result.update(observations=[{"position_m": [x, y], "bearing_deg": angle}
                                for x, y, angle in rows],
                  error_half_width_deg=epsilon_deg)
    return result


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", type=Path, required=True, help="观测 JSON 文件")
    parser.add_argument("--output", type=Path, default=Path("q1_result.json"))
    args = parser.parse_args(argv)
    payload = json.loads(args.input.read_text(encoding="utf-8"))
    result = solve_localization(payload["observations"], payload.get("epsilon_deg", 1.0))
    result["case_id"] = payload.get("case_id", args.input.stem)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"状态: {result['status']}")
    print(f"顶点数: {len(result['vertices_m'])}")
    print(f"面积: {result['area_m2']:.3f} m²" if result["area_m2"] is not None else "面积: 无有限值")
    print(f"直径: {result['diameter_m']:.3f} m" if result["diameter_m"] is not None else "直径: 无有限值")
    print(f"结果已写入: {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
