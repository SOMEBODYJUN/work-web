#!/usr/bin/env python3
from __future__ import annotations
import argparse,json,math,random
from pathlib import Path

def main():
    ap=argparse.ArgumentParser(description='问题二随机首测数据生成器')
    ap.add_argument('--seed',type=int,default=None)
    ap.add_argument('--output',type=Path,default=Path('q2_input.json'))
    args=ap.parse_args()
    seed=args.seed if args.seed is not None else random.SystemRandom().randrange(1,2**63)
    rng=random.Random(seed)
    # 生成一组物理相容的首测，真值仅供本地核验，求解器不会读取。
    sa=rng.random()*math.tau; sr=rng.uniform(0,450)
    s=(sr*math.cos(sa),sr*math.sin(sa))
    ga=rng.random()*math.tau; gd=rng.uniform(450,1400)
    g=(s[0]+gd*math.cos(ga),s[1]+gd*math.sin(ga))
    d=math.hypot(*g)
    if d>1750:
        scale=1750/d;g=(g[0]*scale,g[1]*scale)
    true=math.degrees(math.atan2(g[1]-s[1],g[0]-s[0]))%360
    while True:
        report=round((true+rng.uniform(-1,1))%360,2)%360.0
        final_error=(report-true+180.0)%360.0-180.0
        if abs(final_error)<=1.0:break
    payload={'case_id':f'Q2-seed-{seed}','seed':seed,'first_station_m':[s[0],s[1]],
             'first_bearing_deg':report,'baselines_m':[600,700,800,900,1000],
             'local_truth':{'source_m':[g[0],g[1]],'true_bearing_deg':true}}
    args.output.parent.mkdir(parents=True,exist_ok=True)
    args.output.write_text(json.dumps(payload,ensure_ascii=False,indent=2),encoding='utf-8')
    print(f'随机种子：{seed}')
    print(f'首测点：({s[0]:.3f}, {s[1]:.3f})')
    print(f'示向度：{report:.2f}°')
    print(f'测试数据已保存：{args.output}')
if __name__=='__main__':main()
