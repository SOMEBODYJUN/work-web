"""Conservative 2D geometry. Standard library only; meters/radians internally."""
from __future__ import annotations
import math
import random
from typing import Iterable

Point = tuple[float, float]
TAU = 2.0 * math.pi
EPS = 1e-7
DELTA = math.radians(1.0051)  # 1° physical bound + 0.005° output rounding + 0.0001° guard

def add(a: Point, b: Point) -> Point: return (a[0]+b[0], a[1]+b[1])
def sub(a: Point, b: Point) -> Point: return (a[0]-b[0], a[1]-b[1])
def mul(a: Point, s: float) -> Point: return (a[0]*s, a[1]*s)
def dot(a: Point, b: Point) -> float: return a[0]*b[0]+a[1]*b[1]
def cross(a: Point, b: Point) -> float: return a[0]*b[1]-a[1]*b[0]
def norm(a: Point) -> float: return math.hypot(*a)
def dist(a: Point, b: Point) -> float: return math.hypot(a[0]-b[0], a[1]-b[1])
def unit(a: Point) -> Point:
    n=norm(a)
    return (a[0]/n,a[1]/n) if n>EPS else (1.0,0.0)
def maxdist(p: Point, poly: list[Point]) -> float:
    return max((dist(p,v) for v in poly), default=0.0)

def hull(points: Iterable[Point]) -> list[Point]:
    pts=sorted(set(points))
    if len(pts)<=2: return pts
    lo=[]; hi=[]
    for p in pts:
        while len(lo)>=2 and cross(sub(lo[-1],lo[-2]),sub(p,lo[-1]))<=0: lo.pop()
        lo.append(p)
    for p in reversed(pts):
        while len(hi)>=2 and cross(sub(hi[-1],hi[-2]),sub(p,hi[-1]))<=0: hi.pop()
        hi.append(p)
    return lo[:-1]+hi[:-1]

def clip(poly: list[Point], n: Point, b: float) -> list[Point]:
    """Intersect polygon with n.x <= b. Expand by EPS in physical units."""
    if not poly: return []
    b+=EPS*max(1.0,norm(n))
    out=[]
    a=poly[-1]; fa=dot(n,a)-b
    for c in poly:
        fc=dot(n,c)-b
        if (fa<=0)!=(fc<=0):
            t=fa/(fa-fc)
            out.append(add(a,mul(sub(c,a),t)))
        if fc<=0: out.append(c)
        a,fa=c,fc
    if len(out)>1:
        clean=[out[0]]
        for p in out[1:]:
            if dist(p,clean[-1])>1e-9: clean.append(p)
        if len(clean)>1 and dist(clean[0],clean[-1])<1e-9: clean.pop()
        out=clean
    return out

def arena_polygon(sides: int=48) -> list[Point]:
    # CIRCUMscribed regular polygon: never use an inscribed polygon here.
    r=1800.0/math.cos(math.pi/sides)
    return [(r*math.cos(TAU*k/sides+math.pi/sides),r*math.sin(TAU*k/sides+math.pi/sides)) for k in range(sides)]

def bearing_update(poly: list[Point], p: Point, theta_deg: float) -> list[Point]:
    """Outer approximation of P intersect bearing sector intersect B(p,1500).
    Three supporting halfplanes bound the sector by a triangle. R may be
    tightened by the CURRENT polygon, so the contraction proof still applies.
    """
    R=min(1500.0,maxdist(p,poly)+EPS)
    a=math.radians(theta_deg)
    lower=(math.cos(a-DELTA),math.sin(a-DELTA))
    upper=(math.cos(a+DELTA),math.sin(a+DELTA))
    # cross(lower,x-p)>=0; cross(upper,x-p)<=0
    for n in ((lower[1],-lower[0]),(-upper[1],upper[0])):
        poly=clip(poly,n,dot(n,p))
    u=(math.cos(a),math.sin(a))
    return clip(poly,u,dot(u,p)+R)

