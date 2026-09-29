#!/usr/bin/env python3
from __future__ import annotations
from dataclasses import dataclass,field
import math,random

Point=tuple[float,float]
TAU=2*math.pi
EPS=1e-7
DELTA=math.radians(1.0051)  # 1° physical bound + 0.005° output rounding + 0.0001° guard
CLEAR_CERT=19.8
LAMBDA=0.5
ETA=0.05
REUSE_MIN_BASELINE=25.0

def add(a,b):return a[0]+b[0],a[1]+b[1]
def sub(a,b):return a[0]-b[0],a[1]-b[1]
def mul(a,s):return a[0]*s,a[1]*s
def dot(a,b):return a[0]*b[0]+a[1]*b[1]
def cross(a,b):return a[0]*b[1]-a[1]*b[0]
def norm(a):return math.hypot(*a)
def dist(a,b):return math.hypot(a[0]-b[0],a[1]-b[1])
def maxdist(p,poly):return max((dist(p,v) for v in poly),default=0.0)

def clip(poly,n,b):
    if not poly:return []
    b+=EPS*max(1.0,norm(n));out=[];a=poly[-1];fa=dot(n,a)-b
    for c in poly:
        fc=dot(n,c)-b
        if (fa<=0)!=(fc<=0):
            t=fa/(fa-fc);out.append(add(a,mul(sub(c,a),t)))
        if fc<=0:out.append(c)
        a,fa=c,fc
    clean=[]
    for p in out:
        if not clean or dist(p,clean[-1])>1e-9:clean.append(p)
    if len(clean)>1 and dist(clean[0],clean[-1])<1e-9:clean.pop()
    return clean

def arena_polygon(sides=64):
    r=1800/math.cos(math.pi/sides)
    return [(r*math.cos(TAU*k/sides+math.pi/sides),r*math.sin(TAU*k/sides+math.pi/sides)) for k in range(sides)]

def direction_update(poly,p,theta_deg,U):
    a=math.radians(theta_deg);lo=(math.cos(a-DELTA),math.sin(a-DELTA));hi=(math.cos(a+DELTA),math.sin(a+DELTA))
    for n in ((lo[1],-lo[0]),(-hi[1],hi[0])):poly=clip(poly,n,dot(n,p))
    u=(math.cos(a),math.sin(a));poly=clip(poly,u,dot(u,p)+U)
    return poly

def _diameter_circle(a,b):
    c=mul(add(a,b),.5);return c,dist(a,b)/2

def _circum(a,b,c):
    u=sub(b,a);v=sub(c,a);d=2*cross(u,v)
    if abs(d)<1e-18:return None
    uu=dot(u,u);vv=dot(v,v);o=add(a,((v[1]*uu-u[1]*vv)/d,(u[0]*vv-v[0]*uu)/d))
    return o,dist(o,a)

def mec(points):
    if not points:raise RuntimeError('可行位置集合为空')
    pts=list(points);random.Random(271828).shuffle(pts);circle=None
    for i,p in enumerate(pts):
        if circle and dist(circle[0],p)<=circle[1]+1e-9:continue
        circle=(p,0.0)
        for j,q in enumerate(pts[:i]):
            if dist(circle[0],q)<=circle[1]+1e-9:continue
            circle=_diameter_circle(p,q);pq=sub(q,p);left=right=None
            for r in pts[:j]:
                if dist(circle[0],r)<=circle[1]+1e-9:continue
                cc=_circum(p,q,r)
                if cc is None:continue
                side=cross(pq,sub(r,p));v=cross(pq,sub(cc[0],p))
                if side>0 and (left is None or v>left[0]):left=v,cc
                if side<0 and (right is None or v<right[0]):right=v,cc
            options=[x[1] for x in (left,right) if x is not None]
            if options:circle=min(options,key=lambda z:z[1])
    c=circle[0];return c,maxdist(c,points)+1e-6

def nearest_clear(p,c,r):
    slack=CLEAR_CERT-r
    if slack<0:raise ValueError('尚未达到清除证书')
    d=dist(p,c)
    if d<=slack:return p
    return add(c,mul(sub(p,c),slack/d))

def coverage_route():
    inner=[(995*math.cos(k*math.pi/4),995*math.sin(k*math.pi/4)) for k in range(8)]
    outer=[(1838*math.cos(j*math.pi/8),1838*math.sin(j*math.pi/8)) for j in range(16)]
    order=[14,15]+list(range(14))
    return [(0.0,0.0)]+inner+[outer[j] for j in order]

@dataclass
class Track:
    status:str='UNKNOWN'
    poly:list[Point]=field(default_factory=arena_polygon)
    center:Point=(0.0,0.0)
    radius:float=math.inf
    anchor:Point|None=None
    last:Point|None=None
    bearing_deg:float=0.0
    U:float=1500.0
    measurements:int=0

