# 可复现的本地小样例

这些 JSON 是当前上传源码生成的输入、求解或本地模拟记录，用于学习代码状态和核对时间分解，**不是官方演练或正式成绩**。运行环境：Python 3.12.14；源程序位于 ../source/Q1–Q4；命令中的输出路径可自行修改。

从仓库根目录运行 Q1、Q2：

    python source/Q1/q1_generator.py --seed 20260929 --output examples/q1_seed_20260929_input.json
    python source/Q1/q1_solver.py --input examples/q1_seed_20260929_input.json --output examples/q1_seed_20260929_result.json
    python source/Q2/q2_generator.py --seed 20260929 --output examples/q2_seed_20260929_input.json
    python source/Q2/q2_solver.py --input examples/q2_seed_20260929_input.json --output examples/q2_seed_20260929_quick_result.json --quick

Q1 为 6 顶点有界多边形，直径 44.458564 m、面积 773.517257 m²，该案例的直径圆覆盖为 true；这不意味着所有案例都覆盖。Q2 在缩短采样的 --quick 模式下比较 600、700、800、900、1000 m 基线；本例直径目标与最小包围圆目标恰好选择同一个第二站 $(-1145.108945,-213.282190)$ m，所评读数中的最坏包围圆半径约 55.819929 m、直径约 111.639857 m。两方案在这一局同点，不能据此宣称一种方法优于另一种；也没有 20 m 清除证书。

从仓库根目录执行：

    cd source/Q3
    python q3_local_simulator.py --loops 3 --seed 20260929 --output ../../examples/q3_seed_20260929_3cases.json

返回根目录后执行：

    cd source/Q4
    python q4_local_simulator.py --loops 3 --seed 20260929 --output ../../examples/q4_seed_20260929_3cases.json

| 本地三局 | 清除 | 平均每局虚拟时间 | 逐局等权平均每源时间 | 平均每局移动 / 检测 / 换台 / 清除时间 |
| --- | --- | ---: | ---: | --- |
| Q3 | 3/3 局全清除 | 3856.07 s | 275.03 s | 2990.73 / 668.33 / 125.33 / 71.67 s |
| Q4 | 3/3 局全清除 | 7423.56 s | 526.02 s | 5794.23 / 1323.33 / 234.33 / 71.67 s |

同一个基种子由模拟器内部生成每局种子，JSON 的 cases[i].seed 才是对应单局的实际随机种子。第一局两问都生成 15 个源；Q4 有 4 个定向源。Q3 第一局的搜索证书为 disk_union，访问了 9 个覆盖点；Q4 第一局访问 25 个覆盖点，最多 2 轮成对探测。先在 JSON 中找 cases[0].solver，再沿 Strategy.run → _scan/_scan_site → _observe → _service 追踪。

样本只有三局，只适合学习调用流程和结果结构；不能从 3/3 推断广泛成功率或正式测试表现。源码行为和结果记录已放在同一个仓库，重新运行覆盖这些输出时请先自行备份。
