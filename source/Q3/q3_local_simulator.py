#!/usr/bin/env python3
from __future__ import annotations
from dataclasses import dataclass
import argparse,datetime,json,math,random,time
from pathlib import Path
import q3_local_solver as solver

@dataclass(frozen=True)
class Source:
    channel:int;position:tuple[float,float];radius:float;phase:float

class Simulator:
    def __init__(self,sources,seed):
        self.sources={s.channel:s for s in sources};self.cleared=set();self.p=(0.0,0.0);self.channel=1
        self.time=0.0;self.distance=0.0;self.measurements=0;self.switches=0;self.failed_clears=0;self.seed=seed
    def _move(self,p):
        d=math.dist(self.p,p);self.distance+=d;self.time+=d/5.0;self.p=p
    def _error(self,s,p):
        return max(-1.0,min(1.0,0.62*math.sin(p[0]/211+p[1]/173+s.phase)+0.38*math.cos(p[1]/359-p[0]/283+s.phase*1.37)))
    def measure(self,p,ch):
        self._move(p);self.time+=5;self.measurements+=1
        if ch!=self.channel:self.time+=1;self.switches+=1
        self.channel=ch;s=self.sources.get(ch);out={'accepted':True,'virtual_time_s':self.time}
        if s is None or ch in self.cleared or math.dist(p,s.position)>s.radius:out['measure_result']='no_signal'
        elif math.dist(p,s.position)<=5:out['measure_result']='near'
        else:
            a=math.degrees(math.atan2(s.position[1]-p[1],s.position[0]-p[0]))
            out.update(measure_result='direction',svd_deg=round((a+self._error(s,p))%360,2))
        return out
    def clear(self,p,ch):
        self._move(p);s=self.sources.get(ch);ok=s is not None and ch not in self.cleared and math.dist(p,s.position)<=20
        if ok:self.cleared.add(ch);self.time+=5
        else:self.time+=3;self.failed_clears+=1
        return {'accepted':True,'virtual_time_s':self.time,'clear_result':'success' if ok else 'no_target_in_range'}

def make_case(seed):
    r=random.Random(seed);n=r.randint(10,16);chs=r.sample(range(1,21),n);out=[]
    for ch in chs:
        a=r.random()*math.tau;rr=1800*math.sqrt(r.random());p=(rr*math.cos(a),rr*math.sin(a))
        out.append(Source(ch,p,r.uniform(1000,1500),r.random()*math.tau))
    return out

def _average(cases):
    if not cases:return None
    n=len(cases);sources=sum(c['source_count'] for c in cases);cleared=sum(c['cleared'] for c in cases)
    per_source=[c['average_time_s'] for c in cases if c['average_time_s'] is not None]
    return {
        'case_count':n,
        'source_count_per_case':sum(c['source_count'] for c in cases)/n,
        'cleared_per_case':sum(c['cleared'] for c in cases)/n,
        'virtual_time_s_per_case':sum(c['virtual_time_s'] for c in cases)/n,
        'case_equal_mean_time_s_per_source':sum(per_source)/len(per_source) if per_source else None,
        'pooled_time_s_per_cleared_source':sum(c['virtual_time_s'] for c in cases)/cleared if cleared else None,
        'distance_m_per_case':sum(c['distance_m'] for c in cases)/n,
        'movement_time_s_per_case':sum(c['distance_m'] for c in cases)/(5*n),
        'measurement_time_s_per_case':5*sum(c['measurements'] for c in cases)/n,
        'switch_time_s_per_case':sum(c['switches'] for c in cases)/n,
        'clear_action_time_s_per_case':(5*cleared+3*sum(c['failed_clears'] for c in cases))/n,
        'measurements_per_case':sum(c['measurements'] for c in cases)/n,
        'switches_per_case':sum(c['switches'] for c in cases)/n,
        'failed_clears_per_case':sum(c['failed_clears'] for c in cases)/n,
    }