def exclude_disk_hull(poly: list[Point], c: Point, radius: float) -> list[Point]:
    """conv(P minus open disk), a SAFE convex outer relaxation.
    Its extreme points are surviving polygon vertices and edge/circle crossings.
    Radius is slightly reduced for conservative floating-point behavior.
    """
    if not poly: return []
    r=max(0.0,radius-1e-5); r2=r*r
    candidates=[p for p in poly if dist(p,c)>=r-1e-6]
    for k,a in enumerate(poly):
        b=poly[(k+1)%len(poly)]; d=sub(b,a); f=sub(a,c)
        A=dot(d,d)
        if A<1e-20: continue
        B=2*dot(f,d); C=dot(f,f)-r2
        disc=B*B-4*A*C
        if disc<0: continue
        root=math.sqrt(max(0.0,disc))
        for t in ((-B-root)/(2*A),(-B+root)/(2*A)):
            if -1e-9<=t<=1+1e-9:
                t=max(0.,min(1.,t))
                candidates.append(add(a,mul(d,t)))
    return hull(candidates)

def inside_polygon(p: Point, poly: list[Point], tol: float=1e-4) -> bool:
    if not poly: return False
    if len(poly)==1: return dist(p,poly[0])<=tol
    if len(poly)==2:
        a,b=poly; d=sub(b,a)
        t=dot(sub(p,a),d)/max(dot(d,d),1e-30)
        return -tol<=t<=1+tol and abs(cross(d,sub(p,a)))<=tol*max(1,norm(d))
    return all(cross(sub(poly[(k+1)%len(poly)],v),sub(p,v))>=-tol*max(1,dist(v,poly[(k+1)%len(poly)])) for k,v in enumerate(poly))

def _diameter(a,b):
    c=mul(add(a,b),0.5); return (c,dist(a,b)*0.5)
def _circum(a,b,c):
    # Translate to reduce cancellation.
    u=sub(b,a); v=sub(c,a); D=2*cross(u,v)
    if abs(D)<1e-18: return None
    uu=dot(u,u); vv=dot(v,v)
    o=add(a,((v[1]*uu-u[1]*vv)/D,(u[0]*vv-v[0]*uu)/D))
    return (o,dist(o,a))
def _in(circle,p): return dist(circle[0],p)<=circle[1]+1e-9

def mec(points: list[Point]) -> tuple[Point,float]:
    """Randomized incremental smallest enclosing circle + full radius audit.
    Randomness is fixed per call and has no influence on the strategy's safety.
    """
    if not points: raise ValueError('empty feasible outer set')
    pts=list(points); random.Random(271828).shuffle(pts)
    circle=None
    for i,p in enumerate(pts):
        if circle is not None and _in(circle,p): continue
        circle=(p,0.0)
        for j,q in enumerate(pts[:i]):
            if _in(circle,q): continue
            circle=_diameter(p,q)
            # Two forced boundary points; choose the extremal circle on each side.
            pq=sub(q,p); left=None; right=None
            for r in pts[:j]:
                if _in(circle,r): continue
                side=cross(pq,sub(r,p)); cc=_circum(p,q,r)
                if cc is None: continue
                v=cross(pq,sub(cc[0],p))
                if side>0 and (left is None or v>left[0]): left=(v,cc)
                if side<0 and (right is None or v<right[0]): right=(v,cc)
            options=[z[1] for z in (left,right) if z is not None]
            if options: circle=min(options,key=lambda z:z[1])
    c=circle[0]
    # This audited radius is always used for certification, not an internal radius.
    return c,maxdist(c,points)+1e-6

def nearest_certified_clear(p: Point, c: Point, r: float, clear_r: float=19.8) -> Point:
    """Nearest point in B(c,clear_r-r), a certified subset of valid clear sites."""
    slack=clear_r-r
    if slack<0: raise ValueError('not certified clearable')
    d=dist(p,c)
    if d<=slack: return p
    return add(c,mul(sub(p,c),slack/d))

