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


import argparse,datetime,http.client,json,os,socket,sys,time,unicodedata,uuid
from pathlib import Path
from urllib.parse import urlsplit

class ProtocolError(RuntimeError):pass
class BudgetExceeded(RuntimeError):pass
class ResultUnknown(RuntimeError):pass

class OfficialClient:
    def __init__(self,base_url,robot_id,log_path,timeout=5.0,retries=6):
        parsed=urlsplit(base_url)
        if parsed.scheme!='http' or not parsed.hostname or parsed.path not in ('','/') or parsed.query or parsed.fragment:raise ValueError('接口地址格式错误')
        if parsed.hostname not in ('127.0.0.1','localhost','::1'):raise ValueError('官方接口只能使用本机回环地址')
        if not robot_id or len(robot_id.encode('utf-8'))>64 or any(unicodedata.category(c) in ('Cc','Cf') for c in robot_id):raise ValueError('参赛队号格式不合法')
        self.host=parsed.hostname;self.port=parsed.port or 80;self.robot_id=robot_id;self.timeout=timeout;self.retries=retries;self.conn=None
        self.prefix=uuid.uuid4().hex[:12];self.serial=0;self.deadline=None;self.virtual_time=0.0;self.max_virtual=360000.0
        self.entered=False;self.exited=False;self.retry_count=0;self.position=(0.0,0.0);self.current_channel=1;self.pending=None
        self.exit_attempted=False;self.exit_response=None
        self.log_failed=False;self.log_error=None
        p=Path(log_path);p.parent.mkdir(parents=True,exist_ok=True);self.log=p.open('x',encoding='utf-8')
        self._log({'kind':'metadata','program':'Q4','robot_id':'<TEAM_ID>','utc':datetime.datetime.now(datetime.timezone.utc).isoformat()})
    def _log(self,obj):
        try:self.log.write(json.dumps(obj,ensure_ascii=False,allow_nan=False,separators=(',',':'))+'\n');self.log.flush()
        except Exception as exc:
            self.log_failed=True;self.log_error=repr(exc);print(f'日志写入失败：{exc}',file=sys.stderr,flush=True)
    def _disconnect(self):
        if self.conn:
            try:self.conn.close()
            except OSError:pass
        self.conn=None
    def _connection(self,timeout=None):
        if self.conn is None:
            c=http.client.HTTPConnection(self.host,self.port,timeout=timeout or self.timeout);c.connect()
            if c.sock:c.sock.setsockopt(socket.IPPROTO_TCP,socket.TCP_NODELAY,1)
            self.conn=c
        if timeout is not None:self.conn.timeout=timeout
        if self.conn.sock and timeout is not None:self.conn.sock.settimeout(timeout)
        return self.conn
    @staticmethod
    def _finite(value):
        if isinstance(value,bool) or not isinstance(value,(int,float)):return False
        try:return math.isfinite(float(value))
        except (OverflowError,TypeError,ValueError):return False
    def _cutoff(self,path):
        if self.deadline is None:return None
        return self.deadline-(0.25 if path=='/exit' else 8.0)
    def _attempt_timeout(self,path):
        cutoff=self._cutoff(path)
        if cutoff is None:return self.timeout
        remaining=cutoff-time.monotonic()
        if remaining<=0:raise BudgetExceeded('现实运行时间不足，停止发送新动作')
        return max(0.05,min(self.timeout,remaining))
    def _validate_success(self,path,status,obj):
        if not isinstance(obj,dict):raise ResultUnknown('响应JSON顶层不是对象')
        if not isinstance(obj.get('accepted'),bool):raise ResultUnknown('accepted字段异常')
        for key in ('real_timestamp_ms','virtual_time_s'):
            if not self._finite(obj.get(key)) or float(obj[key])<0:raise ResultUnknown(f'{key}字段异常')
        if status!=200:
            if obj['accepted'] is False:raise ProtocolError(f'HTTP {status}：请求已明确拒绝')
            raise ResultUnknown(f'HTTP {status}与accepted=true矛盾')
        if obj['accepted'] is not True:raise ProtocolError('请求未被接受')
        if float(obj['virtual_time_s'])+1e-5<self.virtual_time:raise ResultUnknown('virtual_time_s倒退')
        if path=='/enter':
            for key in ('max_virtual_duration_s','max_real_duration_s','remaining_real_duration_s'):
                if not self._finite(obj.get(key)) or float(obj[key])<0:raise ResultUnknown(f'{key}字段异常')
            rem=float(obj['remaining_real_duration_s'])
            if rem>1200 or not rem.is_integer():raise ResultUnknown('remaining_real_duration_s异常')
        elif path=='/measure':
            kind=obj.get('measure_result')
            if kind not in ('no_signal','near','direction'):raise ResultUnknown('measure_result异常')
            if kind=='direction' and (not self._finite(obj.get('svd_deg')) or not 0<=float(obj['svd_deg'])<360):raise ResultUnknown('svd_deg异常')
        elif path=='/clear' and obj.get('clear_result') not in ('success','no_target_in_range'):raise ResultUnknown('clear_result异常')
        elif path=='/exit' and obj.get('exit_reason')!='user_exit':raise ResultUnknown('exit_reason异常')
    def _request(self,path,payload,body=None):
        body=body or json.dumps(payload,ensure_ascii=False,separators=(',',':'),allow_nan=False).encode('utf-8')
        if self.pending is None:
            self.pending={'path':path,'payload':dict(payload),'body':body}
            safe=dict(payload);safe['robot_id']='<TEAM_ID>';self._log({'kind':'request','path':path,'payload':safe})
        last=None;unknown=False
        for attempt in range(self.retries+1):
            started=time.monotonic()
            try:
                timeout=self._attempt_timeout(path);c=self._connection(timeout);c.request('POST',path,body,{'Content-Type':'application/json; charset=utf-8'})
                r=c.getresponse();status=r.status;raw=r.read()
                try:obj=json.loads(raw.decode('utf-8'),parse_constant=lambda x:(_ for _ in ()).throw(ValueError(x)))
                except (ValueError,UnicodeDecodeError) as exc:
                    self._log({'kind':'invalid_response','path':path,'request_id':payload['request_id'],'attempt':attempt,'http_status':status,'raw':raw[:1000].decode('utf-8','replace')})
                    raise ResultUnknown('响应不是有效JSON') from exc
                self._log({'kind':'response','path':path,'request_id':payload['request_id'],'attempt':attempt,'elapsed_s':time.monotonic()-started,'http_status':status,'body':obj})
                if status in (429,500,502,503,504):
                    common_ok=(isinstance(obj,dict) and obj.get('accepted') is False
                               and self._finite(obj.get('real_timestamp_ms'))
                               and self._finite(obj.get('virtual_time_s')))
                    if not common_ok:raise ResultUnknown(f'HTTP {status}响应状态不可信')
                    raise OSError(f'HTTP {status}')
                try:self._validate_success(path,status,obj)
                except ProtocolError:self.pending=None;raise
                self.virtual_time=float(obj['virtual_time_s']);self.pending=None;return obj
            except BudgetExceeded:
                if not unknown:
                    self.pending=None;self._log({'kind':'aborted_before_send','path':path,'request_id':payload['request_id'],'attempt':attempt})
                raise
            except ProtocolError:raise
            except (OSError,TimeoutError,http.client.HTTPException,ResultUnknown) as exc:
                last=exc;unknown=unknown or isinstance(exc,ResultUnknown) or not (isinstance(exc,OSError) and str(exc).startswith('HTTP '))
                self._disconnect();self._log({'kind':'retry','path':path,'request_id':payload['request_id'],'attempt':attempt,'elapsed_s':time.monotonic()-started,'error':repr(exc)})
                if attempt==self.retries:break
                self.retry_count+=1;delay=min(.1*2**attempt,1.5);cutoff=self._cutoff(path)
                if cutoff is not None:delay=min(delay,max(0.0,cutoff-time.monotonic()))
                if delay<=0:break
                time.sleep(delay)
        if unknown:raise ResultUnknown(f'动作结果未知，只能保留原request_id：{last}')
        self.pending=None;raise ConnectionError(f'同一请求重试后仍无有效响应：{last}')
    def action(self,path,position=None,channel=None):
        if path not in ('/enter','/measure','/clear','/exit'):raise ValueError('接口路径不合法')
        if self.pending is not None:raise ResultUnknown('上一动作结果未知，禁止生成新的request_id')
        if path in ('/measure','/clear') and (position is None or channel is None):raise ValueError('动作缺少位置或频道')
        if path in ('/enter','/exit') and (position is not None or channel is not None):raise ValueError('enter/exit不应包含位置或频道')
        clean_position=None
        if position is not None:
            if len(position)!=2 or not all(self._finite(v) and abs(float(v))<=2e6 for v in position):raise ValueError('坐标不合法')
            clean_position=(float(position[0]),float(position[1]))
        if channel is not None and (isinstance(channel,bool) or not isinstance(channel,int) or not 1<=channel<=20):raise ValueError('频道不合法')
        if path in ('/measure','/clear'):
            upper=dist(self.position,clean_position)/5.0+5.0
            if path=='/measure' and channel!=self.current_channel:upper+=1.0
            if self.virtual_time+upper>self.max_virtual-0.001:raise BudgetExceeded('下一动作将超过虚拟时间上限')
        self._attempt_timeout(path);self.serial+=1;payload={'arena_id':'default','robot_id':self.robot_id,'request_id':f'{self.prefix}-{self.serial}'}
        if clean_position is not None:payload['position']={'x':clean_position[0],'y':clean_position[1]}
        if channel is not None:payload['channel']=channel
        out=self._request(path,payload)
        if path in ('/measure','/clear'):self.position=clean_position
        if path=='/measure':self.current_channel=channel
        return out
    def wait_until_open(self,wait_s=300.0):
        end=time.monotonic()+wait_s
        while time.monotonic()<end:
            try:
                with socket.create_connection((self.host,self.port),timeout=.5):return
            except OSError:time.sleep(.25)
        raise TimeoutError('等待官方模拟器接口超时')
    def enter(self):
        started=time.monotonic();out=self.action('/enter');rem=out.get('remaining_real_duration_s')
        if not isinstance(rem,(int,float)) or not 0<=float(rem)<=1200:raise ProtocolError('remaining_real_duration_s 异常')
        self.deadline=started+float(rem);self.max_virtual=float(out['max_virtual_duration_s']);self.entered=True;return out
    def measure(self,p,ch):return self.action('/measure',p,ch)
    def clear(self,p,ch):return self.action('/clear',p,ch)
    def exit(self):
        if self.exited:return self.exit_response
        self.exit_attempted=True;out=self.action('/exit');self.exited=True;self.exit_response=out;return out
    def can_exit(self):return self.entered and not self.exited and not self.exit_attempted and self.pending is None and (self.deadline is None or time.monotonic()<self.deadline-0.25)
    def close(self):
        self._disconnect()
        try:self.log.close()
        except OSError as exc:
            self.log_failed=True;self.log_error=repr(exc);print(f'日志关闭失败：{exc}',file=sys.stderr,flush=True)