def _print_average(title,avg):
    if not avg:return
    print(title)
    print(f'  平均每局源数：{avg["source_count_per_case"]:.2f}')
    print(f'  平均每局清除数：{avg["cleared_per_case"]:.2f}')
    print(f'  平均每局总耗时：{avg["virtual_time_s_per_case"]:.2f} s')
    if avg['case_equal_mean_time_s_per_source'] is not None:print(f'  逐局等权平均每源耗时：{avg["case_equal_mean_time_s_per_source"]:.2f} s')
    if avg['pooled_time_s_per_cleared_source'] is not None:print(f'  合并源数加权每源耗时：{avg["pooled_time_s_per_cleared_source"]:.2f} s')
    print(f'  平均每局移动距离：{avg["distance_m_per_case"]:.2f} m')
    print(f'  时间分解（移动/检测/换台/清除）：{avg["movement_time_s_per_case"]:.2f} / {avg["measurement_time_s_per_case"]:.2f} / {avg["switch_time_s_per_case"]:.2f} / {avg["clear_action_time_s_per_case"]:.2f} s')
    print(f'  平均每局测向次数：{avg["measurements_per_case"]:.2f}')
    print(f'  平均每局切频道次数：{avg["switches_per_case"]:.2f}')
    print(f'  平均每局失败清除次数：{avg["failed_clears_per_case"]:.3f}')

def main():
    ap=argparse.ArgumentParser(description='问题三本地连续随机测试')
    ap.add_argument('--loops',type=int,default=None);ap.add_argument('--seed',type=int,default=None)
    ap.add_argument('--output',type=Path,default=None);args=ap.parse_args()
    loops=args.loops if args.loops is not None else int(input('请输入测试局数：').strip() or '1000')
    base=args.seed if args.seed is not None else random.SystemRandom().randrange(1,2**63)
    rng=random.Random(base);cases=[];start=time.perf_counter();success=0
    for i in range(loops):
        seed=rng.randrange(1,2**63);src=make_case(seed);sim=Simulator(src,seed)
        try:
            res=solver.run_case(sim);all_clear=len(sim.cleared)==len(src);err=None
        except Exception as exc:
            res={};all_clear=False;err=repr(exc)
        success+=int(all_clear)
        cases.append({'index':i+1,'seed':seed,'source_count':len(src),'all_cleared':all_clear,
            'cleared':len(sim.cleared),'virtual_time_s':sim.time,'average_time_s':sim.time/len(sim.cleared) if sim.cleared else None,
            'distance_m':sim.distance,'measurements':sim.measurements,'switches':sim.switches,'failed_clears':sim.failed_clears,
            'solver':res,'error':err})
        if (i+1)%max(1,min(100,loops//20 or 1))==0:print(f'进度：{i+1}/{loops}，全清除 {success}/{i+1}',flush=True)

    good=[c for c in cases if c['all_cleared']]
    avg_all=_average(cases);avg_good=_average(good)
    summary={
        'problem':3,'loops':loops,'base_seed':base,
        'full_clear_cases':success,'full_clear_rate':success/loops if loops else 0,
        'average_all_cases':avg_all,
        'average_successful_cases':avg_good,
        'mean_virtual_time_s':avg_good['virtual_time_s_per_case'] if avg_good else None,
        'mean_average_time_s':avg_good['case_equal_mean_time_s_per_source'] if avg_good else None,
        'pooled_average_time_s':avg_good['pooled_time_s_per_cleared_source'] if avg_good else None,
        'runtime_s':time.perf_counter()-start,'cases':cases
    }
    out=args.output or Path('results')/f"q3_local_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    out.parent.mkdir(parents=True,exist_ok=True);out.write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding='utf-8')

    print()
    print(f'完成：{success}/{loops} 局全清除，全清除率 {summary["full_clear_rate"]:.2%}')
    _print_average('【全部测试局平均】',avg_all)
    if success != loops:_print_average('【全清除成功局平均】',avg_good)
    print(f'本机实际运行耗时：{summary["runtime_s"]:.2f} s')
    print(f'结果已保存：{out}')

if __name__=='__main__':main()