def arc_covered_by_disk(c: Point, R: float, s: Point, r: float) -> list[tuple[float,float]]:
    d=dist(c,s)
    if d<1e-10: return [(0.,TAU)] if r>=R else []
    if d+R<=r: return [(0.,TAU)]
    if d>=R+r or R>=d+r: return []
    a=math.atan2(s[1]-c[1],s[0]-c[0])%TAU
    h=math.acos(max(-1.,min(1.,(d*d+R*R-r*r)/(2*d*R))))
    l=a-h; u=a+h
    if l<0: return [(0.,u),(l+TAU,TAU)]
    if u>TAU: return [(l,TAU),(0.,u-TAU)]
    return [(l,u)]

def merge_intervals(intervals):
    out=[]
    for l,u in sorted(intervals):
        if not out or l>out[-1][1]+1e-12: out.append([l,u])
        else: out[-1][1]=max(out[-1][1],u)
    return out

def interval_subset(targets, cover) -> bool:
    cov=merge_intervals(cover)
    for a,b in targets:
        x=a
        for l,u in cov:
            if u<x: continue
            if l>x+1e-10: break
            x=max(x,u)
            if x>=b-1e-10: break
        if x<b-1e-10: return False
    return True

def covers_arena(sites: list[Point], radius: float=999.0) -> bool:
    """Continuous disk-union coverage certificate, not a grid test.
    Check arena boundary AND every exposed sensor-circle arc inside the arena.
    Deduplicate equal circles first. A 1m radius guard handles roundoff.
    """
    pts=[]
    for p in sites:
        if all(dist(p,q)>1e-5 for q in pts): pts.append(p)
    boundary=[]
    for p in pts: boundary+=arc_covered_by_disk((0.,0.),1800.,p,radius)
    if not interval_subset([(0.,TAU)],boundary): return False
    for i,p in enumerate(pts):
        interior=arc_covered_by_disk(p,radius,(0.,0.),1800.)
        if not interior: continue
        others=[]
        for j,q in enumerate(pts):
            if i!=j: others+=arc_covered_by_disk(p,radius,q,radius)
        if not interval_subset(interior,others): return False
    return True

def ring_sites(m: int=7, phi: float=0., clockwise: bool=False) -> list[Point]:
    """Origin plus m outer sites; derive m>=6 using R=1800, r=995."""
    if m<6: raise ValueError('m must be at least 6')
    a=1800*math.cos(math.pi/m)-math.sqrt(995.**2-(1800*math.sin(math.pi/m))**2)+1.
    sign=-1 if clockwise else 1
    return [(a*math.cos(phi+sign*TAU*k/m),a*math.sin(phi+sign*TAU*k/m)) for k in range(m)]


"""Q3 online strategy. Consumes only public action responses, never source truth.

Self-contained geometry is implemented in geometry.py; no Q1 reference solver
or historical result file is imported or loaded by the online strategy.
"""
from dataclasses import dataclass, field
import math
from typing import Callable, Protocol

class Actions(Protocol):
    def measure(self, position: Point, channel: int) -> dict: ...
    def clear(self, position: Point, channel: int) -> dict: ...

@dataclass(frozen=True)
class Config:
    """Frozen mainline defaults, with explicit local-comparison options below.

    The submitted entry uses Config() unchanged.  Sequential and deferred are
    retained only as transparent local comparison modes; no 2-opt is claimed.
    The physical angle error is 1°; DELTA adds a conservative output/numeric guard.
    """
    # Mainline: origin + eight ring sites, MEC certification, small lateral
    # moves, shared observations, and insertion into the remaining search route.
    ring_m: int=8
    offset: float=0.10
    insert_m: float=600.0
    negative: bool=True
    opportunistic: bool=True
    opportunistic_clear: bool=True
    mode: str='integrated'  # Optional local comparisons: sequential, deferred.

    # LOCAL RESEARCH ONLY, disabled in the frozen policy. Keep field names flat
    # for dataclasses.replace/asdict and benchmark compatibility. scan_* matters
    # only when incidental is True; speculative_r=0 means no speculative clear.
    incidental: bool=False
    scan_spacing: float=500.0
    scan_policy: str='distance'
    prune: bool=False
    rotate: bool=False
    speculative_r: float=0.0