class Strategy:
    def __init__(self,api):
        self.api=api;self.tracks={i:Track() for i in range(1,21)};self.p=(0.0,0.0);self.channel=1
        self.virtual_time=0.0;self.actions=0;self.cleared=0;self.route=coverage_route();self.coverage_index=0
        self.coverage_done=False;self.max_pair_rounds=0
    def _update_mec(self,t):t.center,t.radius=mec(t.poly)
    def _positive(self,i,p,bearing):
        t=self.tracks[i];U=min(1500.0,maxdist(p,t.poly)+EPS);new=direction_update(t.poly,p,bearing,U)
        if not new:raise RuntimeError(f'频道{i}的位置集合为空')
        t.status='FOUND';t.poly=new;t.anchor=p;t.bearing_deg=float(bearing);t.U=min(U,maxdist(p,new)+EPS);t.measurements+=1;self._update_mec(t)
    def _clear(self,i,p,certified=True):
        r=self.api.clear(p,i)
        if not r.get('accepted'):raise RuntimeError('清除请求被拒绝')
        self.p=p;self.virtual_time=float(r['virtual_time_s']);self.actions+=1
        if r.get('clear_result')=='success':self.tracks[i].status='CLEARED';self.cleared+=1;return True
        if r.get('clear_result')!='no_target_in_range':raise RuntimeError('未知清除结果')
        if certified:raise RuntimeError(f'频道{i}认证清除失败')
        return False
    def _observe(self,i,p):
        r=self.api.measure(p,i)
        if not r.get('accepted'):raise RuntimeError('检测请求被拒绝')
        self.p=p;self.channel=i;self.virtual_time=float(r['virtual_time_s']);self.actions+=1;self.tracks[i].last=p
        kind=r.get('measure_result')
        if kind=='direction':self._positive(i,p,float(r['svd_deg']))
        elif kind=='near':self.tracks[i].status='FOUND';self._clear(i,p,certified=True)
        elif kind!='no_signal':raise RuntimeError('未知检测结果')
        return kind
    def _known_count(self):return sum(t.status in ('FOUND','CLEARED') for t in self.tracks.values())
    def _finish_unknown_if_possible(self):
        if self._known_count()>=16:
            for t in self.tracks.values():
                if t.status=='UNKNOWN':t.status='ABSENT'
            self.coverage_done=True
        elif self.coverage_index>=len(self.route):
            for t in self.tracks.values():
                if t.status=='UNKNOWN':t.status='ABSENT'
            self.coverage_done=True
    def _reuse(self,limit=2):
        cand=[]
        for i,t in self.tracks.items():
            if t.status=='FOUND' and t.radius>CLEAR_CERT and maxdist(self.p,t.poly)<=999.0:
                if t.last is None or dist(self.p,t.last)<REUSE_MIN_BASELINE:continue
                cand.append((t.radius,i))
        for _,i in sorted(cand,reverse=True)[:limit]:
            self._observe(i,self.p)
    def _scan_site(self,p):
        unknown=[i for i,t in self.tracks.items() if t.status=='UNKNOWN']
        unknown.sort(key=lambda i:(i!=self.channel,i))
        for i in unknown:
            self._observe(i,p)
            if self._known_count()>=16:break
        self._reuse(2);self.coverage_index+=1;self._finish_unknown_if_possible()
    def _dual_negative(self,t,anchor,u,U):
        t.poly=clip(t.poly,u,dot(u,anchor)+LAMBDA*U)
        if not t.poly:raise RuntimeError('双无信号裁剪后集合为空')
        t.U=min(LAMBDA/math.cos(DELTA)*U,maxdist(anchor,t.poly)+EPS);self._update_mec(t)
    def _pair_round(self,i):
        t=self.tracks[i]
        if t.anchor is None:raise RuntimeError('缺少正锚点')
        U=t.U;a=math.radians(t.bearing_deg);u=(math.cos(a),math.sin(a));v=(-u[1],u[0])
        q1=add(t.anchor,add(mul(u,LAMBDA*U),mul(v,ETA*U)));q2=add(t.anchor,add(mul(u,LAMBDA*U),mul(v,-ETA*U)))
        if dist(self.p,q2)<dist(self.p,q1):q1,q2=q2,q1
        r1=self._observe(i,q1)
        if self.tracks[i].status!='FOUND' or r1!='no_signal':return
        r2=self._observe(i,q2)
        if self.tracks[i].status!='FOUND' or r2!='no_signal':return
        self._dual_negative(t,t.anchor,u,U)
    def _service(self,i):
        rounds=0
        while self.tracks[i].status=='FOUND':
            t=self.tracks[i]
            if t.radius<=CLEAR_CERT:
                self._clear(i,nearest_clear(self.p,t.center,t.radius));break
            if rounds>=9:raise RuntimeError(f'频道{i}成对探测超过上限')
            self._pair_round(i);rounds+=1
        self.max_pair_rounds=max(self.max_pair_rounds,rounds);self._reuse(2);self._finish_unknown_if_possible()
    def _choose_insert(self,next_site):
        rows=[]
        for i,t in self.tracks.items():
            if t.status!='FOUND':continue
            if next_site is None:score=dist(self.p,t.center)+t.radius
            else:score=dist(self.p,t.center)+dist(t.center,next_site)-dist(self.p,next_site)+t.radius
            rows.append((score,i))
        if not rows:return None
        score,i=min(rows);return i if next_site is None or score<=600.0 else None
    def run(self):
        if self.coverage_index==0:self._scan_site(self.route[0])
        loops=0
        while loops<2000:
            loops+=1
            self._finish_unknown_if_possible()
            found=[i for i,t in self.tracks.items() if t.status=='FOUND']
            unknown=[i for i,t in self.tracks.items() if t.status=='UNKNOWN']
            if not found and not unknown:break
            next_site=self.route[self.coverage_index] if self.coverage_index<len(self.route) and not self.coverage_done else None
            i=self._choose_insert(next_site)
            if i is not None:self._service(i);continue
            if next_site is not None:self._scan_site(next_site);continue
            if found:self._service(min(found,key=lambda j:dist(self.p,self.tracks[j].center)+self.tracks[j].radius));continue
            self._finish_unknown_if_possible()
        else:raise RuntimeError('策略循环超过上限')
        return {'cleared':self.cleared,'virtual_time_s':self.virtual_time,'average_time_s':self.virtual_time/self.cleared if self.cleared else None,
                'actions':self.actions,'coverage_sites_visited':self.coverage_index,'coverage_done':self.coverage_done,'max_pair_rounds':self.max_pair_rounds,
                'channel_status':{str(i):t.status for i,t in self.tracks.items()}}

def run_case(api):return Strategy(api).run()
