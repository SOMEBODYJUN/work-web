#!/usr/bin/env python3
from __future__ import annotations
import argparse,json,math,random
from pathlib import Path

ARENA_R=1800.0

def main():
    ap=argparse.ArgumentParser(description='问题一随机测试数据生成器')
    ap.add_argument('--seed',type=int,default=None)
    ap.add_argument('--points',type=int,default=4)
    ap.add_argument('--output',type=Path,default=Path('q1_input.json'))
    args=ap.parse_args()
    seed=args.seed if args.seed is not None else random.SystemRandom().randrange(1,2**63)
    rng=random.Random(seed)
    n=max(3,args.points)
    ang=rng.random()*math.tau
    rr=ARENA_R*math.sqrt(rng.random())*0.82
    source=(rr*math.cos(ang),rr*math.sin(ang))
    observations=[]
    base=rng.random()*math.tau
    for k in range(n):
        a=base+2*math.pi*k/n+rng.uniform(-0.20,0.20)
        d=rng.uniform(500.0,1450.0)
        p=(round(source[0]+d*math.cos(a),6),round(source[1]+d*math.sin(a),6))
        true=math.degrees(math.atan2(source[1]-p[1],source[0]-p[0]))%360
        # The simulator reports two decimals.  Rejection after quantisation
        # guarantees that the generated final datum still obeys the ±1° bound.
        while True:
            report=round((true+rng.uniform(-1.0,1.0))%360,2)%360.0
            final_error=(report-true+180.0)%360.0-180.0
            if abs(final_error)<=1.0:break
        observations.append({'position_m':[p[0],p[1]],'bearing_deg':report})
    payload={'case_id':f'Q1-seed-{seed}','seed':seed,'epsilon_deg':1.0,
             'observations':observations,
             'local_truth':{'source_m':[source[0],source[1]]}}
    args.output.parent.mkdir(parents=True,exist_ok=True)
    args.output.write_text(json.dumps(payload,ensure_ascii=False,indent=2),encoding='utf-8')
    print(f'随机种子：{seed}')
    print(f'检测点数量：{n}')
    print(f'测试数据已保存：{args.output}')

if __name__=='__main__':main()