@dataclass
class Track:
    status: str='UNKNOWN'
    poly: list[Point]=field(default_factory=arena_polygon)
    negatives: list[tuple[Point,float]]=field(default_factory=list)
    center: Point=(0.,0.)
    radius: float=math.inf
    last: Point|None=None
    bearing: float=0.0
    measurements: int=0

class Strategy:
    def __init__(self, api: Actions, config: Config=Config(), audit: Callable|None=None):
        self.api=api; self.cfg=config; self.audit=audit
        self.tracks={i:Track() for i in range(1,21)}
        self.p=(0.,0.); self.channel=1; self.virtual_time=0.
        self.scans=[]; self.pending=[]; self.coverage_done=False; self.search_reason=None
        self.cleared=0; self.actions=0; self.certificate_checks=0
        self.max_vertices=0; self.max_local_steps=0
        self._plan_ready=False

    def _audit(self, i):
        t=self.tracks[i]; self.max_vertices=max(self.max_vertices,len(t.poly))
        if self.audit is not None: self.audit(i,t,self.p)

    def _observe(self, i: int, p: Point) -> str:
        response=self.api.measure(p,i)
        if not response.get('accepted'): raise RuntimeError('measure rejected')
        self.p=p; self.channel=i; self.actions+=1
        self.virtual_time=float(response['virtual_time_s'])
        t=self.tracks[i]; result=response['measure_result']
        if result=='no_signal':
            t.negatives.append((p,1000.))
            if t.status=='FOUND' and self.cfg.negative:
                t.poly=exclude_disk_hull(t.poly,p,1000.)
                if not t.poly: raise RuntimeError('inconsistent no_signal; Q3 assumptions violated')
                t.center,t.radius=mec(t.poly)
                self._audit(i)
        elif result=='near':
            self._clear(i,p,certified=True)
        elif result=='direction':
            t.status='FOUND'; t.last=p; t.bearing=float(response['svd_deg']); t.measurements+=1
            range_bound=min(1500.0,maxdist(p,t.poly)+EPS)
            t.poly=bearing_update(t.poly,p,t.bearing)
            if self.cfg.negative:
                for c,r in t.negatives: t.poly=exclude_disk_hull(t.poly,c,r)
            if not t.poly: raise RuntimeError('empty outer set: inconsistent measurements/numerics')
            t.center,t.radius=mec(t.poly)
            # Independent triangular enclosure: sec(delta)^2 / 2 contraction.
            a=math.radians(t.bearing); h=range_bound/(2*math.cos(DELTA)**2)
            tc=add(p,(h*math.cos(a),h*math.sin(a)))
            tr=maxdist(tc,t.poly)+1e-6
            if tr<t.radius: t.center,t.radius=tc,tr
            self._audit(i)
        else: raise RuntimeError('unknown measure_result')
        return result

    def _clear(self,i:int,p:Point,certified:bool=True) -> bool:
        response=self.api.clear(p,i)
        if not response.get('accepted'): raise RuntimeError('clear rejected')
        self.p=p; self.actions+=1; self.virtual_time=float(response['virtual_time_s'])
        if response.get('clear_result')=='success':
            self.tracks[i].status='CLEARED'; self.cleared+=1
            return True
        if response.get('clear_result')!='no_target_in_range': raise RuntimeError('unknown clear_result')
        if certified: raise RuntimeError('CERTIFIED clear failed: stop rather than silently claim success')
        t=self.tracks[i]; t.negatives.append((p,20.))
        t.poly=exclude_disk_hull(t.poly,p,20.)
        if not t.poly: raise RuntimeError('inconsistent failed clear')
        t.center,t.radius=mec(t.poly); self._audit(i)
        return False

    def _coverage(self,points) -> bool:
        self.certificate_checks+=1
        return covers_arena(points)

    def _certify_and_prune(self):
        if self.coverage_done: return
        if sum(t.status in ('FOUND','CLEARED') for t in self.tracks.values())==16:
            self.coverage_done=True; self.pending=[]; self.search_reason='cardinality'
            for t in self.tracks.values():
                if t.status=='UNKNOWN': t.status='ABSENT'
            return
        if self._coverage(self.scans):
            self.coverage_done=True; self.pending=[]; self.search_reason='disk_union'
            for t in self.tracks.values():
                if t.status=='UNKNOWN': t.status='ABSENT'
            return
        if self.cfg.prune and self._plan_ready:
            # Disabled local research branch; the frozen ring is not pruned.
            # Remove a future station ONLY if the remaining union still covers Omega.
            k=0
            while k<len(self.pending):
                future=self.pending[:k]+self.pending[k+1:]
                if self._coverage(self.scans+future): self.pending.pop(k)
                else: k+=1

    def _scan(self,p:Point):
        unknown=[i for i,t in self.tracks.items() if t.status=='UNKNOWN']
        # Keep the actual current receiver channel first when possible.
        unknown.sort(key=lambda i:(i!=self.channel,i))
        for i in unknown: self._observe(i,p)
        self.scans.append(p)
        if self.cfg.opportunistic:
            self._sweep_found(p)
        self._certify_and_prune()

    def _sweep_found(self,p:Point):
        # Never repeat the same channel/location; count actual new measurements.
        for i,t in self.tracks.items():
            if t.status!='FOUND' or t.radius<=19.8 or t.last is None: continue
            if dist(t.last,p)<25.: continue
            if maxdist(p,t.poly)<=999.:
                self._observe(i,p)

    def _make_plan(self):
        if self.coverage_done:
            self.pending=[]; self._plan_ready=True
            return
        phi=0.; clockwise=False
        found=[t for t in self.tracks.values() if t.status=='FOUND']
        if self.cfg.rotate and found:
            # Disabled local research branch; no rotation in the frozen policy.
            # Fixed finite candidate set, score is a heuristic (not a minimax theorem).
            options=[]
            for t in found:
                for off in (0.,math.pi/self.cfg.ring_m):
                    a=math.radians(t.bearing)+off
                    for cw in (False,True):
                        sites=ring_sites(self.cfg.ring_m,a,cw)
                        score=0.
                        for tr in found:
                            k=min(range(len(sites)),key=lambda j:dist(sites[j],tr.center))
                            score+=0.12*k*norm(sites[0])+dist(sites[k],tr.center)
                        options.append((score,a,cw))
            _,phi,clockwise=min(options)
        self.pending=ring_sites(self.cfg.ring_m,phi,clockwise)
        self._plan_ready=True
        self._certify_and_prune()

    def _tracking_point(self,t:Track,next_site:Point|None) -> Point:
        c,r=t.center,t.radius
        if r<=19.8: return nearest_certified_clear(self.p,c,r)
        d=unit(sub(c,self.p)); v=(-d[1],d[0])
        b=self.cfg.offset*r
        candidates=[add(c,mul(v,b)),add(c,mul(v,-b))] if b>0 else [c]
        # Whole feasible set must remain in guaranteed signal range.
        valid=[q for q in candidates if maxdist(q,t.poly)<=999.0]
        if not valid: return c  # first positive set always has radius below 751m
        if next_site is None:
            return min(valid,key=lambda q:dist(self.p,q))
        return min(valid,key=lambda q:dist(self.p,q)+0.15*dist(q,next_site))

    def _serve(self,i:int,next_site:Point|None):
        t=self.tracks[i]; steps=0
        while t.status=='FOUND':
            if steps>=18: raise RuntimeError('local tracking bound exceeded')
            if t.radius<=19.8:
                q=nearest_certified_clear(self.p,t.center,t.radius)
                self._clear(i,q); break
            if self.cfg.speculative_r>0 and t.radius<=self.cfg.speculative_r:
                # Research-only risk-taking; frozen policy clears by certificate.
                if self._clear(i,t.center,certified=False): break
            q=self._tracking_point(t,next_site)
            oldr=t.radius
            result=self._observe(i,q); steps+=1
            if result=='no_signal':
                # This is an invariant failure, not a cue for random exploration.
                raise RuntimeError('lost signal at a guaranteed reception point')
            if result=='direction' and t.radius>0.9*oldr+1e-3:
                raise RuntimeError('local contraction invariant failed')
        self.max_local_steps=max(self.max_local_steps,steps)
        if self.cfg.opportunistic_clear:
            self._sweep_found(self.p)
        self._certify_and_prune()
        if self.cfg.incidental and not self.coverage_done and self.cleared<16:
            # Research-only extra full scans, disabled in the frozen policy.
            if self._worth_extra_scan():
                self._scan(self.p)

    def _worth_extra_scan(self) -> bool:
        """Local research helper, reachable only with incidental=True."""
        if self.cfg.scan_policy=='distance':
            return min((dist(self.p,s) for s in self.scans),default=math.inf)>=self.cfg.scan_spacing
        if not self.pending:return False
        hypothetical=list(self.pending); k=0
        while k<len(hypothetical):
            rest=hypothetical[:k]+hypothetical[k+1:]
            if self._coverage(self.scans+[self.p]+rest):hypothetical.pop(k)
            else:k+=1
        if len(hypothetical)==len(self.pending):return False
        def length(sites):
            return sum(dist(a,b) for a,b in zip([self.p]+sites,sites))
        movement_saved=(length(self.pending)-length(hypothetical))/5.
        q=sum(t.status=='UNKNOWN' for t in self.tracks.values())
        # Compare an explicit path-saving proxy with an upper bound on scan cost.
        return movement_saved>6.*q+5.

    def _choose(self,next_site:Point|None) -> int|None:
        found=[i for i,t in self.tracks.items() if t.status=='FOUND']
        if not found: return None
        if next_site is None or self.cfg.mode=='sequential':
            return min(found,key=lambda i:dist(self.p,self.tracks[i].center)+self.tracks[i].radius)
        if self.cfg.mode=='deferred': return None
        values=[]
        for i in found:
            t=self.tracks[i]; c,r=t.center,t.radius
            detour=dist(self.p,c)+dist(c,next_site)-dist(self.p,next_site)
            # A service excursion may end away from c. Penalize uncertainty in meters.
            score=detour+1.0*r
            values.append((score,i))
        score,i=min(values)
        return i if score<=self.cfg.insert_m else None

    def run(self) -> dict:
        self._scan((0.,0.)); self._make_plan()
        loops=0
        while True:
            loops+=1
            if loops>1000 or self.actions>5000: raise RuntimeError('progress limit exceeded')
            if self.cleared==16:
                # Total cardinality upper bound itself is a valid completion certificate.
                break
            found=[i for i,t in self.tracks.items() if t.status=='FOUND']
            unknown=[i for i,t in self.tracks.items() if t.status=='UNKNOWN']
            if not found and not unknown: break
            next_site=self.pending[0] if self.pending else None
            i=self._choose(next_site)
            if i is not None:
                self._serve(i,next_site)
            elif next_site is not None:
                self.pending.pop(0); self._scan(next_site)
            elif unknown:
                # Planned union was validated. Never mark channels absent just from counts.
                self._certify_and_prune()
                if not self.coverage_done: raise RuntimeError('coverage certificate missing')
            else: break
        return dict(cleared=self.cleared,virtual_time_s=self.virtual_time,
            average_time_s=self.virtual_time/self.cleared if self.cleared else None,
            actions=self.actions,scan_sites=len(self.scans),coverage_certified=self.search_reason=='disk_union',search_certificate=self.search_reason,
            certificate_checks=self.certificate_checks,max_vertices=self.max_vertices,
            max_local_steps=self.max_local_steps,
            channel_status={str(i):t.status for i,t in self.tracks.items()})


def run_case(api, audit=None):
    return Strategy(api,Config(),audit=audit).run()