def main():
    ap=argparse.ArgumentParser(description='问题四正式测试程序')
    ap.add_argument('--robot-id',default=None,help='参赛队号；不写入代码')
    ap.add_argument('--url',default='http://127.0.0.1:2026');ap.add_argument('--wait',type=float,default=300.0);args=ap.parse_args()
    robot_id=args.robot_id or os.environ.get('CUMCM_ROBOT_ID') or input('请输入参赛队号（仅本次运行使用）：').strip();stamp=datetime.datetime.now().strftime('%Y%m%d_%H%M%S_%f')
    log=f'runs/q4_{stamp}.jsonl';api=OfficialClient(args.url,robot_id,log);ok=False;started=time.perf_counter()
    try:
        print('等待问题4测试接口开放……',flush=True);api.wait_until_open(args.wait);api.enter();started=time.perf_counter()
        print('已进入测试，开始自动搜索定位与清除。',flush=True);summary=run_case(api);api.exit()
        summary.update(program_runtime_s=time.perf_counter()-started,retries=api.retry_count)
        Path(log).with_suffix('.summary.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding='utf-8');api._log({'kind':'summary','strategy_complete':True,'exit_confirmed':api.exited,**summary});ok=True
        if api.log_failed:raise OSError(f'运行已完成，但结构化日志不完整：{api.log_error}')
        average='N/A' if summary['average_time_s'] is None else f"{summary['average_time_s']:.3f}"
        print(f"完成：清除 {summary['cleared']} 个频道，虚拟时间 {summary['virtual_time_s']:.3f} s，平均 {average} s/源")
        print(f'本地运行记录：{log}')
    except (Exception,KeyboardInterrupt) as exc:
        ok=False
        api._log({'kind':'fatal','error':repr(exc),'complete':False});print(f'运行未完成：{exc}',file=sys.stderr,flush=True)
        if api.can_exit():
            try:api.exit()
            except Exception as exit_exc:api._log({'kind':'exit_failure','error':repr(exit_exc),'pending':api.pending and {'path':api.pending['path'],'request_id':api.pending['payload']['request_id']}})
    finally:api.close()
    return 0 if ok and not api.log_failed else 1
if __name__=='__main__':raise SystemExit(main())
