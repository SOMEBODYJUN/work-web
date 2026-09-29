#let sect = sym.inter
#let diff = sym.partial
// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = [
  #line(start: (25%,0%), end: (75%,0%))
]

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]
#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

#let conf(
  title: none,
  authors: none,
  date: none,
  abstract: none,
  cols: 1,
  margin: (x: 20mm, y: 18mm),
  paper: "a4",
  lang: "zh",
  region: "CN",
  font: (),
  fontsize: 10.5pt,
  sectionnumbering: none,
  doc,
) = {
  set page(
    paper: paper,
    margin: margin,
    numbering: "1",
  )
  set par(justify: true)
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)
  set heading(numbering: sectionnumbering)

  if title != none {
    align(center)[#block(inset: 2em)[
      #text(weight: "bold", size: 1.5em)[#title]
    ]]
  }

  if authors != none {
    let count = authors.len()
    let ncols = calc.min(count, 3)
    grid(
      columns: (1fr,) * ncols,
      row-gutter: 1.5em,
      ..authors.map(author =>
          align(center)[
            #author.name \
            #author.affiliation \
            #author.email
          ]
      )
    )
  }

  if date != none {
    align(center)[#block(inset: 1em)[
      #date
    ]]
  }

  if abstract != none {
    block(inset: 2em)[
    #text(weight: "semibold")[Abstract] #h(1em) #abstract
    ]
  }

  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}
#show: doc => conf(
  title: [无线电干扰源定位与清除：七天答辩教材],
  lang: "zh",
  region: "CN",
  font: ("Noto Sans SC",),
  cols: 1,
  doc,
)

#outline(
  title: auto,
  depth: 1
);

#pagebreak()
= 无线电干扰源定位与清除：七天精读导论
<无线电干扰源定位与清除七天精读导论>
#blockquote[
读者定位：知道高中三角函数和 Python
基本语法，尚未学过计算几何与鲁棒优化的参赛队员。每天 5 小时，共 35
小时。目标是能从题设推到算法，从公式指到源码，从源码走回物理意义。
]

== 怎样用这本书
<怎样用这本书>
先读第 01 章的一般问题与有出处的教材例题，再读第 02–04
章的本题推导。每问坚持四步：①把观测写成仍可能是真值的位置集合；②写出下一动作如何更新集合与时间；③分清数学保证与参数试跑；④打开第
05 章和相应源码，用输入、变量及返回值复述算法。第 06 章用于闭卷追问。

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [章节], [学习目标], [对应代码],
  [01 通用方法与教材例题],
  [角度约束、凸集、半平面交、旋转卡壳、最小包围圆、极小极大、覆盖、路线与在线决策],
  [四问共同基础],
  [02 Q1/Q2 从角楔到选址],
  [求区域直径、辨析直径圆与包围圆、选择安全的第二测点],
  [source/Q1、source/Q2],
  [03 Q3 全向源搜索定位清除],
  [发现未知频道全部源，更新可能集，安排移动并安全清除],
  [source/Q3],
  [04 Q4 定向盲区与成对探测],
  [定向源下的覆盖、负反馈含义、成对排除与清除],
  [source/Q4],
  [05 源码地图与逐段精读],
  [每个函数及关键分支的参数、状态、公式与调用链],
  [全部 Python],
  [06 答辩追问与推导演练],
  [回答“为什么、在哪里、保证是什么、何时失效”],
  [现场练习],
)
]

== 一张总图：四问各解决什么
<一张总图四问各解决什么>
原题（本轮上传的 B题.pdf，第 1–4 页）给出圆形目标域半径 1800 m、示向误差
±1°、有效接收半径 1000–1500 m、清除距离 20 m。全向源辐射
360°，定向源只在其定向方向两侧各 90°内辐射。频道 1–20
且各源频道互异；移动 5 m/s，换台 1 s，检测 5 s，光学定位 3 s，清除 2
s。同一地点重复测量误差固定，不能靠重复平均消除。

#align(center)[#table(
  columns: 4,
  align: (col, row) => (auto,auto,auto,auto,).at(col),
  inset: 6pt,
  [问题], [给定与目标], [本程序做法], [结论等级],
  [Q1],
  [多站坐标和同源示向度，求定位区域直径与直径圆覆盖性],
  [角楔交、凸多边形直径、圆包含判定],
  [几何计算],
  [Q2],
  [一次全向源示向度，求安全第二站与较好定位],
  [首测可行域、安全接收域、最坏读数下的最小包围圆数值比较],
  [安全条件可论证，选优是数值近似],
  [Q3],
  [10–16 个未知全向源，全找齐全清除并缩短时间],
  [覆盖停靠点、20 频道检测、集合定位、清除证书、任务调度],
  [覆盖与安全分别论证，效率靠试跑],
  [Q4],
  [全向、定向混合，定向方向未知],
  [双圈覆盖、正锚点成对探测、谨慎处理负反馈],
  [无信号推理比 Q3 更受限],
)
]

#strong[不要混淆几个圆。]1800 m 是源位置域；1000–1500 m 是接收范围；20 m
是光学清除范围；Q1
的“以直径为直径的圆”是待检验的几何对象；最小包围圆用于给剩余可能位置的最远距离提供上界。

== 证明、近似与经验要分别表述
<证明近似与经验要分别表述>
+ #strong[题设和不变量。]真实位置在目标域；有效测向的误差有界；正确构造的候选集必须始终保留真值。覆盖和清除各有自己的前提。
+ #strong[数值计算。]Q2
  在连续位置和连续可能读数上使用有限网格、局部细化；已搜索点的最优结果不自动成为全域最优证明。
+ #strong[策略参数。]Q3/Q4
  的停靠点、侧移阈值与访问顺序有几何动机和本地测试比较；"跑得快"不是普遍最优定理。
+ #strong[证据口径。]本地模拟结果可由上传程序与种子再现；正式成绩需要官方模拟器日志。答辩时说清是哪种证据。

== 七天、每天五小时
<七天每天五小时>
每天固定节奏：90 分钟读一般方法 → 90 分钟纸笔推例题 → 60
分钟追踪源码并运行 → 30 分钟无稿口述 → 30
分钟做题和记录卡点。遇到任意代码行，先说变量单位与不变量，再说它怎样改变状态。

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [天], [方法和一般例题], [本题、代码与闭卷验收],
  [1],
  [坐标、atan2、角度回绕、半平面与凸集],
  [从 ±1° 推角楔与多站交；固定种子运行 Q1；能画图说明为何不误删真值],
  [2],
  [凸多边形直径、旋转卡壳、最小包围圆与极小极大],
  [直径圆反例；Q2 首站可行域、安全域、最坏读数；能辨析直径 D
  与包围圆半径 R],
  [3],
  [圆盘覆盖、集合成员定位、TSP 与最近邻启发式],
  [Q3 "发现全部"与“可清除”的两个条件；跟踪检测反馈到集合更新],
  [4],
  [主动感知、任务插入、鲁棒裕量与协议重试],
  [Q3 九点布置、19.8 m 证书；阅读正式客户端和同一 request\_id 重试],
  [5],
  [定向半平面、缺失观测逻辑、反例法],
  [Q4 25 点覆盖与成对观测；给出单次无信号不能排除源的反例],
  [6],
  [复盘薄弱处、随机抽第 06 章问题],
  [不看提示运行四问；练 5 分钟和 8 分钟讲述，分清证明与实验],
  [7],
  [重做错题，不扩充新内容],
  [屏幕共享模拟答辩；随机指源码说输入、公式、理由、局限],
)
]

每晚写一张
A4：左栏公式与前提，中栏函数与文件，右栏反例或局限。次日先凭记忆重建，再查原文。记忆顺序是“事实→推导→代码→反例”。

== 评委指向代码时的六句框架
<评委指向代码时的六句框架>
+ #strong[输入与单位。]位置用米；角度在哪一步从度转为弧度；频道范围是什么。
+ #strong[目标集合或指标。]写出约束，指出初始可能集与返回值。
+ #strong[为何正确。]真值是否仍在集合里；近似发生在何处。
+ #strong[为何选择。]与一个标准教材方法比较前提、复杂度和保证。
+ #strong[代码位置。]文件、函数、关键变量，以及下游怎样使用它。
+ #strong[局限。]退化位置、读数量化、无信号多义、计算时间和全局最优性。

示例："这里输入两个测站位置与示向度。每次读数有 ±1°
误差，真实点落在两条边界射线间；代码把角楔表示成半平面并求交。区域直径是
Q1 的指标；Q2 另外比较最小包围圆半径。保持真值的约束可以论证，Q2
的数值选址不能宣称全局最优。"正式回答时必须再指出实际函数与代码行。

本书是理解与演练材料，不替代原题、论文或官方接口文档。所有公式应能追到前提，所有实验值应带运行条件。

#pagebreak()
= 第 1 章　通用方法与教材例题
<第-1-章-通用方法与教材例题>
#blockquote[
本章把“一个示向度”"一个定位多边形""一条搜索路线"变成能推导、能核验、能与代码对应的数学对象。

公开例题均注明教材节号、例号或原论文图号，解说重新撰写。原文没有公布坐标的示意例，只作符号推演。将同一教材数据用于新的算法计算时，明确标为“延伸计算”。练习围绕原有数据、定理证明和上传代码，不把虚构模拟结果充作教材例题。
]

== 1.0　先建立一张概念地图
<先建立一张概念地图>
本题有三种不同的“未知”：干扰源在哪里、下一次会报告什么、还有哪些干扰源没有发现。三者分别对应#strong[集合估计、鲁棒决策、完整搜索]。把它们都叫作“优化”，容易漏掉各自的证明义务。

#align(center)[#table(
  columns: 4,
  align: (col, row) => (auto,auto,auto,auto,).at(col),
  inset: 6pt,
  [数学对象], [要回答的问题], [必须核验的条件], [上传代码中的入口],
  [角误差楔形],
  [一个示向度允许哪些位置？],
  [角度方向、误差上界、正向射线],
  [Q1 `_wedge`；Q2 `clip_wedge`],
  [半平面交],
  [多个允许集合如何取交？],
  [空、无界、退化、浮点容差],
  [Q1 `intersect_halfplanes`],
  [凸多边形直径],
  [两个可能位置最远相隔多少？],
  [顶点有序、凸性、平行边],
  [Q1 `polygon_diameter`],
  [最小包围圆],
  [哪个行动点离所有可能位置都尽量近？],
  [全部顶点在圆内],
  [Q2 `minimum_enclosing_circle`；Q3/Q4 `mec`],
  [极小极大目标],
  [选站后最不利的报告会有多差？],
  [报告可实现、量词顺序、连续域],
  [Q2 `robust_quality`],
  [集合成员估计],
  [新读数怎样排除不可能状态？],
  [每次更新仍包含真实状态],
  [Q3 `bearing_update`、`exclude_disk_hull`；Q4 `direction_update`],
  [覆盖与在线路径],
  [怎样确认没有遗漏，并少走路？],
  [空间与频道均已覆盖；终止证据],
  [Q3 `covers_arena`、`Strategy`；Q4 `coverage_route`、`Strategy`],
)
]

建议前置知识只有五项：二维坐标、三角函数、联立一次方程、集合交并、Python
的列表与循环。其余知识在下文逐步建立。

=== 统一符号
<统一符号>
- $G eq lr((x comma y))$：未知干扰源位置；$S_i eq lr((s_(i x) comma s_(i y)))$：已知检测点。
- $theta_i$：报告示向度；$beta_i eq "atan2" lr((y minus s_(i y) comma x minus s_(i x)))$：真实方位。
- $delta$：角误差半宽。推导时用弧度；题目物理上界为
  $1^compose eq pi slash 180$。
- $Omega eq brace.l G colon parallel G parallel_2 lt.eq 1800 brace.r$：目标所在圆域；这不是题目给机器狗设置的运动边界。
- $F$：精确可行位置集合；$P$：代码保存的凸多边形，通常要求
  $F subset.eq P$。
- $D lr((P))$、$R lr((P))$、$A lr((P))$：直径、最小包围圆半径、面积，单位分别为米、米、平方米。
- $B lr((c comma r)) eq brace.l x colon parallel x minus c parallel_2 lt.eq r brace.r$：闭圆盘。讨论覆盖需要圆盘内部，不能只看圆周。

#horizontalrule

== 1.1　角误差几何：为什么一条示向线要变成一个楔形
<角误差几何为什么一条示向线要变成一个楔形>
=== 1.1.1　先修与问题
<先修与问题>
#strong[先修：]正弦、余弦、二维向量。初学者首先应能回答：以正东为零度、逆时针增加时，$90^compose$
指向哪里？答案是正北。

题目附录 2 给出的是有界误差，而且同一地点的误差在一段时间内固定。因此

$ lr(|"wrap"_(paren.l minus pi comma pi bracket.r) lr((beta_i minus theta_i))|) lt.eq delta $

表示“真实方位属于一个区间”，没有给出区间内的概率密度。原地重复 $k$
次测量，不能据此把误差上界改成 $delta slash sqrt(k)$。

不要用普通差值判断跨越零度的角度：靠近 $0^compose$
的两条方向可以很近，数值表示却处在 $0$ 和 $360$
的两端。下面的向量写法直接处理这种周期性。

=== 1.1.2　从左右关系推导两个半平面
<从左右关系推导两个半平面>
定义方向向量与二维叉积：

$ u lr((alpha)) eq lr((cos alpha comma sin alpha)) comma #h(2em) "cross" lr((a comma b)) eq a_x b_y minus a_y b_x dot.basic $

叉积大于零表示从 $a$ 转到 $b$ 的局部方向为逆时针。令

$ u_minus eq u lr((theta minus delta)) comma quad u_plus eq u lr((theta plus delta)) comma quad v eq G minus S dot.basic $

当 $0 lt delta lt pi slash 2$ 时，正确的前向楔形为

$ W lr((S comma theta)) eq brace.l G colon "cross" lr((u_minus comma v)) gt.eq 0 comma med "cross" lr((u_plus comma v)) lt.eq 0 brace.r dot.basic $

第一个约束说 $G$
在下边界的左侧，第二个说它在上边界的右侧。展开叉积，得到代码需要的法向量形式：

$ n_minus & eq lr((sin lr((theta minus delta)) comma minus cos lr((theta minus delta)))) comma\
n_plus & eq lr((minus sin lr((theta plus delta)) comma cos lr((theta plus delta)))) comma\
n_minus dot.op G & lt.eq n_minus dot.op S comma #h(2em) n_plus dot.op G lt.eq n_plus dot.op S dot.basic $

这是 Q1 `_wedge` 和 Q2 `clip_wedge`
的核心。#strong[核对符号的方法]是代入
$G eq S plus u lr((theta))$：它应同时满足两个不等式。再代入反向点
$S minus u lr((theta))$：当 $delta gt 0$ 时它应被排除。

如果 $delta eq 0$，两个不等式只剩一条完整直线。Q1 额外加入

$ minus u lr((theta)) dot.op G lt.eq minus u lr((theta)) dot.op S comma $

即
$u lr((theta)) dot.op lr((G minus S)) gt.eq 0$，把直线限制为射线。退化输入不能只按一般情形机械代入。

=== 1.1.3　误差为什么随距离增大
<误差为什么随距离增大>
在沿报告方向、垂直报告方向的局部坐标中，令

$ a eq u lr((theta)) dot.op lr((G minus S)) comma #h(2em) b eq lr((minus sin theta comma cos theta)) dot.op lr((G minus S)) dot.basic $

楔形也可写成

$ a gt.eq 0 comma #h(2em) lr(|b|) lt.eq a tan delta dot.basic $

在纵向距离 $a$ 处，横向全宽是
$2 a tan delta$。角度误差固定，不等于位置误差固定。使用题目参数，$a eq 1000$
米时全宽约 $34.91$ 米，$a eq 1500$ 米时约 $52.37$
米。这些是几何计算，不是模拟器成绩。

=== 1.1.4　交会角与病态性：一个局部诊断式
<交会角与病态性一个局部诊断式>
设 $r_i eq parallel G minus S_i parallel$，真实方向的单位法向量为
$n_i eq lr((minus sin beta_i comma cos beta_i))$。对方位函数求导：

$ nabla_G beta_i eq n_i / r_i comma #h(2em) Delta beta_i approx frac(n_i dot.op Delta G, r_i) dot.basic $

两站时局部误差集合近似为

$ lr(|n_1 dot.op Delta G|) lt.eq r_1 delta comma #h(2em) lr(|n_2 dot.op Delta G|) lt.eq r_2 delta dot.basic $

把两行法向量组成矩阵 $N$，有

$ lr(|det N|) eq lr(|sin lr((beta_2 minus beta_1))|) dot.basic $

由线性变换的面积公式，局部平行四边形面积近似为

$ A_(upright(l o c a l)) approx frac(4 r_1 r_2 delta^2, lr(|sin lr((beta_2 minus beta_1))|)) dot.basic $

这解释了为什么接近平行或反平行的观测方向会产生细长定位区域。但它是局部线性化结果，不能独自决定第二站：真位置未知、接收半径未知、行走需要时间，候选点还必须能收到信号。

=== 1.1.5　公开教材例题：两雷达站测飞机高度
<公开教材例题两雷达站测飞机高度>
#strong[来源：]OpenStax《Precalculus 2e》§8.1，Example 6 "Finding an
Altitude"，Figure 16。两站相距 20 英里，两底角为
$15^compose$、$35^compose$。#footnote[OpenStax, #emph[Precalculus 2e],
§8.1 "Non-right Triangles: Law of Sines", Example 6 "Finding an
Altitude", Figure
16；#link("https://openstax.org/books/precalculus-2e/pages/8-1-non-right-triangles-law-of-sines")[官方在线教材]。采用原例
20 英里、15°、35°，独立重算。]

顶角为 $130^compose$。取 $15^compose$ 端到飞机的距离为 $a$，它对着
$35^compose$，故

$ a eq frac(20 sin 35^compose, sin 130^compose) comma #h(2em) h eq a sin 15^compose eq frac(20 sin 35^compose sin 15^compose, sin 130^compose) approx 3.8758 upright(" 英里") dot.basic $

原书按一位小数给出 $3.9$
英里。重算时先确定“哪个角对哪条边”，再求高度，避免把方位角与三角形内角混用。

#strong[迁移到 B 题：]教材把角度视为精确值，得到一个点；B
题把角度扩成允许区间，得到一片区域。飞机例题为竖直剖面，B
题为水平平面，三角几何可迁移，坐标含义须重新定义。

=== 1.1.6　适用范围、练习与答案
<适用范围练习与答案>
#strong[适用范围：]平面模型、方位读数有已知硬上界、$delta lt 90^compose$。原题的“示向度缺失但已很近”应按
`near` 单独处理；在 $G eq S$ 处方位函数没有定义。

#strong[练习 A：]设 $theta eq 0$，把两个半平面化成局部形式。

#strong[答案：]$minus a tan delta lt.eq b lt.eq a tan delta$。两式相加隐含
$a gt.eq 0$；$delta eq 0$ 时不再隐含，需补正向约束。

#strong[练习 B：]飞机题能否把 $35^compose minus 15^compose$ 当作顶角？

#strong[答案：]不能。两站朝向飞机的水平参照方向相反，顶角为
$180^compose minus 35^compose minus 15^compose eq 130^compose$。

#strong[练习 C：]Q3/Q4 的 `DELTA` 为什么是 `radians(1.0051)`？

#strong[答案：]三角函数使用弧度。代码注释区分了 $1^compose$
物理误差、$0.005^compose$ 输出舍入裕量与 $0.0001^compose$
数值裕量；实现裕量不是题目修改了物理误差。

#horizontalrule

== 1.2　半平面交：从“满足全部读数”到凸多边形
<半平面交从满足全部读数到凸多边形>
=== 1.2.1　先修、定义与凸性证明
<先修定义与凸性证明>
#strong[先修：]一次不等式、集合交、两直线求交。

闭半平面写作

$ H_i eq brace.l x in bb(R)^2 colon a_i^T x lt.eq b_i brace.r comma #h(2em) a_i eq.not 0 dot.basic $

若 $x comma y in H_i$，对任意 $t in lr([0 comma 1])$，

$ a_i^T lr((t x plus lr((1 minus t)) y)) eq t a_i^T x plus lr((1 minus t)) a_i^T y lt.eq b_i dot.basic $

所以 $H_i$ 是凸集，交集 $P eq sect.big_i H_i$
仍为凸集。多个测向楔形取交，只需把每个楔形的两个约束放进同一个约束表。

"凸"表示连接任意两个集合内点的线段仍在集合内，不表示集合一定有面积。空集、点、线段、无界楔形都可能出现。

=== 1.2.2　两直线交点与平行处理
<两直线交点与平行处理>
设边界为 $a_x x plus a_y y eq c_a$、$b_x x plus b_y y eq c_b$，令
$Delta eq a_x b_y minus a_y b_x$。当 $Delta eq.not 0$，

$ x eq frac(c_a b_y minus a_y c_b, Delta) comma #h(2em) y eq frac(a_x c_b minus c_a b_x, Delta) dot.basic $

当 $Delta$
很小，交点对系数扰动敏感；把分母改成一个很小的常数会制造不存在的顶点。Q1
`_intersection` 对近乎平行的边界返回 `None`，由外层继续分类。

Q1 先将法向量归一化。这样同向平行约束中，较小 `offset`
更严格。若不归一化，不能仅比较右端数值：同一约束乘以不同正数，右端也会改变。

=== 1.2.3　两种算法分别适合什么场景
<两种算法分别适合什么场景>
#strong[逐条裁剪。]已有有界凸多边形时，沿每条边 $A arrow.r B$
检查新约束。记
$f lr((A)) eq n dot.op A minus b$、$f lr((B)) eq n dot.op B minus b$。若两端在不同侧，交点为

$ I eq A plus t lr((B minus A)) comma #h(2em) t eq frac(f lr((A)), f lr((A)) minus f lr((B))) dot.basic $

按边的顺序输出保留端点与交点，得到新多边形。Q2 `clip_halfplane`、Q3/Q4
`clip` 使用此思想。每加一个约束，时间与当前顶点数成正比。

#strong[方向排序与双端队列。]直接输入许多半平面时，Q1
的主体先按边界方向排序，维护仍可能成为最终边界的约束。新半平面使队尾相邻边界交点失效时，弹出队尾；队首也作对应检查。最后闭合首尾。

被删除的是“在当前方向顺序与已有约束下，已不能贡献交集边界”的半平面。算法依赖排序和凸性，不能省略方向顺序后照搬弹出规则。

理论上，标准方向排序为 $O lr((m log m))$，队列维护为
$O lr((m))$。#strong[上传 Q1
的总运行复杂度不应直接写成这一句]：它还逐顶点核验所有原约束，可能花
$O lr((m h))$；异常分支 `_feasible_point` 最坏需 $O lr((m^2))$，其中 $h$
为输出顶点数。

=== 1.2.4　为什么必须区分空与无界
<为什么必须区分空与无界>
没有任何可行点时是
`empty`。存在可行点，但能沿某非零方向一直走而不违反约束时，是
`unbounded`。

定义衰退方向集合

$ K eq brace.l d colon a_i^T d lt.eq 0 comma med i eq 1 comma dots.h comma m brace.r dot.basic $

若 $P eq.not diameter$，则 $P$ 有界当且仅当
$K eq brace.l 0 brace.r$。因为 $x in P comma d in K$
时，$x plus t d in P$ 对所有 $t gt.eq 0$
成立；反向结论可由无界可行点序列归一化得到衰退方向。

Q1 `_is_bounded`
使用二维法向量的角度间隙检查。浮点计算无法可靠分类时，代码允许返回
`uncertain`，没有把所有数值失败都误报为空集。

上传 Q1 没有自动添加半径 1800
米的场地约束，某组示向度可返回无界结果。Q2–Q4
为行动推理加入了场地与范围外近似。输入语义不同，不能混为一谈。

=== 1.2.5　公开教材例题：围巾与毛衣的可行域
<公开教材例题围巾与毛衣的可行域>
#strong[来源：]OpenStax《Contemporary Mathematics》§5.11，Example
5.100，Figures 5.99–5.100。每天至多 8 件、27 袋毛线；围巾每件用 3
袋、利润 8，毛衣每件用 4 袋、利润 10。#footnote[OpenStax,
#emph[Contemporary Mathematics], §5.11 "Linear Programming", Example
5.100 "Solving a Linear Programming Problem for Two Products", Figures
5.99–5.100；#link("https://openstax.org/books/contemporary-mathematics/pages/5-11-linear-programming")[官方在线教材]。§1.3
对同一可行域作直径延伸计算。]

设数量为 $x comma y$，则

$ x gt.eq 0 comma med y gt.eq 0 comma med x plus y lt.eq 8 comma med 3 x plus 4 y lt.eq 27 dot.basic $

两斜边相交时，第二式减去第一式的 3 倍，得
$y eq 3 comma x eq 5$。可行域顶点为

$ lr((0 comma 0)) comma med lr((8 comma 0)) comma med lr((5 comma 3)) comma med lr((0 comma 27 slash 4)) dot.basic $

利润 $8 x plus 10 y$ 分别为 $0 comma 64 comma 70 comma 67.5$，最优点为
$lr((5 comma 3))$，且满足整数数量要求。

#strong[迁移到 B
题：]本例四条约束如何共同定义凸多边形，就是半平面交。定位不需要枚举区域内的每个位置。

=== 1.2.6　适用范围、练习与答案
<适用范围练习与答案-1>
#strong[局限：]圆盘不是有限半平面的精确交。圆的切线多边形扩大圆盘，圆周点凸包缩小圆盘，保证方向相反。

#strong[练习 A：]教材例的 $lr((0 comma 8))$ 为什么不可行？

#strong[答案：]需要 $4 times 8 eq 32 gt 27$
袋毛线。候选交点必须检查全部约束。

#strong[练习 B：]只保留 $x gt.eq 0 comma y gt.eq 0$ 应报告什么？

#strong[答案：]非空但无界。不能只找到 $lr((0 comma 0))$ 就误判为单点。

#strong[练习 C：]将教材约束写成 Q1 的 ((a,b),c) 格式。

#strong[答案：] ((-1,0),0)、((0,-1),0)、((1,1),8)、((3,4),27)，可交给
`intersect_halfplanes` 核验手算。

#horizontalrule

== 1.3　凸多边形直径与旋转卡壳
<凸多边形直径与旋转卡壳>
=== 1.3.1　先修与直径的含义
<先修与直径的含义>
#strong[先修：]凸组合、叉积、循环下标。名称写作#strong[旋转卡壳]，英文为
rotating calipers。

非空紧集的直径为

$ D lr((P)) eq max_(x comma y in P) parallel x minus y parallel_2 dot.basic $

它度量两个可能位置最多相差多远，没有指定行动中心，也未声称半径
$D slash 2$ 能覆盖集合。

=== 1.3.2　定理：只需检查顶点对
<定理只需检查顶点对>
设 $P eq "conv" brace.l v_1 comma dots.h comma v_h brace.r$。任意

$ x eq sum_i alpha_i v_i comma #h(2em) y eq sum_j beta_j v_j comma $

其中系数非负且各自和为 1。于是

$ parallel x minus y parallel eq ∥sum_(i comma j) alpha_i beta_j lr((v_i minus v_j))∥ lt.eq sum_(i comma j) alpha_i beta_j parallel v_i minus v_j parallel lt.eq max_(i comma j) parallel v_i minus v_j parallel dot.basic $

顶点本来就在 $P$ 中，所以等号可达，直径就是最远顶点对距离。先理解
$O lr((h^2))$ 的全部点对检查，再学习加速算法。

=== 1.3.3　从支撑线到对踵点
<从支撑线到对踵点>
直线接触凸多边形，且多边形全在它的一侧，就叫支撑线。两个顶点分别被一对平行支撑线接触，形成对踵点对。

直径点对必为对踵点。设最远点对为 $a comma b$，令
$u eq lr((b minus a)) slash parallel b minus a parallel$。若存在
$x in P$ 使 $u dot.op x lt u dot.op a$，则

$ parallel b minus x parallel gt.eq u dot.op lr((b minus x)) gt u dot.op lr((b minus a)) eq parallel b minus a parallel comma $

与最远性矛盾；另一侧同理。所以经过 $a comma b$、垂直于 $u$
的两条线是支撑线。

=== 1.3.4　面积比较为什么能让指针只前进
<面积比较为什么能让指针只前进>
对逆时针凸多边形的边 $v_i arrow.r v_(i plus 1)$，令

$ A_i lr((j)) eq "cross" lr((v_(i plus 1) minus v_i comma v_j minus v_i)) dot.basic $

这是三角形面积的两倍，也等于底长乘以点到边界直线的距离。最大化它就是找对侧支撑点。

底边沿凸多边形转动时，对侧支撑点只沿相同方向前进，无需回头。因此保存指针
$j$，只要 $A_i lr((j plus 1)) gt A_i lr((j))$
就前进。总推进量为线性级别。

教学版框架：

```
输入：逆时针、去掉连续共线冗余点的凸多边形
j = 1
对每条边 i -> i+1：
    当 A_i(j+1) > A_i(j)：j 前进
    检查 (v_i, v_j)、(v_{i+1}, v_j) 的距离
    若面积相等：同时检查下一支撑顶点的相关点对
返回最大距离
```

平行边产生相等面积平台，不能假定最大点唯一。上传 Q1
通过严格递增、检查边两端及整圈遍历处理候选；改写时应特别关注并列支撑事件。

理论核心在有序凸多边形上为 $O lr((h))$。Q1 `polygon_diameter` 先调用
`_convex_hull` 清洗输入，因此该函数还包含 $O lr((h log h))$
凸包排序成本。

=== 1.3.5　原论文示例：支撑线下一次先碰到哪条边
<原论文示例支撑线下一次先碰到哪条边>
#strong[来源：]Toussaint，#emph[Solving Geometric Problems with the
Rotating Calipers]，1983，§1，pp.1–2，Figure 1。原图有顶点
$p_i comma p_j$ 及相邻边，没有数值坐标。#footnote[Godfried T. Toussaint,
"Solving Geometric Problems with the Rotating Calipers", Proceedings of
IEEE MELECON’83, Athens, May 1983, §1, pp.1–2, Figure
1；#link("https://web.cs.swarthmore.edu/~adanner/cs97/s08/pdf/calipers.pdf")[大学课程保存的原论文 PDF]；#link("https://www-cgrl.cs.mcgill.ca/~godfried/research/calipers.html")[作者页面]。原文采用顺时针顶点与右侧约定，代码采用逆时针/左侧约定，符号相应调整。]

两端支撑线到下一条边的转角为 $theta_i comma theta_j$。若
$theta_j lt theta_i$，事件先在 $j$ 端发生，新候选为
$lr((p_i comma p_(j plus 1)))$。若转角相等，两端同时接触新边，应考虑
$lr((p_i comma p_(j plus 1)))$、$lr((p_(i plus 1) comma p_j))$、$lr((p_(i plus 1) comma p_(j plus 1)))$。

原例解释的是事件推进，没有给某个数值直径。上传代码用叉积面积比较代替显式求转角。

=== 1.3.6　适用范围、练习与答案
<适用范围练习与答案-2>
#strong[局限：]线性扫描依赖凸性与顶点顺序。无序点云或凹多边形先求凸包，因为取凸包不改变直径；空集、单点、两点分别处理。

#strong[练习 A：]用 §1.2 的教材顶点计算直径。

#strong[答案：]比较六对距离，最远为 $lr((8 comma 0))$ 与
$lr((0 comma 27 slash 4))$，

$ D eq sqrt(8^2 plus lr((27 slash 4))^2) eq sqrt(1753) / 4 approx 10.4672 dot.basic $

这是对已注明来源的数据作延伸计算。

#strong[练习 B：]为什么比较平方距离即可？

#strong[答案：]平方根在非负数上单调；循环内最大化平方距离，最后只开方一次。

#strong[练习 C：]每条边都把 $j$ 重设为 0，会怎样？

#strong[答案：]失去指针单调前进带来的总量界，可能退回
$O lr((h^2))$。正确性可能仍在，线性效率不再成立。

#horizontalrule

== 1.4　最小包围圆：把定位不确定性变成清除保证
<最小包围圆把定位不确定性变成清除保证>
=== 1.4.1　先修与定义
<先修与定义>
#strong[先修：]距离、圆、垂直平分线、凸集。

最小包围圆问题为

$ R lr((P)) eq min_(c in bb(R)^2) max_(x in P) parallel x minus c parallel_2 dot.basic $

这里有两层选择：先选中心
$c$，再考察集合中离它最远的位置。对凸多边形，只需在顶点上取最大值，证明与前节的凸组合论证相同。等价优化式为

$ min_(c comma r) r quad upright("s.t.") quad parallel v_i minus c parallel_2 lt.eq r quad forall i dot.basic $

它与“在多边形内部放一个最大的圆”不同。部分凸优化教材把最大内切球中心称为
Chebyshev
center，部分集合估计文献则用相同术语指最坏距离中心。报告中优先给出优化式，避免名称歧义。

=== 1.4.2　为什么最多三个点就能决定最小圆
<为什么最多三个点就能决定最小圆>
决定圆的边界点称为支撑点：

+ 只有一个不同点时，半径为 0。
+ 两点支撑时，它们必须是直径端点，否则沿垂直平分线移动圆心可以缩小半径。
+ 三个不共线点支撑时，圆心为两条垂直平分线的交点，即三点外接圆圆心。

为何不需要四点？最优圆心必须处于最远边界点的凸包内，否则可找到一个方向同时靠近所有最远点，稍微移动圆心就能减小最大距离。平面凸包可剖分为三角形，圆心位于其中某个三角形或其边上，因此最多三个边界点就可支撑该中心。圆周上仍然可以有更多点。

对三个点：若为直角或钝角三角形，最长边的直径圆覆盖第三点；若为锐角三角形，则需要外接圆。外接圆公式的分母含叉积，近乎共线时必须单独处理。

#strong[唯一性也有直观证明。]若有两个不同圆心
$c_1 comma c_2$，都以同一最小半径 $r$ 包住全部点，取中点
$m$，由平方距离恒等式，

$ parallel x minus m parallel^2 eq 1 / 2 parallel x minus c_1 parallel^2 plus 1 / 2 parallel x minus c_2 parallel^2 minus 1 / 4 parallel c_1 minus c_2 parallel^2 lt.eq r^2 minus 1 / 4 parallel c_1 minus c_2 parallel^2 lt r^2 dot.basic $

于是以 $m$ 为圆心可取得更小包围圆，矛盾。

=== 1.4.3　直径的一半为什么不够
<直径的一半为什么不够>
任意包围圆包含最远点对，因此

$ D lr((P)) lt.eq 2 R lr((P)) comma #h(2em) R lr((P)) gt.eq D lr((P)) slash 2 dot.basic $

取边长为 $a$ 的等边三角形作为几何反例：直径为
$a$，边中点到第三顶点的距离为
$sqrt(3) a slash 2 gt a slash 2$，所以以任意边为直径的圆不能覆盖三角形。最小包围圆半径为
$a slash sqrt(3)$，也说明别的圆心不能让半径降到 $a slash 2$。

平面上更强的关系为

$ frac(D lr((P)), 2) lt.eq R lr((P)) lt.eq frac(D lr((P)), sqrt(3)) dot.basic $

上界可以从支撑点推出：两点支撑时已有
$R eq D slash 2$；三点支撑时，相邻中心角中至少有一个不小于
$120^compose$，且圆心在三角形内意味着这些间隙不超过
$180^compose$。相应弦长至少为 $sqrt(3) R$，故
$D gt.eq sqrt(3) R$。等边三角形达到上界。

=== 1.4.4　增量算法与最后的覆盖复核
<增量算法与最后的覆盖复核>
依次加入点。若新点在当前圆内，旧圆仍为新集合最小圆：新问题最优半径不能比旧问题更小，而旧圆又可行。若新点在圆外，它必须成为新最小圆的边界点，于是转为带一个强制边界点的子问题；再遇冲突，转为带两个强制边界点的子问题。

随机打乱次序可以得到经典期望线性时间分析。固定种子使程序可复现，但不把“对随机排列的期望界”变成“每个输入的最坏线性界”。Q2
与 Q3/Q4 使用不同固定种子，不影响几何问题定义。

上传代码末尾重新计算

$ r_(upright(a u d i t)) eq max_i parallel v_i minus c parallel plus epsilon dot.basic $

这一复核保证返回半径包住全部输入顶点，弥补浮点比较引起的半径偏小。它核验的是#strong[覆盖性]；若某次算法分支给出非最优中心，增大半径并不能证明中心仍最优。

=== 1.4.5　原论文示例：两个点被强制放在边界上
<原论文示例两个点被强制放在边界上>
#strong[来源：]Welzl，#emph[Smallest Enclosing Disks (Balls and
Ellipsoids)]，1991，§2，Figure 1，出版页 360、作者 PDF 第 2
页。图示一个或两个强制边界点的约束圆，没有提供坐标。#footnote[Emo Welzl,
"Smallest Enclosing Disks (Balls and Ellipsoids)", #emph[New Results and
New Trends in Computer Science], LNCS 555, 1991, pp.359–370；§2、Figure
1 在出版页 360、PDF 第 2
页；#link("https://people.inf.ethz.ch/emo/PublFiles/SmallEnclDisk_LNCS555_91.pdf")[作者 PDF]；#link("https://doi.org/10.1007/BFb0038202")[出版社 DOI]。本章的
$t$ 参数化为对原图两强制边界点情形的独立展开。]

对两边界点情形记为 $a comma b$，令
$m eq lr((a plus b)) slash 2$，取垂直于 $b minus a$ 的单位向量
$n$。所有经过两点的圆均可写成

$ c lr((t)) eq m plus t n comma #h(2em) r lr((t))^2 eq parallel a minus b parallel^2 slash 4 plus t^2 dot.basic $

#strong[本书对该符号情形的展开：]点 $p$ 在圆内等价于

$ parallel p minus m parallel^2 minus 2 t thin n dot.op lr((p minus m)) lt.eq parallel a minus b parallel^2 slash 4 dot.basic $

每个点给 $t$ 一个一次不等式；交集若非空，选其中离 0 最近的 $t$
就最小化半径。这解释了两个强制边界点出现后，圆心为何不再能在平面上任意移动。

=== 1.4.6　从包围圆到实际清除点
<从包围圆到实际清除点>
若已证明 $G in P subset.eq B lr((c comma r))$，对行动点 $q$，

$ parallel G minus q parallel lt.eq parallel G minus c parallel plus parallel c minus q parallel lt.eq r plus parallel c minus q parallel dot.basic $

所以只要

$ r plus parallel q minus c parallel lt.eq 20 comma $

就在光学清除范围内。用代码保守阈值 $rho eq 19.8$，可得到充分安全行动区
$B lr((c comma rho minus r))$。它不一定是全部安全清除点的完整集合，但容易证明和计算。

给定当前位置 $p$，此圆盘中离 $p$ 最近的点为

$ q eq cases(delim: "{", p comma & parallel p minus c parallel lt.eq rho minus r comma, c plus frac(rho minus r, parallel p minus c parallel) lr((p minus c)) comma & upright("否则") dot.basic) $

对应 Q3 `nearest_certified_clear`、Q4
`nearest_clear`。达到半径阈值后不必总走到圆心，这个投影直接节省路程。

=== 1.4.7　适用范围、练习与答案
<适用范围练习与答案-3>
#strong[局限：]清除保证依赖 $G in P$
始终成立。若集合更新删掉真位置，最小包围圆即使算得完全正确也无法挽救策略。

#strong[练习 A：]“$D lt.eq 40$ 米就能保证在某点清除”成立吗？

#strong[答案：]不成立。它是 $R lt.eq 20$
的必要条件；等边三角形表明直径足够小仍可能需要更大半径。直接验证
$R lt.eq 20$，或某个 $q$ 到全部顶点的最大距离不超过 20，才有证据。

#strong[练习 B：]为什么外近似多边形顶点全部在圆内，就保证真源在圆内？

#strong[答案：]圆盘是凸集，包含全部顶点便包含它们的凸包 $P$；再用
$G in F subset.eq P$。

#strong[练习 C：]两强制点公式中，若 $n dot.op lr((p minus m)) eq 0$ 呢？

#strong[答案：]约束与 $t$ 无关：若
$parallel p minus m parallel^2 lt.eq parallel a minus b parallel^2 slash 4$，总满足；否则任何经过
$a comma b$ 的圆都不能同时包含它，不能除以零。

#horizontalrule

== 1.5　鲁棒优化与极小极大：先选站，再面对未知报告
<鲁棒优化与极小极大先选站再面对未知报告>
=== 1.5.1　先修与量词顺序
<先修与量词顺序>
#strong[先修：]最大值、最小值、函数、自变量与参数。

通用鲁棒设计问题为

$ min_(s in cal(S)) sup_(xi in cal(U) lr((s))) L lr((s comma xi)) dot.basic $

- $s$：现在要做的选择，例如第二个检测点。
- $xi$：随后才揭示的不确定量，例如真实位置、误差或相容报告。
- $L$：结果损失，例如新定位区直径或包围圆半径。
- $cal(S)$：可执行候选域；$cal(U) lr((s))$：与所选动作相容的不确定域。

先 min 后 sup 表示在不知道报告时选站。若写成先 sup 后
min，就允许先知道不确定量再选站，解决的是信息更充分的另一问题。在共用不确定域的标准写法中，一般只有

$ sup_xi inf_s L lr((s comma xi)) lt.eq inf_s sup_xi L lr((s comma xi)) comma $

不能任意交换。

=== 1.5.2　把第二站目标写完整
<把第二站目标写完整>
给定第一站可行域 $F_1$，在第二站 $s$ 收到报告 $z$ 后，可构造

$ F_2 lr((s comma z)) eq F_1 sect B lr((s comma 1500)) sect W lr((s comma z)) dot.basic $

此处把不能取得方向的极近距离小孔放松掉，适用于位置外包。令

$ Z lr((s)) eq brace.l z colon F_2 lr((s comma z)) eq.not diameter brace.r dot.basic $

三种目标分别为

$ J_D lr((s)) eq sup_(z in Z lr((s))) D lr((F_2 lr((s comma z)))) comma quad J_R lr((s)) eq sup_(z in Z lr((s))) R lr((F_2 lr((s comma z)))) comma quad J_A lr((s)) eq sup_(z in Z lr((s))) A lr((F_2 lr((s comma z)))) dot.basic $

实现中用外多边形 $P_2$ 替换 $F_2$。因此 P2(z)
非空证明报告与#strong[外近似模型]相容，未必与被放松的小孔或精确圆弧模型完全相容。

为何按报告最大化？不能把某个假定真位置与无关示向度任意组合。必须存在可行真位置与允许误差产生该报告。Q2
`robust_quality` 跳过空的 `post_region`，体现了这一相容性检查。

面积更小未必更利于清除：细长区域面积可以很小，最远两点仍很远。若强调最终
20 米内清除，$R$ 更直接；$D$ 对应 Q1
的明确要求。应分别报告三项，不能把平方米和米未归一化便直接相加。

=== 1.5.3　公开教材例题：名义最优与最坏情形最优
<公开教材例题名义最优与最坏情形最优>
#strong[来源：]Boyd、Vandenberghe《Convex Optimization》§6.4.2，Example
6.5，pp.319–320，Figure 6.15。原例设
$A lr((u)) eq A_0 plus u A_1$、$u in lr([minus 1 comma 1])$，比较名义、随机与最坏情形最小二乘解。#footnote[Stephen
Boyd and Lieven Vandenberghe, #emph[Convex Optimization], Cambridge
University Press, 2004, §6.4.2, Example 6.5, pp.319–320, Figure
6.15；#link("https://stanford.edu/~boyd/cvxbook/bv_cvxbook.pdf#page=332")[作者全书 PDF]；#link("https://web.stanford.edu/~boyd/cvxbook/")[作者主页]。另参
§4.3.1 pp.148–149 对最大内切球中心的命名，避免与最小包围圆混淆。]

固定 $x$，令
$r lr((u)) eq parallel A lr((u)) x minus b parallel_2$。任意
$u in lr([minus 1 comma 1])$ 是端点凸组合，由范数凸性，

$ r lr((u)) lt.eq frac(1 minus u, 2) r lr((minus 1)) plus frac(1 plus u, 2) r lr((1)) lt.eq max brace.l r lr((minus 1)) comma r lr((1)) brace.r dot.basic $

因此连续最坏值可#strong[精确]化为端点最大值。原图的名义解在 $u eq 0$
附近残差小，最坏情形解抑制了全区间最大残差。

#strong[迁移限制：]报告角改变会使定位区活跃边界改变，尚未证明
$D lr((P_2 lr((s comma z))))$、$R lr((P_2 lr((s comma z))))$、$A lr((P_2 lr((s comma z))))$
对 $z$ 凸，就不能照搬“两端点即可”。

=== 1.5.4　有限网格最大值为什么不是连续上界
<有限网格最大值为什么不是连续上界>
固定站点，设 $f lr((z))$ 为精确模型指标、$Z_h subset Z$ 为有限样本集，则

$ max_(z in Z_h) f lr((z)) lt.eq sup_(z in Z) f lr((z)) dot.basic $

采样可能漏掉峰值，所以采样最大值是连续最大值的下界。

若
$F_2 lr((s comma z)) subset.eq P_2 lr((s comma z))$，由集合包含的单调性，#strong[同一报告]下有

$ D lr((F_2)) lt.eq D lr((P_2)) comma quad R lr((F_2)) lt.eq R lr((P_2)) comma quad A lr((F_2)) lt.eq A lr((P_2)) dot.basic $

两种误差不能合并成一个统一方向：外近似把已评估报告指标向上推，有限采样又可能漏峰。因此

$ max_(z in Z_h) "metric" lr((P_2 lr((s comma z)))) $

与精确连续最坏值的大小关系，不能仅凭上述两点确定。Q2
文件开头明确说明这一边界。

要从网格得到认证上界，需要额外证据。例如已证明

$ lr(|f lr((z)) minus f lr((z prime))|) lt.eq L lr(|z minus z prime|) $

且每个连续可行角距某个已评估可行样本不超过 $h slash 2$，才有

$ sup_Z f lt.eq max_(Z_h) f plus L h slash 2 dot.basic $

必须真正证明 Lipschitz
常数与网格覆盖关系。在近平行、可行域消失或活跃约束切换处，不能只凭数值曲线平滑就假设这些条件。

=== 1.5.5　两个不同的精度旋钮
<两个不同的精度旋钮>
Q2 将半径 $r$ 的圆盘近似为外切正 $m$ 边形，其顶点半径

$ r_(upright(v e r t e x)) eq r sec lr((pi slash m)) comma $

最远径向外扩为 $r lr((sec lr((pi slash m)) minus 1))$。增大 `disk_sides`
改善几何外扩。

`report_step_deg`
控制报告角初始扫描。代码再选竞争性局部峰值区间，做有限次黄金分割式细化。从粗网格中挑少数区间，并未证明其他位置没有更高峰值；黄金分割的经典保障还需要相应区间的单峰性质。外层
`optimize_fixed_baseline` 也只搜索有限候选角并局部加密。

计算报告至少应列出：基线长度、安全候选域、圆边数、报告角步长、外层步长、三项指标与加密变化量。变化很小是数值稳定性证据，不自动等于全局最优或连续最坏值认证。

=== 1.5.6　适用范围、练习与答案
<适用范围练习与答案-4>
#strong[适用范围：]误差允许集合可信，任务关心所有允许情况。有概率模型且允许平均风险时可考虑期望优化；只有上界时不能擅自假定均匀分布。

#strong[练习 A：]Boyd 原例只查端点是证明，Q2
每隔一个角度检查却是近似，区别在哪里？

#strong[答案：]前者利用了仿射函数的范数为凸函数；后者尚没有覆盖全部报告角的解析界。

#strong[练习 B：]只增大 `disk_sides` 能否消除报告角漏峰？

#strong[答案：]不能。它改善边界几何，未改变报告域采样覆盖。

#strong[练习
C：]对同一精确函数，把样本集扩充为包含原集合的新集合，采样最大值会下降吗？

#strong[答案：]不会。但同时改变外多边形、容差，或两套网格并不嵌套时，程序结果可能升也可能降。

#horizontalrule

== 1.6　集合成员估计：用不变量连接每一次观测
<集合成员估计用不变量连接每一次观测>
=== 1.6.1　先修与定义
<先修与定义-1>
#strong[先修：]集合交、函数原像、存在量词。

设未知状态为 $x$，观测模型为

$ y_k eq h lr((x comma u_k comma e_k)) comma #h(2em) e_k in E_k comma $

其中 $u_k$ 是已执行动作。一次读数相容的状态集合为

$ M_k eq brace.l x colon exists e_k in E_k comma med y_k eq h lr((x comma u_k comma e_k)) brace.r dot.basic $

静态目标的精确更新为

$ F_k eq F_(k minus 1) sect M_k dot.basic $

"成员"指哪些状态仍可能属于真实状态集合，不是给状态分配概率。移动目标需要先作动态预测再求交；B
题源位置静止，更新尤其直接。

=== 1.6.2　贯穿 Q1–Q4 的归纳证明
<贯穿-q1q4-的归纳证明>
希望始终保持

$ G in F_k subset.eq P_k dot.basic $

证明分三步：

+ #strong[初始。]$G in Omega$，初始化使用包含 $Omega$ 的外切多边形，故
  $G in P_0$。
+ #strong[单步。]假设
  $G in P_k$。由反馈的物理含义证明真源满足新增约束；若使用近似，还需证明它包含精确更新结果。
+ #strong[传递。]得到
  $G in P_(k plus 1)$，归纳法把这个结论传递到全部动作。

这比展示许多“图上包住真值”的实例更强：图只能覆盖所画实例，归纳证明说明全部满足假设的实例为何保留真值。

=== 1.6.3　公开教材例题：带 $minus 1 comma 0 comma 1$ 扰动的传感器
<公开教材例题带--101-扰动的传感器>
#strong[来源：]LaValle《Planning Algorithms》§11.1.1，Example 11.7
"Sensor Disturbance"，p.564。原例设
$X eq Y eq bb(Z)$、$Psi eq brace.l minus 1 comma 0 comma 1 brace.r$、$y eq x plus psi$。#footnote[Steven
M. LaValle, #emph[Planning Algorithms], Cambridge University Press,
2006, §11.1.1, Example 11.7 "Sensor Disturbance",
p.564；#link("https://lavalle.pl/planning/ch11.pdf")[作者第 11 章 PDF]；#link("https://lavalle.pl/planning/")[作者全书主页]。章节
PDF 双页排版，p.564 位于文件第 4 页。]

收到读数 $y$ 后逐个消去扰动，

$ H lr((y)) eq brace.l y minus 1 comma y comma y plus 1 brace.r dot.basic $

若此前可行集合为 $F$，更新是 $F sect H lr((y))$，不能直接宣布
$x eq y$。原题没有三个值的概率，模型也就不能推出哪一个最可能。

#strong[迁移到 B 题：]把整数扰动换成
$lr([minus delta comma delta])$，把加法传感器换成方位函数，原像从三个点变为楔形。

=== 1.6.4　四种反馈如何更新
<四种反馈如何更新>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [反馈与条件], [可证明的信息], [适合处理],
  [`direction`],
  [真源在方位楔形内，距离不超过接收半径上界 1500 米],
  [与楔形及范围外近似相交],
  [`near`],
  [真源在当前位置 5 米内，且该处收到信号],
  [直接光学定位清除],
  [Q3 全向源 `no_signal`],
  [若频道确有未清除源，则它不在保证接收的 1000 米范围内],
  [排除略缩小的 1000 米开圆盘],
  [Q4 类型/朝向未知时 `no_signal`],
  [可能距离过远，或在辐射侧之外，或该频道无源],
  [单次阴性不能排除周围整圆盘],
)
]

Q3 `exclude_disk_hull` 维护

$ P_(k plus 1) eq "conv" #scale(x: 120%, y: 120%)[paren.l] P_k backslash B^compose lr((S comma 1000)) #scale(x: 120%, y: 120%)[paren.r] $

的保守数值版本。挖去圆盘通常产生非凸集合；再取凸包可能填回已排除部分，但不删除真实可行点。牺牲的是精度，保持的是包含关系。若圆盘完全位于多边形内部、没有改变外层极点，阴性信息甚至可能在取凸包后完全消失。

Q4 使用正锚点与成对探测组合解释阴性信息；`_dual_negative`
的合法性依赖联合观测的几何条件，不能从单次无信号直接套用其裁剪式。

=== 1.6.5　为何用三角形外包扇形
<为何用三角形外包扇形>
若已有 $parallel G minus S parallel lt.eq U$，获得报告方向 $u$，则一定有

$ u dot.op lr((G minus S)) lt.eq U dot.basic $

该直线约束与楔形两边围成三角形，包含半径 $U$
的扇形。它只增加三条边，易于更新。三角形角点到 $S$ 的距离却可达
$U slash cos delta$，不能认为所有外包顶点仍满足距离 $lt.eq U$。

Q3 `bearing_update`、Q4 `direction_update`
使用这一结构。计算下一次保证接收条件时，须对当前多边形重新求最远距离，不能沿用不适用的精确圆盘结论。

=== 1.6.6　适用范围、练习与答案
<适用范围练习与答案-5>
#strong[局限：]硬误差上界被真实数据违反时，集合可能为空。应检查协议语义、单位、舍入裕量和观测模型，不能把空集改成任意小圆继续宣布确定清除。

#strong[练习 A：]教材加法传感器对同一静态状态重复得到相同
$y$，集合继续缩小吗？

#strong[答案：]单纯重复同一约束不会，$F sect H lr((y)) sect H lr((y)) eq F sect H lr((y))$。B
题地点固定误差使这一幂等性具有实际意义。

#strong[练习 B：]Q4 在源的辐射背面，即使很近也无信号，能否删去 1000
米圆盘？

#strong[答案：]不能，会删去合法真源。阴性必须与隐藏发射朝向联合解释。

#strong[练习 C：]“外近似更大，因此任何结论都更安全”正确吗？

#strong[答案：]不正确。它适合证明“全部可能位置都被覆盖”的全称命题；若要证明“至少存在一个精确可行点”，外近似伪点会造成假阳性，必须看量词方向。

#horizontalrule

== 1.7　覆盖、TSP、定向越野：先确认自己在解哪一种问题
<覆盖tsp定向越野先确认自己在解哪一种问题>
=== 1.7.1　先修与四种模型
<先修与四种模型>
#strong[先修：]图的顶点、边、路径，距离矩阵，集合覆盖。

#align(center)[#table(
  columns: 4,
  align: (col, row) => (auto,auto,auto,auto,).at(col),
  inset: 6pt,
  [模型], [输入已知什么], [必须完成什么], [常见目标],
  [连续覆盖],
  [目标可能所在区域与传感器足迹],
  [区域每个位置至少被有效检测],
  [路长、时间、站点数],
  [TSP],
  [全部待访点及两两成本],
  [每点访问，经典版本还要回起点],
  [最短巡回],
  [开放路径 TSP],
  [待访点及起点，终点规则另定],
  [每点访问，通常无需回起点],
  [最短开放路径],
  [Orienteering，定向越野],
  [已知候选点、收益、时间预算],
  [允许选择部分点访问],
  [预算内收益最大],
)
]

"定向越野"是组合优化术语，与本题“定向干扰源”的发射方向没有含义联系。KU
Leuven 的研究数据页提供了原始 orienteering
研究文献及标准实例，可据此学习该模型。#footnote[KU Leuven, Division MIM,
"The Orienteering Problem: Test Instances", "The Orienteering
Problem"小节；#link("https://www.mech.kuleuven.be/en/mim/op")[研究者维护的实例与原论文目录]。列出
Tsiligirides (1984)、Chao–Golden–Wasil (1996)、Fischetti–Salazar–Toth
(1998) 的原始文献和实例来源，供模型与标准数据扩展阅读。]

若已知点为 $1 comma dots.h comma n$，访问指示量为
$z_i in brace.l 0 comma 1 brace.r$，收益为 $w_i$，一条路线为
$pi$，两类目标的差别可简写为

$ upright("TSP:") & min L lr((pi)) comma quad z_i eq 1 med forall i semi\
upright("Orienteering:") & max sum_i w_i z_i comma quad L lr((pi)) lt.eq B dot.basic $

两式还需配上保证路径连通、起终点和访问一致性的约束，不能把这个简写当成完整整数规划。

B 题开始时目标位置未知，因此不能直接把真实源坐标交给
TSP。发现阶段可先设计检测站覆盖；目标发现后，任务排序才形成路径子问题。题目要求确保全部清除，"允许漏掉低收益目标"的
orienteering
不能直接替代完整任务。它可以启发受预算约束时的优先级，但不能更改成功标准。

=== 1.7.2　全向源的连续覆盖证据
<全向源的连续覆盖证据>
对接收半径至少 1000 米的全向源，检测站集合 $cal(S)$ 的充分发现条件为

$ Omega subset.eq union.big_(s in cal(S)) B lr((s comma 1000)) dot.basic $

还要在这些站执行所需频道检测。几何覆盖与频道覆盖缺一不可；机器狗沿某条线走过但未停下检测，不算检测覆盖了沿途。

源总数未知，"很久没遇到新源"不是完整性证据。可依据的结束理由包括：已清除达到最多
16
个源；或者仍未知的频道经过完整有效覆盖而无信号，所有已发现源也成功清除。若只是已发现达到
16 个，只能结束未知频道的搜索，仍需清除这些已发现源。

=== 1.7.3　为什么只查场地圆周不够
<为什么只查场地圆周不够>
检测圆盘可能覆盖整个场地边界，却在内部留下洞。所以“所有边界采样点都覆盖”不能证明内部覆盖，甚至“外边界连续覆盖”也不够。

Q3 `covers_arena`
同时检查场地边界，以及处于场地内的检测圆周是否存在未被其他圆盘覆盖的暴露弧。直觉是：内部若有未覆盖区域，它与已覆盖区域之间的边界必来自检测圆周的暴露部分。实现还需处理相切、重复圆、区间端点；代码使用略缩小的
999 米半径留裕量。

另一通用认证路线是网格误差界。若区域任一点到某网格点的距离不超过
$epsilon$，每个网格点都落入某个半径 $r minus epsilon$
的检测圆盘，则三角不等式给出整个区域被半径 $r$
的圆盘覆盖。只检验“网格点在半径 $r$ 内”则缺少裕量。

=== 1.7.4　定向源需要覆盖隐藏发射方向
<定向源需要覆盖隐藏发射方向>
设源位置为 $G$，朝向单位向量为 $d$，站点 $s$ 位于辐射侧的条件为

$ d dot.op lr((s minus G)) gt.eq 0 dot.basic $

保证发现所有定向源的布局，需要

$ forall G in Omega comma med forall d in bb(S)^1 comma med exists s in cal(S) colon quad parallel s minus G parallel lt.eq 1000 comma quad d dot.op lr((s minus G)) gt.eq 0 dot.basic $

比全向覆盖增加了“对所有发射方向”。一个检测圆盘包含
$G$，并未保证站点位于源的辐射侧。

固定 $G$，令

$ V_G eq brace.l s minus G colon s in cal(S) comma med parallel s minus G parallel lt.eq 1000 brace.r dot.basic $

有用的等价判据为
$0 in "conv" lr((V_G))$。若原点在凸包中，这些向量不可能对某方向全有严格负投影；反之，若原点不在有限向量的凸包中，严格分离给出一个方向使全部近站都在其背面。若
$V_G$ 为空，显然不覆盖。这个判据解释了 Q4 为什么需要方向更丰富的检测站。

=== 1.7.5　原论文例题：两块区域合并，六次通过变成五次
<原论文例题两块区域合并六次通过变成五次>
#strong[来源：]Choset、Pignon，#emph[Coverage Path Planning: The
Boustrophedon Decomposition]，1997，§3、Figure 4，PDF 第 3
页。#footnote[Howie Choset and Philippe Pignon, "Coverage Path Planning:
The Boustrophedon Decomposition", Proceedings of the 1st International
Conference on Field and Service Robotics, 1997, pp.216–222, §3, Figure
4，PDF 第 3
页；#link("https://publications.ri.cmu.edu/coverage-path-planning-the-boustrophedon-decomposition")[CMU 论文条目]；#link("https://publications.ri.cmu.edu/storage/publications/pub_files/pub1/choset_howie_1997_5/choset_howie_1997_5.pdf")[CMU 原论文 PDF]。]

原例的两个相邻单元，宽度各为机器人宽度的 $2.5$ 倍。单独覆盖时，每块需
$⌈ 2.5 ⌉ eq 3$ 次纵向通过，共 6
次；合并成适合往复覆盖的一个单元后，总宽为 5 倍，只需 5 次。

这个例子说明，先改变覆盖分解，再优化访问顺序，可能比只在既定分解上改路线更有效。原例为连续扫地作业；B
题的接收足迹由停车检测产生，不能把移动当作连续检测。

=== 1.7.6　适用范围、练习与答案
<适用范围练习与答案-6>
#strong[局限：]覆盖站点设计保证发现，路径优化降低成本，二者是不同义务。短路线少扫一个必要站，可能失去完整性。

#strong[练习 A：]Q3 能否以“访问了所有已发现源”作为任务完成理由？

#strong[答案：]不能，仍可能有未发现源，必须另有全域覆盖或个数上界等证据。

#strong[练习 B：]原论文例题少一次纵向通过，就精确节省六分之一总时间吗？

#strong[答案：]不能这样推断。还存在转弯、连接等成本；原例直接比较的是通过次数。

#strong[练习 C：]为什么 Q4 不能只在场地内部中心附近布站？

#strong[答案：]边缘源可以朝外辐射，全部站都处于背面。原题允许机器狗走出目标分布圆域，Q4
外环利用了这一点；"源不在圆外"不等于“机器狗不能到圆外”。

#horizontalrule

== 1.8　在线路径：边获取信息边决定下一步
<在线路径边获取信息边决定下一步>
=== 1.8.1　先修与策略定义
<先修与策略定义>
#strong[先修：]状态、动作、条件分支、集合估计。

静态路线是一串预先固定的点；在线策略为

$ pi colon I_k arrow.r.bar a_k dot.basic $

信息状态 $I_k$
包含机器狗位置、当前频道、各频道状态、位置外多边形、已扫站点、剩余路线和已用时间等。

完整循环是：按当前信息选动作；收到反馈；更新相关集合与状态；重新选择下一动作。未来动作受当前读数影响，执行前的一条理想路线不能直接等同于最终路线成本。

=== 1.8.2　用实际时间统一移动与检测
<用实际时间统一移动与检测>
一段移动时间为 $parallel p minus q parallel slash 5$ 秒；检测 5
秒，换频道另加 1 秒；成功光学定位与清除合计 5 秒。可按动作写出

$ T eq L_(upright(m o v e)) / 5 plus 5 N_(upright(m e a s u r e)) plus N_(upright(s w i t c h)) plus T_(upright(o p t i c a l) slash c l e a r) dot.basic $

应依据实际调用与响应统计。不能把“扫描 20 个频道”一律算成 120
秒：当前频道若在待扫集合中且先测它，第一次无需切换。Q3/Q4
都优先检测当前频道。

将某类动作成本遗漏，会让路线比较失真。若一条路线少走路却多做许多全频道扫描，总时间可能更长。

=== 1.8.3　插入定位任务的增量成本
<插入定位任务的增量成本>
当前位置为 $p$，下一搜索站为 $s$，已发现目标估计中心为 $c$。临时插入 $c$
的移动增量为

$ Delta L eq parallel p minus c parallel plus parallel c minus s parallel minus parallel p minus s parallel gt.eq 0 dot.basic $

真实定位还可能需要探测，清除点也未必为 $c$。上传 Q3 `_choose` 与 Q4
`_choose_insert` 使用类似

$ upright("score") eq Delta L plus r $

的启发式分数，加入当前不确定半径 $r$，再与 600
米阈值比较。其含义是顺路、较确定的目标可先服务。系数与阈值是策略参数，并非由
TSP 最优性定理推出。

=== 1.8.4　公开教材例题：不知道门在哪一侧的牛
<公开教材例题不知道门在哪一侧的牛>
#strong[来源：]LaValle《Planning Algorithms》§12.3.3 "Competitive
ratios"，pp.673–674，Figure 12.26。取原例“门恰好距起点 1
单位、左右未知”的情形。#footnote[Steven M. LaValle, #emph[Planning
Algorithms], §12.3.3 "Competitive ratios", pp.673–674, Figure
12.26；#link("https://lavalle.pl/planning/ch12.pdf")[作者第 12 章 PDF]。这里只展开原文“门恰好距离
1”的情形，不推广为 B 题策略保证。]

先向左走，最好情况走 1 找到门；最坏情况先左 1、返回 1、再右 1，总长
3。知道门在哪侧的离线最优只走 1，最坏比值为 3。

对任何确定性策略，首先到达的一侧都可能没有门，之后到另一侧至少还需
2。因此这一简化情形的比值下界也是 3。这是对教材原例的独立论证。

#strong[迁移到 B
题：]信息不足本身造成绕路。对照策略应拥有相同观测接口；使用真实源坐标的离线路线可作下界参照，不能当成可部署策略。

=== 1.8.5　适用范围、练习与答案
<适用范围练习与答案-7>
#strong[局限：]局部节省不一定等于全局节省。追近目标可能使后续覆盖更绕；一次顺便测量也可能缩小多个已发现源的区域，应统计整个任务。

#strong[练习 A：]牛若已知门在左边，比值还为 3 吗？

#strong[答案：]不，直接向左成本为 1。竞争分析必须明确算法获知的信息。

#strong[练习 B：]Q3 `_tracking_point`
额外考虑下一站距离，就证明全局最短吗？

#strong[答案：]没有。它是在少量当前候选点中作局部选择，仍是启发式，接收保证等硬约束必须独立满足。

#strong[练习 C：]能否因为一个搜索站较远，就从剩余路线删掉它？

#strong[答案：]不能。必须先证明其余已扫/待扫站仍覆盖全部待搜索状态；距离不是完整性证据。

#horizontalrule

== 1.9　启发式算法：最近邻与 2-opt 的教材对照
<启发式算法最近邻与-2-opt-的教材对照>
=== 1.9.1　先修与两种证据
<先修与两种证据>
#strong[先修：]距离矩阵、路线求和、循环、列表片段反转。

启发式依靠合理规则快速寻找较好解，不因规则合理就自动具有全局最优性。一个策略可以同时包含：

- 有证明的可行性部分：接收保证、集合包含、全域覆盖、清除半径。
- 经验选择的效率部分：插入阈值、侧向探测偏移、服务顺序。

效率部分应通过相同实例、误差场、接口的对照实验评价；保证部分应有数学证据。两种证据不能相互替代。

=== 1.9.2　最近邻构造法
<最近邻构造法>
从给定起点出发，每次访问剩余点中离当前位置最近者；全部访问后，闭合 TSP
再返回起点。

若每一步扫描全部剩余点，时间为
$O lr((n^2))$。它最小化下一条边，未来可能被迫走昂贵的边。固定起点和并列规则，才能复现实验。

重复最近邻从多个起点构造并取最好者，可能改善初始解。但机器狗实际从原点出发，不能免费更换实际起点。闭合回路可循环改写起点；开放路线则须重新计算起点连接成本。

=== 1.9.3　2-opt 改进法
<opt-改进法>
在对称成本路线中，选择按顺序出现的两条不相邻边
$lr((a comma b))$、$lr((c comma d))$。删除它们，反转中间子路径，再连接
$lr((a comma c))$、$lr((b comma d))$，代价变化为

$ Delta eq d lr((a comma c)) plus d lr((b comma d)) minus d lr((a comma b)) minus d lr((c comma d)) dot.basic $

若
$Delta lt 0$，接受交换。成本对称时，中间路径反向不改变其成本，才可只检查四条边；非对称成本不能套用此简式。

一轮有 $O lr((n^2))$
对边，可多轮直到无改进。严格下降且路线有限，故会终止，但得到的是没有
2-opt 改进的局部最优。欧氏 TSP 的 2-opt
也非全局精确算法，原始研究专门分析了其最坏近似比。#footnote[Ulrich A.
Brodowsky and Stefan Hougardy, "The Approximation Ratio of the 2-Opt
Heuristic for the Euclidean Traveling Salesman Problem", STACS 2021,
LIPIcs 187,
pp.18:1–18:15；#link("https://drops.dagstuhl.de/entities/document/10.4230/LIPIcs.STACS.2021.18")[官方论文及 PDF]。用于算法定义与适用边界，不把欧氏
TSP 结果套用于在线总时间。]

=== 1.9.4　公开教材数据：最近的一步导致较长全程
<公开教材数据最近的一步导致较长全程>
#strong[来源：]David Lippman《Math in Society》，#emph[Graph Theory and
Network Flows]，印刷
pp.64–66，四顶点带权完全图。原数据如下。#footnote[David Lippman,
#emph[Math in Society], "Graph Theory and Network Flows", pp.64–66（章节
PDF 第 16–18 页），四顶点 TSP 与 Nearest Neighbor
示例；#link("https://www.opentextbookstore.com/mathinsociety/current/GraphTheory.pdf")[作者开放教材站 PDF]。数据和最近邻过程来自原例，2-opt
为利用相同数据的延伸计算。]

#align(center)[#table(
  columns: 7,
  align: (col, row) => (auto,right,right,right,right,right,right,).at(col),
  inset: 6pt,
  [边], [$A B$], [$A C$], [$A D$], [$B C$], [$B D$], [$C D$],
  [权重],
  [4],
  [2],
  [1],
  [13],
  [9],
  [8],
)
]

最近邻从 $A$ 出发，依次选 $D comma C comma B$，得到

$ A arrow.r D arrow.r C arrow.r B arrow.r A comma #h(2em) L eq 1 plus 8 plus 13 plus 4 eq 26 dot.basic $

教材枚举的最优巡回成本为 23，说明最近邻在此例没有求到最优。

#strong[延伸计算，并非原书已经给出的 2-opt 例题：]对长度 26 的路线，删去
$A D$、$C B$，改接 $A C$、$D B$，得到

$ A arrow.r C arrow.r D arrow.r B arrow.r A comma #h(2em) Delta eq lr((2 plus 9)) minus lr((1 plus 13)) eq minus 3 comma #h(2em) L eq 23 dot.basic $

这是在真实教材数据上独立演示一次 2-opt。此矩阵不是欧氏距离矩阵，如
$B C eq 13 gt B A plus A C eq 6$，不能拿它验证依赖三角不等式的欧氏近似保证。

=== 1.9.5　交叉边为何经常可被 2-opt 改掉
<交叉边为何经常可被-2-opt-改掉>
若线段 $A B$、$C D$ 在内部点 $X$ 横向相交，

$ lr(|A C|) lt.eq lr(|A X|) plus lr(|X C|) comma #h(2em) lr(|B D|) lt.eq lr(|B X|) plus lr(|X D|) dot.basic $

相加得
$lr(|A C|) plus lr(|B D|) lt.eq lr(|A B|) plus lr(|C D|)$，非退化时严格小于。如果这次重接保持有效巡回，就能消除交叉并降低成本。

但没有交叉远不足以证明最短。2-opt
可改善一些不交叉的边，也可能停在没有两边交换改进、却不是全局最优的路线。

=== 1.9.6　与上传代码的真实关系
<与上传代码的真实关系>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [方法], [本章作用], [上传代码实际状态],
  [最近邻],
  [服务排序的教学基线],
  [Q3/Q4 部分分支按距离加半径选目标，属于相关贪心思想，非纯已知点 TSP],
  [2-opt],
  [已知点静态路线的改进对照],
  [当前 Q3/Q4 主线没有执行 2-opt，Q3 `Config` 注释明确不宣称使用],
  [插入评分],
  [兼顾搜索与定位],
  [Q3 `_choose`、Q4 `_choose_insert` 计算绕行量加半径],
  [固定覆盖路线],
  [为发现完整性提供基础],
  [Q3 环形站点；Q4 原点、内环、外环],
)
]

学过经典算法不意味着程序已实现。报告应按实际函数写方法；若将来添加
2-opt，说明对哪些点重排、是否保持覆盖站集合、开放终点规则是否变化、实际成本如何计算。

=== 1.9.7　适用范围、练习与答案
<适用范围练习与答案-8>
#strong[练习 A：]枚举原教材图从 $A$ 出发的三个无向巡回。

#strong[答案：]$A B C D A colon 4 plus 13 plus 8 plus 1 eq 26$；$A B D C A colon 4 plus 9 plus 8 plus 2 eq 23$；$A C B D A colon 2 plus 13 plus 9 plus 1 eq 25$。其余排列是反向形式。

#strong[练习 B：]此例 2-opt 达到 23，能否说它总能求到最优？

#strong[答案：]不能，只证明本实例的交换达到经枚举验证的最优。一般保证须覆盖全部允许输入。

#strong[练习 C：]用 2-opt 重排 Q3 剩余站点，覆盖一定不变吗？

#strong[答案：]若最终完整访问的站点集合及各站所扫频道相同，最终几何覆盖不变；但发现时刻、插入位置、阴性信息、结束条件、总时间均可能变化，要评价完整在线策略。

#horizontalrule

== 1.10　连成一次可核验的建模过程
<连成一次可核验的建模过程>
每一行都为下一行提供前提，不能仅列出算法名称：

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [步骤], [应写出的数学语句], [实现中应找的证据],
  [观测建模],
  [真源满足角误差与接收条件],
  [度转弧度、楔形法向量、反馈类型],
  [集合更新],
  [精确模型更新后仍被外近似包含],
  [裁剪约束的物理来源、包含方向],
  [不确定性度量],
  [$D lr((P)) comma R lr((P)) comma A lr((P))$ 意义不同],
  [直径点对、MEC 覆盖复核],
  [下一步选取],
  [硬约束保证可执行，评分控制成本],
  [候选验证、网格参数、评分函数],
  [局部结束],
  [$r plus parallel q minus c parallel lt.eq 19.8 lt 20$],
  [清除证据、接口成功响应],
  [全局结束],
  [全部源已发现且清除],
  [频道状态、覆盖证据或个数上界],
  [效率评价],
  [完整任务总时间与平均清除时间],
  [移动、检测、切换、清除分别统计],
)
]

=== 自测：能否解释这八句话
<自测能否解释这八句话>
+ 有界角误差读数对应楔形；零误差时还要排除反向射线。
+ 半平面交为凸集，但可能空、无界、退化。
+ 直径只需找最远顶点对；旋转卡壳利用凸性避免全部点对。
+ $D slash 2$ 是最小包围圆半径下界，不能一般地用作清除半径。
+ 外多边形对单个报告保守，有限报告采样却不认证连续最坏值。
+ 集合外近似关键是保留真源；集合很小不等于模型正确。
+ Q4 阴性含朝向歧义，完整搜索需要覆盖位置与方向。
+ 最近邻、2-opt、插入评分改善效率，名称不能替代覆盖与清除证明。

#strong[达标标准：]能各写一个关键不等式，并找到对应函数。然后进入各问题章节，继续学习
Q2 安全候选域、Q3 收缩与覆盖、Q4 正锚点成对探测。

== 公开来源与定位说明
<公开来源与定位说明>
以下链接已核对。印刷页用于学术引用，文件页用于快速定位。公式推导与代码分析由本书独立组织，未复制外部教材整段讲解或图片。

#pagebreak()
= 第二章　Q1 / Q2：从一条有误差的方向，到一个可解释的第二检测点
<第二章-q1-q2从一条有误差的方向到一个可解释的第二检测点>
#blockquote[
学习目标：你不仅能运行两问，还能在纸上推出角楔不等式、解释定位区域为什么是凸的、手算一个反例、说清第二站为什么保证接收，并沿着源码讲完两层优化。特别要分清：#strong[区域包含真源的几何保证、覆盖给定多边形的数值检查、连续选址问题的全局最优证明，是三件不同的事。]

本章以本仓库的原上传源码为准，不把程序没有执行的步骤写进算法。`Q1:L257–265`
表示 `source/Q1/q1_solver.py` 第 257–265 行；`Q2:L307–400` 表示
`source/Q2/q2_solver.py` 第 307–400 行。生成器另写全名。题目页码指上传的
`20-B-.pdf` 的 PDF 页码，恰与页脚页码一致。
]

== 0. 这两问在七天学习中的位置
<这两问在七天学习中的位置>
建议用两个五小时学习日完成本章，而不是连续读十小时。第一天读到第 6
节并完成 Q1；第二天读第 7–13 节完成 Q2。第 14–16
节用于后续答辩复习。这里的时间是学习安排，不是程序运行时间。

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,right,auto,).at(col),
  inset: 6pt,
  [学习块], [时间], [必须亲手完成的产出],
  [Q1：题意、角度、半平面],
  [75 分钟],
  [不看代码写出两条角楔不等式，检查东、北两个方向],
  [Q1：半平面交、退化情形],
  [75 分钟],
  [手算矩形、空集、线段；说出 `uncertain` 的含义],
  [Q1：凸包、直径、直径圆],
  [75 分钟],
  [写出“只检查顶点”的证明，画正三角形反例],
  [Q1：运行与口述],
  [75 分钟],
  [跑固定种子；从 `main` 讲到输出，解释每个字段],
  [Q2：安全域与坐标转换],
  [90 分钟],
  [推出固定基线的安全角上界，并区分两个安全域],
  [Q2：MEC、圆外包络、物理可行报告],
  [75 分钟],
  [写出嵌套的最小最大模型，解释为何不能任意拼接位置与示向度],
  [Q2：源码、搜索、实验],
  [75 分钟],
  [跑 `--quick`；区分内层黄金分割与外层粗细网格],
  [Q2：答辩与查漏],
  [60 分钟],
  [回答第 15 节，不把数值近似说成连续全域证明],
)
]

#strong[第一遍需要掌握的主线]：误差有界 → 所有相容位置 → 角楔交 →
凸多边形 → 最坏空间尺度 → 为下一次观测选择位置。

#strong[第二遍再深入的内容]：衰退方向判定、MEC
的三点支撑、全信息安全域推导、连续报告极大值的数值误差。不要因这些内容尚未熟练而跳过前面的最小例题。

== 1. 先把题意翻译成允许使用的信息
<先把题意翻译成允许使用的信息>
=== 1.1 题目给了什么，程序实际用了什么
<题目给了什么程序实际用了什么>
#align(center)[#table(
  columns: 4,
  align: (col, row) => (auto,auto,auto,auto,).at(col),
  inset: 6pt,
  [信息], [题目位置], [对 Q1 / Q2 的意义], [当前代码],
  [源在原点为中心、半径 1800 m 的圆域内],
  [第 1 页],
  [是位置先验；并非机器狗只能在圆内移动],
  [Q2 用 `ARENA_R=1800`；Q1 不加入此圆约束],
  [示向度从正东起逆时针量，范围 `[0,360)`],
  [第 2 页附录 2(1)],
  [使用 `atan2(y,x)` 的坐标约定],
  [Q1 `_observation`；Q2 `local_to_world`],
  [示向误差在 ±1° 内；同地重复误差不变],
  [第 2 页附录 2(1)],
  [可做集合包含；不能凭重复测量次数缩小误差带],
  [两问都不平均重复测量],
  [有效接收半径未知，但在 1000–1500 m],
  [第 3 页附录 2(2)],
  [收到信号说明距离不超过 1500；保证接收可用 1000],
  [Q2 的 `R_MIN`、`R_MAX`],
  [不超过 20 m 可光学定位并清除],
  [第 3 页附录 2(8)],
  [应关心“能否选一个点覆盖所有可能源位置”],
  [Q2 用最小包围圆半径作为主尺度],
  [不超过 5 m 时，信号过强，不能得到普通示向度],
  [第 3 页附录 2(9)],
  [普通方向报告还意味着距离大于 5 m],
  [Q2 为保持凸性省略这个内洞，构成保守放宽],
  [机器狗位置通常不受目标圆域约束],
  [第 4 页],
  [检测点在 1800 m 圆外不自动违规],
  [Q1 生成器可能生成圆外检测点],
)
]

这里的“保守”需要指明对象：把可能位置集合放大，能够保留真源；在这个放大集合上算覆盖半径，会使#strong[给定观测的空间不确定性]偏大。但以后在有限个观测上取最大值，又可能漏掉未采样观测的峰值。两个方向不能相互抵消后直接称“整体有保证”。

=== 1.2 为什么这里没有误差服从均匀分布的假设
<为什么这里没有误差服从均匀分布的假设>
题目给出误差区间，但没有给出每个地点的误差独立、同分布、均值为零。Q1 和
Q2 选择的是有界误差模型：只要误差不越界，真源就应保留在可行集合里。

生成器用 `uniform(-1,1)`
只是产生本地测试数据的一种办法。#strong[测试数据的抽样分布，不会自动成为求解器的建模假设。]
Q2 文件头 L4–9 已明确说明不设误差分布，不平均重复测量。

=== 1.3 先记住这些符号
<先记住这些符号>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [符号], [含义], [单位],
  [$S_i eq lr((x_i comma y_i))$],
  [第 $i$ 个检测点],
  [m],
  [$G eq lr((x comma y))$],
  [未知真源],
  [m],
  [$z_i$],
  [测得的示向度],
  [°；三角函数前转弧度],
  [$delta$],
  [角误差半宽，默认 $1^compose$],
  [°],
  [$u lr((t)) eq lr((cos t comma sin t))$],
  [单位方向向量],
  [无量纲],
  [$W lr((S comma z comma delta))$],
  [以 $S$ 为顶点的可行角楔],
  [位置集合],
  [$P$],
  [多次观测的定位区域],
  [位置集合],
  [$D lr((P))$],
  [区域直径 $max_(p comma q in P) parallel p minus q parallel$],
  [m],
  [$R lr((P))$],
  [最小包围圆半径 $min_c max_(p in P) parallel p minus c parallel$],
  [m],
  [$A lr((P))$],
  [面积],
  [m²],
  [$L eq parallel S_2 minus S_1 parallel$],
  [两检测点间基线长度],
  [m],
  [$psi$],
  [第二站相对首示向轴的偏角，带正负号],
  [°],
)
]

距离、半径、直径都以米计，但含义不同。把 `worst_R_m` 与
`objective_value` 比较前，先看该行的 `objective` 是 `R` 还是 `D`。

== 2. 方法一：把有界误差写成凸可行集合
<方法一把有界误差写成凸可行集合>
=== 2.1 通用方法与外部讲义例题
<通用方法与外部讲义例题>
#strong[通用方法。] 对未知量 $x$，每条观测产生一个允许集合
$C_i$。所有观测同时成立的集合是 $sect.big_i C_i$。若各 $C_i$
是半空间，则交集是凸多面体；二维中是凸多边形、无界凸区域或退化集合。

#strong[外部例题来源 \[E1\]。] Boyd、Vandenberghe 的官方《Convex
Optimization》原版讲义，第 2 讲 "Hyperplanes and
halfspaces""Polyhedra"，讲义页
2–6、2–9，分别展示法向量指定的半空间与多个半空间围成的多边形；"Intersection"，页
2–12，还把对所有角参数成立的三角多项式幅值约束表示为一族凸带的交。该例说明：每个条件单独简单，全部同时成立要取交，而不是对边界求平均。原文链接见
\[E1\]。本节的无线电角楔与以下数值是针对 B 题重新推导的。

=== 2.2 "方向差不超过 1°"的直接表达为什么不适合几何裁剪
<方向差不超过-1的直接表达为什么不适合几何裁剪>
直接写

$ #scale(x: 120%, y: 120%)[bar.v] "wrap"_(bracket.l minus 180^compose comma 180^compose paren.r) lr(("atan2" lr((y minus y_i comma x minus x_i)) minus z_i)) #scale(x: 120%, y: 120%)[bar.v] lt.eq delta $

在逻辑上可以，但程序需要反复求角、处理 $359^compose$ 与 $0^compose$
的接缝，还要处理
`atan2(0,0)`。角楔边界本来就是直线，把它转换成半平面更直接。

定义二维叉积

$ "cross" lr((lr((a_x comma a_y)) comma lr((b_x comma b_y)))) eq a_x b_y minus a_y b_x dot.basic $

它是带符号的平行四边形面积：向量 $b$ 在有向向量 $a$
的左侧时为正，右侧时为负。

令下边界方向 $u_minus eq u lr((z minus delta))$，上边界方向
$u_plus eq u lr((z plus delta))$，待测位移 $v eq X minus S$。当
$0 lt delta lt 90^compose$ 时，角楔可以写成

$ "cross" lr((u_minus comma v)) gt.eq 0 comma #h(2em) "cross" lr((u_plus comma v)) lt.eq 0 dot.basic $

第一条表示在下边界的左边，第二条表示在上边界的右边。它们共同保留向前的小角楔；并不是把每条射线延长后留下前后两个楔。

=== 2.3 推成代码使用的 $n dot.op X lt.eq c$
<推成代码使用的-ncdot-xle-c>
展开第一条：

$ cos lr((z minus delta)) lr((y minus y_S)) minus sin lr((z minus delta)) lr((x minus x_S)) gt.eq 0 dot.basic $

移项得到

$ underbrace(lr((sin lr((z minus delta)) comma minus cos lr((z minus delta)))), n_minus) dot.op X lt.eq n_minus dot.op S dot.basic $

第二条同理：

$ underbrace(lr((minus sin lr((z plus delta)) comma cos lr((z plus delta)))), n_plus) dot.op X lt.eq n_plus dot.op S dot.basic $

这正是 `Q1:L257–265` 中 `_wedge` 的两个法向量。`HalfPlane` 在
`Q1:L19–27` 中统一存储 `normal`、`offset`；`residual(X)=normal·X-offset`
是违反约束的带符号数。

#strong[自己检查一次东向观测。]
$S eq lr((0 comma 0)) comma z eq 0^compose$，记
$t eq tan 1^compose$。两个约束等价于

$ minus t x lt.eq y lt.eq t x dot.basic $

若
$x lt 0$，下界大于上界，不能满足；因此这是正东前方的楔。若把某个法向量符号写错，就可能保留整个上半平面或反向楔。

#strong[再检查北向。] $z eq 90^compose$ 时应得到
$y gt.eq 0$、$lr(|x|) lt.eq y tan 1^compose$。能完成这两个检查，比记住公式更有用。

=== 2.4 为什么误差为零要另外补一条约束
<为什么误差为零要另外补一条约束>
若 $delta eq 0$，上述两条约束互为反向，合起来只要求 $X minus S$
与方向向量共线，留下的是整条直线。此时需要

$ u lr((z)) dot.op lr((X minus S)) gt.eq 0 quad arrow.l.r.double quad minus u lr((z)) dot.op X lt.eq minus u lr((z)) dot.op S $

把反向半直线删除。这就是 `Q1:L262–264` 的第三个法向量。Q1
支持误差为零的点、线段与射线案例；它不是可有可无的特殊处理。

Q2 的 `clip_wedge`（L157–166）没有这一零误差分支；Q2 正常流程固定使用
`DELTA_DEG=1.0`，所以该差异不会影响默认题设。

=== 2.5 多次观测与一个可手算的交会例子
<多次观测与一个可手算的交会例子>
对于 $m$ 条观测，

$ P eq sect.big_(i eq 1)^m W lr((S_i comma z_i comma delta)) eq brace.l X colon n_j dot.op X lt.eq c_j comma med j eq 1 comma dots.h comma 2 m brace.r dot.basic $

用
$S_1 eq lr((0 comma 0)) comma z_1 eq 0^compose$，$S_2 eq lr((100 comma minus 100)) comma z_2 eq 90^compose$，$delta eq 1^compose$。第一条楔的中轴向东，第二条中轴向北，在
$lr((100 comma 0))$ 附近交会。原 Q1 函数实际给出四个顶点：

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,right,right,).at(col),
  inset: 6pt,
  [顶点], [$x$ / m], [$y$ / m],
  [$v_1$],
  [98.224567],
  [1.714516],
  [$v_2$],
  [98.284439],
  [−1.715561],
  [$v_3$],
  [101.714516],
  [−1.775433],
  [$v_4$],
  [101.776516],
  [1.776516],
)
]

例如交点 $v_4$ 同时满足 $y eq t x$ 和
$x eq 100 plus t lr((y plus 100))$，所以

$ x eq frac(100, 1 minus t) comma #h(2em) y eq frac(100 t, 1 minus t) dot.basic $

得到 $D eq 4.938542582$ m，$A eq 12.187172797$
m²。注意有误差的交会结果是一个区域，中心射线的交点只提供直觉，不能替代整个区域。

=== 2.6 选择它的理由与替代方案
<选择它的理由与替代方案>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [方法], [所需信息／输出], [本题如何取舍],
  [两条中心射线求交],
  [忽略有界误差，得到单点],
  [适合示意；不提供覆盖真源的区域],
  [最小二乘拟合方向],
  [需要选择残差与权重；通常得到单点],
  [可以另做估计，但无法仅靠拟合值回答“所有相容位置有多大”],
  [概率滤波、误差椭圆],
  [需要概率模型、协方差等],
  [题设没有足够信息直接校准置信概率],
  [角楔交],
  [只需误差上界，得到全部相容位置的外包络],
  [与 Q1 的多边形直径问题直接一致，也能供 Q2 做最坏情形选址],
)
]

#strong[保证的条件。]
真实方向误差确实不超过所用半宽、坐标约定正确，并忽略浮点误差时，真源一定属于所有角楔的交。若输入互相矛盾，可能得到空集，不能再声称“模型一定含真源”。

== 3. 方法二：半平面交，把不等式转成有序顶点
<方法二半平面交把不等式转成有序顶点>
=== 3.1 通用方法与外部讲义例题
<通用方法与外部讲义例题-1>
#strong[通用方法。] 已有 $n$
个闭半平面，求全部约束共同允许的区域，并区分空、有界、无界。二维半平面交可用分治、对偶凸包、按边界方向排序后维护队列等算法。

#strong[外部来源 \[E2\]。] David M. Mount 的《CMSC 754: Computational
Geometry》讲义第 8 讲 "Halfplane Intersection and Point-Line
Duality"，印刷页 40–41、图
34，展示若干上半平面交形成的下方折线边界，特别提醒结果可能无界或为空；随后给出“分别求两半集合，再合并凸区域”的分治算法。本源码使用方向排序加双端队列，属于同一问题的另一实现，不应说它逐行实现了讲义的分治法。

=== 3.2 先用一个小例子弄懂交集
<先用一个小例子弄懂交集>
约束为

$ x gt.eq 0 comma quad x lt.eq 2 comma quad y gt.eq 0 comma quad y lt.eq 1 dot.basic $

交集是矩形 $lr([0 comma 2]) times lr([0 comma 1])$。再加
$x plus y lt.eq 2$，右上角 $lr((2 comma 1))$ 被截掉，新增与边界的交点
$lr((2 comma 0))$、$lr((1 comma 1))$。这里 $lr((2 comma 0))$
原本已在边界，几何实现需要去重。

若再加 $x lt.eq minus 1$，结果为空。若一开始只有
$x gt.eq 0 comma y gt.eq 0$，结果是无界第一象限，不能用一个任意“大盒子”截断后把盒子的直径称为答案。

=== 3.3 第一步：规范化约束，才能比较松紧
<第一步规范化约束才能比较松紧>
`_normalise`（Q1:L43–59）把 $a x plus b y lt.eq c$ 除以
$sqrt(a^2 plus b^2)$，使法向量长度为 1。这样 $x lt.eq 2$ 与
$2 x lt.eq 4$ 会具有相同表示，`offset` 的大小才可直接比较。

同方向约束只保留较小的 `offset`：例如 $x lt.eq 3$ 与
$x lt.eq 2$，前者完全多余。`_ordered`（L73–87）先按边界方向排序，再合并同向平行约束，并检查排序角度接缝两端。

注意“同向平行”与“反向平行”不同。$x lt.eq 2$ 和 $x gt.eq 0$
不能合并，因为它们共同形成带状区域。`_same_direction`（L68–70）同时检查叉积近零和点积为正。

=== 3.4 为什么边界方向取 $lr((minus b comma a))$
<为什么边界方向取--ba>
对于 $n eq lr((a comma b))$，代码取 $d eq lr((minus b comma a))$。若
$X_0$ 在边界 $n dot.op X_0 eq c$ 上，则

$ "cross" lr((d comma X minus X_0)) eq minus n dot.op lr((X minus X_0)) dot.basic $

因此 $n dot.op X lt.eq c$ 等价于“沿 $d$
走时，可行域在左侧”。所有半平面都有相同的左右约定，队列删除规则才能统一。对应
`Q1:L62–65`。

=== 3.5 两条边界的交点如何算
<两条边界的交点如何算>
解

$ a_x x plus a_y y eq c_a comma #h(2em) b_x x plus b_y y eq c_b dot.basic $

令 $Delta eq a_x b_y minus a_y b_x$，则

$ x eq frac(c_a b_y minus a_y c_b, Delta) comma #h(2em) y eq frac(a_x c_b minus c_a b_x, Delta) dot.basic $

`_intersection`（Q1:L90–97）直接实现这个公式。$lr(|Delta|) lt.eq 10^(minus 12)$
时当作平行，返回
`None`。几乎平行意味着分母很小，交点可能很远、对角度扰动很敏感；这同时是物理交会质量差和数值计算困难的信号。

=== 3.6 双端队列维护的究竟是什么
<双端队列维护的究竟是什么>
`active`
中存的是当前边界半平面，不是观测点，也不是顶点。相邻两条边界的交点是候选区域顶点。

按方向加入新半平面 `hp` 时：

+ 若队尾最后两条边界的交点落在 `hp`
  外面，队尾边界已经不可能继续成为最终交集边界，弹出队尾，直到尾部合法。
+ 同样检查队首两条边界，必要时弹出队首。
+ 把新半平面加入队尾。
+ 全部加入后，队首与队尾要闭合，再清理两端。

这对应
`Q1:L201–218`。`_cuts`（L105–107）组合“求交点”和“在不在新约束外”两件事。

#strong[不要逐字背两个 `while`。]
应说："我维护按方向排列的有效边界；新约束会使两端的一些相邻交点失效，因此从两端删掉已经被覆盖的边界。"

=== 3.7 从候选顶点到可信输出，还做了什么
<从候选顶点到可信输出还做了什么>
主流程没有直接相信队列。它还：

- 对候选交点求凸包，消除重复、共线中间点，统一顺序（L220）；
- 检查每个候选顶点是否满足#strong[所有原始约束]（L225）；
- 对只有一点或一条线段的结果检查原约束是否真的限制了所有无界方向（L221–224）；
- 主流程未能形成有效有限区域时，寻找一个可行点，再分辨空、无界、数值不确定（L228–237）。

Q1 没有加入人工大边框，所以能诚实地输出 `unbounded`。

=== 3.8 为什么能用法向量的最大角间隙检查有界性
<为什么能用法向量的最大角间隙检查有界性>
若存在非零方向 $v$，使所有法向量满足
$n_i dot.op v lt.eq 0$，则从一个可行点 $X_0$ 出发，

$ n_i dot.op lr((X_0 plus t v)) lt.eq n_i dot.op X_0 lt.eq c_i comma quad t gt.eq 0 dot.basic $

整条射线都在区域中，因此区域无界。这类 $v$ 称为衰退方向。

二维中，所有法向量若能塞进某个闭半圆，就存在相应的逃逸方向；若法向量绕一圈后的任意相邻间隔都小于
$180^compose$，则不存在这种非零方向。`_is_bounded`（Q1:L135–141）通过排序法向角、检查包括首尾接缝在内的最大间隙来判别。代码多留了
`PARALLEL_EPS` 裕量。

这个判定要配合非空性使用。空集不能靠“有没有逃逸方向”判断，所以程序先寻找可行点。

=== 3.9 `_feasible_point` 的边界降维思想
<feasible_point-的边界降维思想>
从 $X eq lr((0 comma 0))$
开始遍历约束。如果当前点违反新约束，就试着在新约束的边界上找一个满足已有约束的点。边界参数化为

$ X lr((t)) eq c n plus t lr((minus n_y comma n_x)) $

（因为 $n$ 已是单位向量）。每个旧半平面都变成一个关于 $t$
的一维不等式，更新 `lower` 或 `upper`；区间为空时就不可行。对应
`Q1:L110–132`。

例：新边界 $x eq 2$ 写成 $lr((2 comma t))$；旧约束
$y gt.eq 0 comma y lt.eq 1$ 给出 $0 lt.eq t lt.eq 1$，于是
$lr((2 comma 0))$ 就是可行见证。

=== 3.10 六种状态，以及复杂度的准确说法
<六种状态以及复杂度的准确说法>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [`status`], [含义], [直径／面积],
  [`polygon`],
  [有限二维凸多边形],
  [有有限值],
  [`segment`],
  [退化为线段],
  [直径为长度，面积 0],
  [`point`],
  [退化为一点],
  [直径与面积均为 0],
  [`empty`],
  [约束无共同可行点],
  [代码用 `None`，JSON 为 `null`],
  [`unbounded`],
  [有可行点，但区域无界],
  [不输出人为有限值，附可行见证点],
  [`uncertain`],
  [已发现可行且按判据有界，但主流程未可靠构造有限形状],
  [需要检查退化和数值条件；不能自动当作空集],
)
]

方向排序加队列的标准核心是
$O lr((n log n))$，队列中每条边界进出至多常数次。但是#strong[整份当前 Q1
实现不能直接宣称最坏 $O lr((n log n))$]：L225 的“全部约束 ×
全部顶点”验证最坏为 $O lr((n^2))$，兜底 `_feasible_point`
也有二重循环。本文据源码把完整实现的最坏上界写为
$O lr((n^2))$，同时指出几何核心的较优复杂度。

这不是说程序一定慢。题目一条观测只增加两个半平面，实际输入通常很小，额外检查有明确价值。

== 4. 方法三：凸包与旋转卡壳计算区域直径
<方法三凸包与旋转卡壳计算区域直径>
=== 4.1 通用方法与外部论文例题
<通用方法与外部论文例题>
#strong[通用方法。]
有限点集先取凸包；凸多边形的最远点对可从顶点的对踵对中寻找。旋转一对平行支撑线，维护可能构成最远点对的两侧顶点，避免枚举全部顶点对。

#strong[外部来源 \[E3\]。] Godfried Toussaint 的原论文 #emph[Solving
Geometric Problems with the Rotating Calipers]（IEEE
MELECON’83），§1、PDF 第 1 页与图
1，说明两个平行支撑线接触的顶点构成对踵对，旋转支撑线可枚举线性数量的此类点对。文中还特别讨论两边同时发生转动事件时的并列情形。以下矩形与数值例子是本章用于理解代码的自算例子，不冒充论文给出的坐标。

=== 4.2 为什么任意两点的最大距离只需查顶点
<为什么任意两点的最大距离只需查顶点>
设凸多边形顶点为 $v_1 comma dots.h comma v_k$，任意两点可写为

$ p eq sum_i alpha_i v_i comma #h(2em) q eq sum_j beta_j v_j comma quad alpha_i comma beta_j gt.eq 0 comma quad sum_i alpha_i eq sum_j beta_j eq 1 dot.basic $

于是

$ parallel p minus q parallel & eq ∥sum_(i comma j) alpha_i beta_j lr((v_i minus v_j))∥\
 & lt.eq sum_(i comma j) alpha_i beta_j parallel v_i minus v_j parallel\
 & lt.eq max_(i comma j) parallel v_i minus v_j parallel dot.basic $

反过来顶点也属于多边形，所以

$ D lr((P)) eq max_(i comma j) parallel v_i minus v_j parallel dot.basic $

这个证明才是“有限顶点代表连续区域”的理由。仅仅说“显然在角上”不足以解释算法。

=== 4.3 为什么源码还要重新求凸包
<为什么源码还要重新求凸包>
`_convex_hull`（Q1:L144–157）用上下链：先按坐标排序，遇到非左转就弹出前一个点。叉积不大于
`EPS`
的共线或右转点不保留在链中。这样可以处理无序点、重复点和共线中间点。

Q1 `polygon_diameter`（L160–181）首先再次取凸包。对于 0、1、2
个点分别处理，只有至少 3 个点才进入卡壳。Q2 在 L246–270
有自己的凸包和直径实现，#strong[没有从 Q1 文件导入函数]。

=== 4.4 面积比较为什么等价于“移动远侧卡壳”
<面积比较为什么等价于移动远侧卡壳>
固定凸包边 $v_i arrow.r v_(i plus 1)$，定义

$ H_i lr((j)) eq "cross" lr((v_(i plus 1) minus v_i comma med v_j minus v_i)) dot.basic $

因为边长对这一步不变，$H_i lr((j))$ 等于“边长 ×
顶点到边界直线的有向距离”。让 $j$ 前进，直到下一顶点的 $H_i$
不再增大，就找到该边对应的远侧支撑顶点。

源码的内层 `while` 正是在比较这个值（Q1:L173–176）。然后分别比较
$lr((v_i comma v_j))$、$lr((v_(i plus 1) comma v_j))$
两个距离（L177–180）。随 $i$
沿凸包移动，远侧顶点也沿凸包向前移动，无须对每条边从头扫描。

凸包已按环序给出时，卡壳部分为
$O lr((k))$；当前函数先做凸包，因此其整体包含 $O lr((k log k))$
的预处理。不要把函数总成本与卡壳核心成本混写。

=== 4.5 小例题：长 2、宽 1 的矩形
<小例题长-2宽-1-的矩形>
顶点依次是
$lr((0 comma 0)) comma lr((2 comma 0)) comma lr((2 comma 1)) comma lr((0 comma 1))$。底边对应的远侧支撑线是
$y eq 1$，有两个并列顶点。真实直径是对角线 $sqrt(5)$，不是长边
2，也不是矩形宽度 1。

这帮助区分三个概念：

- 面积：2；
- 某个方向上的宽度：随方向变化；
- 直径：所有方向上最大投影宽度，也等于最远点对距离。

代码使用 `> 当前面积 + EPS`
的前进条件，并比较边的两个端点。遇到平行边、重复点、共线点时，要结合凸包预处理和并列事件理解，不要用“严格大于”推断程序从来不会遇到并列情况。

== 5. Q1 的关键反例：直径的一半不总是覆盖半径
<q1-的关键反例直径的一半不总是覆盖半径>
=== 5.1 先精准回答题目问的圆
<先精准回答题目问的圆>
设 $p comma q$
为最远点对，$D eq parallel p minus q parallel$。最自然的“以定位区域直径为直径的圆”是以

$ c_D eq frac(p plus q, 2) comma #h(2em) r_D eq D / 2 $

为中心与半径的圆。Q1
`_finite_result`（L184–198）构造这个中心，计算所有顶点到中心的最大距离，并返回覆盖布尔值与余量。

因为圆盘是凸的，若全部多边形顶点都在圆盘内，则它们的所有凸组合都在圆盘内，也就是整个多边形都被覆盖。因此检查顶点足够。

=== 5.2 正三角形反例：一组坐标就能推翻“总能覆盖”
<正三角形反例一组坐标就能推翻总能覆盖>
取

$ A eq lr((0 comma 0)) comma quad B eq lr((40 comma 0)) comma quad C eq lr((20 comma 20 sqrt(3))) dot.basic $

三边都长 40 m，故 $D eq 40$ m。以 $A B$ 为直径的圆心是
$lr((20 comma 0))$，半径 20 m。但

$ parallel C minus lr((20 comma 0)) parallel eq 20 sqrt(3) approx 34.641 gt 20 dot.basic $

因此它不能覆盖三角形。最小包围圆的圆心为
$lr((20 comma 20 slash sqrt(3)))$，半径

$ R eq 40 / sqrt(3) approx 23.094 med upright("m") dot.basic $

所以 $D lt.eq 40$ m 不能保证某个清除点距离所有可能源都不超过 20
m。这正是 Q2 引入 MEC 的理由。

该反例直接调用现有函数得到：

```text
Q1 polygon_diameter: 40.0
Q1 diameter_circle_covers: False
Q1 diameter_circle_cover_margin_m: -14.641016151377542
Q2 minimum_enclosing_circle:
  center = (20.0, 11.54700538379251)
  returned radius = 23.094010867585034
```

最后一个半径比数学精确值大 $10^(minus 7)$ m，这是 Q2
的覆盖审计裕量，不是新几何现象。

=== 5.3 能不能换一个圆心，仍用半径 $D slash 2$ 覆盖
<能不能换一个圆心仍用半径-d2-覆盖>
也不能任意换。若某半径为 $D slash 2$ 的圆同时包含距离为 $D$
的两个端点，则

$ D eq parallel p minus q parallel lt.eq parallel p minus c parallel plus parallel c minus q parallel lt.eq D dot.basic $

两次不等式都必须取等号。于是圆心只能是中点，而且两端必须恰好在圆上。因此当前选定的最远点对直径圆如果漏掉其他点，就不存在“换个圆心但保持同样半径”的解决办法。

#strong[一个有用结论：] 若 Q1 输出
`diameter_circle_covers=True`，忽略浮点裕量时，这个圆就是
MEC，因为任意覆盖圆半径都不能小于 $D slash 2$，而现在已经用 $D slash 2$
完成了覆盖。若为 `False`，Q1 没有继续求
MEC；它只完成题目要求的覆盖判定。

=== 5.4 余量怎么读
<余量怎么读>
代码返回

$ upright("margin") eq D slash 2 minus max_v parallel v minus c_D parallel dot.basic $

- 明显负值：有顶点漏出圆；
- 接近 0：最远点对端点本来就在圆上，所以这很正常；
- 例如 $minus 2.5 times 10^(minus 14)$ m：双精度舍入量级，程序通过
  `EPS=10^{-10}` 判断为覆盖。

对非空有限区域，这个余量理论上不可能显著为正，因为最远点对两端的距离已经是
$D slash 2$。因此不要把它当作通常会有较大正值的“冗余安全半径”。

== 6. 方法四：最小包围圆把定位质量连接到清除动作
<方法四最小包围圆把定位质量连接到清除动作>
=== 6.1 通用方法与真正的外部应用例题
<通用方法与真正的外部应用例题>
#strong[通用方法。] 给定点集 $V$，选择中心
$c$，使最远点到中心的距离最小：

$ min_(c in bb(R)^2) max_(v in V) parallel v minus c parallel dot.basic $

#strong[外部例题 \[E4\]。] ETH Zürich 官方讲义 #emph[Geometry:
Combinatorics & Algorithms] 的 Appendix G "Smallest Enclosing
Balls"，印刷页 232、图
G.1，以村庄消防站选址为例：把房屋看作点，假设出行时间与欧氏距离成正比，最小化最慢到达某户的时间，就应把消防站放在最小包围圆中心。第
235 页讨论二维解由至多三个点确定，§G.2 介绍 Welzl 算法。B
题中，房屋点被替换为所有可能源位置，消防站位置被替换为下一步清除点。

=== 6.2 为什么顶点的 MEC 就是多边形的 MEC
<为什么顶点的-mec-就是多边形的-mec>
若圆盘包含顶点，则包含它们的凸包。反之，包含整个多边形当然包含顶点。因此，求连续多边形的最小包围圆，等价于求其有限顶点集的最小包围圆。Q2
`polygon_metrics`（L272–275）据此直接把顶点交给
`minimum_enclosing_circle`。

这与“直径只需检查顶点”的证明相关，但不是同一个推理：这里用的是圆盘的凸性，那里用的是凸组合与三角不等式。

=== 6.3 一个圆最多需要三个支撑点
<一个圆最多需要三个支撑点>
非空有限点集的最小包围圆可能由下列情形确定：

+ 只有一个位置：半径 0。
+ 两个点在直径两端：圆心是中点，半径为两点距离一半。
+ 三个不共线支撑点共同决定外接圆。三角形若是锐角，可能需要这三个点；若为钝角或直角，最长边的直径圆已经覆盖三角形。

直觉解释：若边界上的所有约束点都挤在圆周某个开半圆内，圆心可以往它们方向略移，使最大距离变小，原圆便不可能最优。最优圆的支撑点必须从相互制约的方向“卡住”圆心。二维最多三个支撑点就足够。

=== 6.4 两点圆与三点圆的计算
<两点圆与三点圆的计算>
两点圆是中点加半距离，对应 `Q2:L186–188`。

三点圆令 $u eq b minus a comma v eq c minus a$，未知圆心写为
$a plus w$。等距条件

$ parallel w parallel^2 eq parallel w minus u parallel^2 eq parallel w minus v parallel^2 $

消去 $parallel w parallel^2$，得到

$ 2 u dot.op w eq parallel u parallel^2 comma #h(2em) 2 v dot.op w eq parallel v parallel^2 dot.basic $

解这个二元线性方程组便得到 `_circumcircle`（Q2:L191–199）。分母是
$2 "cross" lr((u comma v))$；若近零，三点近共线，代码返回
`None`，避免用极小分母生成极大圆心。

=== 6.5 当前增量算法到底做了什么
<当前增量算法到底做了什么>
`minimum_enclosing_circle`（Q2:L202–235）的过程：

+ 用固定种子 `20260911` 打乱点顺序，让运行可复现。
+ 逐点加入。若新点已在当前圆内，当前圆仍能覆盖已处理点，无须重建。
+ 若新点 $p$ 在外，重建时把 $p$ 当作边界约束；遇到第二个违反点
  $q$，先尝试两点直径圆。
+ 对更早的违反点 $r$，计算经过 $p comma q comma r$ 的圆，并按 $p q$
  左、右两侧维护候选。
+ 选满足这一增量边界结构的候选，继续处理。
+ 最后固定得到的圆心，重新计算它到#strong[所有输入点]的最大距离，再加
  $10^(minus 7)$ m。

这是随机增量最小包围圆思想的实现；Welzl 原论文 \[E5\]
可以帮助理解小支撑集合与随机增量，但不要把当前三重循环说成逐行照抄 Welzl
的递归伪代码。

#strong[最后审计保证什么？]
它保证按当前浮点距离计算，返回半径覆盖输入顶点。即使中间舍入造成半径略小，最终会补足。它本身不能证明最终圆心在所有可能圆心中严格最优，也不等价于区间算术意义的机器证明。理论上的
MEC 性质与当前浮点实现的审计要分别说明。

=== 6.6 为何不用所有两点、三点组合暴力算
<为何不用所有两点三点组合暴力算>
暴力思路很适合用来理解和核对小例子：枚举所有两点圆、三点外接圆，逐个检查是否覆盖全部点，选半径最小者。但三点组合有
$O lr((k^3))$ 个，每个再检查 $k$ 个点，朴素总成本可达 $O lr((k^4))$。Q2
要对大量第二站和大量第二示向度重复求圆，增量法更合适。

随机增量理论在合适的随机顺序和精确谓词条件下可给出良好的期望效率；当前固定伪随机种子是可复现性措施，不能据此宣称每份输入的确定性最坏时间都是线性的。直接按源码三重循环计数，可给出
O(k³) 的朴素最坏上界；这与随机增量理论的期望效率是不同口径。

=== 6.7 三个质量指标为何保留，但不能混用
<三个质量指标为何保留但不能混用>
#align(center)[#table(
  columns: 4,
  align: (col, row) => (auto,auto,auto,auto,).at(col),
  inset: 6pt,
  [指标], [问的是什么], [优点], [局限],
  [$D$],
  [两个相容位置最多相隔多远],
  [与 Q1 直接一致，容易解释],
  [$D slash 2$ 未必能覆盖区域],
  [$R$],
  [最好的单个中心距离最坏位置多远],
  [直接对应 20 m 清除距离],
  [必须求覆盖圆；两个观测通常未必足够达到 20 m],
  [$A$],
  [相容位置占多大面积],
  [描述总体区域大小],
  [很长很细的区域面积小，最远距离仍可能很大],
)
]

例如长 100、宽 0.01 的矩形面积仅 1 m²，但覆盖半径约 50
m。面积小不能代替清除可靠性。

对平面有限集合有

$ D / 2 lt.eq R lt.eq D / sqrt(3) dot.basic $

下界来自任意最远点对。上界可由支撑点分情况理解：两点支撑时
$R eq D slash 2$；三点支撑时，圆心周围三个方向至少有一个相邻圆心角不小于
$120^compose$，而最小圆支撑结构保证相关间隔不超过
$180^compose$，对应弦长至少 $sqrt(3) R$，所以
$D gt.eq sqrt(3) R$。正三角形取等号。

因此，$D lt.eq 40$ m 只是 $R lt.eq 20$ m
的必要条件；$D lt.eq 20 sqrt(3) approx 34.641$ m 是充分条件。直接算 MEC
可避免只用直径时的间隙。

== 7. 方法五：用鲁棒约束推出第二检测点的安全候选域
<方法五用鲁棒约束推出第二检测点的安全候选域>
=== 7.1 通用方法与外部讲义例题
<通用方法与外部讲义例题-2>
#strong[通用方法。] 决策 $s$ 必须对所有允许的不确定参数 $u in U$
满足约束：

$ g lr((s comma u)) lt.eq 0 quad forall u in U quad arrow.l.r.double quad sup_(u in U) g lr((s comma u)) lt.eq 0 dot.basic $

先明确 $U$
包含哪些情形，再把“所有情形”化成可计算的最坏值。这是鲁棒可行性的核心。

#strong[外部例题 \[E1\]。] 官方《Convex Optimization》原版讲义 "Robust
linear programming" 与 "deterministic approach via SOCP"，页
4–26、4–27，讨论线性约束的系数
$a eq a^(‾) plus P u comma parallel u parallel_2 lt.eq 1$
不确定时，要求所有 $a$ 都满足 $a^T x lt.eq b$。把线性式对球内 $u$
取最大值，可写成
$a^(‾)^T x plus parallel P^T x parallel_2 lt.eq b$。本题不确定的是源位置和接收半径；同样先做最坏情形化简，但不因此声称整个选址问题也是
SOCP。

=== 7.2 先转到局部坐标，让几何只依赖首示向轴
<先转到局部坐标让几何只依赖首示向轴>
令第一站为局部原点，首示向轴为局部 $a$ 轴。第二站在局部写为
$s eq lr((a comma b))$。其世界坐标是

$ S_2 eq S_1 plus mat(delim: "(", cos z_1, minus sin z_1; sin z_1, cos z_1) vec(a, b) dot.basic $

这是 `Q2:L57–60` 的
`local_to_world`。旋转和平移不改变距离，安全性可以在局部推导，再转换到真实坐标。

固定基线 $L$ 时，

$ a eq L cos psi comma #h(2em) b eq L sin psi dot.basic $

对应 `candidate`（L403–405）。正负 $psi$ 表示首示向轴两侧。`candidate`
还有一个 `side` 参数，但外层优化实际把符号直接放进
`psi`，调用时没有额外传这个参数。

=== 7.3 第一条普通示向报告给出的位置信息
<第一条普通示向报告给出的位置信息>
暂时省略 5 m 近场内洞，理想的凸首测集合是

$ F_1 eq Omega sect B lr((S_1 comma 1500)) sect W lr((S_1 comma z_1 comma delta)) comma #h(2em) Omega eq B lr((lr((0 comma 0)) comma 1800)) dot.basic $

其中收到信号只说明源距第一站不超过自己的接收半径，而该半径至多
1500，所以可以加
$B lr((S_1 comma 1500))$。#strong[不能由“收到信号”推出距离至少 1000。]
1000 是接收能力的下界，不是源到检测点的距离下界。

如果忽略世界圆域截断，局部外包络为扇区

$ cal(S)_1500 eq brace.l r u lr((eta)) colon 0 lt.eq r lt.eq 1500 comma med lr(|eta|) lt.eq delta brace.r dot.basic $

它包含真实首测可能位置。用它设计安全点，比利用某个特定首站位置的世界圆域截断更保守，但表达更简单、能够统一复用。

=== 7.4 默认安全域：统一按 1000 m 保证接收
<默认安全域统一按-1000-m-保证接收>
代码主流程采用

$ K_U eq lr({s colon max_(g in cal(S)_1500) parallel s minus g parallel lt.eq 1000}) dot.basic $

解释：无论真源在首测扇区哪个位置，第二站与它的距离都不超过
1000，而全向源的实际接收半径至少是
1000。因此第二站保证有信号。若距离不超过 5
m，可能得到过强信号而非普通方向报告，但这已经允许直接清除；这里“接收安全”不等同于“一定产生普通示向角”。

函数是
`safe_uniform_1000`（Q2:L91–94）。它没有使用某个生成器真值，也不检查某一个猜测源，而是检查整个扇区。

=== 7.5 无限多个源位置，如何精确化成少数候选极值
<无限多个源位置如何精确化成少数候选极值>
对固定方向 $u lr((eta))$，

$ parallel s minus r u lr((eta)) parallel^2 eq parallel s parallel^2 plus r^2 minus 2 r thin s dot.op u lr((eta)) dot.basic $

这是关于 $r$ 的凸二次函数，在区间 $lr([0 comma R])$
上的最大值一定出现在端点 $r eq 0$ 或 $r eq R$。所以

$ max_(0 lt.eq r lt.eq R comma lr(|eta|) lt.eq delta) parallel s minus r u lr((eta)) parallel^2 eq max lr({parallel s parallel^2 comma parallel s parallel^2 plus R^2 minus 2 R min_(lr(|eta|) lt.eq delta) s dot.op u lr((eta))}) dot.basic $

对 $s eq lr((a comma b))$，需要最小化
$a cos eta plus b sin eta$。候选位置包括两端
$eta eq plus.minus delta$，以及位于区间内的反向方向
$eta eq "atan2" lr((b comma a)) plus pi plus 2 k pi$。这就是
`_sector_max_distance_sq`（L63–77）为什么除了两个端点，还检查内部反向方向。

对实际的向前安全候选，最小投影是

$ a cos delta minus lr(|b|) sin delta dot.basic $

于是默认安全约束可以明确写成

$ a^2 plus b^2 lt.eq 1000^2 $

及

$ a^2 plus b^2 plus 1500^2 minus 3000 lr((a cos delta minus lr(|b|) sin delta)) lt.eq 1000^2 dot.basic $

在本题 $delta eq 1^compose$
的几何下，也可将该域理解为三个圆盘的交：分别以
$0$、$1500 u lr((minus delta))$、$1500 u lr((delta))$ 为圆心、半径均为
1000。满足这些约束的点位于扇区前方，内部反向极值不会成为遗漏项。通用函数仍检查反向方向，以便正确处理任意传入的
$s$。

=== 7.6 固定基线上的安全弧：公式逐步来
<固定基线上的安全弧公式逐步来>
代入 $a eq L cos psi comma b eq L sin psi$，得到

$ a cos delta minus lr(|b|) sin delta eq L cos lr((lr(|psi|) plus delta)) dot.basic $

所以安全性要求

$ 0 lt L lt.eq 1000 comma #h(2em) cos lr((lr(|psi|) plus delta)) gt.eq frac(L^2 plus 1500^2 minus 1000^2, 2 L dot.op 1500) dot.basic $

从而

\$\$

|| ()-.

\$\$

角度必须使用同一单位。`safe_angle_limit`（Q2:L97–111）内部将 `acos`
的弧度结果转成度，再减去
`delta_deg`。当右侧无意义或非正时，优化器不搜索非共线安全候选。

原函数实际计算的上界如下：

#align(center)[#table(
  columns: 3,
  align: (col, row) => (right,right,right,).at(col),
  inset: 6pt,
  [$L$ / m], [默认统一 1000 m 域的 $bar.v psi bar.v$ 上界],
  [`full_information` 域上界],
  [600],
  [25.562841°],
  [71.542397°],
  [700],
  [33.047732°],
  [68.512685°],
  [800],
  [37.047507°],
  [65.421822°],
  [900],
  [39.273893°],
  [62.256316°],
  [1000],
  [40.409622°],
  [59.000000°],
)
]

这解释了为何“沿首示向轴垂直走，构造 90°
基线”不能作为统一保证接收的策略：它可能走出安全域。两条实际观测射线在源处的交会角，与第二站相对首示向轴的
$psi$，也不是同一个角。

默认域的最短可行基线不是精确的 500 m。令 $psi eq 0$，解安全边界：

$ L_min eq 1500 cos delta minus sqrt(1000^2 minus 1500^2 sin^2 delta) approx 500.114261 med upright("m") dot.basic $

在该最短值上只能位于轴线上；若要非零偏角，基线还要略长。`safe_angle_limit(500)`
返回 0，并不表示 $lr((500 comma 0))$ 在 ±1°
扇区下安全；优化器会拒绝这个非正角度范围，实际安全性函数也会再次验证候选。

=== 7.7 代码还提供的全信息安全域：为什么更大
<代码还提供的全信息安全域为什么更大>
设源到第一站的真实距离为 $r$，源的固定接收半径为
$rho in lr([1000 comma 1500])$。第一站已经收到信号，意味着
$rho gt.eq r$。因此，对这个源位置，最小相容接收半径其实是

$ rho_min lr((r)) eq max lr((1000 comma r)) dot.basic $

完整利用这条信息时，只需

$ parallel s minus r u lr((eta)) parallel lt.eq max lr((1000 comma r)) quad upright("对全部允许的 ") r comma eta dot.basic $

对 $r lt.eq 1000$，就是以 1000 为半径覆盖扇区 $cal(S)_1000$。对
$r gt.eq 1000$，平方后是

$ parallel s parallel^2 minus 2 r thin s dot.op u lr((eta)) lt.eq 0 dot.basic $

若在 $r eq 1000$ 已成立，那么
$s dot.op u lr((eta)) gt.eq parallel s parallel^2 slash 2000 gt.eq 0$，左侧随
$r$ 增大而减小，所以更远的 $r$ 自动满足。于是可归结为

$ K_F eq lr({s colon max_(g in cal(S)_1000) parallel s minus g parallel lt.eq 1000}) dot.basic $

这就是 `safe_full_information`（Q2:L80–88）。固定基线时得到

$ 0 lt L lt.eq 1000 comma #h(2em) lr(|psi|) lt.eq arccos L / 2000 minus delta dot.basic $

有 $K_U subset.eq K_F$，所以利用接收信息后可选范围更大。

#strong["全信息"这个名称的准确边界。] 函数注释中的 "Exact robust domain"
对这里所用的#strong[未截断、含 $r eq 0$
的理想扇区模型]成立。若进一步利用真实世界圆域截断，以及普通方向报告必须
$r gt 5$，真正最大候选域还可能更大。因此不能把它称为“用尽了 B
题所有条件后的最大安全域”。

主入口 `solve_case` 没传 `domain`，所以仍用默认
`uniform1000`。函数存在不等于主流程采用。论文若把最终实验说成使用全信息域，应先改程序并重跑；当前章节只解释现状。

=== 7.8 选更保守的域有什么意义，又牺牲了什么
<选更保守的域有什么意义又牺牲了什么>
统一 1000 m
域的优点是保证简单：候选点距每个相容源都不超过最小接收半径；公式与坐标位置关系清楚，也便于给出统一候选弧。

代价是可能排除更好的站点，特别是利用“首站已收到远距离源，源的实际接收半径不可能只有
1000”后，可以有更大横向基线。当前代码是一种#strong[在选定保守域内的可复现策略]，不应宣称已经优化全部物理允许的位置。

下面的函数值可用于自检：

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [局部候选 $s$ / m], [`safe_uniform_1000`], [理由],
  [$lr((1000 comma 0))$],
  [`True`],
  [扇区尖端到候选的距离恰为 1000；远端也在允许范围内],
  [$lr((0 comma 600))$],
  [`False`],
  [1500 m 扇区远端距离约 1625.243 m],
  [$lr((800 comma 400))$],
  [`True`],
  [扇区上的最大距离约 894.427 m],
  [$lr((600 comma 400))$],
  [`True`],
  [扇区上的最大距离约 995.599 m],
)
]

安全只解决“能否保证接收到这个源”，并不直接解决“定位多准确”。例如
$lr((1000 comma 0))$ 可能与首测轴几乎共线，接收安全而交会质量差。

== 8. 方法六：逐半平面裁剪与圆的外接多边形
<方法六逐半平面裁剪与圆的外接多边形>
=== 8.1 通用方法与有坐标的外部例题
<通用方法与有坐标的外部例题>
#strong[通用方法。]
已知一个有序多边形，用一条半平面约束逐条检查边，保留内部顶点，在穿越边界的边上插入交点。连续执行，就得到多边形与多个半平面的交。

#strong[外部例题 \[E6\]。] John E. Howland 在 Trinity University 的
#emph[Polygon Clipping]，§2、图 1–2，给出正方形
$lr((0 comma 0)) comma lr((100 comma 0)) comma lr((100 comma 100)) comma lr((0 comma 100))$
被直线 $y eq x minus 50$ 裁剪的例子。保留 $y gt.eq x minus 50$
一侧后，右下角被去掉，新顶点为
$lr((50 comma 0))$、$lr((100 comma 50))$，得到五边形。讲义用 J
语言解释数组实现；本代码采用逐边循环，几何思想一致。

=== 8.2 四种边穿越情况
<四种边穿越情况>
对边 $a arrow.r b$，定义

$ f lr((a)) eq n dot.op a minus c comma #h(2em) f lr((b)) eq n dot.op b minus c dot.basic $

理想内侧为 $f lt.eq 0$。

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [起点 $a$], [终点 $b$], [该边对输出贡献],
  [内],
  [内],
  [终点 $b$],
  [内],
  [外],
  [边界交点],
  [外],
  [内],
  [边界交点，然后终点 $b$],
  [外],
  [外],
  [不添加],
)
]

交点写成 $a plus t lr((b minus a))$。因为 $f$ 是仿射函数，

$ 0 eq f lr((a)) plus t lr((f lr((b)) minus f lr((a)))) quad arrow.r.double quad t eq frac(f lr((a)), f lr((a)) minus f lr((b))) dot.basic $

`clip_halfplane`（Q2:L124–144）直接用这个公式；再去掉相邻的几乎重复点。它从最后一个顶点开始连接到第一个顶点，因此隐式处理了闭合边，不需要输入列表末尾重复首顶点。

=== 8.3 为什么 Q2 不直接重用 Q1 的队列
<为什么-q2-不直接重用-q1-的队列>
Q1 从一批角楔半平面开始，允许无界结果；Q2
已有圆域的有限多边形外包络，并且要反复加入首测楔、第二站接收圆、第二测楔。保持一个有序有限多边形，再做增量裁剪，代码接口很自然。

两种方法没有数学冲突。它们都在求凸集合交，只是维护的状态不同：Q1
主要维护有效边界队列，Q2 主要维护当前顶点列表。

=== 8.4 圆不能直接写成有限个半平面：要选外包络
<圆不能直接写成有限个半平面要选外包络>
真圆盘为 $B lr((c comma r))$。取 $n$ 个均匀法向量

$ u_k eq u lr((2 pi k slash n)) comma quad k eq 0 comma dots.h comma n minus 1 comma $

使用切线半平面

$ u_k dot.op X lt.eq u_k dot.op c plus r dot.basic $

每个圆内点都满足这些约束，因此交出的正多边形包含整个圆盘。这个多边形的顶点半径为

$ r_v eq frac(r, cos lr((pi slash n))) comma $

顶点角为
$lr((2 k plus 1)) pi slash n$。`circle_outer_polygon`（Q2:L114–121）正是这样生成初始世界圆域；`clip_disk_outer`（L147–154）则逐条加入另一个圆盘的切线半平面。

如果把顶点直接放在半径 $r$
的圆上，会得到#strong[内接]多边形，可能把真实合法位置删掉。集合成员定位通常需要保留真源，所以这里选择外接。

=== 8.5 外包络有多粗：可以量化，但别过度解释
<外包络有多粗可以量化但别过度解释>
单个半径 1500 m 圆的最坏径向外扩量是

$ e_n eq 1500 lr((sec pi / n minus 1)) dot.basic $

#align(center)[#table(
  columns: 3,
  align: (col, row) => (right,right,auto,).at(col),
  inset: 6pt,
  [边数 $n$], [单圆最大径向外扩 / m], [代码中的典型用途],
  [72],
  [1.429028],
  [`--quick` 外层搜索],
  [96],
  [0.803549],
  [默认外层搜索],
  [180],
  [0.228492],
  [`--quick` 最终复评],
  [360],
  [0.057118],
  [默认最终复评],
)
]

1800 m 圆的同类误差再乘
1.2。这里描述的是#strong[单个圆盘近似]，不能不经证明就把它当作最后定位半径误差上界：多个边界相交，尤其接近平行时，交点偏差可能被放大。

边数增加后通常更接近真圆，但 96 边与 360
边的法向网格不是简单的包含关系，多个集合交后的数值也不应机械声称单调递减。正确做法是记录分辨率，做收敛观察，同时保留“数值近似”的表述。

=== 8.6 首测集合和第二测集合的实际构造
<首测集合和第二测集合的实际构造>
`first_feasible_polygon`（Q2:L169–178）：

+ 生成 $Omega$ 的外接多边形；
+ 用 $B lr((S_1 comma 1500))$ 的外接切线裁剪；
+ 加首测角楔。

`physical_base`（L278–279）再用 $B lr((S_2 comma 1500))$
裁剪。`post_region`（L282–284）再加第二测角楔。

若用帽子表示代码中的外包络，则

$ hat(F)_1 eq hat(Omega) sect hat(B) lr((S_1 comma 1500)) sect W_1 comma $

$ hat(P)_2 lr((s comma z)) eq hat(F)_1 sect hat(B) lr((s comma 1500)) sect W lr((s comma z comma delta)) dot.basic $

`first_feasible_polygon` 文档明确说省略普通方向报告对应的 5 m
内洞，保持凸性。在真实普通报告模型中，两站都应满足距离大于 5
m；当前两站的角楔都含自己的顶点，因此这是一个有意放宽的模型。

对默认的理想统一安全域来说，第二站距全部首测真候选已经不超过 1000，故
1500 圆约束在精确模型中往往冗余。但 `robust_quality`
可独立对任意第二站调用，外包络也有数值扩张，所以源码仍显式保留这个物理距离条件。

== 9. 方法七：只在物理相容的第二示向度上做最坏情形分析
<方法七只在物理相容的第二示向度上做最坏情形分析>
=== 9.1 通用方法与外部最坏情形例题的联系
<通用方法与外部最坏情形例题的联系>
#strong[通用方法。]
设计一个动作前，考虑动作之后所有可能观测；每个观测又对应一组可能状态。优化应在“能够共同发生的状态—观测组合”上进行，而不是把各变量的单独取值范围直接做笛卡尔积。

这一做法仍采用第 7.1 节外部讲义 \[E1\]
的“对不确定集合取最坏值”思想。讲义例题中的不确定系数限制在指定椭球内；本题的不确定位置和示向度必须满足同一套角度、距离与场地条件。#strong[不确定集的定义本身就是模型的一部分。]
以下报告可行域是本题的推导，讲义没有现成的无线电公式。

=== 9.2 先写理想凸模型，再辨认代码近似
<先写理想凸模型再辨认代码近似>
在省略近场内洞但保留精确圆盘的模型中，

$ P_2 lr((s comma z)) eq F_1 sect B lr((s comma 1500)) sect W lr((s comma z comma delta)) dot.basic $

允许的第二示向度集合为

$ cal(Z) lr((s)) eq brace.l z in bracket.l 0 comma 360^compose paren.r colon P_2 lr((s comma z)) eq.not diameter brace.r dot.basic $

若交集里有一点 $g$，它同时符合首测、第二测方向及两站最远 1500 m
的接收限制，就存在一组相容源位置与有界方向误差；接收半径可取不小于两站距离和
1000 的数，且不超过 1500。

如果还要求普通方向报告，则必须排除
$parallel g minus S_1 parallel lt.eq 5$ 或
$parallel g minus s parallel lt.eq 5$
的点；当前代码没有排除。程序又用外接多边形代替圆，所以它实际使用

$ hat(cal(Z)) lr((s)) eq brace.l z colon hat(P)_2 lr((s comma z)) eq.not diameter brace.r dot.basic $

`robust_quality`
的注释（Q2:L313–316）称非空与报告物理可行相等价，理解时应加上模型边界：#strong[对它使用的凸放宽集合成立；对原题全部精确物理条件只是保守筛选。]
只有由于外包络误差或被省略近场条件才出现的报告，也可能被计算进去。

=== 9.3 一个不能随意拼接的例子
<一个不能随意拼接的例子>
第一站 $lr((0 comma 0))$，示向 $0^compose$，源距最多
1500。第一楔内的纵坐标至多约 $1500 sin 1^compose approx 26.18$ m。

若第二站为 $lr((600 comma 400))$，第二报告却取 $90^compose$，其 ±1°
楔指向北方，必须进入第二站上方。它不可能与第一楔在允许距离内相交。因此这份第二报告不应该参与“可能发生的最坏观测”。

进一步，若拿一个具体真源 $g eq lr((1000 comma 0))$，第二站到源方向是
$315^compose$。把这个真源与 $60^compose$
报告组合起来，也不满足误差约束。枚举“源的若干位置 ×
互不相关的示向度”而不做相容性检查，会混入不可能事件。

当前程序不先猜真源；它对每个第二报告直接构造后验可行集合，非空才评价，从而避免这种错误组合。

=== 9.4 正式目标的三层含义
<正式目标的三层含义>
主选点模型可以写成

\$\$

#emph[{sK\_U}  ]{zZ(s)}  #emph[{cR^2}  ]{gP\_2(s,z)}g-c.

\$\$

从右向左读：

+ 真源在当前报告相容的区域里，考虑离中心最远的可能位置；
+ 在已知第二报告之后，选择最佳覆盖中心，得到 MEC 半径；
+ 在不知道第二报告之前，考虑所有可能报告中最难定位的一种；
+ 选择使这个最坏结果最小的安全第二站。

代码实现的是它的空间外包络与有限搜索近似。Q1 对照把里侧的 MEC
半径换为区域直径：

$ min_(s in K_U) sup_(z in cal(Z) lr((s))) D lr((P_2 lr((s comma z)))) dot.basic $

#strong[顺序不能乱。] $sup_z min_c$ 允许在实际看到 $z$
后改变清除中心；$min_c sup_z$
则要求没看到第二报告就固定同一个中心，问题更严格，不是当前实现。

=== 9.5 `robust_quality`：按源码逐步追踪
<robust_quality按源码逐步追踪>
入口为 `Q2:L307–400`。固定一个世界坐标下的第二站 `second` 后：

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [步骤], [行号], [具体行为],
  [首测集合],
  [318],
  [按当前 `disk_sides` 构造 `first_poly`],
  [第二站距离约束],
  [319],
  [构造 `base`，暂时未加第二角楔],
  [缓存],
  [320–331],
  [报告归一到 `[0,360)`，保留十位小数作键；裁剪后非空才保存],
  [粗报告扫描],
  [333–346],
  [扫一整圈；空交集跳过；全部为空则报错],
  [局部极大候选],
  [351–368],
  [对 `R`、`D`、`A` 各找粗网格局部峰，最多保留前 8 个],
  [黄金分割],
  [369–391],
  [在各候选相邻粗网格区间内迭代 34 次，再加入末端若干点],
  [分别取三个最大值],
  [393–400],
  [记录最大半径、最大直径、最大面积及各自报告],
)
]

`polygon_metrics` 每次同时算三个指标，因此即使外层当前优化的是
`D`，内层也会计算 MEC 半径和面积。

=== 9.6 三个“最坏”通常不是同一份报告
<三个最坏通常不是同一份报告>
`RobustQuality`（Q2:L287–304）同时保留：

- `worst_R_m` 与 `report_at_worst_R_deg`；
- `worst_D_m` 与 `report_at_worst_D_deg`；
- `worst_A_m2` 与 `report_at_worst_A_deg`；
- `metrics_at_worst_R`：仅在最坏半径那份报告下的三种指标。

不能把 `worst_R_m,worst_D_m,worst_A_m2`
拼成一个必然存在的“最坏多边形”。它们是三个不同最大化问题的结果，最大值位置可以不同。想画一个具体后验区域，应选定一个报告，再调用
`post_region`。

=== 9.7 两个计数的名字容易误导
<两个计数的名字容易误导>
`feasible_report_count=len(records)`
包含粗网格非空报告与细化末尾加入的记录，可能有重复。它不是全连续圆周上可行报告的“数量”，也不是可行角区间长度。

`report_evaluations=len(cache)`
计的是缓存中#strong[不同的非空报告]。空交集不入缓存，所以它不是所有调用尝试次数。既不能把两者相除当作接收概率，也不能把它们当作采样均匀性的证据。

`RobustQuality.as_dict()` 明确添加
`continuous_report_maximum_certified=False`（L303）。这是精度口径的一部分。

主入口 `solve_case` 只挑选部分字段构造 `comparison`，所以最终 CLI JSON
不会原样保留这个诊断布尔值；它通过 `meets_20m_on_evaluated_reports`
的名称和顶层 `note`
说明采样范围。阅读函数级返回值与最终文件时要区分这一层摘要。

== 10. 方法八：两层粗细搜索与黄金分割
<方法八两层粗细搜索与黄金分割>
=== 10.1 通用方法与外部可复算例题
<通用方法与外部可复算例题>
#strong[通用方法。]
一维无导数搜索适合每次评价较贵、导数不容易取得的目标。黄金分割在单峰区间内逐步缩短搜索区间，并复用一处函数值；粗网格加局部细化则先寻找有竞争力的区域，再提高局部分辨率。

#strong[外部数值例题 \[E7\]。] Cornell University 的开放教材
#emph[Derivative free optimization]，"Numerical Examples / Example 1:
Golden Section Search"，使用
$f lr((x)) eq lr((x minus 2))^2 plus 1$，初区间
$lr([0 comma 5])$。首轮内点约为 1.91 和 3.09，前者函数值较小，区间缩为
$lr([0 comma 3.09])$，继续逼近
$x eq 2$。该网页有少量排版笔误，本章采用题干区间与正确加法重新计算，不照抄其有误的符号。Heath
的官方教学模块 \[E8\] 对应《Scientific Computing: An Introductory
Survey》§6.4.1、Algorithm 6.1、Example
6.8，特别说明保留极值的保证需要单峰条件。

=== 10.2 黄金比例为什么能复用函数值
<黄金比例为什么能复用函数值>
令 $tau eq lr((sqrt(5) minus 1)) slash 2 approx 0.618034$，有
$tau^2 eq 1 minus tau$。对区间 $lr([l comma r])$ 取

$ c eq r minus tau lr((r minus l)) comma #h(2em) d eq l plus tau lr((r minus l)) dot.basic $

若做单峰最大化，且 $f lr((c)) gt.eq f lr((d))$，保留
$lr([l comma d])$。旧的 $c$
恰好可成为新区间的一个黄金内点，因此只需算一个新点。最小化时比较方向相反。

Q2 内层在找最坏指标，所以是#strong[最大化版本]：L380 的条件是
`fc >= fd`。每次缩短后的区间长度约乘
$tau$，但区间缩得很短，只能说明这次局部搜索精细，不能证明没有漏掉另一个峰。

=== 10.3 本程序里，黄金分割只用于内层报告搜索
<本程序里黄金分割只用于内层报告搜索>
应区分两层：

#align(center)[#table(
  columns: 4,
  align: (col, row) => (auto,auto,auto,auto,).at(col),
  inset: 6pt,
  [层次], [变量], [目标], [实际方法],
  [内层],
  [第二报告 $z in bracket.l 0 comma 360^compose paren.r$],
  [在固定站点找最坏 $R comma D comma A$],
  [全圆粗扫描 + 每指标最多 8 个局部峰附近的 34 次黄金分割],
  [外层],
  [第二站偏角 $psi$],
  [在固定基线上找较小的最坏指标],
  [两侧粗网格 + 各侧最好角附近的细网格],
  [最外层],
  [基线 $L$],
  [比较不同长度],
  [默认只枚举 600、700、800、900、1000 m],
)
]

不能说程序在全部二维平面上做了连续全局优化，也不能说外层用的是黄金分割。

=== 10.4 外层 `optimize_fixed_baseline` 怎么选点
<外层-optimize_fixed_baseline-怎么选点>
`Q2:L408–469` 的流程：

+ 检查 `metric` 为 `R/D/A`。
+ 由 $L$ 算安全角上界，确定安全性函数。
+ 依次搜索负侧与正侧，角度大小从 `max(0.2,coarse_psi_deg)`
  开始，以粗步长推进。
+ 每个候选先过 `safety`，再转为世界坐标，调用 `robust_quality`。
+ 找本侧最好粗点，在其左右一个粗步长内用细网格再搜，并保持离轴至少 0.05°
  的侧别限制。
+ 在全部已评估候选中取最小分数。

`score`（L424–425）只用指定的单指标。虽然程序同时记录三种指标，但没有实现“先最小
R，再用 D 或 A 做字典序破同分”的规则。`min`
遇到完全相同的分数会按遍历顺序保留先出现项。

=== 10.5 为何一般场景必须搜两侧
<为何一般场景必须搜两侧>
若第一站恰为原点、首示向轴为坐标轴，世界圆域不截断首测 1500 m
扇区，精确几何关于该轴对称，两侧等价。

但一般第一站不在原点，1800 m 世界圆域对两侧的截断不同。此时
$lr((a comma b))$ 与 $lr((a comma minus b))$
可能对应不同首测可行集合边界，定位效果也可能不同。Q2:L427–430
明确解释了这个原因。

还有数值层面的细节：外接圆的法向网格固定在世界坐标中，正负侧细网格的起点、是否恰好落在安全端点也未必镜像一致。因此微小的正负差异不一定全是物理不对称。当前实现确实评估两侧，但没有保证两侧采样集合严格镜像。

=== 10.6 默认与 `--quick` 的真实参数
<默认与---quick-的真实参数>
#align(center)[#table(
  columns: 4,
  align: (col, row) => (auto,right,right,auto,).at(col),
  inset: 6pt,
  [参数], [默认 `solve_case`], [`solve_case(..., quick=True)`],
  [代码位置],
  [搜索时圆边数],
  [96],
  [72],
  [486],
  [搜索时报告粗步长],
  [1°],
  [2°],
  [487],
  [第二站粗偏角步长],
  [1°],
  [2°],
  [488],
  [第二站细偏角步长],
  [0.1°],
  [0.25°],
  [489],
  [选点后的圆边数],
  [360],
  [180],
  [503],
  [选点后的报告粗步长],
  [0.2°],
  [0.5°],
  [504],
  [每个内层局部区间黄金分割次数],
  [34],
  [34],
  [379],
)
]

`final_quality` 自身的默认 `report_step_deg=0.1`（L472–473），但
`solve_case` 调用时传入了上表的 0.2 或
0.5。看函数默认值时，必须继续检查调用处是否覆盖它。

`refine_step_deg` 虽出现在 `robust_quality`
的参数中，也由调用者传入，但函数体没有读取它。当前真正的内层细化由固定
34 次黄金分割决定。不能说“将这个参数减半，就把细化步长减半”。

粗报告扫描的真实步长为

$ frac(360^compose, ⌈ 360^compose slash upright("report_step_deg") ⌉) comma $

而非任意输入下都严格等于参数值。

=== 10.7 两套目标是否真的独立选点
<两套目标是否真的独立选点>
是。`solve_case`（Q2:L491–502）先遍历
`metric in ("D","R")`，在每个基线各运行一次
`optimize_fixed_baseline`，分别从 D 行与 R
行选最佳。因此对照是两套目标分别选点，而不是在一个已经选定的点上顺便报告两个指标。

然而它们#strong[允许选出同一个点]。若相关后验集合经常有
$R approx D slash 2$，两个目标排序相同完全合理。后面的固定种子演示就是这种情况，不能为展示方法差异而改写数值。

=== 10.8 最终复评的范围，以及尚未提供的证书
<最终复评的范围以及尚未提供的证书>
程序根据搜索分辨率的分数，先确定一份最佳 D 点和一份最佳 R
点，再只对这两个点提高分辨率复评（L503–513）。没有在高分辨率下把全部基线候选重新排序，也没有再优化基线和偏角。因此高精度复评有可能改变候选间真实排序，而主程序没有自动追回这一变化。

这些声明可以明确成立：

- 已评估候选满足程序的解析安全性检查；
- 给定已评估报告，其圆外包络在精确几何意义上包含真圆模型的相容位置；
- MEC 最后的距离审计覆盖输入顶点；
- 返回点在本次已记录搜索候选中分数最好。

这些声明当前不能成立：

- 已穷尽整个安全二维候选域；
- 已找到全部连续示向度中的精确最坏值；
- 34 次黄金分割证明报告目标在区间内单峰；
- 五个基线的最好结果就是连续基线全局最好；
- 复评通过 20 m 就自动得到连续全部报告上的清除保证。

=== 10.9 "外包络保守"与“有限最大值”为什么不能合并成保证
<外包络保守与有限最大值为什么不能合并成保证>
对一个确实可能的固定报告 $z$，理想情况下有

$ P_2 lr((s comma z)) subset.eq hat(P)_2 lr((s comma z)) comma quad R lr((P_2 lr((s comma z)))) lt.eq R lr((hat(P)_2 lr((s comma z)))) dot.basic $

但有限采样集合 $cal(Z)_h$ 只给出

$ max_(z in cal(Z)_h) R lr((hat(P)_2 lr((s comma z)))) comma $

而真正需要比较的是

$ sup_(z in cal(Z) lr((s))) R lr((P_2 lr((s comma z)))) dot.basic $

前者既有空间放大的向上误差，也可能有漏掉报告峰值的向下误差，二者大小未知，所以不能建立必然的大小关系。若需要严格证书，要额外发展区间分支定界、解析极值划分、经证明的连续性界加网格误差项等方法；当前源码没有这些步骤。

== 11. 从入口到输出：两问调用图与逐文件阅读顺序
<从入口到输出两问调用图与逐文件阅读顺序>
=== 11.1 Q1 调用图
<q1-调用图>
```mermaid
flowchart TD
    A["main：读 JSON"] --> B["solve_localization"]
    B --> C["_observation：检查与归一化"]
    C --> D["_wedge：每条观测的半平面"]
    D --> E["intersect_halfplanes"]
    E --> F["队列构形与全部约束校验"]
    E --> G["_feasible_point 与 _is_bounded"]
    F --> H["_finite_result"]
    H --> I["凸包、卡壳、面积、直径圆检查"]
    G --> J["empty / unbounded / uncertain"]
    I --> K["写结果 JSON"]
    J --> K
```

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [阅读顺序], [位置], [阅读时应回答的问题],
  [1],
  [Q1:L283–302 `main`],
  [JSON 取了哪些字段？输出写到哪里？],
  [2],
  [L268–280 `solve_localization`],
  [误差范围怎么检查？约束在哪里生成？],
  [3],
  [L240–265 `_observation/_wedge`],
  [角度从哪里来？为什么是这些法向量？],
  [4],
  [L43–107],
  [如何比较平行半平面、求交、判外？],
  [5],
  [L201–237],
  [怎样输出多边形？失败后如何区分状态？],
  [6],
  [L144–198],
  [直径怎么求？直径圆怎么判？],
  [7],
  [L110–141],
  [如何给出可行见证、判断是否无界？],
)
]

这是按数据流读，而不是从第一行开始平均用力。

=== 11.2 Q2 调用图
<q2-调用图>
```mermaid
flowchart TD
    A["main / solve_case"] --> B["D 与 R 分别遍历五条基线"]
    B --> C["optimize_fixed_baseline"]
    C --> D["安全角与安全性检查"]
    D --> E["候选局部坐标转世界坐标"]
    E --> F["robust_quality"]
    F --> G["首测集合与第二站距离裁剪"]
    G --> H["逐报告 post_region"]
    H --> I["polygon_metrics"]
    I --> J1["直径与面积"]
    I --> J2["最小包围圆"]
    J1 --> K["报告粗扫描与局部峰细化"]
    J2 --> K
    K -->|还有报告| H
    K --> L["候选得分与外层最小值"]
    L -->|还有候选| D
    L -->|搜索结束| M["两个选定点 final_quality"]
    M --> N["comparison 与 baseline_search"]
```

#align(center)[#table(
  columns: 4,
  align: (col, row) => (auto,auto,auto,auto,).at(col),
  inset: 6pt,
  [模块], [位置], [输入], [输出／职责],
  [`solve_case`],
  [Q2:L481–519],
  [首测点、首示向、基线列表],
  [两个方法的对照与十条基线搜索摘要],
  [`optimize_fixed_baseline`],
  [L408–469],
  [指标、固定基线、几何参数],
  [一个候选站点及搜索诊断],
  [`robust_quality`],
  [L307–400],
  [固定第二站],
  [有限报告搜索的最坏 R/D/A],
  [`first_feasible_polygon`],
  [L169–178],
  [首测点与角度、圆边数],
  [首测凸外包络],
  [`physical_base/post_region`],
  [L278–284],
  [首测多边形、第二站、第二报告],
  [第二测后验外包络],
  [`polygon_metrics`],
  [L272–275],
  [多边形顶点],
  [`Metrics(D,R,A,vertex_count)`],
  [`minimum_enclosing_circle`],
  [L202–235],
  [顶点集],
  [覆盖中心及审计后的半径],
  [`safe_angle_limit`],
  [L97–111],
  [基线与域名],
  [候选弧角度上界],
)
]

=== 11.3 同名概念在两问中的接口差别
<同名概念在两问中的接口差别>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [细节], [Q1], [Q2],
  [初始可行域],
  [只有观测角楔，允许无界],
  [世界圆、接收圆、首测楔的有限外包络],
  [核心交集接口],
  [一组半平面 → 状态与顶点],
  [一个多边形 + 一个半平面 → 新顶点],
  [空集处理],
  [返回 `status=empty`],
  [空列表；报告评价跳过它],
  [圆指标],
  [最远点对的直径圆是否覆盖],
  [最小包围圆半径],
  [误差半宽],
  [输入可设 `[0,90)`],
  [主入口固定 1°],
  [对真源的依赖],
  [不读取 `local_truth`],
  [不读取 `local_truth`],
  [`include_circle`],
  [保留兼容参数，但 L203 直接删除；不改变覆盖判定],
  [当前 Q2 自包含，不依赖这个参数],
)
]

`Q1:L16` 定义了
`NUMERICAL_ANGLE_GUARD_DEG=0.0`，本文件后续没有使用该常量。Q1/Q2 默认是
1°；不要把 Q3/Q4 中的 1.0051° 保护宽度移植成这里已执行的事实。

== 12. 亲手跑一遍：固定种子的完整数据流
<亲手跑一遍固定种子的完整数据流>
以下命令从仓库根目录执行。生成器会自动创建输出目录。都只使用 Python
标准库；无须安装几何库。

=== 12.1 Q1：生成器如何保证数据与误差模型相容
<q1生成器如何保证数据与误差模型相容>
`source/Q1/q1_generator.py`：

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [行号], [实际操作], [学习要点],
  [10–16],
  [读取种子、点数；实际点数至少 3],
  [`--points 1` 也会生成 3 点，默认 4 点],
  [17–19],
  [在半径 1476 m 的圆域按面积均匀抽真源],
  [半径使用 `sqrt(random())`，1476 来自 `1800*0.82`],
  [21–25],
  [在真源周围分散生成站点，距源 500–1450 m，坐标保留六位小数],
  [检测点不保证位于 1800 m 源分布圆内；题目允许这种位置],
  [26–32],
  [从量化后的检测点计算真实方位，生成误差，再量化到两位小数],
  [量化后重新检查圆周角差是否仍在 ±1° 内，不合格就重抽],
  [34–38],
  [输出观测与 `local_truth`],
  [真值仅用于本地核验],
)
]

角度差计算是 `(report-true+180)%360-180`。若真实方位为 359.8°、报告为
0.2°，误差应为 +0.4°，不是 −359.6°。

运行：

```bash
python source/Q1/q1_generator.py --seed 20260929 --output demo-output/q1_input.json
python source/Q1/q1_solver.py --input demo-output/q1_input.json --output demo-output/q1_result.json
```

生成的输入如下；仅压缩排版，数值与实际文件一致：

```json
{
  "case_id": "Q1-seed-20260929",
  "seed": 20260929,
  "epsilon_deg": 1.0,
  "observations": [
    {"position_m": [-1387.941092, 283.869424], "bearing_deg": 51.26},
    {"position_m": [-33.75358, 465.709799], "bearing_deg": 156.52},
    {"position_m": [-507.343228, 1643.695729], "bearing_deg": 241.44},
    {"position_m": [-1859.196669, 1169.791143], "bearing_deg": 341.28}
  ],
  "local_truth": {"source_m": [-937.2356958408238, 851.1315076011092]}
}
```

求解器的数据流：`main` 只把 `payload["observations"]`、`epsilon_deg`
交给几何求解函数，并补上 `case_id`（Q1:L289–290）。`seed` 和
`local_truth` 不参与定位。你可以删除 `local_truth`
后再运行，定位结果应相同。

=== 12.2 Q1 的已验证输出及解释
<q1-的已验证输出及解释>
控制台：

```text
状态: polygon
顶点数: 6
面积: 773.517 m²
直径: 44.459 m
```

结果文件中的关键精确数值：

```json
{
  "status": "polygon",
  "diameter_m": 44.458563995429614,
  "diameter_pair_m": [
    [-913.1643932192687, 866.1097286754843],
    [-952.8287894718245, 846.0274085292475]
  ],
  "area_m2": 773.5172572679585,
  "diameter_circle_covers": true,
  "diameter_circle_cover_margin_m": -2.4868995751603507e-14
}
```

该例直径圆覆盖全部六个顶点，数学 MEC 半径为直径的一半，约 22.229282
m，因此这两类尺度都提示：尚不能根据整个可行区域保证一次 20 m
清除。余量的极小负数是舍入误差，不能解释为漏出了可观距离。

你还应打开
`vertices_m`，确认六个点按凸包环序排列。它们不是六个真源，也不是六次随机估计，而是相容区域的边界顶点。

=== 12.3 Q2：首测生成器的输入追踪
<q2首测生成器的输入追踪>
`source/Q2/q2_generator.py` L14–20 将首站随机放在距原点最多 450 m
处，再相对首站生成距 450–1400 m 的源；若源离原点超过 1750 m，则缩回 1750
m 圆周。L21–25 同样在两位小数量化后拒绝越过 ±1°
的报告。首站半径直接均匀抽样，因此不是在圆内按面积均匀抽首站。

运行：

```bash
python source/Q2/q2_generator.py --seed 20260929 --output demo-output/q2_input.json
python source/Q2/q2_solver.py --input demo-output/q2_input.json --output demo-output/q2_quick_result.json --quick
```

生成输入：

```json
{
  "case_id": "Q2-seed-20260929",
  "seed": 20260929,
  "first_station_m": [-245.09424208875873, 222.57734388382218],
  "first_bearing_deg": 239.09,
  "baselines_m": [600, 700, 800, 900, 1000],
  "local_truth": {
    "source_m": [-543.2941477665152, -286.1318174026561],
    "true_bearing_deg": 239.62162112213844
  }
}
```

`solve_case`
只读取首站、首示向、基线列表和案例名（Q2:L481–485、514）。没有读取
`local_truth`，也没有用真源位置优化站点。`epsilon_deg`
即使另加到这个输入里，主入口也不会使用它，主流程仍固定为 1°。

=== 12.4 Q2 的已验证 quick 输出：两种方法在此例相同
<q2-的已验证-quick-输出两种方法在此例相同>
```text
Q1直径方法：L=1000.0 m，ψ=-33.25°，最坏R=55.820 m，最坏D=111.640 m，面积=2188.869 m²
  第二检测点：(-1145.109, -213.282)
Q2最小包围圆方法：L=1000.0 m，ψ=-33.25°，最坏R=55.820 m，最坏D=111.640 m，面积=2188.869 m²
  第二检测点：(-1145.109, -213.282)
```

两行均对应下面的复评数值：

#align(center)[#table(
  columns: 2,
  align: (col, row) => (auto,auto,).at(col),
  inset: 6pt,
  [字段], [值],
  [`baseline_m`],
  [1000.0],
  [`psi_deg`],
  [−33.25],
  [`a_m`],
  [836.2861558477596],
  [`b_m`],
  [−548.2932295199138],
  [`second_station_m`],
  [\[−1145.1089454857736, −213.28219044941164\]],
  [`worst_R_m`],
  [55.81992860320586],
  [`worst_D_m`],
  [111.6398570064117],
  [`worst_A_m2`],
  [2188.8690995741636],
  [`report_at_worst_R_deg`],
  [280.9772292406169],
  [`meets_20m_on_evaluated_reports`],
  [`false`],
)
]

这里的 `worst` 全部按本次有限报告搜索口径理解。Q2
只要求较好的第二点选择策略；它并未要求所有首测都能仅靠再测一次达到清除精度。该例明确未达到
20 m，不能写成“两次检测保证清除”。

#strong[如何正确讲述相同选点？] "我分别用最坏直径与最坏 MEC
半径执行了搜索，本案例两者选到了同一站点，复评值相同。这说明该案例没有展示两种目标的性能差异。MEC
的采用理由来自覆盖清除距离的正确性，而不是强行宣称每个案例都有数值改善。"

=== 12.5 所有五条基线都真的算了吗
<所有五条基线都真的算了吗>
是。本次 `baseline_search`
的记录如下；数值为搜索分辨率结果，和上面的最终复评分辨率不同：

#align(center)[#table(
  columns: 5,
  align: (col, row) => (right,right,right,right,right,).at(col),
  inset: 6pt,
  [基线 / m], [D 方法偏角 / °], [D 方法目标值 / m], [R 方法偏角 / °], [R
  方法目标值 / m],
  [600],
  [−25.562841],
  [256.923968],
  [−25.562841],
  [128.461984],
  [700],
  [−33.047732],
  [186.587636],
  [−33.047732],
  [93.293818],
  [800],
  [−37.047507],
  [151.463848],
  [−37.047507],
  [75.731924],
  [900],
  [−38.273893],
  [129.149625],
  [−38.273893],
  [64.574813],
  [1000],
  [−33.250000],
  [111.639857],
  [−33.250000],
  [55.819928],
)
]

这张表支持“该次测试的五个基线中，1000 m
得到最好数值”。它不能支持“所有输入下 1000 m 一定最优”，也不能支持“1000 m
是任意连续基线下全局最优”。

=== 12.6 默认精度与复现实验边界
<默认精度与复现实验边界>
去掉 `--quick` 即可运行默认精度：

```bash
python source/Q2/q2_solver.py --input demo-output/q2_input.json --output demo-output/q2_result.json
```

本章表中的数值是#strong[已经实际运行的 quick
结果]，没有把它冒充默认精度结果。默认命令用于你自行补充分辨率比较，输出值应按实际文件填写，不要预先假设与
quick 完全相同。

一个有目的的精度观察顺序是：固定同一个第二站，改变报告粗步长；再固定报告步长，改变圆边数；最后才重新运行外层选点。若两种分辨率一起变，就难以判断数值变化来自圆近似、内层漏峰还是外层换点。即使观测到稳定，也应表述为“在所比较分辨率下稳定”，不能自动升级为全局证明。

== 13. 边界案例：会运行之后，应会读失败与退化
<边界案例会运行之后应会读失败与退化>
=== 13.1 Q1 已直接调用原函数验证的案例
<q1-已直接调用原函数验证的案例>
把半平面写成三元组 `(a,b,c)`，表示 `a*x+b*y<=c`：

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [约束], [实际状态], [应有解释],
  [`(1,0,0),(-1,0,-1)`],
  [`empty`],
  [同时要求 x≤0 与 x≥1],
  [`(1,0,0)`],
  [`unbounded`],
  [单个半平面无界，可行见证为 (0,0)],
  [`(1,0,0),(-1,0,0),(0,1,0),(0,-1,0)`],
  [`point`],
  [只剩原点，直径与面积为 0],
  [`(1,0,1),(-1,0,0),(0,1,0),(0,-1,0)`],
  [`segment`],
  [\[0,1\]×{0}，直径 1，面积 0],
  [`(1,0,1),(-1,0,0),(0,1,1),(0,-1,0)`],
  [`polygon`],
  [单位正方形，直径 √2，面积 1],
)
]

零误差观测也已验证：

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [`observations` 与 `epsilon_deg=0`], [实际状态], [结果],
  [`[[0,0,0]]`],
  [`unbounded`],
  [正东射线],
  [`[[0,0,0],[10,0,180]]`],
  [`segment`],
  [原点至 (10,0)，直径 10],
  [`[[0,0,0],[0,1,90]]`],
  [`empty`],
  [东向射线与从 (0,1) 出发的北向射线不交],
)
]

这些不是把原题误差改成零，而是在验证通用几何函数声称支持的退化范围。

=== 13.2 遇到这些输出，不要误下结论
<遇到这些输出不要误下结论>
#align(center)[#table(
  columns: 2,
  align: (col, row) => (auto,auto,).at(col),
  inset: 6pt,
  [现象], [正确解释与下一步],
  [多次观测得到空集],
  [检查角度约定、单位、源身份、输入误差是否真的有界；不能直接取顶点均值补一个答案],
  [Q1 无界],
  [角楔约束没有封住所有方向；源的世界圆先验未被该求解器加入],
  [Q1 `uncertain`],
  [程序未可靠构造结果；保留状态，检查近平行、尺度和退化，不将其当作成功定位],
  [加一次观测区域不变],
  [新楔可能完全包含旧区域；不代表代码必然失效],
  [面积为 0],
  [可能是线段或点；必须同时查看直径与状态],
  [Q2 "no feasible second report"],
  [当前放宽集合、参数或几何输入无法产生任何被采到的非空报告；需要检查输入与采样，不是某个源被证明不存在],
  [Q2 "没有可用的安全第二检测点"],
  [给定基线列表没有成功产生可评估候选；不是对所有可能基线的不可行性证明],
  [Q2 三种最坏指标不成固定比例],
  [形状会变，最大值也可能来自不同报告],
  [Q2 `meets_20m_on_evaluated_reports=true`],
  [只覆盖已评价报告的数值检查，字段名已限定范围],
)
]

=== 13.3 输入校验的现实范围
<输入校验的现实范围>
Q1 `_observation` 和 `_normalise` 检查有限数；`solve_localization`
拒绝空观测、负半宽及不小于 90° 的半宽。Q2
主入口的数据检查较少，主要信任生成器给出的有效输入；例如报告步长为
0、非有限坐标、非法圆边数不属于默认支持的正常用法。

`solve_case` 只在单个基线优化处捕获 `ValueError`
并跳过该行（Q2:L493–498），并未把所有异常都转成完整诊断。因此发现异常时，应先保存原输入、种子、命令与报错；不要把输入错误包装成算法找到了某种特殊最优解。

=== 13.4 数值容差不是统计置信度
<数值容差不是统计置信度>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [容差位置], [代码取值], [作用],
  [Q1 约束判外],
  [`EPS=1e-10`，再乘尺度],
  [缓和浮点边界误差],
  [Q1 近平行],
  [`PARALLEL_EPS=1e-12`],
  [避免小行列式除法],
  [Q1 直径圆],
  [半径加 `EPS` 判断],
  [容忍极小舍入差],
  [Q2 半平面裁剪],
  [`EPS=1e-9`],
  [判定边界内外],
  [Q2 去重复点／MEC 圆内判断],
  [约 `1e-8`],
  [避免近重合点与边界抖动],
  [Q2 MEC 最终半径],
  [加 `1e-7` m],
  [按计算距离做覆盖审计],
  [Q2 安全距离平方判定],
  [加 `1e-7`],
  [平方距离比较裕量，单位是 m²],
)
]

这些常数服务于计算稳定性，不是“99%
置信度”，也不是仪器允许误差的概率描述。普通双精度加容差仍不同于严格舍入方向受控的数值证书。

== 14. 把选型理由压缩成一张答辩表
<把选型理由压缩成一张答辩表>
#align(center)[#table(
  columns: 4,
  align: (col, row) => (auto,auto,auto,auto,).at(col),
  inset: 6pt,
  [建模／算法选择], [为什么适用于 B 题], [保证或依据], [没有声称的内容],
  [有界角楔交],
  [已知 ±1° 上界，同地误差不消失],
  [相容真源保留在交集中],
  [误差独立正态或平均后趋零],
  [半平面表示],
  [楔边界是直线，凸性明确],
  [有限线性约束可计算],
  [每次都一定得到非退化多边形],
  [旋转卡壳],
  [Q1 要最远点对，区域凸],
  [顶点直径与区域直径相等],
  [完整源码含审计后仍总为 O(n log n)],
  [MEC 半径为主目标],
  [清除要求存在一个点距全部可能源≤20 m],
  [覆盖半径直接对应行动条件],
  [任意形状都有 R\=D/2],
  [统一 1000 m 安全域],
  [最小接收半径已知，保证可再观测或近场清除],
  [对整个首测扇区的最远距离检查],
  [已使用所有先验得到最大候选域],
  [圆外接多边形],
  [便于用同一裁剪器处理圆与角楔],
  [精确构造下包含原圆盘],
  [有限报告搜索因此自动成为上界],
  [可行报告非空检查],
  [避免位置和读数不相容],
  [在所用凸模型内有共同位置],
  [已排除近场、圆近似的全部虚假可行情形],
  [双侧固定基线搜索],
  [一般场地截断破坏对称；二维任务先化为一维],
  [两侧候选实际都评估],
  [五条基线等于连续全域],
  [粗扫与局部黄金分割],
  [每次几何评价有成本，无解析导数],
  [可复现、可比较分辨率],
  [全局单峰、全域最优、连续最坏值证书],
)
]

== 15. 答辩口述：先说模型，再说代码，再说范围
<答辩口述先说模型再说代码再说范围>
每个答案先练成 30–60 秒；被追问时再展开前文推导。

=== 问 1：示向度只是一个角度，为什么得到的是半平面交？
<问-1示向度只是一个角度为什么得到的是半平面交>
"题目给出 ±1° 有界误差，所以一条测量对应前方的 2°
角楔。角楔的两条边分别给出一个左侧和一个右侧半平面，法向量由正弦、余弦直接计算。多个观测都要成立，所以取这些半平面的交。Q1
的 `_wedge` 生成约束，`intersect_halfplanes` 求交。"

=== 问 2：你为什么没有对多次测量平均？
<问-2你为什么没有对多次测量平均>
"同地环境误差在一段时间内固定，题目没有给出独立零均值误差假设。重复读数不能按样本量开方缩小误差。因此我们保留误差区间，在不同位置用几何约束收缩集合。"

=== 问 3：两条直线总能相交，为什么程序会返回无界？
<问-3两条直线总能相交为什么程序会返回无界>
"输入对应角楔而不是两条无误差直线。角楔可能有共同逃逸方向，交集就无界。Q1
也没有把目标世界圆作为额外裁剪边界，所以不能用场地有限来替它自动补出有限直径。"

=== 问 4：为什么只检查顶点就能算直径？
<问-4为什么只检查顶点就能算直径>
"任意区域点都是凸包顶点的凸组合。把两个点的差写成顶点差的加权和，再用三角不等式，可知两点距离不超过最大的顶点对距离。顶点本身又属于区域，所以两者相等。"

=== 问 5：旋转卡壳究竟比暴力快在哪里？
<问-5旋转卡壳究竟比暴力快在哪里>
"凸包边依次转动时，远侧支撑顶点只沿凸包向前走，因此不必为每条边重新扫描全部顶点。卡壳部分线性；当前函数仍要先求凸包，完整
Q1 还含二次的约束审计，复杂度要分层描述。"

=== 问 6：直径 40 m，能不能在中点清除？
<问-6直径-40-m能不能在中点清除>
"不能一般保证。边长 40 m 的正三角形直径为 40，但最小包围圆半径约 23.094
m。直径圆漏掉第三个顶点。只有额外验证直径圆覆盖全区域时，半直径才等于有效覆盖半径。"

=== 问 7：MEC 是不是最大内切圆？
<问-7mec-是不是最大内切圆>
"不是。这里要一个圆把全部可能源位置包住，因此是最小外包圆。最大内切圆只描述区域内部能放多大圆，不能保证清除点到所有可能源的距离。两者即使都叫某种中心问题，目标也完全不同。"

=== 问 8：安全第二站为什么还要用 1500 m，既然已经知道至少 1000 m？
<问-8安全第二站为什么还要用-1500-m既然已经知道至少-1000-m>
"1500 用来描述首测后源可能在哪里：收到信号意味着距离至多 1500。1000
用来设计对任何源接收能力都有效的站点：第二站到所有首测可能位置都不超过
1000。一个是位置集合上界，一个是接收能力下界。"

=== 问 9：第二站候选区域为什么是圆盘的交，不是圆盘的并？
<问-9第二站候选区域为什么是圆盘的交不是圆盘的并>
"对于每个可能源位置，第二站都必须落在它的 1000 m
接收圆内。要同时对全部源位置成立，所以取交。取并只保证至少存在一个源位置可以接收，无法保证真实源一定可接收。"

=== 问 10：为什么不用 90° 交会？
<问-10为什么不用-90-交会>
"良好的交会角确实有助于减小不确定性，但位置还必须保证接收。第二站相对首示向轴的偏角不是实际射线在源处的交会角。我们先推出安全候选弧，再在其中评价最坏后验覆盖半径，避免只优化几何角度而失去信号。"

=== 问 11：你如何定义最坏误差？
<问-11你如何定义最坏误差>
"我们不用任意独立拼接的真源和第二报告。固定第二站，枚举第二示向度，求满足两次方向、距离和场地约束的后验集合；非空报告才有相容解释。对这些集合分别求
MEC，再找最大的半径。当前圆和近场处理是保守放宽，报告极大值则通过有限搜索近似。"

=== 问 12：同一个报告的半径已经保守，为什么还不叫连续最坏上界？
<问-12同一个报告的半径已经保守为什么还不叫连续最坏上界>
"空间外包络保证的是该报告下的集合包含。有限报告采样可能漏掉采样间的峰值，因此跨报告取最大仍可能偏低。当前输出明确限定为已评价报告，没有连续区间证书。"

=== 问 13：黄金分割 34 次后不是非常精确吗？
<问-13黄金分割-34-次后不是非常精确吗>
"它把已选局部区间压得很小，但只有在单峰条件成立时才保证不丢失该区间极值。程序没有证明目标全域单峰，还只细化粗网格中若干峰，所以迭代次数不能替代全局证明。"

=== 问 14：两种方法输出一样，是不是没有真正做对照？
<问-14两种方法输出一样是不是没有真正做对照>
"源码外层分别用 D 和 R
重新优化，每个基线都执行两次搜索。相同结果是允许的。本章种子 20260929 的
quick 测试两种目标确实选择同一点，因此我们报告相同，不把它写成 MEC
的数值提升案例。"

=== 问 15：第一站不在圆心，为什么仍可使用局部安全公式？
<问-15第一站不在圆心为什么仍可使用局部安全公式>
"旋转平移不改变距离。安全公式覆盖完整首测扇区，真实世界圆只会从这个扇区里删去位置，所以该保证仍成立。评价定位效果时程序再在世界坐标下加入场地圆，因而一般必须搜索轴线两侧。"

=== 问 16：程序用了哪些真值？
<问-16程序用了哪些真值>
"求解器只读取观测和规定的先验参数。生成器为了本地核验记录了
`local_truth`，但两问求解入口都没有读取它。可以删掉真值字段再跑同一个输入，输出应保持一致。"

=== 问 17：你最需要承认的一项局限是什么？
<问-17你最需要承认的一项局限是什么>
"Q2
是在统一安全域、有限基线、有限角度搜索中选点；内层最坏报告和外层最优站点都没有连续全域证书。优点是每层模型和实现可追溯，能通过固定种子与分辨率实验复核。要进一步严格化，需增加连续极值证明或带误差界的全域搜索。"

== 16. 自测与参考答案
<自测与参考答案>
先遮住答案。能算出数值之后，再用一句话解释它解决的是哪个逻辑问题。

=== 练习 1：东向角楔的符号
<练习-1东向角楔的符号>
检测点为原点，示向 0°、半宽 1°。写出两个半平面，并判断
(100,1)、(−100,0)、(100,3) 是否可行。

#strong[答案。] 等价约束是
$minus x tan 1^compose lt.eq y lt.eq x tan 1^compose$。在 x\=100
时纵坐标范围约 \[−1.7455,1.7455\]，故 (100,1) 可行，(100,3)
不可行；(−100,0) 的上下界反转，不可行。对应 Q1:L257–265。

=== 练习 2：角度接缝
<练习-2角度接缝>
真实方向 359.8°，报告 0.2°，角误差是多少？为什么不能直接相减后取绝对值？

#strong[答案。] 将差归一到 \[−180°,180°) 得 +0.4°。角度在圆周上定义，0°
与 360° 相同。生成器的误差拒绝判断使用模运算处理接缝。

=== 练习 3：零误差为什么不是整条直线
<练习-3零误差为什么不是整条直线>
只输入 `[[0,0,0]]` 且
`epsilon_deg=0`，几何集合和代码状态分别是什么？哪个代码分支排除反向位置？

#strong[答案。] 正东射线，状态 `unbounded`。Q1:L262–264 添加法向量
`(-cos(angle),-sin(angle))`，对应前向点积非负。

=== 练习 4：同方向约束取谁
<练习-4同方向约束取谁>
约束 `2x<=6` 与 `x<=2` 应保留哪一个？如果不规范化直接比较 6 和
2，会发生什么问题？

#strong[答案。] 规范化后是 x≤3 与
x≤2，保留后者。这个特定例子直接比较也凑巧正确，但一般 `100x<=100` 与
`x<=2` 若直接比较 offset 100 和 2，会错保留较松的
x≤2；必须统一法向量长度。

=== 练习 5：面积为零是否已经精确定位
<练习-5面积为零是否已经精确定位>
可行区域为从 (0,0) 到 (100,0) 的线段。其面积、直径、MEC
半径是多少？能否保证 20 m 清除？

#strong[答案。] 面积 0，直径 100，MEC 半径
50。不能保证。退化面积不能替代长度尺度。

=== 练习 6：直径圆反例
<练习-6直径圆反例>
正三角形边长为 30 m，写出直径、MEC
半径与一条边中点到第三点的距离。直径圆是否覆盖？MEC 是否满足 20 m？

#strong[答案。] D\=30，R\=30/√3≈17.3205，第三点距边中点
15√3≈25.9808。半径 15 的直径圆不覆盖，但 MEC 的半径小于
20，存在可保证清除的圆心。可见“直径圆不覆盖”不等于“没有合格清除点”。

=== 练习 7：直径阈值的充分必要性
<练习-7直径阈值的充分必要性>
判断：D≤40 m 是 R≤20 m 的充分条件还是必要条件？D≤20√3 m 又是什么条件？

#strong[答案。] 前者是必要但不充分；后者是充分但不必要。一个长 39 m
的线段有 R\=19.5 m，说明后者不是必要条件。

=== 练习 8：接收半径与源距
<练习-8接收半径与源距>
第一站已接收到某源，能否断言源距在 \[1000,1500\] m 内？若实际源距为 1300
m，最小相容接收半径是多少？

#strong[答案。] 不能，源可能更近；普通示向报告在精确题设中给出
5\<距离≤1500。若源距 1300，接收半径至少 1300；这正是 `full_information`
比 `uniform1000` 可放宽的理由。

=== 练习 9：安全弧计算
<练习-9安全弧计算>
统一 1000 m 域，L\=1000 m、δ\=1°。求允许的最大绝对偏角。偏角 45°
是否安全？

#strong[答案。] 比值为 0.75，上界 arccos(0.75)−1°≈40.409622°。45°
超界，不满足统一接收保证。

=== 练习 10：为何径向最大值查端点
<练习-10为何径向最大值查端点>
固定第二站与源方向，写出距离平方随源径向距离 r 的函数，并说明为何最坏 r
只需查 0 与 R。

#strong[答案。] 函数为
$parallel s parallel^2 plus r^2 minus 2 r thin s dot.op u$，二阶导数为
2，是凸函数；任意区间内点的函数值不超过两端点值的最大者。此性质是
`_sector_max_distance_sq` 的径向化简依据。

=== 练习 11：内接圆多边形为何危险
<练习-11内接圆多边形为何危险>
你把 1500 m 圆周上 96
个点直接连起来代替接收圆。对保留真源的目标，有什么风险？

#strong[答案。]
得到的是内接多边形，圆周弧与弦之间的合法位置被删掉，真源可能被误排除。当前代码用切线半平面和顶点半径
r/cos(π/n) 构造外接多边形。

=== 练习 12：最坏报告与固定清除中心
<练习-12最坏报告与固定清除中心>
解释
$sup_z min_c sup_(g in P lr((s comma z))) parallel g minus c parallel$
与
$min_c sup_z sup_(g in P lr((s comma z))) parallel g minus c parallel$
的区别。哪一个更符合看到第二报告后再决定清除点？

#strong[答案。]
第一个允许中心随观测改变；第二个要求所有报告共用一个预先确定的中心，通常更保守。当前程序对应第一个。

=== 练习 13：参数追踪
<练习-13参数追踪>
把 `refine_step_deg` 从 0.2 改为 0.01，当前 `robust_quality`
是否会自动多采样？默认主入口最终复评的报告粗步长到底是 0.1° 还是 0.2°？

#strong[答案。] 不会，该参数当前没有在函数体使用。默认 `solve_case`
显式传 0.2°；`final_quality` 自身的 0.1° 默认被覆盖。依据
Q2:L307–400、472–476、503–508。

=== 练习 14：如何解释同种子结果
<练习-14如何解释同种子结果>
本章 quick 例子的两个方法选点相同，且最坏半径约 55.820
m。写一句可以放进论文的结论，再写一句不能写的结论。

#strong[答案。]
可写："本次固定种子与所用搜索分辨率下，两种目标选择相同第二站，复评最坏半径近似为
55.820 m，未达到 20 m。"不可写："MEC
方法在所有场景优于直径方法，且两次观测必然达到清除精度。"

=== 练习 15：找出不当复杂度声明
<练习-15找出不当复杂度声明>
"程序采用 O(n log n) 半平面交，所以 Q1 全部实现最坏就是 O(n log
n)。"哪里不严谨？

#strong[答案。] 当前 Q1:L225 逐顶点验证全部约束，最坏 O(n²)；兜底
`_feasible_point`
也有二重循环。应区分标准队列核心、凸包／卡壳部分以及完整审计实现。

=== 练习 16：设计一个真正有意义的核验
<练习-16设计一个真正有意义的核验>
你要核验 Q2 求解器没有使用
`local_truth`，以及圆边数变化的影响，各应如何操作？

#strong[答案。] 先保持其余输入完全不变，删除或更改
`local_truth`，结果应不变；这是数据依赖核验。再固定同一个第二站、同一报告步长，只改变
`disk_sides`，比较
R/D/A；这是空间离散敏感性观察。不要同时换种子、站点、边数和步长，否则难以归因。

== 17. 外部学习出处与阅读方法
<外部学习出处与阅读方法>
下列均为原作者、大学课程或大学开放教材页面。这里仅概述与本章相关的小部分，并独立推导
B 题公式。读原文时先找指定章节、例图或例题；不必为理解两问通读整本书。

#align(center)[#table(
  columns: 4,
  align: (col, row) => (auto,auto,auto,auto,).at(col),
  inset: 6pt,
  [编号], [精确来源与链接], [本章实际使用位置], [建议阅读问题],
  [E1],
  [Stephen Boyd、Lieven Vandenberghe，#emph[Convex Optimization —
  Original lecture
  slides]，#link("https://www.stanford.edu/~boyd/cvxbook/bv_cvxslides_original.pdf")[官方 PDF]；"Hyperplanes
  and halfspaces" 2–6、"Polyhedra" 2–9、"Intersection" 2–12、"Robust
  linear programming" 4–26、"deterministic approach via SOCP" 4–27],
  [凸集合与量词化的鲁棒约束；原讲义页码按每讲重新编号],
  ["对所有不确定值成立"怎样变成一个最坏值约束？],
  [E2],
  [David M. Mount，#emph[CMSC 754: Computational Geometry]，Lecture 8
  "Halfplane Intersection and Point-Line Duality"，印刷页 40–41、Fig.
  34，#link("https://graphics.stanford.edu/courses/cs268-16-fall/Notes/cmsc754-lects.pdf")[Stanford 课程托管的原讲义 PDF]],
  [半平面交可能为空、无界；分治作为替代算法],
  [输出为什么不能总假设为有限多边形？],
  [E3],
  [Godfried Toussaint，#emph[Solving Geometric Problems with the
  Rotating Calipers]，IEEE MELECON’83，§1、PDF 第 1 页、Fig.
  1，#link("https://web.cs.swarthmore.edu/~adanner/cs97/s08/pdf/calipers.pdf")[大学课程托管论文]；#link("https://www-cgrl.cs.mcgill.ca/~godfried/research/calipers.html")[作者的旋转卡壳说明页]],
  [支撑线、对踵对与直径；不是直接引用本文自算的矩形坐标],
  [为什么远侧顶点可以顺序前移？],
  [E4],
  [ETH Zürich，#emph[Geometry: Combinatorics & Algorithms]，Appendix G
  "Smallest Enclosing Balls"，印刷页
  232（消防站例）、235（支撑点）、§G.2（Welzl），#link("https://geometry.inf.ethz.ch/gca18-G.pdf")[官方讲义 PDF]],
  [MEC 的选址含义与至多三个支撑点],
  [覆盖所有位置和最小化最大距离为何相同？],
  [E5],
  [Emo Welzl，#emph[Smallest Enclosing Disks (Balls and
  Ellipsoids)]，1991，LNCS
  555，pp. 359–370，#link("https://people.inf.ethz.ch/emo/PublFiles/SmallEnclDisk_LNCS555_91.pdf")[作者公开原论文]，尤其二维最小圆与随机增量部分],
  [算法思想的原始研究出处；当前源码是自己的迭代实现],
  [固定少数边界点后，为何子问题更简单？],
  [E6],
  [John E. Howland，#emph[Polygon Clipping]，Trinity
  University，§2、Fig.
  1–2，#link("https://www.cs.trinity.edu/~jhowland/cs3353/pclip/pclip/")[原文]],
  [正方形被 y\=x−50 裁成五边形的有坐标例题],
  [每条边穿越边界时应该输出哪些点？],
  [E7],
  [Cornell University Computational Optimization Open
  Textbook，#emph[Derivative free optimization]，"Numerical Examples /
  Example 1: Golden Section
  Search"，#link("https://optimization.cbe.cornell.edu/index.php?title=Derivative_free_optimization")[大学开放教材]],
  [(x−2)²+1 在 \[0,5\] 上的黄金分割例题；本文修正其少量排版笔误后复算],
  [为什么一轮能复用一个函数值？],
  [E8],
  [Jeffrey Naisbitt、Michael Heath，#emph[Golden Section
  Search]，Illinois 官方教学模块；对应 Michael T.
  Heath，#emph[Scientific Computing: An Introductory Survey]，2nd
  ed.，§6.4.1、Algorithm 6.1、Example
  6.8，#link("https://heath.cs.illinois.edu/iem/optimization/GoldenSection/")[官方模块]],
  [单峰假设与区间保留保证],
  [区间变短为什么不自动等于找到了全局极值？],
)
]

本章本地证据还包括：上传题目 `20-B-.pdf` 第 1–4 页；`source/README.md`
的 Q1、Q2 与当前算法口径；四个原上传生成器／求解器文件。展示的 Q1
正常案例、半平面退化案例、三角形反例与 Q2 quick
五基线结果均由这些原函数或原命令实际运行得到；源码没有为本章演示作算法修改。

== 18. 学完这一章，应该能离开屏幕说出的五句话
<学完这一章应该能离开屏幕说出的五句话>
+ 我把 ±1°
  误差表示成角楔，用共同满足所有观测的集合代替一个未经保证的点估计。
+ 凸性让我把连续区域的直径与圆覆盖问题化成有限顶点问题，但半直径并不总等于最小覆盖半径。
+ 第二站先满足对全部相容源都能接收的安全约束，再比较观测后的最坏定位尺度。
+ 当前 Q2 用凸外包络和两层有限搜索，分别独立优化直径与 MEC
  半径；代码的参数、调用和输出都能追踪。
+ 我能明确指出哪些是几何定理、哪些是浮点检查、哪些只是当前搜索范围内的数值结果。

#pagebreak()
= 第 3 章　Q3：全向源的搜索、定位与清除
<第-3-章-q3全向源的搜索定位与清除>
#blockquote[
本章要回答的核心问题：机器狗只看到一次次检测与清除响应，怎样既不漏掉未知干扰源，又能保证每次清除的位置足够近，并尽量少走路？
]

== 3.0　学习目标与证据约定
<学习目标与证据约定>
读完本章，应能独立说明以下六件事：

+ 从圆盘覆盖推出“原点加八个外围点”的搜索骨架，并说明它保证发现什么。
+ 把带误差的示向度变成包含真源的几何约束，解释无信号为何只能排除半径
  1000 m 的开圆盘。
+ 从最小包围圆得到清除证书，推导 19.8 m 阈值与最近认证清除点。
+ 解释局部主动测向的收缩、接收保证及有限步性质。
+ 区分频道身份、测向机当前频道、已发现数量与已清除数量。
+ 沿实际函数调用追踪一局运行，分清几何正确性、效率经验和官方测试证据。

本章采用下列缩写。代码行号以本工作区上传源码为准；本地求解器与官方求解器的前
502 行经逐行比较完全相同。

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [缩写], [文件或材料], [本章如何使用],
  [`L`],
  [#link("https://github.com/SOMEBODYJUN/work-web/blob/main/source/Q3/q3_local_solver.py")[`source/Q3/q3_local_solver.py`]],
  [几何与策略主实现；共 502 行。],
  [`O`],
  [#link("https://github.com/SOMEBODYJUN/work-web/blob/main/source/Q3/q3_official_solver.py")[`source/Q3/q3_official_solver.py`]],
  [1–502 行同 `L`，514–712 行增加正式 HTTP 客户端和入口。],
  [`S`],
  [#link("https://github.com/SOMEBODYJUN/work-web/blob/main/source/Q3/q3_local_simulator.py")[`source/Q3/q3_local_simulator.py`]],
  [本地源生成、响应、计时和统计；共 120 行。],
  [`R`],
  [#link("https://github.com/SOMEBODYJUN/work-web/blob/main/source/README.md")[`source/README.md`]],
  [原程序的运行方式、参数说明和证据边界。],
  [`P`],
  [本次上传的 `20-B-.pdf`，题名《无线电干扰源的快速自动定位与清除》],
  [第 1 页问题 3；第 2–3 页附录 1–2；第 3–4 页附录 3。原 PDF
  不在仓库中。],
)
]

外部材料分成“公开原例”和“本章推导”。公开原例有可访问的一手出处、具体节号或图号；本章补算明确标注，不能把我们自行选择的数据写成原教材例题。公开来源清单见本章末尾。

=== 先看整个方法的职责
<先看整个方法的职责>
#align(center)[#table(
  columns: 4,
  align: (col, row) => (auto,auto,auto,auto,).at(col),
  inset: 6pt,
  [方法], [通用问题], [Q3 中承担的职责], [不能由它单独推出的结论],
  [圆盘覆盖],
  [有限个圆盘能否覆盖连续区域？],
  [证明未知频道已经有充分发现机会。],
  [某个已发现源已能安全清除。],
  [集合成员估计],
  [哪些参数仍与全部有界误差观测相容？],
  [保持真源属于可行域外包络。],
  [外包络中心就是真实位置。],
  [最小包围圆及半径复核],
  [一个集合能否装入足够小的圆盘？],
  [产生“所有候选位置都离清除点足够近”的证书。],
  [所有源都已被发现。],
  [主动选点],
  [到哪里再观测能缩小不确定性？],
  [在保证接收的同时收缩单源定位域。],
  [总旅行时间达到全局最优。],
  [在线路径插入],
  [新任务出现后先服务谁？],
  [在固定搜索路线间安排定位与清除。],
  [获得某个经典 TSP 算法的近似比。],
  [状态机与幂等请求],
  [有副作用的动作如何保持一致？],
  [正确记住频道、时间、清除结果和未知请求。],
  [服务端一定没有故障、一定遵守协议。],
)
]

#horizontalrule

== 3.1　把题目写成一个可执行的观测模型
<把题目写成一个可执行的观测模型>
=== 3.1.1　已知、未知与可控量
<已知未知与可控量>
目标区域是

$ Omega eq brace.l x in bb(R)^2 colon parallel x parallel lt.eq 1800 brace.r dot.basic $

第 $i$ 个有效频道若存在源，位置记为 $g_i in Omega$，有效接收半径记为
$rho_i in lr([1000 comma 1500])$。源数 $N$ 满足
$10 lt.eq N lt.eq 16$，但机器狗不知道实际 $N$。20
个频道中，一个频道至多对应一个源，源的频道不随时间改变。Q3
全部为全向源，因此接收与距离有关，没有 Q4 的朝向盲区。

机器狗控制的是“在位置 $p$，对频道 $i$
做什么动作”。检测点不是先验给定的；下一点依赖先前响应。这已经是反馈决策问题。

题面给出的量必须与程序选择的量分开：

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [量], [含义], [来源],
  [1800 m],
  [源所在圆域的半径],
  [`P` 第 1 页。],
  [1000–1500 m],
  [未知有效接收半径的区间],
  [`P` 第 3 页附录 2(2)。],
  [±1°],
  [物理测向误差的确定性上界],
  [`P` 第 2 页附录 2(1)。],
  [20 m],
  [光学精确定位并清除的距离条件],
  [`P` 第 3 页附录 2(8)。],
  [5 m],
  [可直接清除的 `near` 条件],
  [`P` 第 3 页附录 2(9)。],
  [995、999 m],
  [搜索构造和接收判定的保守半径],
  [程序设计值，分别见 `L210`、`L187` 等。],
  [19.8 m],
  [清除认证半径，留 0.2 m 余量],
  [程序设计值，见 `L148`、`L413`。],
  [600 m、0.1],
  [插入阈值与侧移比例],
  [启发式参数，见 `L239–240`。],
)
]

=== 3.1.2　三类检测响应分别证明什么
<三类检测响应分别证明什么>
在尚未清除的有效频道上，理想物理模型为：

$ parallel g_i minus p parallel gt rho_i & colon mono("no_signal") comma\
parallel g_i minus p parallel lt.eq 5 & colon mono("near") comma\
5 lt parallel g_i minus p parallel lt.eq rho_i & colon mono("direction") dot.basic $

不存在的频道也返回
`no_signal`。所以一次无信号不能区分“没有源”和“源离得太远”。

若返回 `direction`，设显示值为
$hat(theta)$。它给出前向角楔，而不是完整直线，也不是一条没有误差的射线。真源满足

$ #scale(x: 120%, y: 120%)[bar.v] "wrap" lr((arg lr((g_i minus p)) minus hat(theta))) #scale(x: 120%, y: 120%)[bar.v] lt.eq delta comma #h(2em) parallel g_i minus p parallel lt.eq 1500 dot.basic $

`wrap` 应理解为最短圆周角差。例如真实方向 359.9° 与读数 0.1° 相差
0.2°，不是 359.8°。代码使用三角函数构造边界方向，天然处理跨越 0°
的角楔。

同地点的误差固定是本题非常关键的条件。反复站在同一位置测同一频道，不会得到一批独立噪声样本；不能以“多测几次再平均，误差趋近于零”作为安全依据。`S18–19`
用位置相关的确定函数模拟这种性质，`L367` 用 25 m
最小移动间隔限制机会补测。25 m
是避免短基线浪费的策略值，不是题目保证的误差独立距离。

#horizontalrule

== 3.2　先学习圆盘覆盖，再推导九点搜索
<先学习圆盘覆盖再推导九点搜索>
=== 3.2.1　公开原例：把二维覆盖化为圆周上的区间覆盖
<公开原例把二维覆盖化为圆周上的区间覆盖>
Huang 与 Tseng 的论文《The Coverage Problem in a Wireless Sensor
Network》§3.1、图 2
给出一个真实的圆周覆盖示例：对某个传感器，先算邻居在它圆周上覆盖的角区间，再将所有区间端点排序，扫描每段被多少邻居覆盖。图中的八个邻居产生多个重叠区间；进入一个区间加一，离开一个区间减一。论文随后以
Lemma 1、Theorem 1 连接圆周覆盖与区域覆盖，并在图 3
单独讨论重合圆心和区域边界。原文没有给这些八个邻居的一组数字坐标，本章也不补造“原文坐标”。#link("https://cs.wmich.edu/gupta/teaching/cs5950/fall2011/coverage%20problem%20in%20WSNs%20by%20Huang%20and%20Tseng%20wsna03%2010.1.1.58.2392.pdf")[Q3-1]

论文同半径情形的基本构造可直接推导。两个半径为 $r$ 的圆心距离为
$d$，把邻居放在被检圆心的正西方。相交弦与连心线形成直角三角形，因此覆盖弧的半角为

$ alpha eq arccos frac(d, 2 r) comma $

对应区间是 $lr([pi minus alpha comma pi plus alpha])$。

#strong[本章补算。] 若 $r eq 1 comma d eq 1$，则
$alpha eq pi slash 3$，西边邻居覆盖本圆周上 120° 到 240°
的弧。一个邻居只覆盖这段圆弧，不能据此宣布整个区域已覆盖。这个小算例的用途是读懂
`arc_covered_by_disk`，并非 Q3 的站点布置。

=== 3.2.2　为什么 Q3 可以把“源被看见”变成“圆盘覆盖”
<为什么-q3-可以把源被看见变成圆盘覆盖>
对于任一全向源，$rho_i gt.eq 1000$。若某次扫描位置 $s$ 满足

$ parallel g_i minus s parallel lt.eq 999 comma $

则必在它的有效接收范围内。因此，只要扫描点集合 $cal(S)$ 满足

$ Omega subset.eq union.big_(s in cal(S)) B lr((s comma 999)) comma $

并且仍为未知的频道在这些点都检测过，就不能再藏着一个从未发现的源。这是把未知接收半径替换成共同保证半径的稳健处理。

注意这里的圆盘以#strong[检测点]为圆心；物理信号圆盘以#strong[源]为圆心。两者能够互换，是欧氏距离对称：$parallel g minus s parallel eq parallel s minus g parallel$。

=== 3.2.3　构造：原点加一个正八边形的顶点
<构造原点加一个正八边形的顶点>
先用原点的圆盘覆盖中心，外围放 $m$ 个等角度站点：

$ s_k eq a lr((cos frac(2 pi k, m) comma sin frac(2 pi k, m))) comma #h(2em) k eq 0 comma dots.h comma m minus 1 dot.basic $

令设计覆盖半径为 $rho eq 995$，目标圆半径
$R_Omega eq 1800$，相邻站点夹角的一半为
$alpha eq pi slash m$。任意方向与最近外围站点方向的角差至多 $alpha$。

在最难覆盖的外边界扇区中点，源到最近站点的距离平方是

$ R_Omega^2 plus a^2 minus 2 R_Omega a cos alpha dot.basic $

要求它不超过 $rho^2$，解关于 $a$ 的二次不等式，得到

$ a in lr([R_Omega cos alpha minus sqrt(rho^2 minus R_Omega^2 sin^2 alpha) comma #h(0em) R_Omega cos alpha plus sqrt(rho^2 minus R_Omega^2 sin^2 alpha)]) dot.basic $

`ring_sites` 选择较小根再向外增加 1 m：

$ a eq 1800 cos pi / m minus sqrt(995^2 minus 1800^2 sin^2 pi / m) plus 1 dot.basic $

增加的 1 m 使站点从较小根向二次不等式内部移动。对默认
$m eq 8$，它确实仍在合法区间内；不能脱离区间检查，把“加
1”当成任何几何问题都成立的规则。

根式有意义要求
$1800 sin lr((pi slash m)) lt.eq 995$，由此得到该对称构造需要
$m gt.eq 6$。这是#strong[该环形构造的条件]，不是关于任意平面布点最少传感器数量的全局最优定理。`ring_sites()`
的函数形参默认是 7，但正式入口实际使用
`Config(ring_m=8)`，读代码时应以后者为准。

=== 3.2.4　仅覆盖外边界还不够：补完整个圆域的证明
<仅覆盖外边界还不够补完整个圆域的证明>
半径 $t lt.eq 995$ 的点由原点覆盖。只需证明 $995 lt.eq t lt.eq 1800$
的环带也被外围站点覆盖。

对与最近站点夹角为 $phi$ 的点，$lr(|phi|) lt.eq alpha$，有

$ parallel x minus s_k parallel^2 eq t^2 plus a^2 minus 2 t a cos phi lt.eq f lr((t)) := t^2 plus a^2 minus 2 t a cos alpha dot.basic $

$f lr((t))$ 是凸二次函数。在闭区间 $lr([995 comma 1800])$
上，其最大值出现在端点。因此只要检查

$ f lr((995)) lt.eq 995^2 comma #h(2em) f lr((1800)) lt.eq 995^2 comma $

就覆盖整个环带。这一步排除了“只画出边界圆被覆盖，但内部有洞”的漏洞。

默认九点方案的补算结果为：

#align(center)[#table(
  columns: 2,
  align: (col, row) => (auto,right,).at(col),
  inset: 6pt,
  [检查量], [数值],
  [外围站点距原点 $a$],
  [945.973419 m],
  [外边界最坏距离 $sqrt(f lr((1800)))$],
  [994.278623 m],
  [内环端点最坏距离 $sqrt(f lr((995)))$],
  [381.705913 m],
  [相邻外围站点距离 $2 a sin lr((pi slash 8))$],
  [724.016710 m],
  [从原点依次走完八外围点的开放骨架长度],
  [6014.090390 m],
)
]

八外围点约为

$ lr((945.973 comma 0)) comma med lr((668.904 comma 668.904)) comma med lr((0 comma 945.973)) comma med lr((minus 668.904 comma 668.904)) comma $

$ lr((minus 945.973 comma 0)) comma med lr((minus 668.904 comma minus 668.904)) comma med lr((0 comma minus 945.973)) comma med lr((668.904 comma minus 668.904)) dot.basic $

"开放骨架"不包含最后返回原点，因为题目没有这个要求；也不包含后续定位、清除及重新接上搜索路线的绕行。

=== 3.2.5　为什么程序还要运行 `covers_arena`
<为什么程序还要运行-covers_arena>
解析证明解释默认九点为何有效；运行时证书还承担另一个任务：判断#strong[目前真正完成扫描的点]是否已经足够。它不能把尚未访问的计划点当成完成的工作。

一般情况下，用半径 $r$、圆心 $s$ 的圆盘覆盖圆心 $c$、半径 $R$ 的圆周。令
$d eq parallel s minus c parallel$，连心线方向为
$beta$。部分相交时余弦定理给出

$ h eq arccos frac(d^2 plus R^2 minus r^2, 2 d R) comma $

覆盖角区间是 $lr([beta minus h comma beta plus h])$。跨越 0
的区间分成两段；完全包含、完全分离、同心情况分别处理。`L156–166`
实现这些分支，`merge_intervals` 排序合并，`interval_subset`
检查目标弧是否全部被并集包含。

`covers_arena` 的两个检查为：

+ $diff Omega$ 的整圈是否被全部扫描圆盘覆盖；
+ 每个扫描圆周落在 $Omega$ 内的部分，是否被其他扫描圆盘覆盖。

第二步的作用是寻找内部暴露的圆弧。若存在一个内部未覆盖区域，它与覆盖区域相邻处必有某个扫描圆的暴露弧；只验外边界发现不了这样的洞。反过来，在圆域边界已覆盖、圆心重合已去重的前提下，内部若有洞，就会违反第二步。因此这是一种连续圆盘并集覆盖判据，不是有限网格抽样。`L192–194`
的去重也与公开论文专门讨论重合圆心的问题相呼应。

严格几何命题针对实数精确运算。当前实现用浮点数、角区间容差和 999 m
相对于物理 1000 m
的余量，属于有保护的数值实现；它没有使用带定向舍入的区间算术来逐条证明机器浮点误差上界。答辩应同时说清理论判据和实现层次。

=== 3.2.6　九点的数量由正确性和效率共同决定
<九点的数量由正确性和效率共同决定>
#align(center)[#table(
  columns: 4,
  align: (col, row) => (right,right,right,auto,).at(col),
  inset: 6pt,
  [外围点数 $m$], [$a$/m], [原点加外环的开放骨架/m], [连续 999 m
  覆盖检查],
  [6],
  [1135.552],
  [6813.313],
  [通过],
  [7],
  [1006.239],
  [6245.327],
  [通过],
  [8],
  [945.973],
  [6014.090],
  [通过],
  [9],
  [910.771],
  [5894.803],
  [通过],
  [10],
  [887.897],
  [5826.653],
  [通过],
)
]

这张本章补算表说明两件事。第一，九点不是唯一正确的覆盖方案。第二，站点更多时骨架反而可以略短，但检测成本上升；站点更少时又会损失部分保证接收的机会补测。不能只优化外围点数或只比较骨架长度。

`R127–129` 把九点、600 m、0.1R
描述为有限配置比较中的稳健选择。由于本仓库没有那批比较的逐局原始记录，本章不把
README 中的耗时比例和参数优胜结论重新包装成已独立复核的实验。

还有一个容易漏掉的事实：默认
$a lt 995$，所以仅八个外围圆盘其实也覆盖原点及整个圆域。把上面的凸函数检查区间改为
$lr([0 comma 1800])$，有 $f lr((0)) eq a^2 lt 995^2$
且外端也通过，即可证明；本章实际调用 `covers_arena(ring_sites(8))`
也返回真。原点扫描的作用是利用出发位置提前获得源的信息，便于在线决策。因此九点是当前执行策略，不能被称为几何上不可再减的站点数。

#horizontalrule

== 3.3　集合成员定位：每一步都保留真源
<集合成员定位每一步都保留真源>
=== 3.3.1　公开原例：Jaulin 的四地标定位题
<公开原例jaulin-的四地标定位题>
Luc Jaulin 的《Codac2: Python manual》§8.3，印刷页
15–16，给出四地标的有界距离与方位测量，并给出求解程序。原题数据如下；角度单位为弧度。#link("https://webperso.ensta.fr/jaulin/codac2_doc.pdf")[Q3-2]

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [地标 $m^(lr((i)))$], [距离区间], [方位区间],
  [$lr((6 comma 12))$],
  [$lr([10 comma 13])$],
  [$lr([0.5 comma 1])$],
  [$lr((minus 2 comma minus 5))$],
  [$lr([8 comma 10])$],
  [$lr([minus 3 comma minus 1.5])$],
  [$lr((minus 3 comma 10))$],
  [$lr([5 comma 7])$],
  [$lr([1 comma 2])$],
  [$lr((3 comma 4))$],
  [$lr([6 comma 8])$],
  [$lr([2 comma 3])$],
)
]

未知机器人位置 $p$ 与一条测量相容，当且仅当存在允许的 $d comma alpha$ 使

$ m^(lr((i))) eq p plus d lr((cos alpha comma sin alpha)) dot.basic $

原解用极坐标区域的分离算子构造每个相容集合，并用允许剔除一条数据的松弛交集处理四条观测。它展示的是“保留所有相容位置”的方法，不是对四个中点做最小二乘。

#strong[对原题数据的本章补算。] 取
$p eq lr((minus 1 comma 4))$，对应四地标的距离约为
$10.630 comma 9.055 comma 6.325 comma 4.000$，方位约为
$0.852 comma minus 1.681 comma 1.893 comma 0$。前三条都落在原题区间内，第四条不相容，所以这个点能通过“至多剔除一条”的条件。这个检验点是本章挑选的，并非原文宣称的唯一解。

Q3 与原例的角色有区别：原例已知地标、估计机器人；Q3
已知机器狗位置、估计源。把式子改写成

$ g eq p plus d lr((cos alpha comma sin alpha)) $

即可看到共同的约束结构。Q3
不允许任意丢掉一条真实观测；题设承诺误差界成立，故主程序求普通交集。这里引用区间教材是说明集合估计思想，Q3
实际没有调用 Codac。

=== 3.3.2　精确可行集与程序外包络
<精确可行集与程序外包络>
设已经收到的正向观测为 $lr((p_j comma hat(theta)_j))$，无信号观测为
$q_k$。有效频道的真实位置属于

$ F_i eq Omega sect sect.big_j lr((W lr((p_j comma hat(theta)_j comma delta)) sect B lr((p_j comma 1500)))) sect sect.big_k brace.l x colon parallel x minus q_k parallel gt 1000 brace.r dot.basic $

这里仍是保守的物理信息表达：没有维护未知 $rho_i$
的完整联合约束，也没有利用 `direction` 所隐含的
$parallel g minus p parallel gt 5$。少用有效信息会使集合偏大，不会因为这一点删掉真源。

程序用凸多边形 $P_i$ 外包络维护它，核心不变量是

$ g_i in F_i subset.eq P_i dot.basic $

"外包络"意味着其中可能含有已经不物理可行的点。算法宁可多留一些候选点，也不能删掉真源后给出错误清除证书。

=== 3.3.3　初始圆域必须用外切多边形
<初始圆域必须用外切多边形>
`arena_polygon` 用 48 边形初始化每个频道的 $P_i$。顶点半径是

$ R_48 eq frac(1800, cos lr((pi slash 48))) comma $

顶点角度增加 $pi slash 48$，使边与半径 1800 的圆相切。因此
$Omega subset P_i$。若把顶点直接放在半径 1800
的圆上，就得到内接多边形，圆弧和边之间的合法源可能一开始就被删掉。`L59`
的强调具有证明意义。

=== 3.3.4　示向角楔怎样变成两个半平面
<示向角楔怎样变成两个半平面>
设
$ell eq lr((cos lr((hat(theta) minus delta)) comma sin lr((hat(theta) minus delta))))$，$u eq lr((cos lr((hat(theta) plus delta)) comma sin lr((hat(theta) plus delta))))$。由于角宽小于
180°，前向角楔可写成

$ "cross" lr((ell comma x minus p)) gt.eq 0 comma #h(2em) "cross" lr((u comma x minus p)) lt.eq 0 dot.basic $

其中
$"cross" lr((lr((a comma b)) comma lr((c comma d)))) eq a d minus b c$。为了统一调用
`clip(poly,n,b)`，程序将两式写为 $n dot.op x lt.eq b$：

$ n_1 eq lr((ell_y comma minus ell_x)) comma quad b_1 eq n_1 dot.op p semi #h(2em) n_2 eq lr((minus u_y comma u_x)) comma quad b_2 eq n_2 dot.op p dot.basic $

`clip` 依次查看多边形的每条边。设端点的带符号量为
$f_a eq n dot.op a minus b$、$f_c eq n dot.op c minus b$，当一内一外时，交点参数是

$ t eq frac(f_a, f_a minus f_c) comma #h(2em) x eq a plus t lr((c minus a)) dot.basic $

保留内部端点和交点，就得到裁剪结果。`L40` 把边界向外推极小距离；`L50–55`
清理重复顶点。它实现的是半平面交的逐边裁剪版本。

=== 3.3.5　为什么角宽是 1.0051°
<为什么角宽是-1.0051>
物理角误差只有 ±1°，但程序看到的可能是两位小数显示值。设未量化读数
$tilde(theta)$ 满足

$ d_(bb(S)^1) lr((tilde(theta) comma theta_(upright(t r u e)))) lt.eq 1^compose comma $

显示值四舍五入到 0.01°，则其量化误差至多
0.005°。用圆周距离的三角不等式，得到

$ d_(bb(S)^1) lr((hat(theta) comma theta_(upright(t r u e)))) lt.eq 1.005^compose dot.basic $

再加 0.0001° 计算裕量，代码定义

$ delta eq 1.0051^compose approx 0.0175423043 med m r a d dot.basic $

这修正的是#strong[从仪器到程序读数的包络]，没有修改题设的物理误差。一个具体例子是：真实方向
0.006°、未量化读数 1.006°，物理误差正好 1°；显示为 1.01°
后，显示角与真角相差 1.004°。若对显示角只开 ±1°
的楔，就会把这个合法真角排除。

`S28` 先模 360 再 `round(...,2)`，因此本地模拟器极靠近 360°
的输出在表示上可能成为 360.0；本地三角函数能处理这个等价角。`O585`
对官方响应要求
$bracket.l 0 comma 360 paren.r$。这说明本地模拟与正式协议校验并不完全等价，角度归一化边界应由正式接口契约核对；不能把本地运行当成正式接口全覆盖测试。

=== 3.3.6　第三个半平面为什么仍然安全
<第三个半平面为什么仍然安全>
程序没有用很多线段拟合接收圆。它取

$ R eq min lr((1500 comma max_(v in "vert" lr((P_i))) parallel v minus p parallel plus epsilon)) comma $

沿当前示向轴 $e eq lr((cos hat(theta) comma sin hat(theta)))$ 加上

$ e dot.op lr((x minus p)) lt.eq R dot.basic $

因为
$e dot.op lr((g minus p)) lt.eq parallel g minus p parallel lt.eq R$，这个半平面包含真源。它与两条角楔边界形成三角形；三角形远端角点的距离略大于
$R$，所以只是圆扇形的外包络，不是精确圆扇形。好处是保留凸多边形运算，并能推导简单收缩界。

为什么可以只看顶点求最大距离？任意
$x eq sum_k lambda_k v_k$，$lambda_k gt.eq 0$、$sum_k lambda_k eq 1$，都有

$ parallel x minus p parallel lt.eq sum_k lambda_k parallel v_k minus p parallel lt.eq max_k parallel v_k minus p parallel dot.basic $

顶点本身也属于多边形，故最大值确实在顶点达到。`maxdist`
是后续多条安全证书共用的基础。

=== 3.3.7　无信号为什么排除 1000 m，而不是 1500 m
<无信号为什么排除-1000-m而不是-1500-m>
若频道存在未清除源，且 $parallel g minus p parallel lt.eq 1000$，由于
$rho_i gt.eq 1000$，一定能接收。因此 `no_signal` 推出

$ parallel g minus p parallel gt 1000 dot.basic $

它不能推出 $parallel g minus p parallel gt 1500$：一个接收半径 1050
m、距离 1200 m 的源就会无信号。把 1500 m 圆盘删掉会误删真源。

删去圆盘后，集合通常不凸。`exclude_disk_hull` 使用

$ P_i arrow.l "conv" lr((P_i backslash "int" B lr((p comma 1000)))) dot.basic $

其候选极点来自保留的原多边形顶点与边—圆交点，随后取凸包。圆周凹缺口的内部弧点无需作为外包络极点；若整个圆盘在多边形内部，这次取凸包甚至可能恢复为原多边形。那是信息损失，不是安全性损失。

`L84`
将排除半径稍减小，进一步避免浮点误差误删。未知频道先把无信号地点存入
`negatives`；第一次得到正向测量后才建立窄定位域，并重新施加历史排除信息。每次新的正向观测后重放这些排除条件，也可能让过去“凸化后没用”的信息再次发挥作用。

#horizontalrule

== 3.4　从最小包围圆到清除证书
<从最小包围圆到清除证书>
=== 3.4.1　公开原例：CGAL 的共线点例程
<公开原例cgal-的共线点例程>
CGAL《Bounding Volumes》用户手册中 "Bounding Spheres for the Homogeneous
Kernel" 的公开例程生成 100
个点：$lr((0 comma 0)) comma lr((minus 1 comma 0)) comma lr((2 comma 0)) comma lr((minus 3 comma 0)) comma dots.h$，分别演示开启和关闭随机打乱顺序。教材借它展示输入顺序对增量算法效率的影响。#link("https://doc.cgal.org/latest/Bounding_volumes/index.html")[Q3-3]

#strong[原例数据的本章推导。] 100 点的最左、最右点为
$lr((minus 99 comma 0))$ 与 $lr((98 comma 0))$，间距
197。任何覆盖圆半径至少是 98.5；以 $lr((minus 0.5 comma 0))$
为中心、半径 98.5 的圆又包含全部点。因此原例的最小包围圆就是

$ c eq lr((minus 0.5 comma 0)) comma #h(2em) r_ast.basic eq 98.5 dot.basic $

两点便能支撑最优解，其余 98
点只需检验是否在圆内。随机打乱影响如何找到它，不改变这个几何答案。

=== 3.4.2　MEC 的定义与支撑点
<mec-的定义与支撑点>
最小包围圆半径为

$ r_ast.basic lr((P)) eq min_c max_(x in P) parallel x minus c parallel dot.basic $

对凸多边形，只需将顶点作为输入。在二维中，最小圆可以由不超过三个边界支撑点确定：一个点对应零半径，两个点通常是直径端点，三个点对应非退化三角形的外接圆。CGAL
的 `Min_circle_2`
文档明确区分“包含全部点”"支撑集决定该圆""支撑集不可再删"三项有效性条件。#link("https://doc.cgal.org/latest/Bounding_volumes/classCGAL_1_1Min__circle__2.html")[Q3-4]

Welzl
的原始论文给出随机增量思想和期望线性时间结果。#link("https://doi.org/10.1007/BFB0038202")[Q3-5]
本程序的三层增量过程与其“新出现的外部点必须成为边界约束”的思想一致；两边界点子问题还可对照
Project Nayuki 的作者公开实现
`_make_circle_two_points`。#link("https://www.nayuki.io/res/smallest-enclosing-circle/smallestenclosingcircle.py")[Q3-6]

`mec` 的读法是：

+ 用固定种子 271828 打乱顶点，保证重跑确定性。
+ 新点已在当前圆内，直接继续。
+ 新点在圆外，先把它作为单点圆；遇到另一个圆外点，用两点直径圆。
+ 对还在外部的旧点，计算三点外接圆，并按直线两侧保留必要的极端候选圆。
+ 最后从最终中心重新计算对#strong[所有原始输入顶点]的最远距离，再加
  $10^(minus 6)$ m。

第五步尤其重要：真正交给策略作证书的半径是 `L146`
的复核半径，不是增量过程内部那个可能受容差影响的半径。即使一个候选中心未达到最优，只要所有顶点的半径上界可靠，它仍可用于安全性；损失的是清除时机和效率。

不能把“标准算法期望线性”直接说成“本实现每次必定线性”。本实现使用固定打乱、嵌套
Python 循环和切片，最坏运行开销与标准随机模型的平均分析要分开。

=== 3.4.3　真正需要的清除条件是一个全称命题
<真正需要的清除条件是一个全称命题>
在点 $q$ 清除频道 $i$，需要保证

$ forall x in P_i comma quad parallel x minus q parallel lt.eq 20 dot.basic $

若 $P_i subset.eq B lr((c comma r))$ 且 $r lt.eq 19.8$，到 $c$
清除即可。注意结论不是“源很可能在中心附近”，而是“即使源处于外包络最不利的位置，距离也不超过认证上界”。

精确可用清除点集合可以写成

$ cal(C)_20 lr((P_i)) eq sect.big_(v in "vert" lr((P_i))) B lr((v comma 20)) dot.basic $

程序不直接求这个圆盘交集，而使用一个简单的认证子集。由三角不等式，若

$ parallel q minus c parallel lt.eq 19.8 minus r comma $

则

$ max_(x in P_i) parallel x minus q parallel lt.eq r plus parallel c minus q parallel lt.eq 19.8 lt 20 dot.basic $

因此

$ B lr((c comma 19.8 minus r)) subset.eq cal(C)_20 lr((P_i)) dot.basic $

19.8 m 是人为留出的 0.2 m 距离余量；它既不是题目要求，也不是“98%
置信区间”。若精确最小包围圆半径大于 20 m，就不存在一个点可对整个 $P_i$
保证 20 m 清除；而审计半径大于 19.8 m
只表示当前保守策略尚未认证，不能据此说物理上一定无法清除。

=== 3.4.4　不必每次走到圆心：最近认证清除点
<不必每次走到圆心最近认证清除点>
当前机器狗位置为 $p$，令 $s eq 19.8 minus r$。若
$parallel p minus c parallel lt.eq s$，当前位置已获证，可以原地清除。否则把
$p$ 投影到圆盘 $B lr((c comma s))$：

$ q eq c plus s frac(p minus c, parallel p minus c parallel) dot.basic $

这是离 $p$ 最近的认证子集中的点，对应
`nearest_certified_clear`。程序只声称“在该认证子圆盘内最近”，没有声称在更大的精确集合
$cal(C)_20$ 中全局最近。

#strong[本章算例。] 若
$c eq lr((100 comma 0))$、$r eq 10$、$p eq lr((0 comma 0))$，则
$s eq 9.8$，最近认证清除点是 $q eq lr((90.2 comma 0))$。对任何真源
$g in B lr((c comma 10))$，都有
$parallel g minus q parallel lt.eq 19.8$。比走到圆心少走 9.8 m，节省
1.96 s 移动时间。

=== 3.4.5　为什么“直径不超过 40 m”仍不能替代 MEC
<为什么直径不超过-40-m仍不能替代-mec>
任意可被半径 20 m 圆盘覆盖的集合，其直径当然不超过 40
m；反向不成立。边长 40 m 的等边三角形直径为 40 m，其最小包围圆半径却为

$ 40 / sqrt(3) approx 23.094 gt 20 dot.basic $

所以 Q1 的直径与 Q3
的清除安全指标有关，但不能相互替代。这也是本题跨问联系中最适合答辩追问的一点。

#horizontalrule

== 3.5　主动定位为什么能继续收缩
<主动定位为什么能继续收缩>
=== 3.5.1　推导代码中的独立三角形包围圆
<推导代码中的独立三角形包围圆>
把测量点移到原点，并把示向轴旋到横轴。`bearing_update`
的三个半平面给出三角形

$ T_R eq "conv" brace.l lr((0 comma 0)) comma lr((R comma R tan delta)) comma lr((R comma minus R tan delta)) brace.r dot.basic $

设其外接圆心为 $lr((h comma 0))$，圆同时通过原点与远端角点，故

$ h^2 eq lr((R minus h))^2 plus R^2 tan^2 delta dot.basic $

展开得

$ 2 R h eq R^2 lr((1 plus tan^2 delta)) eq R^2 sec^2 delta comma $

因此

$ h eq frac(R, 2 cos^2 delta) dot.basic $

该外接圆半径也是 $h$，因而包住整个三角形。取第一次正向观测最坏
$R eq 1500$，得到

$ h approx 750.230847 med m m lt 751 med m m dot.basic $

这说明第一次正向观测后，至少存在一个相当小的有保证圆包络。`L305–308`
构造这个三角形圆心，再对当前多边形全顶点复核半径；若比 `mec`
的结果更小就采用它。它是独立的几何后备候选，避免把局部进展证明完全押在某次
MEC 数值求解上。实际数值会比理想公式多极小容差。

=== 3.5.2　侧移 0.1R 的几何含义
<侧移-0.1r-的几何含义>
设当前包络
$P_i subset.eq B lr((c comma r))$。机器狗从当前位置朝圆心看，单位方向为
$d$，垂直方向为 $v eq lr((minus d_y comma d_x))$。`_tracking_point` 构造

$ q_plus.minus eq c plus.minus 0.1 r thin v dot.basic $

小侧移可以改善与旧示向线的交会角，同时仍使机器狗走到不确定区域附近。它不是把
Q2 的完整极小极大选址算法嵌入 Q3，也没有逐点枚举所有可能第二示向度。

对任一候选点，由三角不等式

$ max_(x in P_i) parallel x minus q_plus.minus parallel lt.eq r plus 0.1 r eq 1.1 r dot.basic $

第一次正向观测后，$1.1 r$ 约不超过 825.254 m，远小于 999
m。因此在理想几何条件下，这些局部点有共同接收保证。代码仍逐顶点检查
`maxdist(q,t.poly)<=999`，不只相信概略推导。

候选点没有通过检查时返回圆心
`c`。这是一个安全回退，因为已认证的包络半径控制了所有可能源到圆心的距离。若两侧都可用，则按移动距离、以及到下一搜索站点距离的
0.15 倍评分。0.15 是路线偏好参数。

=== 3.5.3　局部收缩界与 18 步保护
<局部收缩界与-18-步保护>
到达局部点 $q$ 后，新的范围上界满足
$R_(upright(n e w)) lt.eq 1.1 r$。套用三角形包围圆公式，得到理想收缩界

$ r_(upright(n e w)) lt.eq frac(1.1, 2 cos^2 delta) thin r approx 0.5501693 thin r dot.basic $

于是第一次正向观测半径约 750.231 m 后，保守地再作 7
次这样的有效方向观测，便足以使理想上界低于 19.8 m。若得到
`near`，则可更早直接清除。有限次补测的理由是几何收缩，不是“随机走总会碰到”。

代码把每次 `_serve` 的局部测量限制设为 18 次，并检查新半径不能大于
$0.9 r plus 10^(minus 3)$。0.9 比理论 0.551 宽松，用作异常检测；18
是实现保护界，不能倒过来当成最紧复杂度结论。

#strong[必须区分两类观测。] 上述收缩推导针对主动走到 `q_±` 或 `c`
后的局部测向。途中已有停靠点的机会补测没有被要求满足这一比例；它可能提供很少的信息。源码也只在
`_serve` 的 `L425–426` 检查收缩，`_sweep_found` 没有同一检查。

如果在“所有可能位置都小于 999 m”的点得到
`no_signal`，程序立即报错。这意味着物理假设、历史响应或数值不变量至少有一项失效。它不会继续随机探索，也不会悄悄把该源记为已完成。

#horizontalrule

== 3.6　状态机：发现一个源与完成整场任务
<状态机发现一个源与完成整场任务>
=== 3.6.1　公开原例：MIT 的闸机状态机
<公开原例mit-的闸机状态机>
MIT 6.01SC 的 Lecture 2 handout 第 5–6 页用闸机解释有记忆的系统：状态为
`locked`、`unlocked`，输入为
`coin`、`turn`、`none`。投币转到解锁，转动转到锁定；没有动作时保留原状态，因此同一个
`none` 输入在两个状态下会产生不同输出。讲义还给出
`getNextValues(state, inp)`
的实现。#link("https://ocw.mit.edu/courses/6-01sc-introduction-to-electrical-engineering-and-computer-science-i-spring-2011/6befa2f7542ca110af48020a8c8cf8ad_MIT6_01SCS11_lec02_handout.pdf")[Q3-7]

这个例子教的是：输入本身不足以决定结果，还必须知道旧状态。Q3
中的“切换到频道
7”是否收费，也取决于当前测向频道；"返回无信号"意味着什么，还取决于这个频道以前有没有被确认存在、是否已经清除。

=== 3.6.2　每个频道的四个状态
<每个频道的四个状态>
`Track.status` 的含义如下：

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [状态], [已经知道什么], [仍需完成什么],
  [`UNKNOWN`],
  [尚未收到能够确认该频道存在源的响应。],
  [继续执行发现扫描，或者得到全局不存在证书。],
  [`FOUND`],
  [收到过方向响应，维护着位置外包络。],
  [收缩到清除条件并成功执行清除。],
  [`CLEARED`],
  [清除接口明确返回成功。],
  [不再测量或重复清除此频道。],
  [`ABSENT`],
  [由数量上界或连续覆盖证明该频道没有未发现源。],
  [无需继续搜索。],
)
]

```mermaid
stateDiagram-v2
    [*] --> UNKNOWN
    UNKNOWN --> UNKNOWN: 无信号，保存地点
    UNKNOWN --> FOUND: 获得方向
    UNKNOWN --> CLEARED: near 后清除成功
    UNKNOWN --> ABSENT: 全局发现证书
    FOUND --> FOUND: 更新位置外包络
    FOUND --> CLEARED: 认证后清除成功
```

`near` 分支没有先改成 `FOUND`，而是直接调用
`_clear`。这符合“已经离源不超过 5 m”的更强证据。只有清除响应为 `success`
才计入 `CLEARED`。

=== 3.6.3　源数上界如何形成完成证书
<源数上界如何形成完成证书>
记 $F$ 为 `FOUND` 频道数，$C$ 为 `CLEARED`
频道数。因为每个源有唯一频道，且只对不同频道计数，有

$ F plus C lt.eq N lt.eq 16 dot.basic $

一旦 $F plus C eq 16$，就推出
$N eq 16$，所有未知频道都不存在源，搜索可以结束；已发现但未清除的 $F$
个源仍须继续处理。`_certify_and_prune` 在 `L334–338`
实现此逻辑，把证书原因记为 `cardinality`。

一旦 $C eq 16$，则连清除任务也已完成，`run`
直接退出主循环。这里利用的是上界 16。下界 10 不能用作停止条件：清除了 10
个，仍可能还有 1–6 个没有发现。

`F+C` 是不同频道数量，不是方向读数条数。一个频道测了 20 次仍只贡献 1
个源。`Track.measurements`
只记录该频道收到方向响应的次数，也不是整局检测动作数。

=== 3.6.4　连续覆盖如何证明其余频道不存在
<连续覆盖如何证明其余频道不存在>
若 $F plus C lt 16$，可以依靠已经完成的扫描点集合 $cal(S)$
的圆盘覆盖证书。考虑扫描结束后仍处于 `UNKNOWN` 的任意频道 $i$：

+ 它在每一次过去的 `_scan` 时也必为 `UNKNOWN`；否则状态不会退回未知。
+ `_scan` 对当时所有未知频道都检测，因此这个频道在每个 $s in cal(S)$
  均有一次检测。
+ 若它存在源 $g_i in Omega$，覆盖证书保证存在 $s$ 使
  $parallel g_i minus s parallel lt.eq 999$。
+ 全向源在该距离必能接收，响应应为 `direction` 或
  `near`，与它仍为未知矛盾。

因此该频道可以标记
`ABSENT`。这个证明用到了“每个仍未知频道都扫描过所有已记录的扫描点”，不能仅证明机器狗走过这些坐标。

机会补测 `_sweep_found` 只检测已发现频道，所以它所在点不会自动加入
`scans`，不能拿来证明从未发现的频道不存在。单纯经过某点也不算扫描，因为移动中不能检测。

=== 3.6.5　全清除需要两类证书同时成立
<全清除需要两类证书同时成立>
整场任务完成条件为

$ underbrace(upright("没有遗漏的未知源"), upright("数量上界或覆盖证书")) quad and quad underbrace(upright("所有已经发现的源均成功清除"), upright("逐源清除响应")) dot.basic $

安全清除一个源，只证明这次动作没有离它太远；不能证明别处没有源。反过来，完成九点扫描只证明已经发现了所有源；未清除的
`FOUND` 仍必须服务。

输出字段 `coverage_certified` 只在 `search_reason=='disk_union'`
时为真。若原因是 `cardinality`，它可以为假而任务仍正确完成。读输出应看
`search_certificate` 和频道状态，不要把这个布尔值误读成“整场是否成功”。

=== 3.6.6　测向机当前频道是另一份状态
<测向机当前频道是另一份状态>
源频道编号与“接收机当前调谐频道”是不同概念。策略里的
`self.channel`、正式客户端里的 `current_channel`、本地模拟器里的
`channel` 都记录后者。

#align(center)[#table(
  columns: 4,
  align: (col, row) => (auto,auto,auto,auto,).at(col),
  inset: 6pt,
  [动作], [位置变化], [当前测向频道变化], [服务计时],
  [`measure(p,i)`],
  [移动到 $p$],
  [改为 $i$],
  [检测 5 s；若原频道不同另加 1 s。],
  [`clear(p,i)`],
  [移动到 $p$],
  [保持原测向频道],
  [本地成功 5 s，失败 3 s；清除目标编号不等于调谐动作。],
)
]

对应代码是 `L284` 与 `L316` 的区别、`O656–657` 的区别，以及 `S23` 与
`S30–34`。`_scan`
优先检测当前频道（若它仍未知），能够省一次进入扫描序列的换台。

#strong[本章状态核算例。] 假定均在同一点、相应清除可成功，初始频道为
1，依次执行
`measure(...,4)`、`clear(...,7)`、`measure(...,4)`。接收机频道依次为
4、4、4；动作耗时为 6、5、5 s，共 16 s。若误把清除动作当成切到
7，就会把第三步多算 1 s，还会影响后续扫描排序。

#horizontalrule

== 3.7　在线路线：哪里有证明，哪里是启发式
<在线路线哪里有证明哪里是启发式>
=== 3.7.1　公开原例一：插入方法比较的是新增路线成本
<公开原例一插入方法比较的是新增路线成本>
Cook、Cunningham、Pulleyblank、Schrijver 的《Combinatorial
Optimization》第 7 章 §7.2，印刷页
243–245，介绍插入构造：把新节点插入现有环游，使新增成本较小。书中同一个
1173 节点测试实例，图 7.2 的最近插入路线长度为 72337，图 7.3
的最远插入为
65980。书中明确把构造启发式、局部改进和最坏界区分开。#link("https://math.mit.edu/~goemans/18453S17/TSP-CookCPS.pdf")[Q3-8]

这是真实的教材实例比较；它不说明“最远插入在 Q3 一定最好”，因为 Q3
的源位置还未知，且有测向服务成本。我们要借用的是新增距离的思想。把当前边
$p arrow.r s$ 换成 $p arrow.r c arrow.r s$，新增长度为

$ Delta lr((p comma c comma s)) eq parallel p minus c parallel plus parallel c minus s parallel minus parallel p minus s parallel gt.eq 0 dot.basic $

#strong[本章补算。]
$p eq lr((0 comma 0)) comma s eq lr((1000 comma 0)) comma c eq lr((500 comma 100))$
时，$Delta eq 2 sqrt(500^2 plus 100^2) minus 1000 approx 19.804$ m。若
$r eq 100$ m，代码评分约为 119.804 m，低于 600
m，因此这个已发现任务可以被插入。

=== 3.7.2　公开原例二：启发式路线和已知最优解可以不同
<公开原例二启发式路线和已知最优解可以不同>
Larson 与 Odoni 的《Urban Operations Research》§6.4.6，Example 9
给出一个垃圾收集路线实例：仓库加九个收集点。教材先得到长度 258
的最小生成树，加入长度 143 的匹配，得到长度 401
的欧拉游程；跳过重复访问后路线为 371，而此实例的已知最优值是
331。随后进一步局部调整可降为
347。#link("https://web.mit.edu/urban_or_book/www/book/chapter6/6.4.6.html")[Q3-9]

这个公开算例最值得学习的不是记住那条路线，而是同时报告“构造结果”"改进结果""比较基准"。同理，Q3
若只运行一种配置，就不能写成“路线已优化到全局最短”。

上述两份教材的静态 TSP 都预先知道待访问节点。Ausiello
等人的在线旅行商研究则明确研究按时间陆续到达的请求，并区分是否要求回到起点；其作者所在大学公开研究记录可核对这种模型定义。#link("https://research.tue.nl/en/publications/algorithms-for-the-on-line-travelling-salesman/")[Q3-10]
Q3
的新任务由机器狗主动搜索发现，位置还会随测向收缩成变化的服务区域，和该论文的请求发布模型也有差别。故本文只作模型对照，不套用其竞争比。

=== 3.7.3　Q3 实际用的评分和选择规则
<q3-实际用的评分和选择规则>
设下一待扫描点为 $s$，已发现源 $i$ 当前包络为
$B lr((c_i comma r_i))$。`_choose` 使用

$ J_i eq underbrace(parallel p minus c_i parallel plus parallel c_i minus s parallel minus parallel p minus s parallel, upright("经圆心的新增距离")) plus underbrace(r_i, upright("不确定性惩罚，单位 m")) dot.basic $

选择最小 $J_i$ 的源；只有 $J_i lt.eq 600$ m
才在下一扫描站点之前服务。否则先走搜索骨架。

这里的 $r_i$
是经验惩罚：实际服务可能经过多个局部测量点，最后清除点也不等于旧圆心，因此“经圆心的两段路”并不是真实最终绕行长度。600
m 换算成纯移动约 120 s，但评分还含不确定性项，不能称为精确 120 s
调度预算。

没有下一个搜索点时，`_choose` 用
$parallel p minus c_i parallel plus r_i$
选择下一个已发现源，确保继续清除剩余任务。`deferred`
对照模式只是在仍有搜索点时暂缓服务，骨架结束后仍会进入这个分支。

=== 3.7.4　机会补测复用的是停靠位置，不是免费观测
<机会补测复用的是停靠位置不是免费观测>
`_sweep_found(p)` 会考虑所有尚未清除、半径仍大于 19.8 m
的已发现源。它还要求：

$ parallel p minus p_(upright(l a s t)) parallel gt.eq 25 comma #h(2em) max_(x in P_i) parallel x minus p parallel lt.eq 999 dot.basic $

第一项避免紧挨最近一次有效方向观测点再测；第二项保证所有可能源位置都能接收。此处少的是额外移动，检测的
5 s 和可能的换台 1 s仍照计。

源码中的检查只对该频道的最近一次方向观测点
`last`，不是对全部历史地点做全局去重；经历其他地点后，仍可能再次回到更早的位置。答辩描述应与这个实际判断一致。

`opportunistic_clear=True` 的名字容易误导：在当前主线里，它控制 `_serve`
结束后调用
`_sweep_found`。这主要是“完成一次服务后，再给其他未清除频道补测”，并非把所有半径已小于
19.8 m 的源立即逐个清除。事实上 `_sweep_found`
会跳过这些小半径源，等待调度器再服务。

=== 3.7.5　默认主线和研究分支必须分开
<默认主线和研究分支必须分开>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [配置项], [默认值], [当前主线中的作用],
  [`ring_m`],
  [8],
  [原点加八外围点。],
  [`offset`],
  [0.10],
  [主动定位侧移 $0.1 r$。],
  [`insert_m`],
  [600.0],
  [路线插入评分门槛。],
  [`negative`],
  [`True`],
  [使用全向无信号排除信息。],
  [`opportunistic`],
  [`True`],
  [扫描后复用停靠点补测已发现源。],
  [`opportunistic_clear`],
  [`True`],
  [服务结束后补测其他已发现源。],
  [`mode`],
  [`integrated`],
  [搜索与服务交织执行。],
  [`incidental`],
  [`False`],
  [不在服务终点另加全未知频道扫描。],
  [`prune`],
  [`False`],
  [不逐个删除未来环形站点。],
  [`rotate`],
  [`False`],
  [不按首测方向旋转搜索环。],
  [`speculative_r`],
  [0.0],
  [不在尚未认证时试探清除。],
)
]

`run_case` 使用不改参数的
`Config()`。本章不会把关闭的研究分支当作默认算法成果。源码中也没有
2-opt：没有枚举两条路线边再进行交换的循环，`Config`
注释还明确说明不声称实现 2-opt。

#horizontalrule

== 3.8　时间会计：优化目标怎样落到每一个动作
<时间会计优化目标怎样落到每一个动作>
=== 3.8.1　公开原例：模拟时间与实际等待时间
<公开原例模拟时间与实际等待时间>
SimPy 官方入门 "Basic Concepts → Our First Process" 给出一辆车交替停车 5
个时间单位、行驶 2 个时间单位的完整例子。运行到模拟时刻 15
时，事件依次发生于 0、5、7、12、14。它用 `env.now`
表示模拟时钟，`Timeout`
安排未来模拟事件。#link("https://simpy.readthedocs.io/en/latest/simpy_intro/basic_concepts.html")[Q3-11]

用这组公开数据手算一个周期，停车 5 加行驶 2 等于 7，第二周期结束于
14。这说明事件累计的模拟时间和执行 Python 程序花的真实时间是两个量。

Q3 的虚拟时钟由接口返回。检测动作已让模拟器推进 5 s，客户端无需再
`sleep(5)`。正式客户端的 `time.sleep`
用于连接等待和网络重试退避，消耗的是现实预算，不替代或增加题目中的检测服务时间。

=== 3.8.2　逐动作成本
<逐动作成本>
若当前位置为 $p$，当前测向频道为 $j$，则检测动作到 $q$ 测频道 $i$
的增量为

$ Delta T_(upright(m e a s u r e)) eq frac(parallel q minus p parallel, 5) plus 5 plus bold(1)_(i eq.not j) dot.basic $

本地模拟器清除动作的增量为

$ Delta T_(upright(c l e a r)) eq frac(parallel q minus p parallel, 5) plus cases(delim: "{", 5 comma & upright("成功：3 s 光学定位加 2 s 清除") comma, 3 comma & upright("失败：只付光学定位时间") dot.basic) $

失败计 3 s 是 `S33`
中的本地规则；完整官方失败响应与计费语义仍应以官方接口附件为准。官方客户端在发送清除前按
5 s 检查预算上界，见 `O645–647`。

整局本地成本恒等式为

$ T eq L_(upright(m o v e)) / 5 plus 5 M plus S_(upright(s w i t c h)) plus 5 C plus 3 F_(upright(c l e a r)) dot.basic $

这里 $M$ 是全部检测次数，包括方向、近源与无信号；$C$
是成功清除数；$F_(upright(c l e a r))$ 是失败清除数。定位算法 CPU
计算时间不在这个虚拟成本和中，却消耗现实运行预算。

=== 3.8.3　扫描顺序能节省多少换台
<扫描顺序能节省多少换台>
原点初始频道为 1。首次扫描所有 20 频道，若没有 `near` 插入清除，则

$ T_(upright(o r i g i n)) eq 20 times 5 plus 19 times 1 eq 119 med m s dot.basic $

对后续一次含 $q gt 0$
个未知频道的同点扫描：若当前频道也在未知集合，排第一位则换台 $q minus 1$
次；若不在，进入第一个频道也需一次换台，总计 $q$
次。主线按当前频道优先、其余编号升序实现这一点。

扫描发生 `near` 时会立刻清除，所以完整动作成本还需加清除成本；上面的
$5 q plus q minus 1$ 或 $6 q$ 只计算扫描中的检测与换台部分。

=== 3.8.4　两种跨局均值不能混用
<两种跨局均值不能混用>
单局平均每源耗时为
$A_k eq T_k slash C_k$。在每局均有至少一个成功清除时，常用两种汇总为

$ overline(A)_(upright(c a s e)) eq 1 / K sum_(k eq 1)^K T_k / C_k comma #h(2em) overline(A)_(upright(p o o l e d)) eq frac(sum_k T_k, sum_k C_k) dot.basic $

后一式是按清除数加权的平均。#strong[本章算例：] 两局分别
$lr((T comma C)) eq lr((1000 comma 10)) comma lr((3200 comma 16))$，单局每源耗时为
100、200 s；逐局等权均值为 150 s/源，合并后为
$4200 slash 26 approx 161.538$ s/源。

`S43–62` 同时输出两种统计，`S98–107`
还分别计算全部测试局与全清除成功局。若一局清除数为零，平均每源耗时未定义，代码在每源均值中跳过
`None`；研究报告应另外显式报告该失败局，不能让“未定义”消失在漂亮的平均值里。只报成功局的平均也可能有选择偏差，所以应同时报告总测试局数、全清除率和失败信息。

#horizontalrule

== 3.9　正式客户端：算法之外还有动作一致性
<正式客户端算法之外还有动作一致性>
=== 3.9.1　公开原例：已经创建了实例，却没收到响应
<公开原例已经创建了实例却没收到响应>
Malcolm Featonby 在 Amazon Builders’ Library 的 "Making retries safe
with idempotent APIs" 中给出一个单实例工作负载例子：调用方请求创建一个
EC2
实例，却因超时没有收到响应；若直接把重试当新请求，可能创建两个实例。文章的解法是由调用方提供唯一请求标识，服务端识别同一调用方、同一标识的重复请求；"同
ID、不同参数"应报参数不一致。#link("https://aws.amazon.com/builders-library/making-retries-safe-with-idempotent-APIs/")[Q3-12]

映射到 Q3：一次 `/measure`
可能已经移动机器狗、换台并推进虚拟时间，只是响应丢了。若客户端换一个
`request_id` 再测，那就可能是第二个动作。丢响应不等于没执行。

RFC 9110 §9.2.2 以断连后重发 PUT
说明幂等请求，并要求非幂等方法只有在已知其语义可幂等或原请求未生效时才自动重试。#link("https://www.rfc-editor.org/rfc/rfc9110.html#section-9.2.2")[Q3-13]
Q3 使用 POST，所以客户端的安全重试必须依赖#strong[应用层的请求 ID
去重契约]，不能从 HTTP 的 POST 方法名推出。

=== 3.9.2　当前代码确实做了什么
<当前代码确实做了什么>
`OfficialClient` 的请求序列是严格串行的：

+ `action` 检查上个动作是否仍在 `pending`；如果是，禁止产生新 ID。
+ 为新动作增加序号，生成一次 `request_id`，组装请求体。
+ `_request` 保存 `path`、`payload` 和原始 `body`。
+ 网络错误或不可信响应触发重试，但仍复用同一请求内容和同一 ID。
+ 得到可信明确响应后，更新虚拟时间并清空 `pending`。
+ 重试耗尽且结果仍未知时保留 `pending`、抛出
  `ResultUnknown`，停止生成后继动作。

默认 `retries=6`
对应最多初次加六次，共七次尝试。它是有限重试策略，不保证任何故障环境都最终成功。

可用一个状态表理解：

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [客户端认知状态], [可做的事], [对几何状态的影响],
  [没有待定动作],
  [发送一个新动作。],
  [暂不提前假设服务端已经执行。],
  [同一动作在重试],
  [复用旧请求 ID 和完整内容。],
  [不以超时充当 `no_signal`。],
  [收到合法明确接受],
  [接受响应并继续。],
  [由响应更新位置、频道、包络、时间。],
  [收到明确拒绝],
  [报协议错误。],
  [不把被拒动作算成已执行。],
  [结果未知且重试结束],
  [保留待定状态并报错。],
  [不生成新定位动作，也不假装全清除。],
)
]

客户端行为本身可以从源码核对。服务器是否持久记录
ID、重复请求是否只执行一次，则需要服务端契约与测试证据。上传的题目 PDF
在附录 3
引用了通信附件，但没有包含这些详细条款；本章不把客户端代码当成服务端行为的证明。

=== 3.9.3　为什么结果未知时连 `/exit` 也要限制
<为什么结果未知时连-exit-也要限制>
`main` 遇到异常并非无条件发送新 `/exit`，而是先调用
`can_exit()`。只有已经进入、没有退出、未尝试过退出、没有
`pending`，且还有现实余量时才允许退出。

原因是：前一个动作结果未知时，客户端无法安全确定动作序列已经到哪里。新
ID 的退出会把“未确认的几何动作”与“结束测试”并排留下。保留原动作
ID、停止后续请求，能使故障含义可审计。它仍然是故障停止，不能被写成完成了清除任务。

=== 3.9.4　两套预算和响应检查
<两套预算和响应检查>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [检查], [代码位置], [作用],
  [只接受本机回环 HTTP 地址],
  [`O516–520`],
  [与当前本机模拟器部署方式一致。],
  [坐标有限且分量不超 $2 times 10^6$],
  [`O639–642`],
  [避免异常位置提交。],
  [频道为 1–20 的整数，排除布尔值],
  [`O643`],
  [避免 Python 中 `bool` 作为 `int` 的混淆。],
  [下一动作最坏虚拟增量],
  [`O644–647`],
  [移动加 5 s；检测需要时再加换台 1 s。],
  [`/enter` 后读取实际剩余现实时间],
  [`O666–668`],
  [不把每次运行都假定有完整 1200 s。],
  [正常动作保留约 8 s 退出余量],
  [`O558–566`],
  [尽量避免在现实截止前还生成新动作。],
  [HTTP 状态与 `accepted` 同时检查],
  [`O567–588`],
  [不把“解析出了 JSON”当成动作成功。],
  [数值有限、虚拟时钟不倒退、结果枚举合法],
  [`O570–588`],
  [防止错误响应进入策略状态。],
)
]

题面还区分 25 分钟测试窗口与 `/enter` 后至多 20 分钟程序运行时间。`O667`
在调用进入之前记录时刻，再加返回的实际剩余时间设置截止时刻，这样不会把进入请求的网络耗时额外送给自己。

=== 3.9.5　日志证明什么
<日志证明什么>
正式客户端写自己的 JSONL 请求、响应、重试和汇总日志；请求队号被替换成
`<TEAM_ID>`。这些日志有助于定位程序和网络问题。题目要求的官方加密行为日志是另一份材料，不能用客户端
JSONL 替代。官方测试案例编码也不能从当前客户端自动推断。

本章没有启动官方模拟器、调用正式测试或取得官方日志。下节全部数值均明确属于本地教学复现。

#horizontalrule

== 3.10　代码地图：从公式到函数，再到真实调用
<代码地图从公式到函数再到真实调用>
=== 3.10.1　几何与策略逐段对应
<几何与策略逐段对应>
`O1–502` 与 `L1–502` 相同，表中的本地行号也适用于官方单文件的同段。

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [代码位置], [输入与输出], [数学或策略责任],
  [`L10`，`DELTA`],
  [定义 1.0051° 的弧度值],
  [物理误差、显示量化与计算裕量。],
  [`L22–23`，`maxdist`],
  [点、顶点表 → 最大距离],
  [包络半径、统一接收和清除距离的顶点检验。],
  [`L25–35`，`hull`],
  [点集 → 凸包],
  [为无信号排除后的非凸集合构造凸外包络。],
  [`L37–56`，`clip`],
  [多边形、半平面 → 裁剪多边形],
  [半平面相交，向外容差和重复点清理。],
  [`L58–61`，`arena_polygon`],
  [边数 → 初始多边形],
  [外切 48 边形包含整个目标圆域。],
  [`L63–76`，`bearing_update`],
  [旧域、测量点、显示角 → 新外包络],
  [两侧角楔约束与轴向范围约束。],
  [`L78–98`，`exclude_disk_hull`],
  [多边形、排除圆盘 → 凸外包络],
  [安全使用全向无信号，减小排除半径以保守计算。],
  [`L100–107`，`inside_polygon`],
  [点、多边形 → 内外判定],
  [本地审计辅助；主在线策略不读取真值调用它。],
  [`L109–118`，几何圆辅助],
  [两点或三点 → 圆],
  [直径圆、平移后计算的外接圆和容差内判定。],
  [`L120–146`，`mec`],
  [顶点表 → 中心与审计半径],
  [寻找小包围圆，并对全部顶点复核。],
  [`L148–154`，`nearest_certified_clear`],
  [当前点、包围圆 → 清除点],
  [投影到 $B lr((c comma 19.8 minus r))$。],
  [`L156–185`，圆弧与区间函数],
  [圆盘几何 → 区间覆盖判定],
  [将二维边界检查化为一维角区间并集。],
  [`L187–205`，`covers_arena`],
  [真正扫描过的点 → 布尔值],
  [区域边界与内部暴露圆弧的连续覆盖证书。],
  [`L207–212`，`ring_sites`],
  [点数、旋转角、方向 → 外环点],
  [默认策略传入 8，使用解析半径公式。],
  [`L228–265`，`Config/Track`],
  [配置与每频道状态],
  [冻结主线、保留研究分支、维护未知域与历史测量。],
  [`L281–311`，`_observe`],
  [频道、位置 → 响应种类],
  [接收后更新状态；负观测、near、正观测三分支。],
  [`L313–326`，`_clear`],
  [频道、位置、是否认证 → 成功与否],
  [成功才计数；认证失败立即停止。],
  [`L332–351`，`_certify_and_prune`],
  [当前状态 → 更新搜索完成标志],
  [数量上界或已扫描圆盘并集证书。],
  [`L353–369`，`_scan/_sweep_found`],
  [停靠点 → 一组实际观测],
  [未知频道扫描与已发现频道机会补测。],
  [`L371–394`，`_make_plan`],
  [配置、历史 → 待扫描列表],
  [默认生成固定环；旋转研究分支关闭。],
  [`L396–407`，`_tracking_point`],
  [单源包络、下一站 → 下一点],
  [认证清除点、小侧移、接收检查、圆心回退。],
  [`L409–434`，`_serve`],
  [频道、下一站 → 服务到清除],
  [18 步保护、收缩检查、完成后机会补测。],
  [`L436–452`，`_worth_extra_scan`],
  [当前路线与扫描历史 → 额外扫描值不值],
  [研究分支；默认不会执行。],
  [`L454–468`，`_choose`],
  [已发现源、下一站 → 选择频道或不插入],
  [绕行加半径评分，不含 2-opt。],
  [`L470–498`，`run`],
  [已初始化策略 → 汇总],
  [原点扫描、建计划、搜索/服务交替、终止判断。],
  [`L501–502`，`run_case`],
  [行动接口、可选审计 → 单局结果],
  [固定使用 `Config()` 的统一入口。],
)
]

`L217` 中提到 `geometry.py`
的注释属于合并为单文件后残留的模块描述。当前文件已经把几何函数定义在同一文件顶部，实际并不需要外部
`geometry.py`。分析依赖应看 `import` 和实际定义，不能只看注释。

=== 3.10.2　一次本地启动怎样进入策略
<一次本地启动怎样进入策略>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [顺序], [调用], [数据在这一层的含义],
  [1],
  [`S78 main`],
  [读取循环数、批测种子和输出路径。],
  [2],
  [`S85–86`：生成子种子、`make_case(seed)`、`Simulator(...)`],
  [模拟器生成并保存真值。],
  [3],
  [`S88`：`solver.run_case(sim)`],
  [向求解器只传行动接口对象。],
  [4],
  [`L502`：`Strategy(api,Config(),audit).run()`],
  [初始化 20 个频道轨迹。],
  [5],
  [`L471`：`_scan((0,0))`],
  [对所有未知频道检测。],
  [6],
  [`L357 → L282 → S20`],
  [`_scan → _observe → Simulator.measure`。],
  [7],
  [`S21–29 → L284–309`],
  [模拟器更新物理状态后返响应；策略使用响应裁剪定位域。],
  [8],
  [`L471`：`_make_plan()`],
  [得到外围八点队列。],
  [9],
  [`L483–487`],
  [`_choose` 决定插入 `_serve`，或前往下一站 `_scan`。],
  [10],
  [`L414–415 → L314 → S30`],
  [得到清除证书后调用模拟器清除。],
  [11],
  [`L493–498 → S88–95`],
  [策略返回；模拟器使用真值核查是否全清除并记录案例。],
)
]

从 Python 对象能力看，`sim` 对象上确实有 `sources` 属性；但当前
`Strategy` 的实现只调用 `measure` 和
`clear`，不读取该属性。严谨表述应是“实现中未读取真值”，而不是声称语言运行环境强制实施了访问隔离。正式求解器也不导入本地模拟器或随机源生成器。

=== 3.10.3　正式启动增加了哪几层
<正式启动增加了哪几层>
正式运行由 `O683 main` 开始：解析队号与接口地址，创建
`OfficialClient`，等待端口开放，调用 `/enter`，然后运行相同的
`run_case(api)`。核心策略中的一次 `_observe` 最终到达

$ mono("OfficialClient.measure") med arrow.r med mono("action(’/measure’,p,i)") med arrow.r med mono("_request") med arrow.r med mono("HTTP POST") dot.basic $

读回响应时先经过 `_validate_success`，再返回策略。完成后 `main` 调用
`/exit`，写汇总并检查日志是否完整。客户端的预算和协议保护包在策略外围，因此相同策略可以在本地直接对象调用和正式
HTTP 通信两种环境下运行。

=== 3.10.4　真实固定案例：前 21 个动作
<真实固定案例前-21-个动作>
下面是本章在 Python 3.12.14 中实际执行 `make_case(2026)`
后得到的本地轨迹。为避免大量重复，原点动作按频道组汇总；序号是检测与清除合并计数的实际动作号。

#align(center)[#table(
  columns: 4,
  align: (col, row) => (auto,auto,auto,right,).at(col),
  inset: 6pt,
  [实际动作号], [位置/频道], [响应或操作], [累计虚拟时间/s],
  [1],
  [原点，频道 1],
  [无信号；保持频道 1],
  [5.000],
  [2–6],
  [原点，频道 2–6],
  [均无信号，每次加 6 s],
  [35.000],
  [7],
  [原点，频道 7],
  [方向 41.72°],
  [41.000],
  [8],
  [原点，频道 8],
  [无信号],
  [47.000],
  [9–11],
  [原点，频道 9、10、11],
  [方向 151.85°、104.94°、281.76°],
  [65.000],
  [12–13],
  [原点，频道 12、13],
  [无信号],
  [77.000],
  [14–15],
  [原点，频道 14、15],
  [方向 207.96°、184.71°],
  [89.000],
  [16–20],
  [原点，频道 16–20],
  [均无信号],
  [119.000],
  [21],
  [$lr((945.973419 comma 0))$，频道 20],
  [先保留当前频道，移动后检测，无信号],
  [313.194684],
)
]

动作 21 增量可手算为

$ 945.973419 / 5 plus 5 eq 194.194684 med m s dot.basic $

没有换台，因为上一动作结束时已经是频道
20。这就是状态机与时间会计进入真实路线的地方。

此后同站扫描未知频道；动作 28 在频道 8 得到方向
343.86°。先前在原点对频道 8 得到的无信号，也会被作为半径 1000 m
的历史排除条件重新施加。

=== 3.10.5　同一案例中频道 7 的完整观测与清除链
<同一案例中频道-7-的完整观测与清除链>
以下列出该频道全部四次方向观测和一次清除；其他频道的中间动作没有展开。半径来自每次
`_audit` 调用时的真实策略状态。

#align(center)[#table(
  columns: 5,
  align: (col, row) => (right,auto,auto,right,right,).at(col),
  inset: 6pt,
  [动作号], [检测/清除点约值], [响应], [更新后的包络半径/m],
  [累计虚拟时间/s],
  [7],
  [$lr((0 comma 0))$],
  [方向 41.72°],
  [750.230851],
  [41.000000],
  [47],
  [$lr((668.904220 comma 668.904220))$],
  [方向 32.70°],
  [182.628526],
  [613.998026],
  [143],
  [$lr((1244.869311 comma 1038.154139))$],
  [方向 211.70°],
  [163.394260],
  [2975.582283],
  [144],
  [$lr((975.811273 comma 887.816782))$],
  [方向 234.94°],
  [10.487204],
  [3042.224330],
  [145],
  [$lr((957.119260 comma 861.429303))$],
  [清除成功],
  [已清除],
  [3053.691757],
)
]

最后一次观测后的包围圆心约为

$ c eq lr((951.736133 comma 853.829953)) comma #h(2em) r eq 10.487204 dot.basic $

可用移动余量是 $19.8 minus r approx 9.312796$
m，程序把当前位置投影到这个子圆盘，得到动作 145
的清除点。它没有先假设真源在圆心。

为了独立核对，本章在求解器外用模拟器真值做审计：每次更新后检查真源仍在多边形内，并检查它到所报圆心的距离不大于所报半径。该案例频道
7 的真源为 $lr((953.041425 comma 855.753695))$，实际清除距离约 6.988652
m。这个真值仅用于事后审计，没有参与下一动作的选择。

=== 3.10.6　用总成本核对完整一局
<用总成本核对完整一局>
同一案例结束时：

$ L_(upright(m o v e)) eq 13718.578103730204 med m m comma quad M eq 136 comma quad S_(upright(s w i t c h)) eq 127 comma quad C eq 10 comma quad F_(upright(c l e a r)) eq 0 dot.basic $

代入得到

$ T eq 13718.578103730204 / 5 plus 5 times 136 plus 127 plus 5 times 10 eq 3600.715620746041 med m s dot.basic $

每源耗时为 360.071562 s。完整路线远长于 6014.090390 m
的固定搜索骨架，这恰好说明局部定位、清除和接回搜索路线的成本不能忽略。

本章还跑了另外三个直接案例种子：

#align(center)[#table(
  columns: 7,
  align: (col, row) => (right,auto,right,right,right,auto,right,).at(col),
  inset: 6pt,
  [直接案例种子], [源数/清除数], [虚拟总时间/s], [每源耗时/(s/源)],
  [扫描站数], [搜索完成证书], [失败清除],
  [2026],
  [10/10],
  [3600.716],
  [360.072],
  [9],
  [`disk_union`],
  [0],
  [20260929],
  [13/13],
  [4217.264],
  [324.405],
  [9],
  [`disk_union`],
  [0],
  [271828],
  [15/15],
  [3695.770],
  [246.385],
  [9],
  [`disk_union`],
  [0],
  [0],
  [16/16],
  [4105.312],
  [256.582],
  [8],
  [`cardinality`],
  [0],
)
]

这四局是代码讲解用的小规模可复现检查，没有用来估计总体成功概率、比较参数优劣或代替官方正式成绩。第四局展示了不走完全部九站也可证明完成搜索的合法情形。

=== 3.10.7　怎样复现，怎样避免种子误会
<怎样复现怎样避免种子误会>
在仓库根目录运行下面的只读教学命令，可复现第一局输出：

```bash
PYTHONDONTWRITEBYTECODE=1 python -c "import sys;sys.path.insert(0,'source/Q3');from q3_local_simulator import make_case,Simulator;from q3_local_solver import run_case;s=Simulator(make_case(2026),2026);r=run_case(s);print(r['cleared'],round(r['virtual_time_s'],3),round(r['average_time_s'],3),r['scan_sites'],r['search_certificate'])"
```

预期输出：

```text
10 3600.716 360.072 9 disk_union
```

这是直接把 2026 传给 `make_case`。而下列标准批测命令的 `--seed 2026`
是#strong[批次种子]：`S84–86`
会先用它生成每局的子种子，所以不会得到上面的同一局。

```bash
python source/Q3/q3_local_simulator.py --loops 20 --seed 2026 --output q3_local_demo.json
```

批测结果 JSON 中保留了每局 `seed`，可以将失败局的那个子种子直接传给
`make_case` 重放。运行本地模拟器才是本地入口；`q3_local_solver.py`
仅定义函数和类，没有自动启动一场测试的 `main`。

#horizontalrule

== 3.11　正确性论证、回退与实验边界
<正确性论证回退与实验边界>
=== 3.11.1　可以给出的条件性定理
<可以给出的条件性定理>
在下列假设下讨论精确几何算法：源静止、频道唯一、全部为全向、接收半径在规定区间、角误差及显示误差满足包络、行动响应可信且最终可完成，集合运算保持真源不变量。

#strong[命题 A：发现完整性。]
完成九点扫描后，所有存在源的频道均已获得正向或 near
响应；或者，在此前已确认 16 个不同源时也可提前结束搜索。证明见 §3.2 和
§3.6。

#strong[命题 B：清除安全性。] `near` 表明距离不超过 5
m；其余主线清除点满足
$r plus parallel q minus c parallel lt.eq 19.8 lt 20$。因此每次主线认证清除都在物理清除范围内。证明依赖真源始终保留在外包络中。

#strong[命题 C：单源有限定位。] 第一次方向响应后有约 750.231 m
的包围半径；后续主线主动测向在保证接收的点进行，理想半径以约 0.55017
的比例收缩，因而有限步达到认证阈值。

#strong[合并。]
搜索骨架有限、源数有限，每个已发现源需要的主动定位步骤有限；在接口可持续完成动作的条件下，可以完成全部源的清除。

不能把这段条件性论证扩大为“在任何网络中，当前浮点程序一定完成官方测试”。浮点实现没有机器证明，客户端还可能遇到明确拒绝、超时和结果未知。异常停止保住的是结果表述的诚实性，并不等于任务成功。

=== 3.11.2　各类回退的真实含义
<各类回退的真实含义>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [情形], [程序行为], [应如何解释],
  [侧移点不满足统一接收检查],
  [返回包围圆心],
  [几何安全回退。],
  [MEC 候选较大],
  [比较独立三角形中心的全点复核半径],
  [另一种有效外包围圆候选。],
  [得到 `near`],
  [同点直接清除],
  [使用更强的距离信息。],
  [不够“顺路”],
  [先去下一搜索站],
  [调度延后；没有丢弃已发现任务。],
  [已扫描站点不够覆盖],
  [继续剩余骨架],
  [搜索继续，不能宣告缺席。],
  [计划耗尽但无覆盖/数量证书],
  [报 `coverage certificate missing`],
  [拒绝给出虚假的不存在结论。],
  [外包络变空],
  [报不相容或数值异常],
  [不用空集制造半径零的假清除证书。],
  [认证清除失败],
  [立即报错],
  [主线安全不变量已受挑战。],
  [保证接收点出现无信号或局部不收缩],
  [立即报错],
  [要追查物理、响应或数值假设。],
  [网络错误],
  [同 ID、同内容重试],
  [以服务端幂等契约为前提的通信恢复。],
  [请求最终结果未知],
  [保留待定状态并停止],
  [不用新 ID 延续一条未经确认的动作链。],
)
]

试探清除失败后排除 20 m 圆盘的分支仅在开启 `speculative_r`
的研究模式可能触发，默认主线不会依靠失败清除获取信息。

=== 3.11.3　哪些说法有证据，哪些还需要实验
<哪些说法有证据哪些还需要实验>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [说法], [当前证据], [合理表述],
  [默认搜索点能够连续覆盖目标圆域],
  [解析构造、端点凸性检查、运行时圆弧证书],
  [有几何证明。],
  [认证清除点对全部保留候选位置安全],
  [集合包含、顶点审计、三角不等式],
  [有条件性安全证明。],
  [主动局部定位有限步缩小],
  [三角形圆包络与接收界],
  [有理想几何收缩证明。],
  [600 m 插入阈值最好],
  [README 的有限配置经验描述],
  [当前未独立复核其原始比较数据。],
  [0.1r 侧移全局最优],
  [无连续全域优化证明],
  [经验参数，可做消融比较。],
  [本地四局全清除],
  [本章真实执行与模拟器真值检查],
  [教学检查通过，样本很小。],
  [官方三局也达到这些数值],
  [本章没有官方日志],
  [不作此声称。],
  [Q3 实现了 2-opt 或完整 GTSP 求解],
  [源码没有相应优化器],
  [使用在线插入启发式。],
)
]

若要继续做效率实验，应固定同一批案例子种子，比较
`sequential`、`deferred`、`integrated`，再单独关闭机会补测、改变
`offset` 或
`ring_m`；同时报告全清除率、失败原因、总虚拟时间、移动距离、测量和换台次数。只有这样才能把“观察到更快”归因到明确的策略差异。

#horizontalrule

== 3.12　答辩问答：先说结论，再补证明
<答辩问答先说结论再补证明>
#strong[问 1：你们怎么知道还有没有没发现的源？] \
答：用全局发现证书。已确认 16
个不同频道时，由源数上界推出没有其他源；否则完成对仍未知频道的连续圆盘覆盖扫描，再以全向源最小接收半径推出剩余未知频道不存在。

#strong[问 2：清除了 10 个为什么不能停止？] \
答：10 是源数下界，不是实际源数。只凭清除 10 个，无法排除还存在最多 6
个源。

#strong[问 3：九点中的原点是几何覆盖必需的吗？] \
答：默认外围半径约 945.973 m，小于设计半径 995
m，所以八外围圆盘本身已经覆盖目标圆。原点扫描利用出发位置提前提供信息；九点是执行策略，没有声称最少覆盖点。

#strong[问 4：为什么覆盖半径用 999 m，构造又用 995 m？] \
答：物理保证半径是 1000 m。995 m 用来构造留有几米余量的布点；999 m
用于运行时统一接收与覆盖判定，保留 1 m 余量。两个值是不同层的保守设计。

#strong[问 5：为什么接收到方向后不是沿示向线直接走到头？] \
答：示向度有误差，沿线行走不一定提供足够横向几何信息。程序维护角楔交的整个候选域，在小包围圆附近侧移补测，保留接收保证并获得收缩。

#strong[问 6：1.0051° 是否把题目的 1° 改大了？] \
答：物理误差仍为 1°。另加的 0.005°包住两位小数读数的量化误差，再加
0.0001°计算余量，使程序角楔仍包含真方向。

#strong[问 7：无信号为什么不直接宣布频道为空？] \
答：它也可能是距离超出未知有效半径。对全向源一次无信号只能安全排除该点周围的
1000 m 开圆盘；需要覆盖全部目标区域后才能判不存在。

#strong[问 8：MEC 中心是估计位置，为什么可在它附近直接清除？] \
答：决策不是依赖中心“估计得准”，而是用全部顶点审计半径证明真源在圆内，并令清除点满足
$parallel q minus c parallel plus r lt.eq 19.8$。这个上界覆盖最坏候选位置。

#strong[问 9：如果 MEC 算法没有找到真正最小圆，还安全吗？] \
答：只要最终复核半径确实包含所有顶点，就仍能得到安全包围圆。圆过大会多测或多走；若半径被低估则安全性受损，所以程序用全点审计并留余量。

#strong[问 10：你们有没有证明总时间最优？] \
答：没有。覆盖、位置保留和清除有几何证明；总时间由在线插入、小侧移和停靠点复用降低，参数优劣需固定案例的比较实验，当前代码没有全局路线最优证书。

#strong[问 11：清除频道 7 后，当前频道是不是变成 7？] \
答：不是由清除目标决定。清除使用光学装置，代码保持原测向频道；只有
`measure` 更新当前测向频道。

#strong[问 12：同一点多测几次平均，会不会更好？] \
答：题面说同地点误差固定，不能假设独立噪声再用平均减小安全误差界。移动形成新基线才可能增加新的几何约束。

#strong[问 13：网络超时后重新发一个 ID 更保险吗？] \
答：结果可能已经执行，新 ID 会形成新动作。当前客户端在重试中复用旧 ID
和完整请求；若最终结果仍未知，就保留待定状态停止。此机制依赖服务端同 ID
去重契约。

#strong[问 14：本地模拟器成功，能否称官方演练成功？] \
答：不能。本地模拟器采用自定义源分布与误差场，且没有完整 HTTP
故障环境；官方演练和正式成绩需要对应官方记录。

#strong[问 15：`coverage_certified=False` 是不是漏搜？] \
答：要看 `search_certificate`。若是 `cardinality`，说明通过 16
源上界完成发现证书，布尔值为假只是没有采用圆盘并集证书。

#strong[问 16：算法报“认证清除失败”后会怎么办？] \
答：主线停止并报告异常，不把失败算成成功，也不启用默认关闭的试探策略掩盖不变量失效。

#horizontalrule

== 3.13　练习与完整解答
<练习与完整解答>
=== 练习 1：分清读数误差与物理误差
<练习-1分清读数误差与物理误差>
真实方向为 0.006°，物理读数为
1.006°，显示到两位小数。写出显示值、显示误差，并说明 ±1° 角楔和 ±1.0051°
角楔的差别。

#strong[解答。] 显示值为 1.01°，它与真方向的圆周距离为
1.004°。物理误差正好 1°，符合题设；只围绕显示值开 ±1° 会删掉真方向，而
±1.0051° 能包含它。

=== 练习 2：解释无信号排除半径
<练习-2解释无信号排除半径>
某源接收半径为 1100 m，机器狗与它相距 1200 m，返回无信号。为什么删除
1500 m 圆盘错误？为何删除半径略小于 1000 m 的开圆盘安全？

#strong[解答。] 真源在 1500 m
圆盘内但不能接收，删除该圆盘会误删真源。相反，若一个有效全向源距测点不超过
1000 m，它必在至少 1000 m
的接收范围内，不可能无信号；稍减小排除半径会多保留一些点，仍安全。

=== 练习 3：计算三角形外包络
<练习-3计算三角形外包络>
某次正向更新前，旧多边形给出的最大距离为 900 m。取
$delta eq 1.0051^compose$，求新的三角形包围圆半径上界。

#strong[解答。] $R eq min lr((1500 comma 900)) eq 900$
m，忽略极小计算余量，

$ h eq frac(900, 2 cos^2 lr((1.0051^compose))) approx 450.138508 med m m dot.basic $

即使 MEC 没有带来进一步改善，也有这个外包围圆可用。

=== 练习 4：从矩形得到最近认证清除点
<练习-4从矩形得到最近认证清除点>
定位外包络为顶点 $lr((plus.minus 12 comma plus.minus 9))$ 的矩形，当前点
$p eq lr((40 comma 0))$。求 MEC、最近认证清除点和到达该点的移动时间。

#strong[解答。] 两个对角顶点间距为 30，故半径至少
15；原点到每个顶点距离也为 15，所以 MEC 为
$c eq lr((0 comma 0)) comma r eq 15$。认证子圆盘半径为
$19.8 minus 15 eq 4.8$，最近点 $q eq lr((4.8 comma 0))$。移动 35.2
m，耗时 $35.2 slash 5 eq 7.04$ s。认证最大源距不超过
$15 plus 4.8 eq 19.8$ m。

=== 练习 5：发现完整性与清除完整性
<练习-5发现完整性与清除完整性>
情形 A：`FOUND=4`、`CLEARED=11`、其余未知，尚未覆盖全域。情形
B：`FOUND=4`、`CLEARED=12`、其余未知。分别能停止搜索吗？能结束任务吗？

#strong[解答。] A 共确认 15 个源，可能还有第 16
个，因此不能仅凭数量停止搜索，也不能结束任务。B 已确认 16
个源，可以将剩余未知频道判为不存在并停止搜索，但还有 4
个已发现源要清除，任务尚未结束。

=== 练习 6：为什么只覆盖外边界会漏掉内部洞
<练习-6为什么只覆盖外边界会漏掉内部洞>
目标圆半径为 1800 m，在它的圆周上等距放八个扫描点，每个扫描圆盘半径 710
m。证明目标圆的外边界被覆盖，但中心没有被覆盖。

#strong[解答。] 外边界任一点距最近站点的圆心角差至多
$pi slash 8$，弦长至多

$ 2 times 1800 sin lr((pi slash 16)) approx 702.325159 lt 710 dot.basic $

因此外边界被覆盖；中心距所有站点都为 1800，大于
710，所以中心未覆盖。这给出了必须检查内部暴露圆弧的明确反例。

=== 练习 7：收缩到清除阈值需要几次
<练习-7收缩到清除阈值需要几次>
从半径上界 750.231 m 开始，每次主动方向测量最多乘以
0.551。至少需要多少次这样的测量，才能用这一上界保证不超过 19.8 m？

#strong[解答。] 要满足 $750.231 lr((0.551))^k lt.eq 19.8$，即

$ k gt.eq frac(log lr((19.8 slash 750.231)), log lr((0.551))) approx 6.1 dot.basic $

所以取
$k eq 7$。这是理想几何的保守保证次数，不是声称每个案例实际都测七次，也不是机会补测必须满足同一收缩。

=== 练习 8：一次扫描的频道成本
<练习-8一次扫描的频道成本>
当前位置不变，要检测 14
个未知频道。当前测向频道也在未知集合中。若把它排第一位，检测加换台共多少秒？若先做了针对另一个频道的清除，是否必须重新付一次换台？

#strong[解答。] $14 times 5 plus 13 eq 83$
s。清除不改变测向频道，因此只要原当前频道仍在未知集合，排序和换台数不因这次清除改变；清除动作本身的时间另计。

=== 练习 9：核算一局总时间
<练习-9核算一局总时间>
一局移动 10000 m，检测 120 次，换台 110 次，成功清除 12 个，失败清除 0
次。求总虚拟时间与平均每源耗时。

#strong[解答。]
$T eq 10000 slash 5 plus 5 times 120 plus 110 plus 5 times 12 eq 2770$
s。每源耗时 $2770 slash 12 approx 230.833$ s/源。若这 12
个不是全部实际源，还不能仅凭这个平均时间认为策略达标。

=== 练习 10：读懂插入评分
<练习-10读懂插入评分>
当前点 $lr((0 comma 0))$，下一搜索站点 $lr((1000 comma 0))$。任务 A
的圆心为 $lr((500 comma 100))$、半径 100；任务 B 圆心为
$lr((500 comma 500))$、半径 250。默认 `_choose` 会选哪个？

#strong[解答。]

$ J_A eq 2 sqrt(500^2 plus 100^2) minus 1000 plus 100 approx 119.804 comma $

$ J_B eq 2 sqrt(500^2 plus 500^2) minus 1000 plus 250 approx 664.214 dot.basic $

选 A，且其评分不超过 600，允许插入；B
的评分超过阈值。评分并非精确未来服务时间，因此结论只描述这条启发式。

=== 练习 11：超时后的正确状态
<练习-11超时后的正确状态>
客户端向 `/clear` 发出 ID 为 `abc-17`
的动作，连接断开，没有收到可信响应。能否马上改用 `abc-18`
重发同样清除？若七次同 ID 尝试仍无法确认，能否用新 ID 发送退出？

#strong[解答。] 不能改 ID
重发，因为第一个清除可能已经执行。应按服务端约定复用 `abc-17`
和完整请求。仍未知时保留 `pending`，当前代码阻止新动作，`can_exit()`
也不会允许一个新的退出。此时应报告结果未知或运行未完成。

=== 练习 12：辨认实验结论的力度
<练习-12辨认实验结论的力度>
已知本章四个本地固定种子均全清除。下列哪些说法成立：①这四局通过；②所有允许案例均通过了软件验证；③几何模型有条件性全清除论证；④九点在所有策略中最快；⑤可把表中数值写成官方三次正式成绩。

#strong[解答。]
①成立，是实际运行事实。③可以成立，但依据是另外的几何证明和其假设，不是四次实验。②、④、⑤均无相应证据。有限样本用于发现实现错误与比较经验效率，不能替代连续全域证明或官方来源。

#horizontalrule

== 3.14　复述提纲与一手来源
<复述提纲与一手来源>
=== 五分钟复述提纲
<五分钟复述提纲>
+ #strong[目标与信息：] 未知 10–16 源、20
  个唯一频道；全向、接收半径有共同下界、角误差有确定界。
+ #strong[发现：] 九点搜索骨架；圆盘连续覆盖或 16
  源上界作为发现完成证书。
+ #strong[定位：]
  外切初始域、带量化裕量的角楔、无信号圆盘排除与凸外包络，始终保留真源。
+ #strong[清除：]
  审计包围半径；$r plus parallel q minus c parallel lt.eq 19.8$；小侧移保证接收并几何收缩。
+ #strong[效率与执行：] 在线插入、机会补测、准确频道成本；串行、同 ID
  重试、未知结果停止；效率经验与官方成绩各需其证据。

=== 可逐项核查的公开来源
<可逐项核查的公开来源>
下列均为论文、作者教材、大学课程材料或原项目官方文档，于 2026-09-29
核查。除本章明确列出的原例数据外，推导与课堂算例均为本章重述、补算；没有整页复制原文或原图。

#strong[#link("https://cs.wmich.edu/gupta/teaching/cs5950/fall2011/coverage%20problem%20in%20WSNs%20by%20Huang%20and%20Tseng%20wsna03%2010.1.1.58.2392.pdf")[Q3-1]
Chi-Fu Huang, Yu-Chee Tseng.] "The Coverage Problem in a Wireless Sensor
Network," WSNA 2003, pp. 115–121。定位：§3.1、Figure 2、Lemma 1、Theorem
1；边界特例见 Figure 3，异半径公式见
§3.2。已核查论文全文中角区间扫描与边界讨论。 \
URL：#link("https://cs.wmich.edu/gupta/teaching/cs5950/fall2011/coverage%20problem%20in%20WSNs%20by%20Huang%20and%20Tseng%20wsna03%2010.1.1.58.2392.pdf")[大学课程保存的原论文 PDF]。

#strong[#link("https://webperso.ensta.fr/jaulin/codac2_doc.pdf")[Q3-2]
Luc Jaulin.] #emph[Codac2: Python manual]。定位：§8.3 "Exercises 11:
Localization of a robot"，印刷页 15–16；四地标表、极坐标约束与 `q=1`
的公开解程序。 \
URL：#link("https://webperso.ensta.fr/jaulin/codac2_doc.pdf")[作者发布的手册 PDF]。

#strong[#link("https://doc.cgal.org/latest/Bounding_volumes/index.html")[Q3-3]
CGAL Project.] #emph[Bounding Volumes: User Manual]。定位："Bounding
Spheres for the Homogeneous Kernel"，例程
`Min_circle_2/min_circle_homogeneous_2.cpp`；100
个交替正负的共线点，以及有/无随机打乱对照。 \
URL：#link("https://doc.cgal.org/latest/Bounding_volumes/index.html")[官方用户手册]。

#strong[#link("https://doc.cgal.org/latest/Bounding_volumes/classCGAL_1_1Min__circle__2.html")[Q3-4]
CGAL Project.] `CGAL::Min_circle_2<Traits>` 类文档。定位：Detailed
Description 的 support set 定义，以及 "Validity Check" 三个条件。 \
URL：#link("https://doc.cgal.org/latest/Bounding_volumes/classCGAL_1_1Min__circle__2.html")[官方类文档]。

#strong[#link("https://doi.org/10.1007/BFB0038202")[Q3-5] Emo Welzl.]
"Smallest enclosing disks (balls and ellipsoids)," #emph[New Results and
New Trends in Computer Science], LNCS 555, 1991,
pp. 359–370。定位：摘要中的随机算法与期望线性结果；此处只用作算法原始出处，不把该复杂度直接移植到固定打乱的
Python 实现。 \
URL：#link("https://doi.org/10.1007/BFB0038202")[出版社 DOI 页面]；#link("https://people.inf.ethz.ch/emo/PublFiles/SmallEnclDisk_LNCS555_91.pdf")[作者存档 PDF]。

#strong[#link("https://www.nayuki.io/res/smallest-enclosing-circle/smallestenclosingcircle.py")[Q3-6]
Project Nayuki.] "Smallest enclosing circle" 作者公开 Python
实现。定位：`make_circle`、`_make_circle_one_point`、`_make_circle_two_points`；尤其两边界点时按左右外接圆极值选择的实现。
\
URL：#link("https://www.nayuki.io/res/smallest-enclosing-circle/smallestenclosingcircle.py")[作者发布的源程序]。该来源用于算法结构对照，不据此认定当前上传代码的作者或来源归属。

#strong[#link("https://ocw.mit.edu/courses/6-01sc-introduction-to-electrical-engineering-and-computer-science-i-spring-2011/6befa2f7542ca110af48020a8c8cf8ad_MIT6_01SCS11_lec02_handout.pdf")[Q3-7]
MIT OpenCourseWare, 6.01SC.] "Lecture 2: Primitives, Combination,
Abstraction, and Patterns," 2011-02-08。定位：handout 第 5–6
页，"Example: Turnstile""Turn Table""Turnstile Class"。 \
URL：#link("https://ocw.mit.edu/courses/6-01sc-introduction-to-electrical-engineering-and-computer-science-i-spring-2011/6befa2f7542ca110af48020a8c8cf8ad_MIT6_01SCS11_lec02_handout.pdf")[MIT 讲义 PDF]。

#strong[#link("https://math.mit.edu/~goemans/18453S17/TSP-CookCPS.pdf")[Q3-8]
William J. Cook, William H. Cunningham, William R. Pulleyblank,
Alexander Schrijver.] #emph[Combinatorial Optimization]，第 7 章 §7.2
"Heuristics for the TSP"，印刷页 243–245，Insertion Methods、Figures
7.2–7.3。定位：同一 1173
节点实例的最近插入与最远插入结果。旧教材中的时代性最佳纪录不作为当前纪录引用。
\
URL：#link("https://math.mit.edu/~goemans/18453S17/TSP-CookCPS.pdf")[MIT 课程提供的教材节选 PDF]。

#strong[#link("https://web.mit.edu/urban_or_book/www/book/chapter6/6.4.6.html")[Q3-9]
Richard C. Larson, Amedeo R. Odoni.] #emph[Urban Operations
Research]，§6.4.6 "Solving TSP1"，Example 9 "Refuse-Collection
Tour"，Figures 6.21–6.25。定位：258、143、401、371、331 的公开数值链。 \
URL：#link("https://web.mit.edu/urban_or_book/www/book/chapter6/6.4.6.html")[MIT 在线教材 §6.4.6]。

#strong[#link("https://research.tue.nl/en/publications/algorithms-for-the-on-line-travelling-salesman/")[Q3-10]
Giorgio Ausiello, Esteban Feuerstein, Stefano Leonardi, Leen Stougie,
Maurizio Talamo.] #emph[Algorithms for the on-line travelling salesman],
Memorandum COSOR 9909, Eindhoven University of Technology,
1999。定位：大学研究记录的
Abstract，在线请求和是否返起点两种问题定义。原 PDF
下载在本次检索中超时，因此本章只使用已核实的摘要模型定义，不引用未核实的证明或例题细节。
\
URL：#link("https://research.tue.nl/en/publications/algorithms-for-the-on-line-travelling-salesman/")[作者所在大学的研究记录]。

#strong[#link("https://simpy.readthedocs.io/en/latest/simpy_intro/basic_concepts.html")[Q3-11]
SimPy Project.] "Basic Concepts"，小节 "Our First Process"。定位：停车
5、行驶 2 的 `car` 过程以及运行到 15 的事件输出。 \
URL：#link("https://simpy.readthedocs.io/en/latest/simpy_intro/basic_concepts.html")[SimPy 官方入门]。

#strong[#link("https://aws.amazon.com/builders-library/making-retries-safe-with-idempotent-APIs/")[Q3-12]
Malcolm Featonby.] "Making retries safe with idempotent APIs," Amazon
Builders’ Library。定位："Retrying and side effects""Reducing client
complexity""Same client request ID, different intent"。原例是 EC2
单实例创建请求丢响应，不是 Q3 的测量接口。 \
URL：#link("https://aws.amazon.com/builders-library/making-retries-safe-with-idempotent-APIs/")[AWS 作者文章]。

#strong[#link("https://www.rfc-editor.org/rfc/rfc9110.html#section-9.2.2")[Q3-13]
R. Fielding, M. Nottingham, J. Reschke, eds.] #emph[RFC 9110: HTTP
Semantics], June 2022，§9.2.2 "Idempotent Methods"。定位：PUT
请求断连后重试的例子，以及非幂等方法自动重试的语义条件。 \
URL：#link("https://www.rfc-editor.org/rfc/rfc9110.html#section-9.2.2")[RFC Editor 原文 §9.2.2]。

#pagebreak()
= 第四章　Q4：定向盲区、负观测与成对探测
<第四章-q4定向盲区负观测与成对探测>
#blockquote[
学习目标：能够解释为什么“没有信号”通常不能删除位置；独立证明 25
个停靠点的方向覆盖；推导成对探测的距离条件、几何条件与收缩率；从代码追踪一次“双无信号—正观测—认证清除”的完整过程。

阅读顺序：先读第 1—5 节的通用方法与外部原例，再读第 6—12 节的 B
题推导，最后用第 13—16
节核对代码、演练和答辩。全文中的外部例题均标明原出处；另行设计的数字例子均标为“本章算例”。
]

== 1　通用起点：观测是在排除哪些状态
<通用起点观测是在排除哪些状态>
=== 1.1　先写物理状态，再写观测
<先写物理状态再写观测>
设未知状态为 $x$，检测动作是 $a$，环境扰动属于已知集合
$w in W$，观测模型为

$ y eq h lr((x comma a comma w)) dot.basic $

收到读数 $y$ 后，与它相容的状态集合为

$ cal(H) lr((a comma y)) eq brace.l x colon exists w in W comma med h lr((x comma a comma w)) eq y brace.r dot.basic $

如果之前的候选集合是 $X$，安全更新就是

$ X^plus eq X sect cal(H) lr((a comma y)) dot.basic $

这里的量词不能省略。删除一个候选状态，意味着已经证明：#strong[允许的任何扰动都不能让这个状态产生当前读数。]
"这个状态看起来不太像"不足以删除它。

如果为了计算方便使用外包络 $hat(X) supset.eq X$，应保持

$ x_ast.basic in X subset.eq hat(X) comma $

其中 $x_ast.basic$
是真实状态。外包络可以偏大；偏大使定位慢一些，却保留真实状态。向内误裁一次，后面即使得到很小的包围圆，也可能只是对错误位置集合给出证书。

=== 1.2　外部教材原例：符号传感器与空传感器
<外部教材原例符号传感器与空传感器>
LaValle《Planning Algorithms》§11.1.1 的 Example 11.3
定义整数状态的符号传感器 $h lr((x)) eq "sgn" x$；Example 11.6
定义所有状态都返回同一读数的空传感器。前者的负号排除非负整数；后者的固定读数不排除任何状态。参见
\[1\]，纸书第 562—563 页。

这个对照说明：读数的名字不决定它的信息量；信息量由观测模型的逆像决定。某个系统返回
`no_signal`，必须先问“哪些物理原因都能产生这个结果”。

#strong[本章扩展算例。] 已知 $x in lr([minus 10 comma 10])$，传感器返回
$"sgn" lr((x plus e))$，其中 $lr(|e|) lt.eq 2$。返回正号只能推出
$x gt minus 2$，不能推出 $x gt 0$。例如 $x eq minus 1 comma e eq 2$
仍会返回正号。只要存在一个允许的误差解释读数，这个候选就应保留。

=== 1.3　正观测与负观测没有天然的强弱次序
<正观测与负观测没有天然的强弱次序>
正观测往往确认“目标存在，且满足接收条件”；负观测可能对应多个原因。假设目标位置为
$g$，有效半径为 $rho$，有向覆盖区域为 $H$。一次无信号可能表示

$ upright("没有目标") quad or quad parallel q minus g parallel gt rho quad or quad q in.not H dot.basic $

这是一条“或”关系。要把它变成某个确定的几何不等式，必须先排除其他分支。设计测点以排除“距离太远”这个原因，就是主动检测的一种基本做法。

如果模型还允许遮挡、设备掉线、漏检或目标暂时停发，这些也会成为负观测的解释。此时本章后面的半平面结论需要重新检验，不能沿用理想模型的删除规则。

== 2　通用定向覆盖：从扇区到半平面
<通用定向覆盖从扇区到半平面>
=== 2.1　外部论文原例：更多开启的传感器未必覆盖更多目标
<外部论文原例更多开启的传感器未必覆盖更多目标>
Ai 与 Abouzeid 的《Coverage by Directional Sensors》在 Fig. 1
展示同一组四个定向传感器与六个目标：一个配置开启四个传感器仍漏掉两个目标，另一个配置只开启三个却覆盖全部目标。论文
§III-A、§III-B
用位置、半径、视角和朝向定义扇区，并用点积判断目标是否落在扇区内。参见
\[2\]。这里复述原例的逻辑，不复制原图。

设定向设备位于 $g$，单位朝向为 $n$，全开角为 $alpha$，半径为 $rho$。点
$q$ 被覆盖的条件是

$ parallel q minus g parallel lt.eq rho comma #h(2em) n^(sans(T)) lr((q minus g)) gt.eq parallel q minus g parallel cos lr((alpha slash 2)) dot.basic $

当 $alpha eq pi$ 时，$cos lr((alpha slash 2)) eq 0$，角度条件简化为

$ n^(sans(T)) lr((q minus g)) gt.eq 0 dot.basic $

因此 180°
定向覆盖是“圆盘与一个经过源位置的闭半平面之交”。这个模型区分两种方向：$n$
是源的发射方向；$g minus q$ 是检测点指向源的测向方向。它们不能混用。

=== 2.2　未知朝向下，为什么要围住目标
<未知朝向下为什么要围住目标>
给定目标位置 $g$，设附近检测点组成集合

$ S_g eq brace.l s_j colon parallel s_j minus g parallel lt.eq R_min brace.r dot.basic $

希望对每一个单位朝向 $n$，至少有一个检测点满足
$n^(sans(T)) lr((s_j minus g)) gt.eq 0$。一个非常有用的充分必要条件是

$ g in "conv" lr((S_g)) dot.basic $

#strong[充分性。] 若
$g eq sum_j lambda_j s_j$，$lambda_j gt.eq 0$，$sum_j lambda_j eq 1$，则

$ sum_j lambda_j n^(sans(T)) lr((s_j minus g)) eq 0 dot.basic $

所有参与的点积不可能同时严格为负，故至少一个检测点位于覆盖闭半平面内。

#strong[必要性。] 若 $g$ 不在有限点集 $S_g$ 的凸包中，取凸包内距 $g$
最近的点 $z$，令
$n eq lr((g minus z)) slash parallel g minus z parallel$。最近点的性质给出
$lr((g minus z))^(sans(T)) lr((s minus z)) lt.eq 0$，从而对所有
$s in S_g$，有

$ n^(sans(T)) lr((s minus g)) lt.eq minus parallel g minus z parallel lt 0 dot.basic $

朝向 $n$ 的源会避开所有这些检测点。若 $S_g$ 为空，当然也不能保证发现。

这条判据比“每个位置都有一个不远的站点”更强。全向覆盖只要求有近点；180°
未知方向覆盖要求近点在几何上包围该位置。这里利用了边界包含在有效覆盖角度内；若边界不接收，边界退化情形要单独处理。

=== 2.3　把连续覆盖证明转换成三角形检查
<把连续覆盖证明转换成三角形检查>
若某区域被若干三角形铺满，每个三角形的三个顶点都是检测点，且最长边不超过
$R_min$，那么区域中的任意点都满足式 (4.1)。

证明分两步。设 $g eq sum_i lambda_i v_i$ 在一个三角形内。对任意顶点
$v_j$，

$ parallel g minus v_j parallel eq ∥sum_i lambda_i lr((v_i minus v_j))∥ lt.eq sum_i lambda_i parallel v_i minus v_j parallel lt.eq R_min dot.basic $

所以三个顶点都足够近；同时 $g$
本来就在这三个点的凸包中。这样的证明覆盖三角形内部、边和顶点，不依赖网格采样密度。

== 3　通用安全裁剪：外包络与“删不掉”
<通用安全裁剪外包络与删不掉>
=== 3.1　外部原例：同一个函数的两种区间计算
<外部原例同一个函数的两种区间计算>
Jaulin 与 Walter 的《Set inversion via interval analysis for nonlinear
bounded-error estimation》§3.3、Example 4 讨论
$f lr((x)) eq x^2 minus x$，$x in lr([minus 1 comma 3])$。直接区间计算得到
$lr([minus 3 comma 10])$，改写为 $x lr((x minus 1))$ 得到
$lr([minus 6 comma 6])$，两者相交为 $lr([minus 3 comma 6])$，真实值域为
$lr([minus 1 slash 4 comma 6])$。参见 \[3\]，第 1057 页。

下面重新算一遍关键步骤：

$ lr([minus 1 comma 3])^2 minus lr([minus 1 comma 3]) eq lr([0 comma 9]) minus lr([minus 1 comma 3]) eq lr([minus 3 comma 10]) dot.basic $

而

$ lr([minus 1 comma 3]) thin lr((lr([minus 1 comma 3]) minus 1)) eq lr([minus 1 comma 3]) lr([minus 2 comma 2]) eq lr([minus 6 comma 6]) dot.basic $

准确值域可由 $f lr((x)) eq lr((x minus 1 slash 2))^2 minus 1 slash 4$
看出。区间结果偏宽源于同一变量的相关性在分别运算时被忽略。偏宽仍可安全包含真值。

=== 3.2　从原例提炼安全删除规则
<从原例提炼安全删除规则>
假设实测结果规定 $f lr((x)) in Y$，候选盒子 $B$ 有可信的函数外包络
$F lr((B)) supset.eq f lr((B))$。

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [检查结果], [可以作出的结论], [后续处理],
  [$F lr((B)) sect Y eq diameter$],
  [盒中没有相容状态],
  [删除整个盒子],
  [$F lr((B)) subset.eq Y$],
  [盒中所有状态都相容],
  [接受整个盒子],
  [两者部分相交],
  [目前不能判断全部状态],
  [继续细分或保留为外包络],
)
]

SIVIA 利用这样的判别与细分构造内外集合。Q4 的实现没有运行
SIVIA；它选择容易表示成凸多边形的外包络，并用半平面裁剪。共同的原则是：删除必须由包含关系或不相容证明支持。

#strong[本章算例。] 候选位置有两个小区域
$A comma B$。当前位置无信号；$A$ 距离近但可能背向发射，$B$
距离远。若只按距离解释无信号而删除
$A$，便忽略了方向这个隐变量。真正应问的是：对
$g in A$，是否还有一个允许的朝向能解释历史全部观测？只要有，就不能删。

=== 3.3　保留隐变量，还是设计观测消去隐变量
<保留隐变量还是设计观测消去隐变量>
有两种常用路线：

+ 维护联合集合
  $X subset.eq brace.l lr((位 置 comma 半 径 comma 朝 向 comma 类 型)) brace.r$，每次按完整观测关系更新，再向位置平面投影。这能利用更多证据，但集合通常非凸，维数也更高。
+ 维护位置的保守外包络，设计少量特殊探测动作，使几次观测合起来可以推出与未知朝向无关的安全不等式。

成对探测属于第二条路线。它的价值在于通过动作的几何结构，获得可以直接执行的低维裁剪规则。

== 4　通用主动感知：一次检测的价值取决于下一步能做什么
<通用主动感知一次检测的价值取决于下一步能做什么>
=== 4.1　外部论文原例：两扇门后的老虎
<外部论文原例两扇门后的老虎>
Kaelbling、Littman、Cassandra 的论文《Planning and acting in partially
observable stochastic domains》§5.1 给出 Tiger problem：打开安全门奖励
10，打开老虎所在门损失 100，听一次代价 1；听辨正确率为 0.85。参见
\[4\]，第 119—120 页。

对均匀先验，听到“老虎在左边”后的左侧概率为 0.85；连续两次相同听辨后为

$ p eq frac(0.85^2, 0.85^2 plus 0.15^2) approx 0.9698 dot.basic $

只看立即收益，打开右门的期望为
$10 p minus 100 lr((1 minus p)) eq 110 p minus 100$。第一次听后是
$minus 6.5$，第二次同向听后约为
$6.68$。这项重算展示检测如何改变行动价值；完整最优策略还依赖剩余时域、折扣和开门后的重置，不能仅由这两个数决定。

=== 4.2　概率置信与确定包含是两种任务约定
<概率置信与确定包含是两种任务约定>
Tiger problem
明确给出概率观测模型，可以用贝叶斯更新。若只有误差上界、没有可信误差分布，应使用集合来表达“所有仍可能的状态”。两种信息状态分别是：

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [表示], [维护对象], [典型停止标准],
  [概率方法],
  [后验分布 $b lr((x))$],
  [成功概率达到阈值，或期望收益允许行动],
  [集合成员方法],
  [相容集合或它的外包络 $P$],
  [对所有 $g in P$，动作都成功],
)
]

LaValle 在 §12.1.1 将信息状态作为新的规划状态，在式 (12.1)
用“整个相容集合都在目标集内”定义保证成功的目标条件。\[1\] Q4
的清除证书正好可以采用这种形式。

特别要注意，题设同地点测向误差固定。不能把同一点测十次当成十个独立样本，再套用标准误差按
$1 slash sqrt(10)$
缩小的结论。改变空间位置能够改变观测几何；是否统计独立仍需要额外的模型支持。

=== 4.3　一个可以指导设计的通用目标
<一个可以指导设计的通用目标>
设 $P$ 为位置外包络，动作 $a$ 的代价是 $c lr((a))$，结果集合为
$cal(Y) lr((P comma a))$，结果 $y$ 后的更新为
$T lr((P comma a comma y))$。可以设计

$ a^ast.basic in arg min_a lr({c lr((a)) plus beta max_(y in cal(Y) lr((P comma a))) R #scale(x: 120%, y: 120%)[paren.l] T lr((P comma a comma y)) #scale(x: 120%, y: 120%)[paren.r]}) comma $

其中 $R$ 是不确定集合的最小包围圆半径，$beta$
负责把米转换为时间或价值单位。也可以把“最终一定能清除”作为硬约束，再最小化最坏累计代价。

式 (4.2)
是通用的设计框架。本章代码没有求解这个连续、多步的极小极大问题。它选取一个可证明收缩的成对动作模板，再用局部路径评分减少额外移动。这样能分别解释可靠性来自哪里、效率来自哪里。

== 5　通用清除证书与在线路径选择
<通用清除证书与在线路径选择>
=== 5.1　最小包围圆解决的是最坏距离
<最小包围圆解决的是最坏距离>
给定凸多边形 $P$，最小包围圆问题是

$ min_c R lr((c)) comma #h(2em) R lr((c)) eq max_(g in P) parallel g minus c parallel dot.basic $

只检查顶点即可：任意内部点都是顶点的凸组合，距离的凸性保证它到 $c$
的距离不超过顶点距离的最大值。

Welzl 的 1991 年论文《Smallest enclosing disks (balls and
ellipsoids)》研究有限点集的最小包围圆，给出期望线性时间的随机算法；二维圆的边界由少量支撑点决定。\[5\]
本章程序采用随机打乱后的增量构造思想，并在返回前重新计算全部顶点到圆心的最大距离。不能仅凭“算法属于同一家族”就将原论文的所有复杂度结论照搬到这份实现。

#strong[本章算例。] 边长 36 的等边三角形，直径是
36，但其最小包围圆半径为

$ 36 slash sqrt(3) approx 20.785 dot.basic $

因此“定位区域直径小于 40”还不能保证找到一个距所有候选点都不超过 20
的清除点。应检查包围圆半径，或直接检查清除点到所有候选点的最大距离。

=== 5.2　外部算法：插入一站的路程增量
<外部算法插入一站的路程增量>
Rosenkrantz、Stearns、Lewis 的经典论文在 §3、式 (3.1) 定义：把点 $k$
插入路线边 $lr((x comma y))$ 的增量是

$ Delta L eq d lr((x comma k)) plus d lr((k comma y)) minus d lr((x comma y)) dot.basic $

论文 §4 对特定静态度量旅行商插入算法给出近似界。\[6\]
这些前提包括已知节点、完整路线构造和相应插入规则。

#strong[本章算例。] 当前点 $p eq lr((0 comma 0))$，下一固定站
$s eq lr((1000 comma 0))$，候选任务 A 的中心
$lr((500 comma 100))$、不确定半径 30；任务 B 的中心
$lr((100 comma 500))$、不确定半径 10。二者距当前位置都约为 509.902，但

$ Delta L_A approx 19.804 comma #h(2em) Delta L_B approx 539.465 dot.basic $

若再加不确定半径作定位难度惩罚，A 的分数约 49.804，B 为
549.465。这个例子说明“当前最近”与“插入当前路段最顺路”不同。

=== 5.3　为什么只能把 Q4 的调度称为启发式
<为什么只能把-q4-的调度称为启发式>
Q4
的目标要靠检测才逐渐出现，目标位置也只是集合；执行定位会改变当前位置，还可能顺带获得其他频道的信息。这与静态旅行商问题的固定节点距离表不同。

程序只评估当前点到下一覆盖站之间的插入，并加上一个半径项；600 m
是执行阈值。它没有搜索所有任务次序，也没有对未来全部观测结果做动态规划。因此可以称为在线的顺路服务启发式，不能引用静态插入算法的两倍界来声称本程序也有相同比例保证。

== 6　回到 B 题：从题设逐项建立模型
<回到-b-题从题设逐项建立模型>
本章据题目 `20-B-.pdf` 第 1—4 页、附录 1—4，以及仓库 `source/README.md`
和当前 `source/Q4/` 源码写成。题设事实与程序选择分列如下。

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [项目], [题设事实], [当前 Q4 实现],
  [源位置],
  [半径 1800 m 的闭圆域],
  [用外切正 64 边形初始化位置外包络],
  [源数量、频道],
  [10—16 个；各占不同频道；频道 1—20],
  [维护 20 个独立 `Track`],
  [定向覆盖],
  [朝向两侧各 90°，包括边界],
  [闭半平面接收模型],
  [接收半径],
  [每源固定，在 1000—1500 m],
  [1000 用于保证探测距离，1500 用于正观测初始上界],
  [测向误差],
  [全域不超过 ±1°；同地点误差固定],
  [计算角楔半角 1.0051°],
  [检测],
  [停下检测；每次 5 s；换台 1 s],
  [检测与换台由模拟器推进虚拟时间],
  [移动],
  [直线，5 m/s],
  [按每次动作目标点计算移动],
  [`near`],
  [距源不超过 5 m 且位于辐射区，无法测向],
  [立即在当前位置清除],
  [清除],
  [距源不超过 20 m 即成功，与辐射角无关],
  [MEC 半径不超过 19.8 m 后选择认证清除点],
)
]

物理模型中，对未清除源 $g_i$，若为定向源则有未知单位向量 $n_i$。检测点
$q$ 的接收条件为

$ parallel q minus g_i parallel lt.eq rho_i comma quad upright("且") quad n_i^(sans(T)) lr((q minus g_i)) gt.eq 0 dot.basic $

全向源省略第二项。接收且距离大于 5 m 时，示向度满足

$ lr(|"wrap" #scale(x: 120%, y: 120%)[paren.l] theta_i lr((q)) minus arg lr((g_i minus q)) #scale(x: 120%, y: 120%)[paren.r]|) lt.eq 1^compose dot.basic $

程序的额外 0.005° 用于两位小数输出量化保护，0.0001°
是数值裕量。这里应称为计算外包络保护；题设误差本身仍为
±1°。本地模拟器的两位小数舍入可在 `q4_local_simulator.py:30` 直接核对。

=== 6.1　全状态表达说明普通无信号为何不能裁剪
<全状态表达说明普通无信号为何不能裁剪>
对已知存在的定向源，完整候选状态可以写成

$ X subset.eq brace.l lr((g comma rho comma n)) colon g in Omega comma rho in lr([1000 comma 1500]) comma parallel n parallel eq 1 brace.r dot.basic $

普通负观测对应

$ X^plus eq brace.l lr((g comma rho comma n)) in X colon parallel q minus g parallel gt rho med or med n^(sans(T)) lr((q minus g)) lt 0 brace.r dot.basic $

如果还不知道该频道是否有源，必须加上“不存在”的分支。只维护位置投影时，式
(4.5) 不能简化成 $parallel q minus g parallel gt 1000$。

#strong[误删反例 A。] 源在 $g eq lr((100 comma 0))$，接收半径
1000，朝向正东。机器狗在 $q eq lr((0 comma 0))$，只距源 100
m，却在背向半平面，因此无信号。如果无信号就删除以 $q$ 为心的 1000 m
圆盘，真实源立即被删除。

当前 `_observe()` 对 `no_signal`
不更新多边形；它只更新当前位置、频道、时间和该频道的最近测点。只有第 9
节证明成立的双负观测才触发裁剪。

== 7　25 站如何保证发现：一个连续几何证明
<站如何保证发现一个连续几何证明>
=== 7.1　先核对实际站点与访问顺序
<先核对实际站点与访问顺序>
`coverage_route()` 位于本地与正式求解器共同的第 85—89 行。站点是

$ O eq lr((0 comma 0)) comma $

$ I_k eq 995 #scale(x: 120%, y: 120%)[paren.l] cos lr((k pi slash 4)) comma sin lr((k pi slash 4)) #scale(x: 120%, y: 120%)[paren.r] comma quad k eq 0 comma dots.h comma 7 comma $

$ E_j eq 1838 #scale(x: 120%, y: 120%)[paren.l] cos lr((j pi slash 8)) comma sin lr((j pi slash 8)) #scale(x: 120%, y: 120%)[paren.r] comma quad j eq 0 comma dots.h comma 15 dot.basic $

共 $1 plus 8 plus 16 eq 25$ 个站。访问次序为中心、$I_0$ 到
$I_7$、$E_14 comma E_15 comma E_0 comma dots.h comma E_13$。几何覆盖取决于站点集合；访问顺序影响移动时间。外圈半径超过
1800 m
并不违反原题：目标被限制在圆域内，机器狗动作坐标只受接口给定的大范围数值限制。

=== 7.2　外圈先包住目标圆域
<外圈先包住目标圆域>
外圈正十六边形的内切圆半径为

$ r_(upright(i n)) eq 1838 cos lr((pi slash 16)) approx 1802.683345 gt 1800 dot.basic $

所以整个目标圆域包含在外圈正十六边形内。仅凭“外圈顶点半径 1838 大于
1800”还不够；需要检查边中点距离，也就是内切半径。

=== 7.3　把外圈多边形分成 32 个小三角形
<把外圈多边形分成-32-个小三角形>
以下下标分别按 8 或 16 取模。内圈八边形由 8 个三角形

$ triangle.stroked.t lr((O comma I_k comma I_(k plus 1))) $

铺满。每个 45° 环带扇区对应五边形

$ I_k comma E_(2 k) comma E_(2 k plus 1) comma E_(2 k plus 2) comma I_(k plus 1) dot.basic $

把它沿对角线分成

$  & triangle.stroked.t lr((I_k comma E_(2 k) comma E_(2 k plus 1))) comma\
 & triangle.stroked.t lr((I_k comma E_(2 k plus 1) comma I_(k plus 1))) comma\
 & triangle.stroked.t lr((I_(k plus 1) comma E_(2 k plus 1) comma E_(2 k plus 2))) dot.basic $

八个扇区给出 24 个三角形，加上中心的 8 个，总计 32
个。它们的内部互不重叠，拼成整个外圈正十六边形。

所有可能的边长只有下列几类：

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,right,).at(col),
  inset: 6pt,
  [边的类型], [长度公式], [数值/m],
  [中心到内圈],
  [$995$],
  [995.000000],
  [相邻内圈点],
  [$2 dot.op 995 sin lr((pi slash 8))$],
  [761.540030],
  [同射线内外圈点],
  [$1838 minus 995$],
  [843.000000],
  [相邻外圈点],
  [$2 dot.op 1838 sin lr((pi slash 16))$],
  [717.152024],
  [夹角 22.5° 的内外圈点],
  [$sqrt(995^2 plus 1838^2 minus 2 dot.op 995 dot.op 1838 cos lr((pi slash 8)))$],
  [994.519353],
)
]

最长边为 995 m。因此任意目标 $g$ 所在三角形的三个检测顶点，距离 $g$
都不超过 995 m，小于每个源的最小有效接收半径 1000 m。

=== 7.4　距离覆盖加凸包，得到方向覆盖
<距离覆盖加凸包得到方向覆盖>
任取定向朝向 $n$。由第 2.2 节的凸组合证明，上述三角形至少有一个顶点 $v$
满足

$ n^(sans(T)) lr((v minus g)) gt.eq 0 dot.basic $

这个顶点同时满足距离要求，故在那里会得到 `direction` 或
`near`。全向源只需要距离条件，也被覆盖。

#strong[结论。] 在题设半平面辐射、没有额外漏检且源静止的模型下，扫描 25
站处每个尚未知频道，能发现所有未清除源。这个结论是对连续位置和连续朝向成立的证明；不需要声称“抽样足够密所以不会漏”。

=== 7.5　为什么可以把剩余频道标成 `ABSENT`
<为什么可以把剩余频道标成-absent>
有两个独立的充分条件：

+ 已知存在的频道数达到 16。题设源数上限为
  16，频道又互不相同，所以其余频道不存在源。
+ 所有 25 个站已完成对当时未知频道的扫描。若某频道仍为
  `UNKNOWN`，假设它有源会与覆盖证明矛盾。

发现 10 个源不能据此停止，因为 10 只是数量下限。`FOUND` 与 `CLEARED`
都计入已知存在数量；已清除频道不能从计数中丢掉。

25 站完整骨架的相邻直线段总长约为 17926.061
m，不含中途定位与清除的绕行。站点数、半径和顺序没有最少站数或最短路线的证明。几何可行与时间最优是两个需要分别回答的问题。

== 8　正观测怎样维护安全位置集合
<正观测怎样维护安全位置集合>
=== 8.1　以最近一次正观测为局部坐标系
<以最近一次正观测为局部坐标系>
设正锚点为 $a$，读数为 $theta$，单位轴向和侧向分别为

$ u eq lr((cos theta comma sin theta)) comma #h(2em) v eq lr((minus sin theta comma cos theta)) dot.basic $

把候选源写成

$ g eq a plus x u plus y v dot.basic $

用计算半角 $delta eq 1.0051^compose$，角楔约束为

$ x gt.eq 0 comma #h(2em) lr(|y|) lt.eq x tan delta dot.basic $

正观测说明真实距离不超过 1500 m。程序将已知距离上界记为
$U$，并增加保守的轴向约束

$ x lt.eq U dot.basic $

注意式 (4.7) 是半平面，允许少量欧氏距离大于 $U$
的角楔角点。代码没有用圆弧精确裁剪距离圆；这是一种便于计算的外包络。

=== 8.2　角楔怎样成为两个半平面
<角楔怎样成为两个半平面>
令

$ ell eq lr((cos lr((theta minus delta)) comma sin lr((theta minus delta)))) comma quad h eq lr((cos lr((theta plus delta)) comma sin lr((theta plus delta)))) dot.basic $

则楔内点满足

$ lr((ell_y comma minus ell_x))^(sans(T)) lr((g minus a)) lt.eq 0 comma $

$ lr((minus h_y comma h_x))^(sans(T)) lr((g minus a)) lt.eq 0 dot.basic $

因为角宽小于
180°，这两个半平面的交正好给出向前角楔。`direction_update()` 第 44—46
行依次裁剪这两个半平面和轴向距离半平面。

`_positive()` 的次序是：

+ 从旧多边形与 1500 m 确定
  $U_0 eq min lr((1500 comma max_(z in P) parallel z minus a parallel plus upright(E P S)))$。
+ 与新角楔及轴向上界相交，得到 $P^plus$。
+ 把当前位置记为新正锚点，保存新示向度。
+ 以
  $min lr((U_0 comma max_(z in P^plus) parallel z minus a parallel plus upright(E P S)))$
  更新 `U`。
+ 重算 `center`、`radius`。

这里存储的是“保证真实源距离不超过它”的上界；`U`
不是接收半径的估计值，也不等于 MEC 半径。

=== 8.3　正锚点还提供了一个没有显式存储的事实
<正锚点还提供了一个没有显式存储的事实>
对定向源，其未知朝向 $n$ 一定满足

$ n^(sans(T)) lr((a minus g)) gt.eq 0 dot.basic $

这表示锚点确实处于辐射闭半平面。程序没有保存一个朝向区间，但成对探测证明会使用式
(4.8)。最近测点 `last` 可以是无信号点；它不能替代 `anchor`。

== 9　成对探测：把两个负观测变成安全半平面
<成对探测把两个负观测变成安全半平面>
=== 9.1　两个点是怎样选择的
<两个点是怎样选择的>
在上述局部坐标中，取

$ q_plus eq a plus lambda U u plus eta U v comma #h(2em) q_minus eq a plus lambda U u minus eta U v comma $

代码参数为

$ lambda eq 0.5 comma #h(2em) eta eq 0.05 dot.basic $

程序先去离当前点更近的那个；这个换序只改变移动量，不改变两点的几何证据。

成对动作有三个可能的终止分支：

```mermaid
flowchart TD
    A["从正锚点构造成对测点"] --> B["访问较近测点"]
    B -->|direction| C["更新角楔与正锚点"]
    B -->|near| D["立即清除"]
    B -->|no_signal| E["访问另一测点"]
    E -->|direction| C
    E -->|near| D
    E -->|no_signal| F["认证半平面裁剪"]
```

它不是“无论如何都测两次”。首点取得正观测后，本轮立即结束，下一轮按新的锚点与尺度重建测点。

=== 9.2　条件一：两个探测点都必须处于保证距离内
<条件一两个探测点都必须处于保证距离内>
先用略宽但易算的三角形外包络

$ T lr((U)) eq brace.l lr((x comma y)) colon 0 lt.eq x lt.eq U comma med lr(|y|) lt.eq x tan delta brace.r dot.basic $

对 $lambda eq 1 slash 2$，每个 $g in T lr((U))$ 到任一探测点的距离不超过

$ kappa U comma quad kappa eq sqrt(1 / 4 plus lr((eta plus tan delta))^2) dot.basic $

可以直接用
$lr(|x minus U slash 2|) lt.eq U slash 2$、$lr(|y minus.plus eta U|) lt.eq U lr((tan delta plus eta))$
得到这个上界。也可利用距离凸性检查三角形三个顶点。

本程序中

$ tan delta approx 0.017544104 comma #h(2em) kappa approx 0.504541580 dot.basic $

又因 $U lt.eq 1500$，

$ parallel q_plus.minus minus g parallel lt.eq 0.504541580 dot.op 1500 approx 756.812370 lt 1000 dot.basic $

因此两个点无论遇到哪个真实候选源，都不会因接收距离不够而无信号。5 m
近距离也不会变成无信号：若接收角度满足，接口应返回 `near`。

对一般 $0 lt lambda lt 1$，一个便于核验的充分条件是

$ U sqrt(max lr((lambda comma 1 minus lambda))^2 plus lr((eta plus tan delta))^2) lt.eq R_min dot.basic $

条件可进一步收紧，但当前参数已有很大的距离余量。

=== 9.3　条件二：探测线段必须横跨整个锚点角楔
<条件二探测线段必须横跨整个锚点角楔>
线段 $lr([q_minus comma q_plus])$ 位于 $x eq lambda U$，纵向范围为
$lr([minus eta U comma eta U])$。它截住全部角楔射线所需的条件是

$ eta gt.eq lambda tan delta dot.basic $

本程序右侧约为 $0.008772052$，而 $eta eq 0.05$，因此成立。$eta$
太小，两个点可能都落在角楔某条真实射线同一侧；$eta$
太大，则探测距离与横向移动代价会增加。

=== 9.4　核心定理及完整证明
<核心定理及完整证明>
#strong[定理。] 假定：源存在且尚未清除；$a$
是对它取得正观测的锚点；真实位置满足角楔与上界；两个探测点满足距离条件；横跨条件
(4.13) 成立；没有模型外漏检。若 $q_plus$、$q_minus$ 都返回
`no_signal`，则

$ u^(sans(T)) lr((g minus a)) lt lambda U dot.basic $

#strong[证明第一步：识别负观测的原因。]
两点都在有效距离内，全向源不可能产生无信号。故这个分支只能由定向源产生，并且

$ n^(sans(T)) lr((q_plus minus g)) lt 0 comma #h(2em) n^(sans(T)) lr((q_minus minus g)) lt 0 dot.basic $

严格小于来自题设：辐射边界属于可接收范围。

#strong[证明第二步：反设源在探测线或它前方。] 设
$g eq a plus x u plus y v$，且 $x gt.eq lambda U$。射线段
$lr([a comma g])$ 与探测直线的交点为

$ r eq a plus lambda U u plus frac(lambda U, x) y v dot.basic $

由角楔条件，

$ lr(|frac(lambda U, x) y|) lt.eq lambda U tan delta lt.eq eta U dot.basic $

因此 $r in lr([q_minus comma q_plus])$，可写成两个负观测点的凸组合。式
(4.15) 于是推出

$ n^(sans(T)) lr((r minus g)) lt 0 dot.basic $

#strong[证明第三步：利用正锚点制造矛盾。] 另一方面

$ r minus g eq lr((1 minus frac(lambda U, x))) lr((a minus g)) dot.basic $

括号非负，而正锚点给出式 (4.8)，所以

$ n^(sans(T)) lr((r minus g)) gt.eq 0 comma $

与式 (4.16) 矛盾。故必须有 $x lt lambda U$。证毕。

这是“两个负观测”发挥作用的具体原因：它们的连线横跨可能的源射线；正锚点又位于已知的接收一侧。证明没有估计定向方向的数值。

=== 9.5　裁剪与尺度更新
<裁剪与尺度更新>
程序保守地保留闭半平面

$ P^plus eq P sect brace.l g colon u^(sans(T)) g lt.eq u^(sans(T)) a plus lambda U brace.r dot.basic $

同时由角楔内 $parallel g minus a parallel lt.eq x slash cos delta$，得

$ U^plus lt.eq frac(lambda, cos delta) U approx 0.500076943 U dot.basic $

`_dual_negative()` 第 156 行做式 (4.17)，第 158 行取式 (4.18)
与当前多边形最大距离的较小值，然后重算
MEC。双负观测不产生新正锚点，旧锚点仍保留。

=== 9.6　三个误用反例
<三个误用反例>
#strong[反例 B：一个负观测不够。] 取
$a eq lr((0 comma 0))$、$g eq lr((800 comma 0))$、$U eq 1500$、半径
1000、$n eq lr((minus 0.01 comma minus sqrt(1 minus 0.01^2)))$。锚点的点积为
8，大于零。$q_plus eq lr((750 comma 75))$ 的点积约为
$minus 74.50$，所以无信号；$q_minus eq lr((750 comma minus 75))$
则有信号。若首点无信号后立即裁到 $x lt.eq 750$，就删掉了真实源
$x eq 800$。

#strong[反例 C：两个点不在保证距离内。] 取
$g eq lr((800 comma 0))$、$a eq lr((0 comma 0))$、半径
1000、朝向正西。选
$q_plus.minus eq lr((600 comma plus.minus 1200))$，两点都距源约 1216.55
m，因超距而无信号。若据此裁到
$x lt.eq 600$，同样误删。双负观测的名称本身不提供安全性。

#strong[反例 D：两个点没有跨住角楔。] 取
$g eq lr((800 comma 10))$、$a eq lr((0 comma 0))$、$n eq lr((minus 0.02 comma sqrt(1 minus 0.02^2)))$、半径
1000，读数取 0°。真实角度约 0.716°，符合误差界。选
$q_plus.minus eq lr((750 comma plus.minus 5))$。锚点有信号，两点均在
1000 m 内，却都在背向半平面。真实源仍位于
$x eq 800 gt 750$。原因是线段在 $x eq 750$ 处只覆盖
$y in lr([minus 5 comma 5])$，而真实射线在那里有 $y eq 9.375$。

以上三个反例分别对应：必须成对、必须认证距离、必须横跨角楔。

== 10　为什么成对探测会结束
<为什么成对探测会结束>
=== 10.1　正分支与双负分支都压缩尺度
<正分支与双负分支都压缩尺度>
为看清算法而先采用精确实数计算，忽略极小的数值容差。维护不变量

$ P subset.eq a plus T lr((U)) comma #h(2em) g_ast.basic in P dot.basic $

若本轮取得正观测，新的位置集合是旧集合的子集。由式
(4.10)，它到新锚点的最大距离不超过 $kappa U$；`_positive()`
利用这个最大距离更新上界，故

$ U^plus lt.eq kappa U approx 0.504541580 U dot.basic $

若本轮双负，则式 (4.18) 给出约 0.500077 倍。若返回
`near`，直接完成清除。于是未清除情况下，每轮都具有约 0.505
以下的统一尺度收缩。

=== 10.2　从距离尺度转成 MEC 半径上界
<从距离尺度转成-mec-半径上界>
三角形 $T lr((U))$ 的顶点为

$ lr((0 comma 0)) comma quad lr((U comma U tan delta)) comma quad lr((U comma minus U tan delta)) dot.basic $

取圆心 $lr((c comma 0))$，令它到顶点的距离相等，有

$ c^2 eq lr((U minus c))^2 plus U^2 tan^2 delta comma $

因此

$ c eq frac(U, 2 cos^2 delta) dot.basic $

以它为圆心、半径 $c$ 的圆覆盖三角形，故

$ R lr((P)) lt.eq frac(U, 2 cos^2 delta) dot.basic $

这是一个足够用的上界；实际旧角楔交集往往远小于整三角形。

以 $U_0 eq 1500$、每轮都用较慢的收缩率 $kappa$ 计算：

#align(center)[#table(
  columns: 3,
  align: (col, row) => (right,right,right,).at(col),
  inset: 6pt,
  [完成轮数 $k$], [$1500 kappa^k$/m], [由式 (4.19) 给出的半径上界/m],
  [0],
  [1500.000],
  [750.231],
  [1],
  [756.812],
  [378.523],
  [2],
  [381.843],
  [190.980],
  [3],
  [192.656],
  [96.358],
  [4],
  [97.203],
  [48.616],
  [5],
  [49.043],
  [24.529],
  [6],
  [24.744],
  [12.376],
)
]

因此在这些不变量与精确计算条件下，6 轮已足以降到 19.8 m 以下。代码的 9
轮上限是异常保护：达到上限会抛出错误，不能把它理解为到第 9
轮会强行清除。

数值实现的 `EPS` 外扩、`mec()` 的半径重算和 0.2 m
清除裕量提升了计算稳健性，但并非带定向舍入的形式化浮点证明。上表是理想几何收缩推导，异常上限是运行保护，二者应分开陈述。

== 11　认证清除与 25 m 机会复用
<认证清除与-25-m-机会复用>
=== 11.1　19.8 m 证书到底证明什么
<m-证书到底证明什么>
已知 $P subset.eq B lr((c comma R))$，且 $R lt.eq 19.8$。任取

$ z in B lr((c comma 19.8 minus R)) comma $

对真实源 $g_ast.basic in P$，有

$ parallel z minus g_ast.basic parallel lt.eq parallel z minus c parallel plus parallel c minus g_ast.basic parallel lt.eq 19.8 minus R plus R eq 19.8 lt 20 dot.basic $

因此不必总走到 MEC 圆心。设当前位置为 $p$、$s eq 19.8 minus R$：

$ z eq cases(delim: "{", p comma & parallel p minus c parallel lt.eq s comma, c plus frac(s, parallel p minus c parallel) lr((p minus c)) comma & parallel p minus c parallel gt s dot.basic) $

`nearest_clear()`
正是把当前位置投影到这个安全圆盘，获得圆盘内最近的清除点。

这里的“最近”有明确范围：最近于充分安全圆盘
$B lr((c comma 19.8 minus R))$。完整可清除集合是

$ sect.big_(g in P) B lr((g comma 20)) comma $

它通常更大，程序没有求在这个完整交集中的最近点。清除操作与无线电朝向无关，所以无需再证明
$z$ 位于辐射半平面。

=== 11.2　`near` 是另一条独立的清除证书
<near-是另一条独立的清除证书>
`near` 表示接收区内距源不超过 5 m，因此当前点本身就在 20 m
清除半径内。这个分支不需要等待多边形收缩，也不需要再求第二个示向度。注意背向源即使距离
3 m，也可能是 `no_signal`；不能把近距离反过来当作必得 `near` 的保证。

=== 11.3　机会复用的全部条件
<机会复用的全部条件>
机器人因其他任务停下来时，`_reuse(limit=2)`
尝试顺便检测已发现频道。其条件逐项为：

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [代码条件], [含义], [不代表什么],
  [`status == 'FOUND'`],
  [源已发现、尚未清除],
  [不能替代未知频道覆盖扫描],
  [`radius > 19.8`],
  [还需要缩小位置集合],
  [已达证书的源交给清除流程],
  [`maxdist(self.p, poly) <= 999.0`],
  [所有多边形候选都在保证距离内],
  [不保证朝向允许接收],
  [`last is not None`],
  [有该频道的历史测点],
  [`last` 不一定是正锚点],
  [`dist(self.p, last) >= 25.0`],
  [与该频道最近测点至少相距 25 m],
  [不保证独立误差或足够大的交会角],
  [按半径降序最多选两个],
  [优先处理更不确定的频道，控制停靠开销],
  [不是全局最优的信息价值排序],
)
]

第 144 行用 `<25.0` 跳过，因此恰好 25 m
满足距离条件。比较对象是#strong[同一频道最近一次检测的位置]，包括无信号检测；不是上一条任意频道动作位置，也不是仅与正锚点比较。

25 m 门槛减少短基线重复测量，但它是效率启发式。两点相距 25 m
仍可能与源几乎共线，也可能都在背向半平面。复用无信号只更新
`last`，不会直接裁剪。普通复用与认证成对探测的推理条件不同。

== 12　一步一步跟踪一次单频道服务
<一步一步跟踪一次单频道服务>
=== 12.1　案例说明与复现方法
<案例说明与复现方法>
这是本章构造的#strong[单源服务子程序算例]，用于核对 `_service()`
的分支，不是一局满足 10—16
源要求的正式案例，也不是官方测试成绩。真实源设为

$ g eq lr((200 comma 0)) comma quad rho eq 1000 comma quad n eq lr((minus 1 comma 0)) comma $

即向西辐射。令示向误差恒为 0，读数仍按本地接口保留两位小数。0°
误差符合题设误差上界。运行的是当前原始求解器；只用一个临时模拟器子类替换教学环境的误差函数。

在仓库根目录可用以下片段复现关键结果，不改写源程序：

```python
import math
import sys
sys.path.insert(0, "source/Q4")
import q4_local_solver as solver
from q4_local_simulator import Simulator, Source

class ExactTeachingSimulator(Simulator):
    def _error(self, source, position):
        return 0.0

sim = ExactTeachingSimulator([
    Source(1, (200.0, 0.0), 1000.0, True, math.pi, 0.0)
])
strategy = solver.Strategy(sim)
strategy._observe(1, (0.0, 0.0))
strategy._service(1)
print(strategy.tracks[1].status)
print(strategy.max_pair_rounds, sim.measurements, sim.distance, sim.time)
```

=== 12.2　运行记录及每一步的理由
<运行记录及每一步的理由>
以下数字来自对上述算例实际调用当前源码后的记录，显示值取适当小数位；累计时间包含移动和检测，不含任何人为等待。

#align(center)[#table(
  columns: 6,
  align: (col, row) => (auto,auto,auto,right,right,right,).at(col),
  inset: 6pt,
  [步骤], [动作点/m], [返回或更新], [`U`/m], [MEC 半径/m],
  [累计虚拟时间/s],
  [0],
  [$lr((0 comma 0))$],
  [`direction = 0°`],
  [1500.000],
  [750.231],
  [5.000],
  [1],
  [$lr((750 comma 75))$],
  [`no_signal`],
  [1500.000],
  [750.231],
  [160.748],
  [2],
  [$lr((750 comma minus 75))$],
  [`no_signal`],
  [1500.000],
  [750.231],
  [195.748],
  [2 后],
  [不增加动作],
  [保留 $x lt.eq 750$],
  [750.115],
  [375.115],
  [195.748],
  [3],
  [$lr((375.058 comma minus 37.506))$],
  [`no_signal`],
  [750.115],
  [375.115],
  [276.111],
  [4],
  [$lr((375.058 comma 37.506))$],
  [`no_signal`],
  [750.115],
  [375.115],
  [296.113],
  [4 后],
  [不增加动作],
  [保留 $x lt.eq 375.058$],
  [375.115],
  [187.587],
  [296.113],
  [5],
  [$lr((187.558 comma 18.756))$],
  [`direction = 303.56°`],
  [27.100],
  [4.494],
  [338.800],
  [6],
  [$lr((191.622 comma 12.676))$],
  [`clear = success`],
  [—],
  [—],
  [345.263],
)
]

#strong[步骤 0。] 锚点在源的西侧，有信号。首个 0°
读数产生向东的长角楔。读数给出射线方向，不能仅凭它知道源距锚点 200
m，所以初始 `U` 仍为 1500。

#strong[步骤 1—2。]
两个点都在源东侧，落在背向半平面。首个无信号没有改变多边形；第二个无信号才触发认证裁剪。新的
`U` 为 $750 slash cos delta$，所以略大于 750。

#strong[步骤 3—4。]
两个新探测点仍在真实源东侧，再次双负。因为当前位置在上轮下方点，先访问本轮下方点，这体现了
`_pair_round()` 的近点优先换序。

#strong[步骤 5。] 新点的横坐标约 187.558，小于源的
200，进入辐射半平面。其真实指源向量约为
$lr((12.442 comma minus 18.756))$，示向度舍入后为
303.56°。新旧角楔相交很小，MEC 中心约为
$lr((200.127 comma minus 0.049))$，半径约
4.494。此时不再访问本轮另一点。

#strong[步骤 6。] 安全圆盘半径
$19.8 minus 4.494 approx 15.306$。投影所得清除点距真实源约 15.194
m，成功。这里选择的清除点与 MEC 圆心不同，式 (4.20)
保证它对整个候选集合安全。

整个服务使用 3 轮成对动作、6 次检测、0 次换台、1 次成功清除、0
次失败清除，移动约 1551.313 m。时间核算为

$ T eq 1551.312844 slash 5 plus 6 times 5 plus 1 times 5 approx 345.262569 med upright(s) dot.basic $

这个算例也展示了一个效率限制：因为最初距离不确定，前两轮走过了真实源。保证收缩的策略未必使每一次行走都短。

== 13　逐函数对应当前源码
<逐函数对应当前源码>
本节行号对应本次核对的原始文件。`q4_local_solver.py` 共 208 行；其第
1—208 行与 `q4_official_solver.py` 第 1—208
行逐行相同。正式文件随后增加独立 HTTP 客户端，不导入本地模拟器。

=== 13.1　数学与策略核心
<数学与策略核心>
以下“共同”表示本地与正式求解器具有相同行号。

#align(center)[#table(
  columns: 4,
  align: (col, row) => (auto,auto,auto,auto,).at(col),
  inset: 6pt,
  [数学或决策], [函数/对象], [当前行号], [阅读时要核对的细节],
  [角误差、清除与探测参数],
  [模块常量],
  [共同 8—13],
  [`DELTA`、19.8、0.5、0.05、25.0],
  [半平面裁剪],
  [`clip`],
  [共同 24—37],
  [第 26 行向外加容差；第 29—31 行插交点并保留内点],
  [初始位置外包络],
  [`arena_polygon`],
  [共同 39—41],
  [用 $1800 slash cos lr((pi slash 64))$
  生成外切多边形；不能改成同半径内接多边形],
  [正观测角楔],
  [`direction_update`],
  [共同 43—47],
  [两条角边加一条轴向上界；没有圆弧精确交],
  [两点支撑圆、三点圆],
  [`_diameter_circle`, `_circum`],
  [共同 49—56],
  [近共线时 `_circum` 返回 `None`],
  [MEC 计算],
  [`mec`],
  [共同 58—76],
  [固定种子 271828；返回前按所有顶点重新取最大距离并加 $10^(minus 6)$],
  [最近充分安全清除点],
  [`nearest_clear`],
  [共同 78—83],
  [安全圆盘投影；不是整个可清除区域的全局最近点],
  [25 站几何与访问顺序],
  [`coverage_route`],
  [共同 85—89],
  [中心、8 内圈、16 外圈；外圈先 14、15],
  [每频道信息状态],
  [`Track`],
  [共同 91—101],
  [`anchor`、`last`、`U` 和 `radius` 各有不同语义],
  [初始策略状态],
  [`Strategy.__init__`],
  [共同 103—107],
  [原点、频道 1、20 条轨迹],
  [接纳正观测],
  [`_positive`],
  [共同 109—112],
  [更新正锚点、距离上界、角楔和 MEC],
  [执行清除],
  [`_clear`],
  [共同 113—120],
  [认证清除失败即异常，不静默计为成功],
  [解释三种检测结果],
  [`_observe`],
  [共同 121—129],
  [无信号不裁；`near` 直接清；每次检测更新 `last`],
  [已知存在数与未知终结],
  [`_known_count`, `_finish_unknown_if_possible`],
  [共同 130—139],
  [16 个已知或完整覆盖；10 个不触发],
  [停靠时复用],
  [`_reuse`],
  [共同 140—147],
  [999 m 距离条件、同频道 25 m 门槛、最多两个],
  [覆盖站逐频道扫描],
  [`_scan_site`],
  [共同 148—154],
  [当前频道优先，扫描未知频道后再复用],
  [双负认证裁剪],
  [`_dual_negative`],
  [共同 155—158],
  [半平面阈值 $lambda U$ 与 $lambda slash cos delta$ 收缩],
  [一轮成对探测],
  [`_pair_round`],
  [共同 159—169],
  [固定本轮测点；首点正观测即返回；只有双负才裁],
  [单源服务闭环],
  [`_service`],
  [共同 170—178],
  [达证书就清，最多 9 轮后报错；完成后复用],
  [在线插入评分],
  [`_choose_insert`],
  [共同 179—187],
  [绕行增量加 `radius`；600 m 阈值],
  [总调度与输出],
  [`run`, `run_case`],
  [共同 188—208],
  [发现、服务、覆盖交替；2000 次外层循环保护],
)
]

=== 13.2　状态机及两个容易混淆的量
<状态机及两个容易混淆的量>
```mermaid
stateDiagram-v2
    [*] --> UNKNOWN
    UNKNOWN --> FOUND: direction
    UNKNOWN --> CLEARED: near 后清除成功
    UNKNOWN --> ABSENT: 完整覆盖或已有 16 个源
    FOUND --> FOUND: 正观测或双负更新
    FOUND --> CLEARED: 认证清除成功
    CLEARED --> [*]
    ABSENT --> [*]
```

无信号使 `UNKNOWN` 保持未知；它也能使 `FOUND`
保持发现状态而不改变多边形。图中省略了这些自环和异常退出。

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [变量], [含义], [更新时机],
  [`anchor`],
  [最近一个有示向度的正检测点],
  [`direction` 时更新；双负后不变],
  [`last`],
  [本频道最近一次检测的位置],
  [每次检测都更新，包括无信号],
  [`U`],
  [相对于正锚点的真实源距离上界],
  [正观测或双负后更新],
  [`radius`],
  [当前位置多边形的包围圆半径],
  [多边形有效更新后重算],
)
]

例如首测后 `U=1500`，MEC 半径约为
750；两者相差约一倍，本来就不应该混作一个量。

=== 13.3　本地模拟器怎样实现题设
<本地模拟器怎样实现题设>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [行号], [对象], [可核对的事实],
  [8—10],
  [`Source`],
  [频道、位置、半径、定向标志、朝向、误差相位],
  [16—17],
  [`_move`],
  [移动时间为距离/5],
  [18—20],
  [`_visible`],
  [定向接收用点积；全向直接通过],
  [21—22],
  [`_error`],
  [固定空间函数，幅度夹在 ±1°；同位置重复不改变误差],
  [23—31],
  [`measure`],
  [5 s 检测、1 s 换台，依次判无信号、`near`、示向度],
  [32—36],
  [`clear`],
  [仅检查距离不超过 20 m；成功 5 s，失败 3 s],
  [38—43],
  [`make_case`],
  [圆域面积均匀位置，半径均匀抽样，1 到 $n minus 1$ 个定向源],
  [45—65],
  [`_average`],
  [分开输出逐局等权、合并源数加权与时间分解],
  [82—109],
  [`main`],
  [批量运行、记录 seed、全清除状态和异常、写结果 JSON],
)
]

`_visible()` 使用 $minus 10^(minus 10)$
的数值容差，这与数学上的边界包含方向一致，但不等于官方内部采用相同浮点实现。误差函数的空间相关结构也是本地模拟的选择，题设没有指定这个正弦余弦场。

=== 13.4　正式客户端：几何正确以外的运行条件
<正式客户端几何正确以外的运行条件>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [文件行号], [函数], [作用],
  [正式 219—231],
  [`OfficialClient.__init__`],
  [只允许回环 HTTP 地址；初始化时间、位置、频道与请求状态],
  [正式 254—262],
  [`_cutoff`, `_attempt_timeout`],
  [为正常退出保留现实时间],
  [正式 263—283],
  [`_validate_success`],
  [检查 HTTP/`accepted`、时间、三种检测结果与清除结果],
  [正式 284—323],
  [`_request`],
  [同一动作重试复用原请求体与 `request_id`；结果未知时不擅自认定失败],
  [正式 324—344],
  [`action`],
  [阻止未决动作后生成新 ID；验证坐标频道；检查下一动作虚拟时间预算],
  [正式 352—355],
  [`enter`],
  [使用返回的实际剩余现实时间建立期限],
  [正式 356—361],
  [`measure`, `clear`, `exit`, `can_exit`],
  [清除不改变测向频道；未决请求时不能新发退出动作],
  [正式 368—391],
  [`main`],
  [进入、执行、退出、记录结果；异常时仅在可安全退出时退出],
)
]

`action()` 对下一次检测的上界是移动时间 +5 s，必要时 +1
s；清除使用移动时间 +5 s。程序没有在每次检测后另等 5 秒，因为该 5
秒属于模拟器虚拟时间。

本章仅说明已读取的实现；HTTP
字段的具体官方定义还需结合附件协议。不能把本地 JSONL
当作题目要求导出的官方加密正式日志，也不能从本地案例 seed
编造正式案例编码。

== 14　证据、实验与结论的边界
<证据实验与结论的边界>
=== 14.1　四层结论要分别写
<四层结论要分别写>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [结论], [证据], [适用前提],
  [25 站保证发现],
  [三角剖分、边长、凸包证明],
  [静止源；180° 闭半平面；最小半径 1000；扫描动作完成],
  [双负裁剪保留真值],
  [距离排除、线段横跨、正锚点证明],
  [原正锚点有效；无模型外漏检；角误差上界成立],
  [认证清除成功],
  [候选集合包含真值与三角不等式],
  [几何外包络未误删；动作按目标点执行],
  [总时间较短],
  [同条件对照实验与统计],
  [仅适用于实际比较的参数、样本与环境],
)
]

前三条不直接证明最后一条。程序还有现实时间上限、网络异常、数据校验、9
轮与 2000
次循环保护；这些条件触发时可能中断，不能把理论几何保证扩大为任何运行环境下无条件完成。

=== 14.2　适合验证这一策略的实验
<适合验证这一策略的实验>
应保留每局种子与全部失败局，不只统计成功局。除随机混合案例外，可设计以下定点压力场景：

+ 目标靠近 1800 m 边界，朝向径向外侧，检查外圈发现。
+ 目标位于三角剖分的边和顶点，朝向让一个或多个站恰好位于辐射边界。
+ 接收半径恰为 1000 m，测向误差取端点附近，检验保守距离和角楔。
+ 正锚点接近辐射边界，首个成对测点无信号、第二点有信号，检验反例 B
  的分支。
+ 多轮双负后才转正，检查 `anchor` 没有被无信号点替换。
+ 同频道两个停靠点距离为 24.9、25.0、25.1 m，核对复用门槛语义。
+ 一局恰有 10 个和恰有 16 个源，区分完整覆盖终止与数量上限终止。

对效率参数进行比较时，应让不同配置运行相同案例。可比较复用开关、25 m
门槛、插入阈值、覆盖顺序；每项变化都要重新检查是否影响已有证明。尤其改变外圈半径、站数、$lambda$、$eta$
时，应先核对几何不等式，再讨论平均耗时。

#strong[本章实际运行的固定种子小演示。]
在仓库根目录执行以下命令；输出路径可换成自己的结果目录：

```bash
python source/Q4/q4_local_simulator.py --loops 10 --seed 20260929 --output q4_demo_20260929.json
```

核对结果如下。它是本地 10
局复现演示，样本量不足以刻画尾部失败概率，也不是官方成绩。

#align(center)[#table(
  columns: 2,
  align: (col, row) => (auto,right,).at(col),
  inset: 6pt,
  [指标], [实际结果],
  [全清除局数],
  [10/10],
  [源总数 / 定向源总数],
  [145 / 66],
  [失败清除次数],
  [0],
  [每局平均虚拟时间],
  [6675.53 s],
  [逐局等权平均每源耗时],
  [468.43 s],
  [合并源数加权平均每源耗时],
  [460.38 s],
  [每局平均移动距离],
  [26126.63 m],
  [每局平均移动 / 检测 / 换台 / 清除时间],
  [5225.33 / 1172.00 / 205.70 / 72.50 s],
)
]

实际核对运行使用同一命令参数，将输出文件放在仓库外的临时目录；改变
`--output`
不改变生成的案例和上述虚拟时间指标。程序现实运行时间受机器影响，不作为该固定种子的恒定结果。

=== 14.3　统计指标与正式报告
<统计指标与正式报告>
对第 $j$ 局，记源总数 $N_j$、成功清除数 $C_j$、虚拟时间
$T_j$。题设单局指标为

$ upright("清除比例") eq C_j slash N_j comma #h(2em) upright("平均每源耗时") eq T_j slash C_j dot.basic $

跨局时，

$ 1 / M sum_(j eq 1)^M T_j / C_j quad upright("与") quad frac(sum_j T_j, sum_j C_j) $

通常不同；前者按局等权，后者按清除源数加权。$C_j eq 0$
时每源耗时无定义，不能写成 0；还需报告失败数与错误原因。

本地模拟器两种平均都会输出。应注明所用分母、是否包含失败局以及案例分布。本章没有官方三次测试的结果；正式表格中的案例编码和成绩必须来自实际官方记录。

=== 14.4　当前实现的具体限制
<当前实现的具体限制>
- 25
  站是有证明的可行构造，没有最少站数证明。固定访问顺序没有最短路证明。
- 普通负观测没有被充分利用。即使在认证距离内，一次负观测也可能约束朝向；当前代码未维护完整位置—朝向联合集合。
- 成对模板为保证最坏收缩而设计，可能走过近源，单次移动未必经济。
- 999 m 与 25 m
  门槛只解决各自的距离余量和短基线复用问题；它们不保证接收到定向信号，也不保证好交会角。
- 初始圆域用外切多边形，正观测距离圆用轴向半平面。保守近似可能增加检测次数。
- MEC
  返回半径覆盖当前顶点，使清除证书更稳健；浮点几何仍不是经过形式化验证的精确算术。
- 本地误差场、分布与官方未知案例不必一致。本地全清除率不能替代连续几何证明或官方正式成绩。

== 15　答辩追问：回答时先说条件，再说结论
<答辩追问回答时先说条件再说结论>
=== 问 1：Q3 的圆盘覆盖，为什么不能直接用于 Q4？
<问-1q3-的圆盘覆盖为什么不能直接用于-q4>
答：一个点在接收半径内，只满足距离条件；定向源还要求检测点处于它的辐射半平面。未知朝向下要让近检测点的凸包包含源位置。25
站通过小三角形剖分满足这个更强条件。

=== 问 2：25 个点覆盖了无穷多个源位置和方向，依据是什么？
<问-225-个点覆盖了无穷多个源位置和方向依据是什么>
答：外圈十六边形内切半径约 1802.683 m，包住目标圆域；32
个三角形铺满该多边形，所有边不超过 995
m。源所在三角形三个顶点都在最小接收半径内，凸组合又保证它们不可能都处于任意辐射半平面的外侧。

=== 问 3：一个站就很近了，为何还要强调凸包？
<问-3一个站就很近了为何还要强调凸包>
答：近点解决接收距离，凸包解决任意方向。如果所有近点在源的一侧，源可以朝相反方向发射，把它们全部避开。

=== 问 4：无信号为什么不直接排除附近区域？
<问-4无信号为什么不直接排除附近区域>
答：近但背向也无信号。源在 $lr((100 comma 0))$ 朝东，原点距它 100 m
仍无信号，就是反例。要删除必须排除所有相容朝向解释。

=== 问 5：两个无信号为什么突然可以删？
<问-5两个无信号为什么突然可以删>
答：这里不是任意两点。它们处在认证接收距离内，且连线横跨正锚点角楔。如果源在连线前方，锚点到源的线段会穿过这条探测线段；正锚点要求交点在接收侧，双负要求交点在背向侧，矛盾。因此可保留锚点这一侧。

=== 问 6：源是全向还是定向都不知道，会影响双负推理吗？
<问-6源是全向还是定向都不知道会影响双负推理吗>
答：认证距离内的全向源不可能双负；出现双负本身排除了全向类型。正观测分支则对两种类型均成立，所以无需事先分类。

=== 问 7：如果两个负点其实都因为太远而无信号呢？
<问-7如果两个负点其实都因为太远而无信号呢>
答：那就不能裁。当前参数保证它们到全部候选位置不超过约 756.813
m，小于最小半径 1000 m。条件失效时必须停止使用这条推理。

=== 问 8：$lambda eq 0.5$、$eta eq 0.05$ 是最优值吗？
<问-8lambda0.5eta0.05-是最优值吗>
答：它们同时满足横跨角楔与距离条件，并带来约 0.505
的收缩上界。当前源码没有给出连续参数空间的全局最优证明；若声称某配置更快，应给同案例对照实验。

=== 问 9：为什么不用位置集合直径判断能不能清除？
<问-9为什么不用位置集合直径判断能不能清除>
答：直径不超过 40 m 不保证半径 20 m 的一个圆能覆盖集合；边长 36 m
的等边三角形就是反例。清除需要控制一个行动点到全部候选位置的最大距离，MEC
与这个条件直接对应。

=== 问 10：明明半径小于 19.8，为何清除点不是圆心？
<问-10明明半径小于-19.8为何清除点不是圆心>
答：距圆心不超过 $19.8 minus R$
的任意点都安全。代码取该安全圆盘中离当前位置最近的点，减少移动；三角不等式保证距真源不超过
19.8。

=== 问 11：25 m 的意义是不是让测向误差独立？
<问-1125-m-的意义是不是让测向误差独立>
答：不能这样说。它避免同频道在极短基线处重复使用检测，属于效率规则；题设未给出独立距离。较大空间间隔也不保证正交交会或处在辐射方向。

=== 问 12：你们用了旅行商插入法，所以是不是两倍近似？
<问-12你们用了旅行商插入法所以是不是两倍近似>
答：代码借用了绕行增量形式，但目标位置未知、逐步发现，评分加入半径，只在下一覆盖边上插入。因此静态旅行商特定算法的近似界不适用；我们称之为在线启发式。

=== 问 13：发现 10 个源是否能结束？
<问-13发现-10-个源是否能结束>
答：不能。10
是下限；必须完整完成覆盖并清除发现的源，或者已知存在数达到上限
16，再清除全部已发现源。

=== 问 14：理论上都能结束，为什么代码还有轮数上限？
<问-14理论上都能结束为什么代码还有轮数上限>
答：理论推导依赖传感器语义、误差界和位置集合不变量。轮数上限用来暴露实现、协议或假设异常；触发后报错，不把未完成任务伪装成完成。

=== 问 15：正式程序与本地程序有没有读取真值的区别？
<问-15正式程序与本地程序有没有读取真值的区别>
答：策略核心前 208 行相同，策略通过 `measure`、`clear`
两个接口读取反馈。正式文件的后半部是独立 HTTP
客户端，没有导入本地真值生成器。本地模拟器可以访问真值来判定反馈和计算评价指标；这不等于策略使用了真值。

== 16　练习与解答
<练习与解答>
=== 练习 1　把方向写成点积
<练习-1-把方向写成点积>
一个源位于 $lr((10 comma 20))$，朝向正北，半径 1000。判断
$lr((10 comma 19))$、$lr((10 comma 20))$、$lr((510 comma 20))$、$lr((10 comma 1021))$
能否接收。暂不区分 `near` 与 `direction`。

#strong[解答。] 朝向 $n eq lr((0 comma 1))$，角度条件为
$q_y gt.eq 20$。第一点在背向侧；第二、第三点可接收，第三点在辐射边界且距离
500；第四点方向满足，但距离 1001
超出半径。第二点在几何模型中满足接收，接口会用近距离结果处理。

=== 练习 2　证明一次覆盖必须考虑围住源
<练习-2-证明一次覆盖必须考虑围住源>
源在原点，三个可达检测点为
$lr((1 comma 1))$、$lr((2 comma 1))$、$lr((1 comma 2))$。能否保证任意朝向都被接收？

#strong[解答。] 不能。取
$n eq lr((minus 1 comma minus 1)) slash sqrt(2)$，三个点与 $n$
的点积均为负。它们虽然都近，但凸包不含原点。

=== 练习 3　检查另一个外圈半径
<练习-3-检查另一个外圈半径>
把 Q4 外圈半径改为 1800，仍使用 16 个等角点。仅凭外圈多边形能否包住半径
1800 的目标圆域？

#strong[解答。] 不能。其内切半径
$1800 cos lr((pi slash 16)) approx 1765.414$。圆域在边中点方向上伸出多边形，原来的三角剖分覆盖证明不再覆盖这些区域。这不自动证明整个新方案必然漏检，但证明必须重新建立。

=== 练习 4　推导双负所需的横向距离
<练习-4-推导双负所需的横向距离>
若
$U eq 1200$、$lambda eq 0.5$、$delta eq 1.0051^compose$，探测线位于锚点前方多少米？两探测点到轴线至少应相距多少米才能跨住整个角楔？代码实际选多少米？

#strong[解答。] 探测线在 600 m 处；每侧至少为
$600 tan delta approx 10.5265$ m。代码每侧取 $0.05 times 1200 eq 60$
m，两点之间为 120 m。题目中的“每侧距离”与“两点间距”不要混淆。

=== 练习 5　检验一组过大的参数
<练习-5-检验一组过大的参数>
保持 $lambda eq 0.5$、$U eq 1500$、$delta eq 1.0051^compose$，改用
$eta eq 0.6$。能否继续引用本章距离认证？

#strong[解答。] 不能。式 (4.10) 给出

$ 1500 sqrt(0.25 plus lr((0.6 plus 0.0175441))^2) approx 1192 med upright(m) gt 1000 dot.basic $

该上界不能保证所有候选位置都在接收距离内，故双负不能按原规则裁剪。事实上远端角点也会产生超距，问题不是单纯上界太松。

=== 练习 6　用清除余量减少移动
<练习-6-用清除余量减少移动>
MEC 中心 $c eq lr((100 comma 0))$、半径 $R eq 12$，当前位置
$p eq lr((0 comma 0))$。按代码证书计算最近清除点、移动距离、到所有候选点的最坏距离上界。

#strong[解答。] 余量为 7.8，安全点为 $z eq lr((92.2 comma 0))$，移动
92.2 m。最坏距离不超过 $7.8 plus 12 eq 19.8$ m。若走到圆心，需走 100
m，多走 7.8 m，即多用 1.56 s。

=== 练习 7　区分 `last` 与 `anchor`
<练习-7-区分-last-与-anchor>
某频道在 A 点得到示向度，随后 B 点无信号。下一停靠点 C 距 A 为 40 m、距
B 为 10 m，其余复用条件均满足。程序是否复用该频道？成对探测用哪个锚点？

#strong[解答。] 不复用，因为 `last=B`，距离只有 10 m，小于 25
m。正锚点仍为 A；B 的无信号没有把 `anchor` 改成 B。

=== 练习 8　复算单频道轨迹的时间
<练习-8-复算单频道轨迹的时间>
第 12 节中移动 1551.312844 m，检测 6 次，换台 0 次，成功清除 1
次。若误把程序再等待的 5 s 加在每次检测后，会报告多少额外时间？

#strong[解答。] 正确虚拟时间约 345.262569 s。额外加入 $6 times 5 eq 30$
s 会得到约 375.262569
s，属于重复计时。现实程序运行时长与虚拟任务耗时也要分别记录。

=== 练习 9　判断三种结束理由
<练习-9-判断三种结束理由>
分别判断：A. 清除了 10 个源但还有未知频道；B. 已发现或清除的不同频道恰为
16，且最终全部清除；C. 25
站全部扫描完毕，剩余未知频道均无发现，全部已发现源已清除。

#strong[解答。] A 不足以宣布完成；B 可依据数量上限完成；C
可依据方向覆盖完成。B 中仅“发现 16 个”还不够，发现后的清除必须全部完成。

=== 练习 10　把保证与性能拆开陈述
<练习-10-把保证与性能拆开陈述>
请改写“我们使用 25
个最优站点和最优插入算法，仿真全成功，所以在所有情况下全局最快”。

#strong[解答。] 可写为："在题设理想接收模型下，25
站的三角剖分保证发现全部源，成对探测与 MEC
证书保证安全定位清除。访问顺序、复用门槛和插入规则用于改善耗时，其性能通过指定案例集的对照测试评价；本文未证明站数最少或总时间全局最优。"

== 17　带着三条线索回读代码
<带着三条线索回读代码>
第一次只追踪不变量：`poly` 始终包含真实位置，`anchor`
始终是正观测位置，`U` 始终是相对锚点的可靠上界。

第二次只追踪证据：普通无信号为什么不删；双负时距离分支如何被排除；MEC
与清除点如何构成成功证明。

第三次只追踪代价：25 站访问顺序、插入绕行、最多两个复用频道、25 m
门槛、近点优先和清除余量如何影响移动与检测时间。把这三条线分清，才能既说出算法为什么可靠，也准确说明哪些部分仍属于效率选择。

== 参考来源与精确阅读位置
<参考来源与精确阅读位置>
以下链接为原作者、出版社或高校托管的论文/教材。外部例题在正文中经过概述与重算；本题
25
站构造、成对探测证明、数字轨迹与练习按当前源码另行推导，不宣称来自外部论文。

+ Steven M. LaValle. #emph[Planning Algorithms]. Cambridge University
  Press, 2006.
  #link("https://lavalle.pl/planning/ch11.pdf")[Chapter 11: Sensors and Information Spaces]，§11.1.1，Example
  11.3、11.6；#link("https://lavalle.pl/planning/ch12.pdf")[Chapter 12: Planning Under Sensing Uncertainty]，§12.1.1、式
  (12.1)。对应通用观测逆像和信息集合目标。
+ Jing Ai, Alhussein A. Abouzeid. #emph[Coverage by Directional
  Sensors]. WiOpt, 2006.
  #link("https://sites.ecse.rpi.edu/~abouzeid/preprints/2006wiopt.pdf")[作者所在高校托管的论文稿]，Fig.
  1，§III-A、§III-B；#link("https://eudl.eu/doi/10.1109/wiopt.2006.1666444")[出版记录]。作者稿标注
  2005 年草稿日期，会议出版年为 2006。对应方向覆盖原例与扇区点积判定。
+ Luc Jaulin, Eric Walter. #emph[Set inversion via interval analysis for
  nonlinear bounded-error estimation]. Automatica, 29(4), 1053–1064,
  1993.
  #link("https://webperso.ensta.fr/jaulin/paper_automatica93.pdf")[作者主页 PDF]，§3.3、Example
  4、式 (22)—(23)，以及 §5 的集合反演算法。对应有界误差与外包络原例。
+ Leslie Pack Kaelbling, Michael L. Littman, Anthony R. Cassandra.
  #emph[Planning and acting in partially observable stochastic domains].
  Artificial Intelligence, 101, 99–134, 1998.
  #link("https://people.csail.mit.edu/lpk/papers/aij98-pomdp.pdf")[作者主页 PDF]，§5.1—§5.2，第
  119—120 页。对应 Tiger problem 原例；正文的两次更新为按原参数重算。
+ Emo Welzl. #emph[Smallest enclosing disks (balls and ellipsoids)].
  LNCS 555, 359–370, 1991.
  #link("https://people.inf.ethz.ch/emo/PublFiles/SmallEnclDisk_LNCS555_91.pdf")[作者主页 PDF]；#link("https://doi.org/10.1007/BFb0038202")[出版社摘要与 DOI]。对应最小包围圆与随机算法背景；不据此把当前三重增量循环写成已证最坏线性。
+ Daniel J. Rosenkrantz, Richard E. Stearns, Philip M. Lewis II.
  #emph[An Analysis of Several Heuristics for the Traveling Salesman
  Problem]. SIAM Journal on Computing, 6(3), 563–581, 1977.
  #link("https://disco.ethz.ch/courses/fs16/podc/readingAssignment/1.pdf")[高校托管重印本]，§3、式
  (3.1)，§4、Theorem
  4；#link("https://doi.org/10.1137/0206041")[原文 DOI]。对应插入增量与近似界的适用范围。
+ 本题原始材料：`20-B-.pdf`，问题 4、附录 1—4；当前仓库
  #link("https://github.com/SOMEBODYJUN/work-web/blob/main/source/README.md")[`source/README.md`]、#link("https://github.com/SOMEBODYJUN/work-web/blob/main/source/Q4/q4_local_solver.py")[`q4_local_solver.py`]、#link("https://github.com/SOMEBODYJUN/work-web/blob/main/source/Q4/q4_official_solver.py")[`q4_official_solver.py`]、#link("https://github.com/SOMEBODYJUN/work-web/blob/main/source/Q4/q4_local_simulator.py")[`q4_local_simulator.py`]。行号按本章核对版本记录；若后续源码改变，应同步重核映射。

#pagebreak()
= 05 源码地图与逐段精读
<源码地图与逐段精读>
== 5.0 怎样用这一章准备逐行答辩
<怎样用这一章准备逐行答辩>
本章以仓库 `source/` 中未修改的 Python 文件为准。行号用 `nl -ba`
核对，函数与类的起止用 Python AST 的 `lineno/end_lineno`
复核；装饰器算在类或方法范围内。表中的范围是实际定义范围，不包含后面的空行。遇到一行写了多条语句时，按执行顺序解释。

答辩时，对被指到的代码按以下顺序回答：#strong[输入是什么 →
表示哪条数学约束 → 修改什么状态 → 哪个函数继续使用结果 →
什么情况下报错或不能作更强结论]。只念变量名或把 `for`
翻译成“循环”是不够的。

本章的“保证”均以程序采用的物理模型及数值容差为前提。它区分三类依据：解析几何关系、程序中的运行时检查、有限数值搜索或本地试验。三者不能互换。

=== 5.0.1 文件与真实入口
<文件与真实入口>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [文件], [入口与责任], [不应误读之处],
  [`source/Q1/q1_generator.py:8-41`],
  [`main()` 生成一组观测 JSON。],
  [生成器知道真值，求解器不读取 `local_truth`。],
  [`source/Q1/q1_solver.py:283-302`],
  [`main()` 读取 JSON，调用 `solve_localization`，写结果。],
  [不计算最小包围圆；会检查“直径圆”是否覆盖顶点。],
  [`source/Q2/q2_generator.py:6-35`],
  [生成一个物理相容的首测。],
  [只生成首测，不替优化器选择第二站。],
  [`source/Q2/q2_solver.py:481-538`],
  [`solve_case → optimize_fixed_baseline → robust_quality`。],
  [D 与 R 两种目标各自重新选站；有限搜索不是连续全局证明。],
  [`source/Q3/q3_local_simulator.py:78-120`],
  [创建本地真值与 `Simulator`，调用 `q3_local_solver.run_case`。],
  [本地 solver 文件没有命令行主入口，单独执行不会开始一局。],
  [`source/Q3/q3_official_solver.py:683-712`],
  [创建 HTTP 客户端，等待、入场、运行同一策略、退出、记日志。],
  [正式文件不导入本地模拟器。],
  [`source/Q4/q4_local_simulator.py:82-118`],
  [创建全向/定向混合本地源，调用本地 solver。],
  [模拟器的可见性分支与策略的普通无信号分支分属不同职责。],
  [`source/Q4/q4_official_solver.py:368-391`],
  [Q4 正式 HTTP 入口。],
  [正式策略同样不能读取模拟器隐藏真值。],
)
]

=== 5.0.2 本地与正式的重复代码确实相同
<本地与正式的重复代码确实相同>
逐字节检查得到：

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [本地代码], [正式代码中的对应范围], [结论],
  [`source/Q3/q3_local_solver.py:1-502`],
  [`source/Q3/q3_official_solver.py:1-502`],
  [502 行完全一致。Q3 几何、状态、调度与 `run_case` 的行号一一相同。],
  [`source/Q4/q4_local_solver.py:1-208`],
  [`source/Q4/q4_official_solver.py:1-208`],
  [208 行完全一致。Q4 的核心策略行号一一相同。],
)
]

后文讲 Q3/Q4
核心时列本地文件名；#strong[同一行号也精确对应上表中的正式文件]，不是“近似对应”。正式文件后半段才是新增客户端。重复是单文件提交的组织方式，不代表两套不同算法。

Q3 第 217
行注释还写着“geometry.py”，但当前目录没有这个模块，几何实现就在同一个
solver 的第 1–212 行；不能照注释声称运行时导入了它。Q2
的“Q1直径方法”标签也不表示导入 Q1：Q2 第 246–270
行自行实现凸包和直径，只借用“以 D 为目标”的方法含义。

=== 5.0.3 最常见的量与不变量
<最常见的量与不变量>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [量/状态], [在代码中的含义], [答辩时应说的关系],
  [`Point`],
  [二元组 `(x,y)`，单位米。],
  [点和位移向量都用同一种容器；含义由调用处决定。],
  [半平面 `(n,b)`],
  [`n·x <= b`。],
  [所有裁剪都保留这一侧。],
  [`poly`],
  [按边界顺序排列的凸多边形顶点，允许退化。],
  [用保守外近似维持真实源仍在集合内；不能当概率置信区间。],
  [`center,radius`],
  [覆盖当前顶点及其凸包的圆。],
  [每个源到圆心的距离不超过 `radius`；清除依据是覆盖而非平均误差。],
  [`D` 与 `R`],
  [最远两点距离与最小包围圆半径。],
  [总有 `D <= 2R`，通常不能反写成 `R=D/2`。],
  [`UNKNOWN/FOUND/CLEARED/ABSENT`],
  [未知/已发现未清除/已确认清除/有证据不存在。],
  [一次无信号不等于频道不存在。],
  [`virtual_time_s`],
  [模拟器返回的任务时间。],
  [与 Python 程序耗时、HTTP 超时是不同的时钟。],
  [`pending`],
  [已准备或发送但结果尚未确认的正式动作。],
  [结果未知时不允许生成新请求 ID。],
)
]

== 5.1 Q1：从示向度到半平面交，再到直径
<q1从示向度到半平面交再到直径>
=== 5.1.1 数据类型和小函数：每个符号的用途
<数据类型和小函数每个符号的用途>
本节文件均为 `source/Q1/q1_solver.py`。

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [定义与精确位置], [参数 → 返回/状态], [操作、调用关系与数学意义],
  [`HalfPlane`，`source/Q1/q1_solver.py:19-27`],
  [`normal: Point, offset: float` → 冻结数据对象。],
  [表示闭半平面 `normal·X<=offset`；由 `_normalise` 和 `_wedge`
  创建。`frozen=True` 防止随后改写这两个字段。],
  [`HalfPlane.residual`，`source/Q1/q1_solver.py:26-27`],
  [点 → `n·x-b`。],
  [负数在内、零在边上、正数在外； `_outside` 再加数值阈值。],
  [`_cross`，`source/Q1/q1_solver.py:30-31`],
  [两个二维向量 → 叉积标量。],
  [`ax*by-ay*bx`；正号用于左转，绝对值对应平行四边形面积。排序、凸包、卡壳都用它。],
  [`_sub`，`source/Q1/q1_solver.py:34-35`],
  [两点/向量 → 坐标差。],
  [构造边和相对位置，避免把点的绝对坐标直接当方向。],
  [`_distance2`，`source/Q1/q1_solver.py:38-40`],
  [两点 → 距离平方。],
  [比较远近时省去开平方；最终输出再开根号。],
  [`_normalise`，`source/Q1/q1_solver.py:43-59`],
  [`HalfPlane`、`((a,b),c)` 或 `(a,b,c)` → 单位法向量的 `HalfPlane`。],
  [接受三种输入格式；转浮点、拒绝 NaN/无穷和零法向量；同时除以正数
  `hypot(a,b)`，保留原不等式方向和集合。],
  [`_direction`，`source/Q1/q1_solver.py:62-65`],
  [半平面 → `(-b,a)`。],
  [法向量逆时针转
  90°。沿此方向看，可行域在边界左侧；这是半平面交排序的方向约定。],
  [`_same_direction`，`source/Q1/q1_solver.py:68-70`],
  [两半平面 → 布尔值。],
  [叉积近零判平行，点积大于零判同向。只有平行还不够：相反方向的两个约束可能形成条带，不能合并。],
  [`_intersection`，`source/Q1/q1_solver.py:90-97`],
  [两条边界 → 交点或 `None`。],
  [用二阶线性方程的行列式求交；`abs(det)<=1e-12` 按平行处理。`None`
  不代表半平面交空，只代表此对边界没有可靠唯一交点。],
  [`_outside`，`source/Q1/q1_solver.py:100-102`],
  [半平面、点 → 布尔值。],
  [以 `EPS*max(1,abs(offset),abs(x),abs(y))`
  放宽残差判断；相对坐标尺度控制舍入影响。],
  [`_cuts`，`source/Q1/q1_solver.py:105-107`],
  [新半平面、两旧边界 → 布尔值。],
  [先求旧交点再判它是否被新约束排除；平行情形返回
  False，留给后面的可行性/有界性判别兜底。],
)
]

第 13–16 行定义 `Point`、`EPS=1e-10`、`PARALLEL_EPS=1e-12` 和
`NUMERICAL_ANGLE_GUARD_DEG=0.0`。最后一个名称在当前文件中没有被读取；不要声称它已被加进每个角楔。Q1
实际角宽由 `solve_localization` 的 `epsilon_deg` 决定。

=== 5.1.2 观测转换：为什么是这两个法向量
<观测转换为什么是这两个法向量>
#align(center)[#table(
  columns: 2,
  align: (col, row) => (auto,auto,).at(col),
  inset: 6pt,
  [定义与位置], [输入、输出与依赖],
  [`_observation`，`source/Q1/q1_solver.py:240-254`],
  [一条字典或长度为 3 的序列 → `(float x,float y,bearing%360)`。],
  [`_wedge`，`source/Q1/q1_solver.py:257-265`],
  [站点、报告角度、误差半宽 → 两个或三个 `HalfPlane`。],
  [`solve_localization`，`source/Q1/q1_solver.py:268-280`],
  [观测列表与误差半宽 → 定位结果字典；调用上面两函数和
  `intersect_halfplanes`。],
)
]

`_observation` 第 241–246 行允许
`position_m`/`position`、`bearing_deg`/`svd_deg` 两组键，位置也可以是
`{"x":...,"y":...}`。第 248–253 行对序列长度和数值有限性作校验。`%360`
把方向统一到一圈，不改变几何方向。

设站点为 (p)，报告为 θ，半宽为 ε；下、上边界单位向量分别为
(u\_-\=u(θ-ε))、(u\_+\=u(θ+ε))。前向角楔满足：

$ u_minus times lr((x minus p)) gt.eq 0 comma #h(2em) u_plus times lr((x minus p)) lt.eq 0 dot.basic $

展开第一式，得到 `(sin(lower),-cos(lower))·x <= n·p`；第二式得到
`(-sin(upper),cos(upper))·x <= n·p`。这正是第 259–261、265
行。两个法向量的符号决定保留哪一侧，不能随意反号。

第 262–264 行专门处理 ε\=0：两侧不等式只能限制在一条直线上，因此另加
`-u·(x-p)<=0`，即 `u·(x-p)>=0`，把整条直线限制成向前射线。

`solve_localization` 第 269–274 行要求 `0<=epsilon<90`
且至少一条观测；这个角宽条件确保一个前向角楔能用相应凸半平面交表达。第
275 行是双层列表推导：每条观测各给出 2 条约束，ε\=0 时给 3 条。第 276
行求交，第 277–279
行把规范化后的观测和角宽附加到结果里，不读取真值，也不重新拟合平均方位角。

=== 5.1.3 半平面排序与双端队列
<半平面排序与双端队列>
#strong[`_ordered`：`source/Q1/q1_solver.py:73-87`。]
参数为可迭代半平面，返回规范化、按边界方向排序、同向去冗余后的列表。

+ 第 74 行先统一法向量长度，否则不能直接比较不同约束的 `offset`。
+ 第 75 行用 `atan2(y,x)%tau` 得到完整的 \[0,2π) 方向并排序；只用
  `atan(y/x)` 会丢象限且怕 x\=0。
+ 第 77–82 行处理相邻同向边界。单位法向量相同的时候，`n·x<=c` 中 c
  越小越严格，所以保留较小 offset。
+ 第 83–86 行补查圆周首尾，因为接近 0° 与 360°
  的同向方向可能被排序拆到两端。

#strong[`intersect_halfplanes`：`source/Q1/q1_solver.py:201-237`。]
输入半平面可迭代对象；返回含 `status`、顶点、面积、直径等字段的字典。

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [行段], [精确执行含义], [为什么需要],
  [203],
  [`del include_circle`。],
  [这是保留的兼容参数，当前不控制任何圆计算；后面仍会输出直径圆覆盖检查。],
  [204–211],
  [排序后逐条入队；新约束若排除队尾两线交点则 `pop`，排除队首两线交点则
  `popleft`，最后 `append`。],
  [方向有序时，被切掉的旧边界只需从两端删除，保留可能构成最终边界的约束。每条边界在主队列中至多入队、出队一次。],
  [212–215],
  [用首约束修剪尾端，再用尾约束修剪首端。],
  [输入遍历是线性的，多边形边界是闭环；必须收口。],
  [217–220],
  [相邻边界求交，包括尾与首；若没有平行交点则再取凸包。],
  [得到候选顶点顺序并去掉重复/共线点。],
  [224],
  [至少 3 个顶点，或退化为点/线段且原约束方向保证有界。],
  [只有两条相邻线的交点不能被误当成“定位成一个点”：两条半平面的交仍可能是无界角域。],
  [225–226],
  [检查每个候选顶点满足每条原约束，通过才返回有限结果。],
  [这是对队列结果的独立回查，不只信任中间队列。凸性使顶点满足即可推出它们的凸包满足。],
  [228–235],
  [求可行点；没有则 `empty`；有且不有界则 `unbounded` 并给见证点。],
  ["空"与“无界”都有可能没有有限闭多边形，不能按顶点数直接区分。],
  [236–237],
  [其余返回 `uncertain`。],
  [已找到可行点且方向应有界，但候选闭图形未通过验证；代码保留不确定结果，不伪造顶点。],
)
]

复杂度要完整说：排序是 (O(mm))，主队列部分是 (O(m))；第 225
行的全约束回查是 (O(mh))，兜底 `_feasible_point` 最坏
(O(m^2))。所以不能把整段实现不加条件地都称为 (O(mm))。

=== 5.1.4 空集、无界与退化情形
<空集无界与退化情形>
#strong[`_feasible_point`：`source/Q1/q1_solver.py:110-132`。]
输入规范化约束列表；返回可行点，或
`None`。它只作分类，不寻找“最好的定位点”。

初始点为原点。第 113–115
行如果当前点满足新约束，直接继续；否则把点移到新约束的边界上。因法向量已单位化，`base=n*offset`
在边界上，`tangent=(-ny,nx)` 沿边界。新点写成

$ x eq upright("base") plus t thin upright("tangent") dot.basic $

第 119–121 行把每条旧约束代入，变成
`coefficient*t <= bound`。系数正，更新 t
的上界；系数负，除法反向，更新下界；系数近零且 bound
负，说明这条边界上不可能满足旧约束，返回 None。第 128
行判断上下界是否冲突；第 130 行把 0 投影到允许区间，选离 base
最近的参数，再写回坐标。

为什么可转到“新边界上找”？此前约束的可行域是凸集，原可行点违反新约束；若合并后仍有可行点，把二者连线，会在新边界上经过一个满足全部旧约束的点。

#strong[`_is_bounded`：`source/Q1/q1_solver.py:135-141`。]
返回是否不存在非零无界移动方向。对法向量按角排序，补最后到最前的一段圆周空隙；若最大间隙小于
π，法向量在各个方向封闭了逃逸通道。数学上判断的是衰退锥

$ brace.l d colon n_i dot.op d lt.eq 0 med forall i brace.r eq brace.l 0 brace.r dot.basic $

它本身不判可行性；一个矛盾约束组也可能方向封闭。因此主函数先分可行/不可行，再用它区分有界/无界。少于
3 条约束直接返回 False。

=== 5.1.5 凸包、旋转卡壳与结果字段
<凸包旋转卡壳与结果字段>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [定义与精确位置], [输入 → 输出], [逐段阅读要点],
  [`_convex_hull`，`source/Q1/q1_solver.py:144-157`],
  [点集 → 逆时针凸包顶点。],
  [145–147：转浮点、去重、字典序排序、处理 0/1
  点。157：上下链去掉重复端点再拼接。],
  [内部 `chain`，`source/Q1/q1_solver.py:149-155`],
  [有序点列 → 单侧凸链。],
  [152–153：最后两个点与新点不构成足够明确左转时弹出中间点；154
  再入栈。维持凸链，不保留直边上的中间点。],
  [`polygon_diameter`，`source/Q1/q1_solver.py:160-181`],
  [点列 → `(直径,最远点对)`。],
  [162 先取凸包；164–169 对 0、1、2
  点分别处理；普通情况以叉积高度移动对踵点 j，比较边两端到 j
  的平方距离。],
  [`_finite_result`，`source/Q1/q1_solver.py:184-198`],
  [非空有限候选顶点 → 结果字典。],
  [再清理凸包；极短线段合并成点；按顶点数分类；算直径、鞋带面积、直径圆覆盖与最小覆盖裕量。],
)
]

卡壳第 174–176
行比较的不是两点距离，而是“同一条边到下一个候选顶点的有向高度”，即
`cross(edge,point-edge_start)`。在凸多边形上转动边时，最远支撑顶点沿同一方向推进，所以
j 不必为每条边从头搜索。第 177–180
行才比较真正距离，并同时检查边的两端。

`_finite_result` 的第 190–191 行是鞋带公式 (A\=|x\_i y\_{i+1}-y\_i
x\_{i+1}|)。第 192–198 行用最远点对的中点、D/2 构造直径圆，逐顶点检查
`farthest<=radius+EPS`。凸圆包含所有顶点就包含整个凸包；但“最远点对是直径”并不自动保证这个圆覆盖所有点，等边三角形就是反例。字段
`diameter_circle_cover_margin_m=radius-farthest`
为负便说明有顶点落在圆外。

=== 5.1.6 Q1 入口与生成器的可解释执行轨迹
<q1-入口与生成器的可解释执行轨迹>
`source/Q1/q1_solver.py:283-298` 的 `main(argv=None)`：第 284–287 行解析
`--input/--output`；288 读 UTF-8 JSON；289 调用求解；290 用输入 case\_id
或文件名作标识；291 创建目录；292 写易读 JSON；293–297 打印状态；298
返回进程成功码 0。第 301–302
行只在直接执行文件时运行入口，导入函数时不会执行。

拿到一个观测文件后，实际调用链为：

```mermaid
flowchart TD
    A[main 读入观测] --> B[solve_localization]
    B --> C[_observation 与 _wedge]
    C --> D[intersect_halfplanes]
    D --> E[队列候选交点]
    E --> F{有限候选通过回查}
    F -->|是| G[_finite_result 与直径]
    F -->|否| H[可行性与有界性分类]
    G --> I[写 JSON]
    H --> I
```

`source/Q1/q1_generator.py:8-41` 只有一个 `main`：

#align(center)[#table(
  columns: 2,
  align: (col, row) => (auto,auto,).at(col),
  inset: 6pt,
  [行段], [做什么与为什么],
  [9–16],
  [参数、随机种子、独立随机发生器；观测数至少 3。未给种子时从
  `SystemRandom` 取一个并记录，以便复现。],
  [17–19],
  [在半径 `1800*0.82` 的圆内按面积均匀采样真源：角度均匀，半径取
  `R*sqrt(U)`。若直接 `R*U`，会更偏向圆心。],
  [21–26],
  [围绕真源布置多站：大致等角分布加扰动、距离
  500–1450m、站点坐标四舍五入；用 `atan2(source-station)` 算真示向。],
  [29–33],
  [加 ±1° 随机误差并四舍五入成两位小数；把圆周差折到
  \[−180°,180°)，若最终误差超过 1° 就重抽。],
  [34–38],
  [输出 seed、观测与仅用于本地核验的
  `local_truth`。注意“先限制误差、再量化”可能越界，因此前一步要对最终报告重查。],
  [39–41、43],
  [打印路径等信息；脚本直接执行时调用 main。],
)
]

== 5.2 Q2：安全第二站与最坏剩余不确定性
<q2安全第二站与最坏剩余不确定性>
本节所有 solver 定义在
`source/Q2/q2_solver.py`。它没有在线移动动作，也没有
HTTP；任务是给定首站/首报告，数值选择第二站。

=== 5.2.1 基础运算与坐标变换完整索引
<基础运算与坐标变换完整索引>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [定义与精确位置], [参数 → 返回], [用途],
  [`add`，`source/Q2/q2_solver.py:33-34`],
  [a,b → a+b。],
  [平移。],
  [`sub`，`source/Q2/q2_solver.py:37-38`],
  [a,b → a−b。],
  [边向量和相对坐标。],
  [`mul`，`source/Q2/q2_solver.py:41-42`],
  [向量 a、标量 k → ka。],
  [插值、圆心中点。],
  [`dot`，`source/Q2/q2_solver.py:45-46`],
  [a,b → 点积。],
  [半平面残差、投影、距离平方。],
  [`cross`，`source/Q2/q2_solver.py:49-50`],
  [a,b → 二维叉积。],
  [鞋带、转向、外接圆行列式、卡壳。],
  [`dist`，`source/Q2/q2_solver.py:53-54`],
  [a,b → 欧氏距离。],
  [包围圆及距离检查。],
  [`local_to_world`，`source/Q2/q2_solver.py:57-60`],
  [首站、首报告角、局部 a,b → 世界点。],
  [将局部坐标按首示向旋转，再加首站平移：`S1+a*u+b*v`。],
  [`candidate`，`source/Q2/q2_solver.py:403-405`],
  [基线 L、偏角 ψ、side\=1 → 局部站点。],
  [`(L cosψ, side*L sinψ)`。实际优化使用带正负号的 ψ，side 参数保持默认
  1。],
)
]

局部 x 轴沿首示向、局部 y 轴向左。第 25–30 行把误差半宽定为
1°，接收半径范围定为 1000–1500m，源场地半径定为 1800m，几何残差容差定为
(10^{-9})。首站不在原点时，源场地圆仍以世界原点为圆心，因此正负 ψ
两侧可能不再等价。

=== 5.2.2 安全域函数：公式就在这些行
<安全域函数公式就在这些行>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [定义与精确位置], [参数 → 返回], [保证的内容],
  [`_sector_max_distance_sq`，`source/Q2/q2_solver.py:63-77`],
  [局部站点 s、扇区半径 ρ、半宽 δ → 最大距离平方。],
  [求 `max ||s-r*u(eta)||²`，`0<=r<=ρ, abs(eta)<=δ`。],
  [`safe_full_information`，`source/Q2/q2_solver.py:80-88`],
  [s、δ、rmin → 布尔值。],
  [利用“首站已经收到”的信息，检测截到 rmin 的首测扇区是否都在
  `B(s,rmin)`。],
  [`safe_uniform_1000`，`source/Q2/q2_solver.py:91-94`],
  [s、δ、rmin、rmax → 布尔值。],
  [整个 1500m 首测扇区都离第二站至多
  1000m；这是更保守、统一使用最小接收半径的设计。],
  [`safe_angle_limit`，`source/Q2/q2_solver.py:97-111`],
  [固定 L、安全域名、δ、半径上下界 → 最大绝对偏角或 None。],
  [给外层一维站点搜索一个解析安全弧边界。],
)
]

`_sector_max_distance_sq` 展开平方为

$ parallel s minus r u lr((eta)) parallel^2 eq L^2 plus r^2 minus 2 r thin lr([a cos eta plus b sin eta]) dot.basic $

对固定 η，它是 r 的凸二次式，最大值在 r\=0 或 r\=ρ。第 69–75
行找角度区间上点积的最小值：检查两端，再检查与 s 反向的内部驻点
`psi+pi+2*pi*k`。第 77 行把 r\=0 的 `length2`
与外弧最坏值比较。因此这段不是用角度采样近似安全域，而是枚举解析极值位置。

`safe_full_information` 为什么只用 rmin？如果真实源距首站
r，首站收到说明真实接收半径至少为 `max(rmin,r)`。对 r\>\=rmin，要求
`||s-r*u||<=r` 等价于 `L²<=2r*s·u`；一旦 rmin 处满足，相关投影为非负，r
增大只使条件放宽。对 r\<\=rmin 则需覆盖整个短扇区。于是归结为第 88
行的检测。这个函数所称 exact
是对该未截场地的首测信息模型，不是利用世界场地边界后的最大安全域。

固定 L 后，最不利角度在离 s 最远的扇区边，得到：

$ lr(|psi|) lt.eq cases(delim: "{", arccos #h(-1em) lr((frac(L, 2 r_min))) minus delta comma & upright("full_information") comma, arccos #h(-1em) lr((frac(L^2 plus r_max^2 minus r_min^2, 2 L r_max))) minus delta comma & upright("uniform1000") dot.basic) $

对应第 103–111 行。第 101 行还要求
`0<L<=rmin`，因为扇区包含首站附近位置，过远站点无法对所有可能源统一保证接收。`ratio>1`
返回 None；负的剩余角宽压为 0。优化器随后拒绝 0
角宽，避免只能共线的候选。

=== 5.2.3 外接多边形与逐边裁剪
<外接多边形与逐边裁剪>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [定义与精确位置], [输入 → 输出], [关键操作与集合语义],
  [`circle_outer_polygon`，`source/Q2/q2_solver.py:114-121`],
  [圆心、半径、边数 → 外接正多边形。],
  [边数至少 24；顶点半径
  `radius/cos(pi/sides)`，顶点角度偏移半个角步长，使边到圆心距离恰为
  radius。],
  [`clip_halfplane`，`source/Q2/q2_solver.py:124-144`],
  [凸顶点序列、法向量、偏移 → 裁后顶点序列。],
  [按每条边是否跨越 `n·x=offset`
  增加交点与内侧端点，去除连续重复顶点。],
  [`clip_disk_outer`，`source/Q2/q2_solver.py:147-154`],
  [多边形、圆心、半径、边数 → 交圆外接多边形的结果。],
  [每个均匀方向 n 用 `n·x<=n·center+radius`
  作切线约束；空集后提前退出。],
  [`clip_wedge`，`source/Q2/q2_solver.py:157-166`],
  [多边形、站点、报告、δ → 与角楔的交。],
  [两个法向量与 Q1 相同，调用两次裁剪。默认 δ\=1°。],
  [`first_feasible_polygon`，`source/Q2/q2_solver.py:169-178`],
  [首站、首报告、δ、边数 → 首测可行域外包络。],
  [外接场地圆 → 外接首站 1500m 圆 → 首测角楔，按此顺序相交。],
  [`physical_base`，`source/Q2/q2_solver.py:278-279`],
  [首测多边形、第二站、边数 → 第二站 1500m 距离限制后的公共基底。],
  [与第二个报告无关，可以在内层搜索之前只算一次。],
  [`post_region`，`source/Q2/q2_solver.py:282-284`],
  [公共基底、第二站、第二报告、δ → 后验区域外包络。],
  [给公共基底增加第二个角楔。],
)
]

裁剪第 128–137 行先令 a
为最后一个点，以便自然处理“末点到首点”的闭边。边两端残差为
fa、fb，若内外判断不同，线性插值得到交点参数

$ t eq frac(f_a, f_a minus f_b) comma #h(2em) x eq a plus t lr((b minus a)) dot.basic $

它来自 `f(a+t(b-a))=(1-t)fa+t*fb=0`。随后只保留内侧 b；第 138–143
行清理相邻重复点和首尾重复点，避免后续产生零长度边。这里以 `fa<=EPS`
判内，但交点公式仍求精确零残差，因此 EPS
是浮点判别容差，不是整个多边形的严格符号区间证书。

圆一定要外接：内接多边形会错误排除靠近真实圆弧的可能源。外接多边形多保留了一些点，所以对某个已评价报告得到的
D/R/A 偏向保守。首测 `direction` 还隐含离站超过 5m，代码第 173–174
行明确不挖这个小内孔，以保留凸性并保持外包络。

=== 5.2.4 面积、直径与最小包围圆逐函数索引
<面积直径与最小包围圆逐函数索引>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [定义与精确位置], [参数 → 返回], [方法与关系],
  [`polygon_area`，`source/Q2/q2_solver.py:181-183`],
  [顶点序列 → 面积。],
  [鞋带公式；少于 3 点面积 0。],
  [`_diameter_circle`，`source/Q2/q2_solver.py:186-188`],
  [两点 → `(中点,距离/2)`。],
  [两个边界支撑点的最小圆。],
  [`_circumcircle`，`source/Q2/q2_solver.py:191-199`],
  [三点 → `(圆心,半径)` 或 None。],
  [平移到 a 附近后解等距方程；行列式小于 `1e-14` 视为共线。],
  [`minimum_enclosing_circle`，`source/Q2/q2_solver.py:202-235`],
  [非空点集 → `(圆心,审核后的半径)`。],
  [固定随机种子的增量最小包围圆，最终对所有原点重新取最大距离再加
  `1e-7`。],
  [`Metrics`，`source/Q2/q2_solver.py:238-243`],
  [D、R、A、顶点数 → 冻结数据对象。],
  [作为单个报告的几何指标，不包含最坏报告搜索。],
  [`_hull`，`source/Q2/q2_solver.py:246-255`],
  [点集 → 凸包。],
  [去重、排序、上下链；少于等于 2 点直接返回。],
  [`_hull.chain`，`source/Q2/q2_solver.py:249-254`],
  [单向点序 → 凸链。],
  [叉积 `<=1e-10` 弹出中间点，保持凸性。],
  [`polygon_diameter`，`source/Q2/q2_solver.py:257-270`],
  [点集 → `(直径,点对)`。],
  [对凸包作旋转卡壳；与 Q1 同原理，空集返回 `(0,None)`。],
  [`polygon_metrics`，`source/Q2/q2_solver.py:272-275`],
  [非空多边形 → `Metrics`。],
  [依次算直径、MEC 半径和面积。空集不能传到其中的 MEC。],
)
]

外接圆公式第 192–199 行：令 (u\=b-a,v\=c-a,o\=-a)，由到 a、b 等距得
(2ou\=|u|^2)，到 a、c 等距得 (2ov\=|v|^2)。解这个二元方程组，分母就是
`2*cross(u,v)`。平移是为了减轻用大绝对坐标平方相减的消减误差。

MEC 的非平凡部分不能简化成“逐点求外接圆”：

+ 第 204–208 行拒绝空输入，复制点序并用固定种子 20260911
  打乱。随机顺序为了增量算法效率，可复现种子不代表给测向误差赋概率。
+ 第 209–212 行若新点 p 已在当前圆内，无需变化；否则 p
  必須成为新圆的边界支撑点，先从零半径圆开始。
+ 第 213–218 行旧点 q 若在外，改成 p、q 为直径的圆，并固定这两个边界点。
+ 第 219–230 行，先只看该直径圆外的旧点 r；计算过 p、q、r 的外接圆，并按
  r 在 pq
  左/右分组。左侧保留圆心有向高度最大的候选，右侧保留最小的候选；这些是满足固定
  p、q 边界条件所需的极端圆。
+ 第 231–233 行从可用侧候选选半径较小者。共线三点没有唯一外接圆，返回
  None 后跳过。
+ 第 234–235 行最后不直接信任内部
  r，而是保留求出的圆心，重新算所有输入点到该圆心的最大距离并加微小裕量。这个半径能保证覆盖当前浮点顶点；它可能比理想精确
  MEC 半径大一点，审计不等于在浮点下形式化证明“全局最小”。

=== 5.2.5 内层最坏报告搜索：完整阅读 `robust_quality`
<内层最坏报告搜索完整阅读-robust_quality>
`RobustQuality` 在
`source/Q2/q2_solver.py:287-304`，保存三个独立最坏值、各自达到最坏值的报告、R
最坏时的整套 `Metrics`、搜索计数和精度参数。其 `as_dict()` 在
`source/Q2/q2_solver.py:301-304` 用 `asdict` 递归转字典，明确加
`continuous_report_maximum_certified=False`。

#strong[主函数 `robust_quality`：`source/Q2/q2_solver.py:307-400`。]
输入第二站，关键字参数包括首站/首示向/δ/圆边数/报告网格步长；返回
`RobustQuality`。它不修改任何机器人状态。

数学目标是对第二站 s 计算

$ hat(Q) lr((s)) approx max_(z colon P_2 lr((s comma z)) eq.not diameter) Q lr((P_2 lr((s comma z)))) comma quad Q in brace.l D comma R comma A brace.r dot.basic $

选择报告 z
后再求可行区域，保证“源位置与报告误差”相容；不能分别取一个最坏源和一个与它不相容的报告硬拼。代码中的
(P\_2)
是圆的外接多边形近似，所以非空可行性也针对外包络，会多接纳一些边缘报告。

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [行段], [操作], [数学/工程理由],
  [318–320],
  [建首测集合、第二站物理距离基底与缓存。],
  [距离约束不随报告改变，重复使用。],
  [322–331],
  [内部 `evaluate(z)`：将角度 `%360` 后四舍五入到 10
  位作键；命中缓存则返回；否则裁角楔，空集返回
  None，非空算指标并缓存。],
  [合并 0°/360°
  等价方向，节约三个目标共同搜索的重复开销。空集结果没有写入缓存。],
  [333–344],
  [令 `count=ceil(360/report_step)`，均匀取 `z=i*360/count`；非空记录在
  `records` 和 `coarse`，空值仍在 coarse 中占位置。],
  [真实网格间距是
  `360/count`，不一定恰等于参数值；保留空槽才能看相邻方向是否可行。],
  [345–346],
  [一个可行网格报告都没找到则抛错。],
  [这是当前有限网格没有结果，不是连续报告域为空的正式证明。],
  [351–367],
  [对 R、D、A
  各自找粗网格局部极大：邻居不可行按负无穷处理；没有候选时取当前记录最大点作备用。],
  [三个指标最坏位置可以不同，要分别细化。],
  [368–370],
  [只取数值最大的 8 个局部峰，在左右各一个网格间距范围内细化。],
  [控制计算成本；没有证明其他未选峰不含更高连续峰。],
  [372–374],
  [内部 `field_value(z)`，从 evaluate 取当前指标；空集合回负无穷。],
  [把带可行性判断的问题转为有界标量最大化。],
  [376–387],
  [黄金比例取 c,d，比较 fc,fd，保留较大值一侧，重复 34 次。],
  [重用一个内部评价，减少调用；该方法对单峰区间最有依据，此处没有证明每个区间单峰。],
  [388–391],
  [将细化后 5 个位置中的可行值追加到 `records`。],
  [最终最大值从 records 里选。细化过程中的其他缓存评价并非全部追加到
  records。],
  [393–400],
  [分别取 records 中的 R/D/A 最大行，组装返回值。],
  [`metrics_at_worst_R` 中的 D/A 是 R 最坏报告处的
  D/A，不必等于全报告最坏 D/A。],
)
]

内部函数的精确范围是 `source/Q2/q2_solver.py:322-331`（`evaluate`）与
`source/Q2/q2_solver.py:372-374`（`field_value`）。

#strong[容易被问住的输出口径：] `feasible_report_count=len(records)`
可以包含重复追加的报告；`report_evaluations=len(cache)`
只数不同键的非空缓存，不包括每次空集尝试，也不等于所有 evaluate
调用次数。参数 `refine_step_deg`
虽在签名和调用中出现，但函数体没有读取它；真正细化轮数固定为
34，不能说它控制了最终步长。

圆外近似对一个给定报告的 D/R/A
是保守的，#strong[并不能推出有限报告最大值是连续最坏值的上界]。报告漏采样可能低估峰值；圆多保留位置可能高估指标；两种方向的误差不能自动互相抵消。

=== 5.2.6 外层选站与主入口逐段精读
<外层选站与主入口逐段精读>
#strong[`optimize_fixed_baseline`：`source/Q2/q2_solver.py:408-469`。]
输入目标名 `R/D/A`、基线
L、首测信息、安全域、搜索精度；返回最佳被评价候选的站点坐标、ψ、质量与数值范围说明。

#align(center)[#table(
  columns: 2,
  align: (col, row) => (auto,auto,).at(col),
  inset: 6pt,
  [行段], [状态/分支与原因],
  [416–421],
  [校验目标；算安全角极限；没有非共线安全弧则报错；选择 uniform1000 或
  full\_information 安全判定器。],
  [424–425],
  [内部 `score(q)` 将目标字母映射到对应最坏值；精确函数范围为
  `source/Q2/q2_solver.py:424-425`。],
  [430–441],
  [对负、正两侧分别粗搜。从 `max(0.2,coarse_psi_deg)` 开始，每步加
  coarse；每个点先验安全，转世界坐标，再调用 robust\_quality。保存
  `(score,psi,q)`。],
  [442–456],
  [每侧单独找最佳粗点，在其前后一个 coarse 宽度内用 fine
  步长再搜；将范围夹到安全弧，且与 0° 至少隔 0.05°。],
  [457–461],
  [无候选则报错；从两侧所有被评价点取最小分数，再计算最终局部/世界坐标。],
  [462–469],
  [返回候选数、最优被评价值及
  `continuous_global_optimum_claimed=False`。],
)
]

"两側搜索"很关键：若首站位于世界原点，首测扇区与场地圆关于首示向对称，则两侧可能等价；首站平移后，世界场地截断通常破坏这种对称。第
430 行明确搜两侧，不能口述成只搜左边再镜像。

`final_quality` 在
`source/Q2/q2_solver.py:472-477`：给已选定第二站换更细圆边数和报告网格，再调用
`robust_quality`、转字典；它不重新优化 ψ 或基线。其签名没有 δ 参数，使用
robust\_quality 默认 1°。

`solve_case` 在 `source/Q2/q2_solver.py:481-519`：

+ 第 482–485 行读取首站、首示向和基线列表；默认基线
  600、700、800、900、1000m。
+ 第 486–489 行选择 quick/常规精度：搜索圆边数 72/96，报告步长
  2°/1°，外层 coarse 2°/1°，fine 0.25°/0.1°。
+ 第 491–499 行分别以 D 和 R 为目标遍历全部基线；某基线 `ValueError`
  时跳过。A 可由底层优化器单独使用，但这个入口不优化 A。
+ 第 500–502 行要求至少有候选，并分别选 D 方案和 R 方案。
+ 第 503–513 行用更细的 180/360 边、0.5°/0.2°
  报告网格复评这两个固定方案。`meets_20m_on_evaluated_reports`
  字段精确地只说“已评价报告上 R\<\=20m”。
+ 第 514–519 行输出比较表和所有基线搜索摘要，固定主方法为
  R。输入里的额外真值不会读取，输入自带其他误差字段也不改变此处固定
  `DELTA_DEG=1` 的模型。

`main(argv=None)` 在
`source/Q2/q2_solver.py:521-536`，解析输入/输出/quick，读 JSON，调用
solve\_case，创建目录，写 JSON，打印两套方案和第二站坐标。第 538
行触发脚本入口。

完整执行顺序是：`main → solve_case → 对每个目标和L调用 optimize_fixed_baseline → 对每个安全ψ调用 robust_quality → 对每个报告调用 post_region/polygon_metrics → 选站 → final_quality复评 → 输出`。内层是最大化，外层是最小化，这就是该实现的
minimax 结构；这里的 max/min 都受有限搜索范围约束。

=== 5.2.7 Q2 生成器
<q2-生成器>
`main()` 在 `source/Q2/q2_generator.py:6-34`，第 35 行是脚本入口。

#align(center)[#table(
  columns: 2,
  align: (col, row) => (auto,auto,).at(col),
  inset: 6pt,
  [行段], [输入/操作/输出],
  [7–12],
  [解析 seed/output，记录可复现 seed，并创建独立 Random。],
  [14–17],
  [采样距原点 0–450m 的首站，再在其周围 450–1400m
  采样源。这里首站半径是均匀分布，不是面积均匀采样。],
  [18–21],
  [若源离场地原点超过 1750m，把它径向缩回
  1750m，再算首站到最终源的真方位。],
  [22–25],
  [加误差、两位小数量化，并对最后圆周误差重查，保证生成报告仍在 ±1°
  内。],
  [26–30],
  [保存首站、首报告、基线候选和 `local_truth`；不保存第二站答案。],
  [31–34],
  [打印 seed、首测与输出位置。],
)
]

== 5.3 Q3：全向源在线发现、集合定位与清除
<q3全向源在线发现集合定位与清除>
以下核心代码的位置同时适用于 `source/Q3/q3_local_solver.py` 和
`source/Q3/q3_official_solver.py`，它们的前 502
行逐字相同。表中以本地文件给出 `file:line`，正式代码按同一行号查找。Q3
将机器人动作藏在 `api` 接口后面；几何计算本身不接触真值。

=== 5.3.1 几何小函数与保守量
<几何小函数与保守量>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [定义与精确位置], [参数 → 返回], [调用与不变量],
  [`add`，`source/Q3/q3_local_solver.py:12`],
  [a,b → a+b。],
  [构造世界点、插值、圆心。],
  [`sub`，`source/Q3/q3_local_solver.py:13`],
  [a,b → a−b。],
  [相对方向与边向量。],
  [`mul`，`source/Q3/q3_local_solver.py:14`],
  [a,s → sa。],
  [缩放位移。],
  [`dot`，`source/Q3/q3_local_solver.py:15`],
  [a,b → 点积。],
  [残差、二次交点系数、投影。],
  [`cross`，`source/Q3/q3_local_solver.py:16`],
  [a,b → 叉积。],
  [转向、凸包、外接圆。],
  [`norm`，`source/Q3/q3_local_solver.py:17`],
  [向量 → 长度。],
  [`hypot(*a)` 将二元组拆成两个实参。],
  [`dist`，`source/Q3/q3_local_solver.py:18`],
  [两点 → 距离。],
  [路程、覆盖与清除判定。],
  [`unit`，`source/Q3/q3_local_solver.py:19-21`],
  [向量 → 单位向量。],
  [太短时返回
  `(1,0)`，避免除零；侧移方向在圆心与当前位置几乎重合时仍确定。],
  [`maxdist`，`source/Q3/q3_local_solver.py:22-23`],
  [点 p、凸包顶点 → 最大顶点距离，空集为 0。],
  [距离是凸函数，所以最大值可由顶点控制整个凸包。空集默认值只是工具约定，主流程会另行拒绝空可行域。],
  [`hull`，`source/Q3/q3_local_solver.py:25-35`],
  [点集合 → 凸包。],
  [字典序去重、构造上下凸链，非左转时弹栈；用于无信号后的凸松弛。],
  [`clip`，`source/Q3/q3_local_solver.py:37-56`],
  [多边形、n、b → 与半平面的交。],
  [与 Q2 同样逐边裁剪，但第 40 行先把 b 增加
  `EPS*max(1,norm(n))`；各边交点仍按残差线性插值。],
  [`arena_polygon`，`source/Q3/q3_local_solver.py:58-61`],
  [sides\=48 → 场地圆的外接正多边形。],
  [顶点半径 `1800/cos(pi/sides)`，保持源集合包含真实场地。],
)
]

第 7–10 行的 `DELTA=radians(1.0051)` 包含物理 1°、两位小数报告的 0.005°
量化裕量与 0.0001° 数值保护。代码计算用弧度，API 接收/返回的 `svd_deg`
用度，入口处有显式转换。

`clip` 第 43–49 行跨边相交的参数是 `fa/(fa-fc)`，原理与 Q2 一样；第
50–55 行去重。由于阈值先加到 b
中，裁的是略向外扩的半平面。法向量通常是单位向量；`max(1,norm(n))`
保证在更大法向量尺度下也有相应保护。

=== 5.3.2 正观测更新为什么是一个三角形外包络
<正观测更新为什么是一个三角形外包络>
#strong[`bearing_update`：`source/Q3/q3_local_solver.py:63-76`。]
输入当前 `poly`、站点 p、报告角；输出裁过后的凸多边形。

第 68 行取
`R=min(1500,maxdist(p,poly)+EPS)`：既不超过物理最大接收距离，又利用旧可行域收紧距离上界。第
69–74 行裁两个角楔边界；第 75–76 行再裁 `u·(x-p)<=R`。

为何不直接求圆弧交？任意真实源满足 `||x-p||<=R`，必有
`u·(x-p)<=R`；后者是圆的一个支撑半平面，和两条角楔边围成前向三角形。它比真实圆扇区稍大，但裁剪快且始终保留真实源。

把 p 放在原点，u 当 x 轴，三角形顶点是

$ lr((0 comma 0)) comma quad lr((R comma R tan delta)) comma quad lr((R comma minus R tan delta)) dot.basic $

令圆心为 `(h,0)`，使它到原点与角点等距，有

$ h^2 eq lr((R minus h))^2 plus R^2 tan^2 delta arrow.r.double h eq frac(R, 2 cos^2 delta) dot.basic $

所以一次正观测至少给出一个半径约 `0.500154R`
的可覆盖圆。这个公式实际出现在 `Strategy._observe` 第 305
行，不只存在于文字证明中。首个 `R<=1500`，因此覆盖半径小于
751m，是后续移动到圆心仍在 1000m 保证接收范围内的依据。

=== 5.3.3 无信号不是“没有源”，而是安全排除一块区域
<无信号不是没有源而是安全排除一块区域>
#strong[`exclude_disk_hull`：`source/Q3/q3_local_solver.py:78-98`。]
输入当前凸区域 P、测站 c、可排除圆半径；返回

$ "conv" #scale(x: 120%, y: 120%)[paren.l] P backslash B^compose lr((c comma r)) #scale(x: 120%, y: 120%)[paren.r] $

的保守浮点构造。Q3 的源全向，接收半径至少 1000m，因此某频道在 c
无信号，若该频道确有尚未清除的源，它不在保证接收的 1000m
范围内。取凸包会把一部分已排除区域重新填回来，但仍不会把真实源错误删掉。

#align(center)[#table(
  columns: 2,
  align: (col, row) => (auto,auto,).at(col),
  inset: 6pt,
  [行段], [具体操作与理由],
  [83–85],
  [空集原样返回；排除半径减少 `1e-5`，保留圆外的原顶点，并再放宽
  `1e-6`。],
  [86–90],
  [遍历每条边，写作 `a+t*d`，令 f\=a−c；与圆交点满足
  `A*t²+B*t+C=0`，其中 A\=d·d，B\=2f·d，C\=f·f−r²。],
  [89、91–93],
  [零长度边跳过；判别式负则不相交；否则安全开平方。],
  [94–97],
  [两个根若在略放宽的 \[0,1\] 内，夹回该区间并加入边圆交点。],
  [98],
  [对“留下的原顶点 + 边圆交点”取凸包。],
)
]

为什么只取这些点？去掉开圆后，原多边形的外边界仍由原顶点和边上的圆交点控制；朝向洞的圆弧对凸包贡献的是弦，取凸包无需保留曲线洞。若无信号发生在尚未发现的频道，策略只保存负观测，首次正观测后再对紧区域批量应用这些排除，避免对整个场地反复作较松的凸化。

#strong[`inside_polygon`：`source/Q3/q3_local_solver.py:100-107`。] 参数
p、poly、tol；返回是否在多边形内。空集
False，点集合比较距离，线段用投影参数与垂距，普通凸多边形检查每条有向边的左侧。当前默认策略没有直接调用它；它是供本地审计等用途的辅助函数，不是每次
HTTP 观测都会执行的真值检查。

=== 5.3.4 包围圆与最近认证清除位置
<包围圆与最近认证清除位置>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [定义与精确位置], [参数 → 返回], [要点],
  [`_diameter`，`source/Q3/q3_local_solver.py:109-110`],
  [a,b → 中点圆。],
  [固定两个边界支撑点。],
  [`_circum`，`source/Q3/q3_local_solver.py:111-117`],
  [a,b,c → 外接圆或 None。],
  [平移求二元等距方程，`abs(D)<1e-18` 判近共线。],
  [`_in`，`source/Q3/q3_local_solver.py:118`],
  [circle,p → 布尔值。],
  [距离不超过内部半径加 `1e-9`，只用于增量构造。],
  [`mec`，`source/Q3/q3_local_solver.py:120-146`],
  [非空顶点 → 圆心、审核半径。],
  [固定种子 271828 打乱；p/q/r 三层增量构造和两侧极值圆与 Q2
  相同；最终返回 `maxdist(c,points)+1e-6`。],
  [`nearest_certified_clear`，`source/Q3/q3_local_solver.py:148-154`],
  [当前位置 p、覆盖圆 c/r、clear\_r\=19.8 → 最近的认证清除点。],
  [将 p 投影到圆盘 `B(c,19.8-r)`；r 太大则报错。],
)
]

MEC 第 127–143 行依次处理“新点已覆盖”"强制 p 为边界""强制 p,q
为边界""左/右极端三点圆"。第 144–146
行独立重新计算最大距离：真实源在顶点凸包内，因此这个审核半径才是清除证书使用的半径。

最近清除点公式：若 `slack=19.8-r<0`，还不能认证；若当前位置已满足
`||p-c||<=slack`，不必移动；否则返回

$ q eq c plus frac(19.8 minus r, parallel p minus c parallel) lr((p minus c)) dot.basic $

由三角不等式，对任意可能源
g，`||q-g||<=||q-c||+||c-g||<=19.8<20`。这是当前覆盖圆给出的充分条件集合中的最近点；代码没有声称它是所有实际可清除位置中的绝对最近点。

=== 5.3.5 连续覆盖证书：为什么不是网格检查
<连续覆盖证书为什么不是网格检查>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [定义与精确位置], [输入 → 输出], [调用关系与含义],
  [`arc_covered_by_disk`，`source/Q3/q3_local_solver.py:156-166`],
  [目标圆 c/R、覆盖圆 s/r → 若干 \[0,2π\] 角区间。],
  [求目标圆周上被覆盖圆覆盖的部分。],
  [`merge_intervals`，`source/Q3/q3_local_solver.py:168-173`],
  [角区间列表 → 排序合并后的区间。],
  [相交/相接间隔合并，用微小阈值处理舍入。],
  [`interval_subset`，`source/Q3/q3_local_solver.py:175-185`],
  [目标区间与覆盖区间 → 布尔值。],
  [合并覆盖区间，然后逐目标从左往右推进覆盖游标。],
  [`covers_arena`，`source/Q3/q3_local_solver.py:187-205`],
  [测站列表、radius\=999 → 布尔值。],
  [检查整个场地边界，以及每个检测圆在场地内的暴露圆弧。],
  [`ring_sites`，`source/Q3/q3_local_solver.py:207-212`],
  [外围点数 m、旋转角 phi、顺逆时针 → m 个外围点。],
  [默认函数参数 m\=7，但提交 `Config.ring_m=8`；此函数不返回原点。],
)
]

`arc_covered_by_disk` 第 158–160
行处理同心、全覆盖、相离/内含不交。一般情况第 161–162
行由余弦定理求覆盖半角：

$ alpha eq arccos frac(d^2 plus R^2 minus r^2, 2 d R) comma #h(2em) d eq parallel s minus c parallel dot.basic $

`max(-1,min(1,...))` 防止舍入让 acos 的参数落到定义域外。中心角用
atan2。第 163–166 行若区间跨过 0，就拆为两段，避免直接比较负角与正角。

`interval_subset` 的 x 是“当前目标区间已经被连续覆盖到哪里”。覆盖区间在
x 左侧就跳过；下一区间左端超过 x 就出现空洞，停止；否则推进
x。目标终点前仍有空洞即 False。

`covers_arena`：

+ 第 192–194 行去掉几乎重合的测站，避免相同圆彼此制造无意义边界关系。
+ 第 195–197
  行检查场地圆周的整圈都被检测圆覆盖。只做这一步不够，圆内仍可能有孔洞。
+ 第 198–204
  行对每个检测圆，求它处在场地内的那段圆周，再要求该段都被其他检测圆覆盖。若存在一个未覆盖内孔，它的边界必然含某检测圆的场地内暴露弧；此检查排除这样的孔洞。
+ 全部通过才 True。radius\=999m 留了 1m
  接收裕量，这个检查没有用有限空间网格替代连续圆弧。

`ring_sites` 第 210
行的站点半径来自相邻外围站服务的场地边界中点。令场地半径 A\=1800、半角
β\=π/m、接收设计半径 r\=995，解

$ a^2 minus 2 A a cos beta plus A^2 eq r^2 $

取较小根，代码再加 1m。m\<6
被拒绝，是为了根号内部及覆盖几何的要求。函数注释“Origin plus m outer
sites”描述整体方案；实际返回值只含外围 m 点，原点在 `Strategy.run:471`
单独扫描。

=== 5.3.6 接口、配置和每频道状态
<接口配置和每频道状态>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [类与精确位置], [字段/契约], [对算法的作用],
  [`Actions`，`source/Q3/q3_local_solver.py:224-226`],
  [`measure(position,channel)->dict`（225）；`clear(position,channel)->dict`（226）。],
  [`Protocol` 描述所需接口；本地 Simulator 和正式 OfficialClient
  都提供这两个方法，无需读取隐藏字段。方法体 `...` 是接口占位。],
  [`Config`，`source/Q3/q3_local_solver.py:228-254`],
  [不可变策略参数。],
  [主流程用 `Config()`，没有在正式入口覆盖研究参数。],
  [`Track`，`source/Q3/q3_local_solver.py:256-265`],
  [每个频道的可变状态。],
  [`field(default_factory=...)` 给每个频道创建独立多边形和负观测列表。],
  [`Strategy`，`source/Q3/q3_local_solver.py:267-498`],
  [api、配置、20 个 Track、位置/频道/时间、覆盖与调度状态。],
  [所有在线决策集中在此类，几何辅助函数不发送动作。],
)
]

Config 默认值逐项解释：

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [精确行号], [值], [实际用途],
  [238–240],
  [`ring_m=8, offset=.10, insert_m=600`],
  [原点加 8 外围点；定位点侧移 0.1R；服务插入评分阈值 600m。],
  [241–244],
  [`negative/opportunistic/opportunistic_clear=True, mode='integrated'`],
  [使用负观测；扫描停靠点与服务结束点可复用已知频道；按绕路成本插入服务。],
  [249–254],
  [`incidental=False, scan_spacing=500, scan_policy='distance', prune=False, rotate=False, speculative_r=0`],
  [研究/对照分支默认关闭；不新增偶遇全扫描、不删固定覆盖点、不自适应旋转、不试探性清除。],
)
]

Track 第 258–265 行：`status` 默认 UNKNOWN；`poly`
初始场地外包络；`negatives` 记录 `(位置,排除半径)`；`center/radius` 初始
`(0,0)/inf`；`last`
是#strong[上次正方向观测位置]，不是所有类型观测的最后一次；`bearing`
保存那次报告；`measurements` 只对 direction 累加，不等于 API
总测量次数。

`Strategy.__init__` 在 `source/Q3/q3_local_solver.py:268-275`：构造频道
1–20，初始机器人位置原点、测向频道 1、时间 0；`scans`
是完成全未知频道扫描的点，`pending`
是将访问的外围站点，`coverage_done/search_reason`
是发现结束状态；另记录动作数、覆盖检查数、最大多边形顶点数、最大单源定位步数和计划是否建立。

`Strategy._audit` 在 `source/Q3/q3_local_solver.py:277-279`：更新
`max_vertices`，若调用方提供 audit
回调，再把频道、Track、当前位置交给回调。默认 `run_case(api)`
没有回调，正式策略不会因此获得真值。

=== 5.3.7 一次观测如何改变 Track：`_observe`
<一次观测如何改变-track_observe>
#strong[位置：`source/Q3/q3_local_solver.py:281-311`。] 输入频道
i、请求位置 p；返回测量结果字符串。它是副作用方法：调用
API、移动策略当前位置、改当前频道/虚拟时间/动作计数，并依结果更新该频道。

#align(center)[#table(
  columns: 2,
  align: (col, row) => (auto,auto,).at(col),
  inset: 6pt,
  [行段], [分支与准确语义],
  [282–286],
  [发 `api.measure(p,i)`；accepted
  假则报错。只有接受后才更新本地位置、测向频道、动作数与模拟器返回时间。],
  [287–293],
  [`no_signal`：总是保存 `(p,1000)`；如果已经 FOUND 且 negative
  开启，则排除保证接收圆并取凸包，再算
  MEC；若空集立即报“模型/观测不一致”。UNKNOWN
  阶段只保存，不立刻裁初始大多边形。],
  [294–295],
  [`near`：调用同点认证 `_clear`。近距离阈值 5m 小于清除半径
  20m，无需继续求角楔。],
  [296–303],
  [`direction`：标记 FOUND，记录
  last/bearing，增加正方向计数；保存裁剪前可用距离上界，裁正角楔；再重放所有历史负观测；非空才计算
  MEC。],
  [304–308],
  [用上节推导的三角形圆心 h 作第二个候选，再对当前 poly 算实际覆盖半径
  tr。如果比 MEC 实现返回半径更小，就采用此候选。],
  [309–311],
  [调 audit；未知结果类型报错；正常返回结果字符串。],
)
]

第 305
行那个独立圆并不是“再估计一个真源坐标”。它给出一个可以逐顶点审计的覆盖证书，即便增量
MEC
受数值误差影响，仍有解析三角形结构可以利用。负观测重放后集合只会更小，所以该圆继续覆盖。

=== 5.3.8 清除动作、覆盖停止与扫描复用
<清除动作覆盖停止与扫描复用>
#strong[`_clear`：`source/Q3/q3_local_solver.py:313-326`。]
输入频道、位置、是否有证书；返回是否清除成功，并更新位置/时间/动作/频道
Track 状态。

- 314–319：发动作，校验 accepted，成功就标记
  CLEARED、清除计数加一。这里不修改
  `self.channel`，因为清除不会改变接收机当前测向频道。
- 320–321：未知 clear\_result 报错；如果有证书却返回
  `no_target_in_range`，直接报错，不把失败当成成功或无事发生。
- 322–326：只有显式的研究性非认证清除失败，才添加 `(p,20)`
  负观测、排除清除圆、更新 MEC 并返回
  False。默认配置不会主动进入试探清除分支。

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [方法与精确位置], [输入/输出/状态], [分支与选择理由],
  [`_coverage`，`source/Q3/q3_local_solver.py:328-330`],
  [测站列表 → bool；覆盖检查数加一。],
  [包装 `covers_arena`，方便记录几何证书成本。],
  [`_certify_and_prune`，`source/Q3/q3_local_solver.py:332-351`],
  [无显式参数；更新 coverage\_done、pending、search\_reason、UNKNOWN
  状态。],
  [已完成则返回；已发现/清除 16
  源，用题设上限终止搜索；否则尝试连续圆并覆盖证书；prune
  研究分支只在剩余点仍能保证覆盖时删未来站。],
  [`_scan`，`source/Q3/q3_local_solver.py:353-361`],
  [一个位置；无返回值。],
  [提取所有 UNKNOWN 频道，当前接收频道优先，依次观测；加入
  scans；机会复用 FOUND 频道；尝试结束发现。],
  [`_sweep_found`，`source/Q3/q3_local_solver.py:363-369`],
  [停靠点 p；无返回值。],
  [只处理 FOUND、半径尚大于 19.8、已有正观测的频道；离上次正观测至少
  25m，且整个可行域距 p 不超过 999m，才在此点补测。],
)
]

`_certify_and_prune` 的第 334 行是
`==16`，用的是源数#strong[上限]，不是假定每局恰好 16
个。发现到上限意味着余下 UNKNOWN 必为空；若只发现 10–15
个，必须靠覆盖证据。第 339–343 行只有 `covers_arena(scans)` 成功才把其他
UNKNOWN 标 ABSENT。第 344–351 行的 prune
默认关闭；它试删一个点，再检验已扫点加未来点的并是否仍覆盖，是可行性保护下的贪心删点，不是路径全局最优算法。

复用规则的 999m 在 Q3 意味着必然有信号，避免为获取方向又丢失接收。25m
最小基线是减少同位置/短基线冗余的启发式，不是 25m
以上每次就增加固定信息量的定理。

=== 5.3.9 规划、定位点和单源服务
<规划定位点和单源服务>
#strong[`_make_plan`：`source/Q3/q3_local_solver.py:371-394`。] 默认设置
`phi=0,clockwise=False`，用 Config 的 m\=8 生成外围路线，置
`_plan_ready=True`，尝试覆盖认证。若之前已按源数结束发现，则 pending
为空。

第 377–391 行是默认关闭的旋转研究分支：根据已有 FOUND 的报告角，枚举 0
或半角偏移、顺逆时针；对每个已发现源找最近环点，以
`0.12*k*norm(site0)+distance`
累加打分。这个分数把较晚访问的环点与距离一起惩罚，是有限候选启发式，不能声称
minimax 最优或 2-opt。

#strong[`_tracking_point`：`source/Q3/q3_local_solver.py:396-407`。]
参数 Track 与下一覆盖站（可为 None）；返回下一定位/清除位置。

+ 已 `r<=19.8`，直接返回最近认证清除点。
+ 取当前位置到圆心的单位方向 d，再转 90° 得 v；候选为 `c±0.1r*v`，offset
  为 0 时只取 c。
+ 第 403 行逐候选检查当前多边形的最大距离
  `<=999`；没有可用侧移点就退回圆心。第一正观测的圆小于
  751m，使默认策略的圆心回退具备接收依据。
+ 无下一站时选择最近候选；有下一站时最小化
  `当前位置距离 + .15*到下一站距离`。0.15
  是移动启发式权重，不是物理常量。

侧移的作用是改变观测几何，同时不破坏距离保证。若新测站 q 到旧圆心至多
0.1r，则旧区域到 q 的距离至多 1.1r；一次正观测三角形包围半径至多约
`1.1r/(2cos²δ)≈.55017r`。这个收缩解释了为什么不用一直在同一站重复测量；程序没有依靠误差独立、零均值或平均抵消。

#strong[`_serve`：`source/Q3/q3_local_solver.py:409-434`。] 输入某 FOUND
频道和下一覆盖站；无显式返回，持续更新该 Track，直到清除或异常。

#align(center)[#table(
  columns: 2,
  align: (col, row) => (auto,auto,).at(col),
  inset: 6pt,
  [行段], [执行内容与不变量],
  [410–415],
  [单源循环；最多 18
  个定位步；若半径达到证书阈值，算最近安全清除点并清除。],
  [416–418],
  [仅 speculative\_r\>0 且半径够小时允许试探清除，默认关闭。失败由
  `_clear(...,False)` 作负约束。],
  [419–426],
  [算定位点、保存旧半径、观测、步数加一。保证接收点却 no\_signal
  是不变量失败；direction 后半径仍大于 `0.9*oldr+1e-3` 也报错。],
  [427–430],
  [记录最大步数；在服务终点复用其他 FOUND
  频道；重新检查发现是否可结束。],
  [431–434],
  [incidental 研究开关启用时，可能在服务终点新增一次全部 UNKNOWN
  扫描；主策略关闭。],
)
]

0.9 不是理论收缩因子的推导值；它是留有余量的运行时上界检查。18
也不是函数每次必须测 18 次，而是异常保护上限。

=== 5.3.10 调度研究分支与主循环
<调度研究分支与主循环>
`_worth_extra_scan` 在
`source/Q3/q3_local_solver.py:436-452`，返回是否值得一次研究性额外全扫描，只在
`incidental=True` 时可从 `_serve` 到达。

- 438–439：distance 策略只检查当前位置离所有已扫站至少 scan\_spacing。
- 440–446：另一种分支尝试把当前位置加入已扫站后，贪心删去仍可省掉的未来站；一个也省不掉则
  False。
- 内部 `length` 位于 `source/Q3/q3_local_solver.py:447-448`，用
  `zip([self.p]+sites,sites)` 配对相邻路段求路径长度。
- 449–452：省去路径距离除以速度 5，得到节时代理；UNKNOWN 频道数 q
  的扫描费用上界约 6q 秒，加 5 秒裕量，只有节时更大才做。

`_choose` 在 `source/Q3/q3_local_solver.py:454-468`，输入下一站或
None，返回待服务频道或 None。无 FOUND 直接 None。没有下一覆盖站或
`mode='sequential'` 时，以到圆心距离加半径评分；`mode='deferred'`
且还在发现阶段则不插入；默认 integrated 时评分为

$ underbrace(parallel p minus c parallel plus parallel c minus s_(n e x t) parallel minus parallel p minus s_(n e x t) parallel, upright("经圆心绕路增加量")) plus r dot.basic $

半径 r 惩罚服务还可能偏离圆心的剩余不确定性。最小评分不超过 600m
才插入，不然先去下一覆盖站。该函数没有 `heapq`、动态规划或 TSP
精确求解器，每次直接扫当前 FOUND 列表取最小值。

#strong[`run`：`source/Q3/q3_local_solver.py:470-498`。]
真正在线主循环：

#align(center)[#table(
  columns: 2,
  align: (col, row) => (auto,auto,).at(col),
  inset: 6pt,
  [行段], [先后次序与结束依据],
  [471],
  [先扫原点，再建立外围路线；最初原点扫描所得信息可用于研究性旋转，但默认不旋转。],
  [472–478],
  [主循环计数，上限 1000 轮/5000 动作保护；已清除 16
  个则按源数上限结束。],
  [479–481],
  [重新计算 FOUND/UNKNOWN
  列表；两者都空，说明所有频道已清除或有不存在证据。],
  [482–487],
  [看下一 pending 站；若 `_choose`
  给频道，则服务；否则弹出并扫描下一站。],
  [488–492],
  [路线没有剩余但仍 UNKNOWN
  时，必须再做认证；缺证书报错，不能仅因“走完若干点”就假称全清。],
  [493–498],
  [输出清除数、虚拟时间、每源时间、动作/扫描/证书检查数、最复杂几何与定位步数、各频道状态。],
)
]

字段 `coverage_certified` 只在 `search_reason=='disk_union'` 时
True。若按发现 16
个结束，`search_certificate='cardinality'`，coverage\_certified 为 False
并不意味着任务没有完成证据，而是证据种类不同。每源时间分母为成功清除数，为零则
None。

`run_case(api,audit=None)` 位于
`source/Q3/q3_local_solver.py:501-502`，只创建
`Strategy(api,Config(),audit)` 并
`.run()`；正式副本相同行号也是这个入口。它不加载历史结果，也不读取源列表。

=== 5.3.11 Q3 本地模拟器：隐藏环境在哪里
<q3-本地模拟器隐藏环境在哪里>
以下文件为 `source/Q3/q3_local_simulator.py`，它第 6 行只导入本地
solver。

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [类/函数与精确位置], [参数、返回和状态], [精读],
  [`Source`，`source/Q3/q3_local_simulator.py:8-10`],
  [channel、position、radius、phase 的冻结记录。],
  [隐藏源真值仅在模拟器一侧持有。],
  [`Simulator`，`source/Q3/q3_local_simulator.py:12-34`],
  [提供 measure/clear 的环境对象。],
  [不通过返回值暴露真位置/半径/误差相位。],
  [`Simulator.__init__`，`source/Q3/q3_local_simulator.py:13-15`],
  [sources、seed → 建对象。],
  [按频道建立源字典、空清除集合、原点位置、频道1、时间/里程/测量/换台/失败计数；seed
  被保存，本误差函数不在每次测量用它重抽。],
  [`Simulator._move`，`source/Q3/q3_local_simulator.py:16-17`],
  [新位置 p → 无返回。],
  [先累计距离与 `距离/5` 秒，再改变当前位置。],
  [`Simulator._error`，`source/Q3/q3_local_simulator.py:18-19`],
  [源、站点 → \[−1°,1°\] 误差。],
  [0.62#emph[sin 与 0.38]cos
  的位置相关组合，再夹界；同一源同一站点误差相同，不是每次独立噪声。],
  [`Simulator.measure`，`source/Q3/q3_local_simulator.py:20-29`],
  [p、频道 → accepted/时间/结果字典。],
  [移动、加5秒测量、换频道另加1秒；源不存在/已清除/超接收范围则无信号；5m内
  near；否则真角+误差并量化为两位小数。],
  [`Simulator.clear`，`source/Q3/q3_local_simulator.py:30-34`],
  [p、频道 → accepted/时间/clear\_result。],
  [移动后检查未清除真源是否在20m内；成功加5秒并标记，失败加3秒；不改变接收频道。],
  [`make_case`，`source/Q3/q3_local_simulator.py:36-41`],
  [seed → Source 列表。],
  [均匀取整数源数10–16，无放回选频道；圆内按面积均匀源位置；半径1000–1500，独立误差相位。],
  [`_average`，`source/Q3/q3_local_simulator.py:43-62`],
  [多局结果 → 汇总字典或 None。],
  [同时算逐局等权与合并源数加权每源时间、各项均值和四部分时间。第45行
  sources 局部变量没有用于后续返回。],
  [`_print_average`，`source/Q3/q3_local_simulator.py:64-76`],
  [标题、汇总 → 打印，无返回。],
  [avg 为 None 则不输出；两个每源时间都展示，便于避免统计口径混淆。],
  [`main`，`source/Q3/q3_local_simulator.py:78-118`],
  [命令行/提示输入 → 跑批、写 JSON。],
  [120行触发直接执行。],
)
]

`measure` 第 28 行先对角度 `%360` 再
`round(...,2)`；极端边缘报告可能显示
360.00，策略的三角函数仍有周期意义。这个本地接口不像正式客户端那样另外验证
`[0,360)`。不能把本地宽松字典接口等同于官方协议的完整校验。

`main` 的数据流：79–84 解析 loops/seed/output、建立批次随机器；85–90
每局取一个独立子 seed，创建真环境，调用
`solver.run_case(sim)`，捕获异常并保留错误；91–96
记录#strong[模拟器实际清除数]、时间、里程和动作统计；98–109
对全部局和全清成功局分别汇总；110–111 写文件；113–118 打印摘要。

判“全清”的 `len(sim.cleared)==len(src)`
在模拟器端，它能用真值作评估；算法自己的完成依据仍是上限/覆盖证书与频道状态。两种角色要分清。

时间分解第 55–58
行为：移动距离/5、测向次数×5、换台次数×1、成功清除×5+失败清除×3。逐局等权平均为
`mean(T_k/C_k)`，合并源数加权平均为
`sum(T_k)/sum(C_k)`；源数不同或失败时，两者通常不相等。`average_all_cases`
包含失败局的实际成本；`average_successful_cases` 才只取全清局。

== 5.4 Q4：定向源改变了无信号的含义
<q4定向源改变了无信号的含义>
本节核心范围为
`source/Q4/q4_local_solver.py:1-208`；`source/Q4/q4_official_solver.py:1-208`
与之逐字相同，同一行号直接对应。

Q4
的关键不是另换一个三角测量公式，而是增加隐藏的可见半平面。某次无信号可能因为源在背向一侧，即使距离只有几米，也不能像
Q3 那样排除 1000m 圆。因此代码不包含 Q3 的 `exclude_disk_hull`；普通
`no_signal` 只记下实际动作状态，不能直接裁掉源的位置。

=== 5.4.1 常量与几何函数完整索引
<常量与几何函数完整索引>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [定义与精确位置], [输入 → 输出], [语义及与 Q3 的关系],
  [`add`，`source/Q4/q4_local_solver.py:15`],
  [a,b → a+b。],
  [平移与构造探测点。],
  [`sub`，`source/Q4/q4_local_solver.py:16`],
  [a,b → a−b。],
  [位置差。],
  [`mul`，`source/Q4/q4_local_solver.py:17`],
  [a,s → sa。],
  [标量缩放。],
  [`dot`，`source/Q4/q4_local_solver.py:18`],
  [a,b → 点积。],
  [半平面与距离方程。],
  [`cross`，`source/Q4/q4_local_solver.py:19`],
  [a,b → 叉积。],
  [外接圆与支撑点判侧。],
  [`norm`，`source/Q4/q4_local_solver.py:20`],
  [a → 长度。],
  [裁剪容差。],
  [`dist`，`source/Q4/q4_local_solver.py:21`],
  [a,b → 距离。],
  [路线、清除、复用。],
  [`maxdist`，`source/Q4/q4_local_solver.py:22`],
  [p、poly → 最大顶点距离，空集 0。],
  [控制整个凸区域距离。],
  [`clip`，`source/Q4/q4_local_solver.py:24-37`],
  [poly,n,b → 裁后的多边形。],
  [第26行向外放宽 b，第27–32行跨边插值与内侧保留，第33–36行去重。],
  [`arena_polygon`，`source/Q4/q4_local_solver.py:39-41`],
  [sides\=64 → 场地外接正多边形。],
  [比 Q3 默认 48 边更细，但仍是外接。],
  [`direction_update`，`source/Q4/q4_local_solver.py:43-47`],
  [poly,p,报告角,U → 正观测后的区域。],
  [两个角楔半平面加轴向投影 `u·(x-p)<=U`；U 由策略调用方传入。],
  [`_diameter_circle`，`source/Q4/q4_local_solver.py:49-50`],
  [a,b → 中点圆。],
  [两支撑点圆。],
  [`_circum`，`source/Q4/q4_local_solver.py:52-56`],
  [a,b,c → 外接圆或 None。],
  [平移后解等距方程，近共线返回 None。],
  [`mec`，`source/Q4/q4_local_solver.py:58-76`],
  [非空点 → 圆心、审核半径。],
  [固定种子271828的增量 MEC；最后 `maxdist+1e-6` 确认覆盖。],
  [`nearest_clear`，`source/Q4/q4_local_solver.py:78-83`],
  [当前位置、圆心、半径 → 最近认证清除点。],
  [与 Q3 投影到 `B(c,19.8-r)` 的公式相同。],
  [`coverage_route`，`source/Q4/q4_local_solver.py:85-89`],
  [无参数 → 25 个站点。],
  [原点，半径995的8内圈点，半径1838的16外圈点；外圈访问顺序为14、15、0…13。],
)
]

第 6–13 行定义 Point、TAU、EPS、同 Q3 的 DELTA，以及
`CLEAR_CERT=19.8`、`LAMBDA=.5`、`ETA=.05`、`REUSE_MIN_BASELINE=25`。这些常量分别控制认证清除半径、成对点前进比例、横向分离比例、复用最小基线。

`mec` 第 59 行拒绝空集；60 打乱副本；61–75 逐层强制 p、p/q、p/q/r
支撑圆，左右两侧保留极端候选，最后取半径较小者；76 重新审计覆盖半径。与
Q3 的区别主要是写法更紧凑，不是另一种 MEC 原理。

=== 5.4.2 25 点路线在代码里做了什么、没有做什么
<点路线在代码里做了什么没有做什么>
`coverage_route` 第 86 行生成每隔 45° 的内圈点，第 87 行生成每隔 22.5°
的外圈点，第 88 行只改变访问顺序，第 89 行拼成 1+8+16\=25 点。第 88
行的换序不会改变覆盖集合，只影响走路长度。

全向覆盖只要求每个可能源至少有一个站在保证接收距离内；定向覆盖还要保证未知的任意半平面朝向都至少看见一站。一个可用的等价几何条件是：对任意源位置
g，落在其保证接收范围内的站点集合 S(g) 满足

$ g in "conv" S lr((g)) dot.basic $

否则存在一条过 g
的分离线，使所有站点都在某个方向的背向半平面。路线参数应由这种连续位置与方向覆盖论证支持，不能只展示若干随机朝向成功就当证明。

#strong[当前 Q4 程序没有像 Q3 `covers_arena` 那样在运行时检查这个条件。]
它直接使用固定路线，并在完整走完后把剩余 UNKNOWN 置
ABSENT。因此“路线已执行完”是程序状态；其正确性依赖固定 25
点方案的几何覆盖论证。外圈 1838m 大于源场地半径
1800m；代码将1800当作源的允许位置圆，不把它作为测站的硬坐标边界。

=== 5.4.3 Track 与 Strategy 状态
<track-与-strategy-状态>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [类/方法与精确位置], [参数/状态], [作用],
  [`Track`，`source/Q4/q4_local_solver.py:91-101`],
  [status、poly、center、radius、anchor、last、bearing\_deg、U、measurements。],
  [各频道独立实例，poly 使用 default\_factory；U 初始1500。],
  [`Strategy`，`source/Q4/q4_local_solver.py:103-206`],
  [API、20个Track、机器人状态、固定路线和访问下标。],
  [管理发现、成对定位、清除、调度。],
  [`Strategy.__init__`，`source/Q4/q4_local_solver.py:104-107`],
  [api → 建对象。],
  [初始原点/频道1/时间0，创建路线、coverage\_index\=0、coverage\_done\=False、max\_pair\_rounds\=0。],
  [`Strategy._update_mec`，`source/Q4/q4_local_solver.py:108`],
  [Track → 无返回，更新 center/radius。],
  [将几何计算集中为一行，调用 `mec(t.poly)`。],
)
]

必须分清两个“最后位置”：

- `anchor`（97行）是#strong[最近一次正方向观测站]。它既提供带误差角楔，也证明这个站处在源的可见半平面内；这是双无信号推理的前提。
- `last`（98行）在 `_observe:124`
  对每种测量结果都更新，用于25m复用过滤。无信号可以改变 last，但不会改变
  anchor、bearing\_deg 或 U。
- `U`（100行）是相对正锚点的保守距离上界，同时配合当前角楔控制前向投影；它与
  MEC 半径不是同一个量。源可能离 anchor
  很远，而当前不确定区域圆已经很小。
- `measurements` 仅在 `_positive` 中递增，即正方向观测次数。

=== 5.4.4 正观测与普通无信号分支
<正观测与普通无信号分支>
#strong[`_positive`：`source/Q4/q4_local_solver.py:109-112`。]
输入频道、正观测站、报告角；无显式返回，更新该频道。

第110行先取
`U=min(1500,maxdist(p,old_poly)+EPS)`，再与新角楔及投影界相交；第111行拒绝空集；第112行一次更新
FOUND、多边形、正锚点、报告角、距离界、正观测计数和 MEC。新的 U 为
`min(旧距离界,新多边形到p最大距离+EPS)`，进一步利用已有信息。它不会估计定向源的
heading。

#strong[`_observe`：`source/Q4/q4_local_solver.py:121-129`。]
输入频道和测量站；返回测量结果字符串。

#align(center)[#table(
  columns: 2,
  align: (col, row) => (auto,auto,).at(col),
  inset: 6pt,
  [行段], [操作与含义],
  [122–124],
  [发
  API，拒绝则报错；接受后更新位置、当前测向频道、虚拟时间、动作数和该频道
  last。],
  [126],
  [direction 调 `_positive`，替换正锚点。],
  [127],
  [near 先标 FOUND，再同点认证清除。clear 不受源的发射朝向限制。],
  [128],
  [no\_signal 正常返回，但#strong[不改 poly、不减 U、不改
  anchor]；其他未知结果报错。],
  [129],
  [把结果返回给成对探测等调用方，由调用方判断能否组合推理。],
)
]

#strong[`_clear`：`source/Q4/q4_local_solver.py:113-120`。]
输入频道、站点、certified\=True；返回布尔值并更新动作状态。成功标
CLEARED、计数加一；未知结果报错；认证清除失败则抛错。若显式
certified\=False 失败，只返回 False，没有 Q3
的失败圆排除逻辑；默认策略所有主动清除都有证书。

=== 5.4.5 成对点公式与两类收缩
<成对点公式与两类收缩>
#strong[`_pair_round`：`source/Q4/q4_local_solver.py:159-169`。]
参数频道 i；完成至多两次测量，必要时再调用 `_dual_negative`。设正锚点为
a，报告方向单位向量 u，左法向 v，当前距离界 U，代码第162–163行构造

$ q_plus.minus eq a plus lambda U u plus.minus eta U v comma #h(2em) lambda eq 0.5 comma med eta eq 0.05 dot.basic $

第164行选择离机器人近的一侧先测，只交换访问顺序，不改变两个几何点。

#align(center)[#table(
  columns: 2,
  align: (col, row) => (auto,auto,).at(col),
  inset: 6pt,
  [行段], [为什么这样分支],
  [160–161],
  [必须有 anchor，否则不能把“锚点可见”作为推理前提。],
  [165–166],
  [先测 q1。若 near 已清除，或获得 direction，立即返回；direction
  已建立一个新锚点并缩小区域，不必继续测旧计划 q2。],
  [167–168],
  [q1 为 no\_signal 才测 q2。同样只要有正/near 就返回。],
  [169],
  [只有同一轮、同一旧正锚点、这对点都无信号，才执行双负裁剪。普通两次无信号不能随意触发它。],
)
]

#strong[为什么这两个点不会因超出1000m而无信号？]
忽略极小数值裕量，旧区域在锚点坐标满足
`0<=x<=U, abs(y)<=x*tan(delta)`。最远距离发生在三角形顶点。对
q+、q−统一可取上界

$ max_(g in P) parallel q_plus.minus minus g parallel lt.eq U max lr((sqrt(lambda^2 plus eta^2) comma sqrt(lr((1 minus lambda))^2 plus lr((tan delta plus eta))^2))) approx 0.504542 U dot.basic $

U≤1500时约为756.813m，远低于1000m。这个宽裕间隔也吸收了代码 EPS
级别的扩张。因此若测得
direction，新距离上界约缩到旧U的0.504542倍；若无信号，才可以归因于定向可见性而非未知接收半径。

#strong[为什么双无信号可删前半段？] 假定某候选源 g 的前向投影
x≥λU。锚点到 g 的线段，与探测点横线 `x=λU` 相交于 h。角楔保证
`abs(h_y)<=λU*tan(delta)<ηU`，所以 h 位于 q+ 与
q−之间。锚点可见，源本身在可见半平面边界上，因此整段 a–g、尤其 h
都在可见闭半平面内。若 q+ 与
q−都不可见，它们的连线段会全在不可见开半平面，产生矛盾。于是这样的 g
必须排除，留下 `u·(g-a)<=λU`。

对应函数
#strong[`_dual_negative`：`source/Q4/q4_local_solver.py:155-158`]：

+ 156行调用 clip，增加 `u·x<=u·anchor+λU`。
+ 157行空集合则报错，拒绝静默失去真源。
+ 158行把径向界更新为
  `min(λU/cos(delta),maxdist(anchor,poly)+EPS)`，再更新 MEC。由角楔
  `r*cos(delta)<=前向投影` 得到这个 secant 因子；数值约0.500077U。

两类分支都使 U
约减半，但方向信息的来源不同：正分支来自新测角，双负分支来自正锚点、范围保证、未知半平面共同约束。代码无需辨识源究竟全向还是定向，也无需恢复发射朝向。对全向源，这两个点既保证在接收范围内，就不会正常走到双无信号分支。

=== 5.4.6 覆盖结束、复用、服务与插入
<覆盖结束复用服务与插入>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [方法与精确位置], [输入/输出/状态], [每个关键分支的用途],
  [`_known_count`，`source/Q4/q4_local_solver.py:130`],
  [无参数 → FOUND或CLEARED的频道数。],
  [源数上限证据；不计 UNKNOWN/ABSENT。],
  [`_finish_unknown_if_possible`，`source/Q4/q4_local_solver.py:131-139`],
  [无返回，可能设置 ABSENT/coverage\_done。],
  [已知源数\>\=16，或25点路线已走完，才把其余UNKNOWN置ABSENT；后者依赖固定路线的覆盖论证。],
  [`_reuse`，`source/Q4/q4_local_solver.py:140-147`],
  [limit\=2 → 无返回，至多补测两个频道。],
  [筛 FOUND、r\>19.8、当前点到多边形最大距离\<\=999；排除 last
  为空或基线\<25；半径大者优先。],
  [`_scan_site`，`source/Q4/q4_local_solver.py:148-154`],
  [站点p → 无返回。],
  [UNKNOWN频道中当前测向频道优先；逐一测，已知16即提前停；再复用2个FOUND，路线下标加一，检查发现结束。],
  [`_service`，`source/Q4/q4_local_solver.py:170-178`],
  [一个FOUND频道 → 无返回，直至清除/报错。],
  [r\<\=19.8则最近点清除；否则最多9轮成对探测；记录最大轮数，服务后复用2频道并再判发现结束。],
  [`_choose_insert`，`source/Q4/q4_local_solver.py:179-187`],
  [下一站或None → 频道或None。],
  [评分为绕路增加量+r；无下一站则当前位置到圆心距离+r；有下一站时最小评分\<\=600才插入。],
)
]

Q4 `_reuse` 的 `maxdist<=999`
#strong[只保证距离范围，不保证源朝向可见]。若复用得到
no\_signal，就按普通无信号处理，不裁剪也不报接收不变量失败；它和 Q3
`_sweep_found` 的全向接收意义不同。Q4 用 last 而非 anchor
作25m检查，最近一次复用失败也会阻止马上原地再试。

`_service`
第176行“超过9轮”是异常保护，不是每个源固定探测18次。某一轮第一测就是
direction 时，只发生一次测量；near 可以立即清除。停止看
`radius`，而几何收缩证明主要控制
U：两者均为不同形式的保守范围，随相交一起缩小。

=== 5.4.7 Q4 主循环可跟踪执行顺序
<q4-主循环可跟踪执行顺序>
`run` 位于 `source/Q4/q4_local_solver.py:188-206`，`run_case(api)` 位于
`source/Q4/q4_local_solver.py:208`。

+ 189行先扫描路线第0点原点，此动作使 coverage\_index 变为1。
+ 191–196行每轮先更新发现结束状态，再查看是否仍有 FOUND 或
  UNKNOWN；二者均无就结束。
+ 197行仅在未结束覆盖且下标仍有站时拿下一站，否则 None。
+ 198–200行先尝试插入单源服务，不能插入就去下一覆盖站。
+ 201行没有下一站但仍有FOUND，就按近圆心加半径选源服务；202再做一次结束检查。
+ 203行属于 `while ... else`：循环因2000次上限自然耗尽才抛错；正常 break
  不执行 else。
+ 204–206行返回清除数、虚拟时间、每源时间、动作数、已访问覆盖点数、coverage\_done、最大成对轮数、频道状态。

`coverage_done=True` 只说明发现阶段可结束，可能还有 FOUND 等待清除。真正
run 的正常终止还要求没有 FOUND/UNKNOWN；不能仅检查 coverage\_done
就宣称全清。

=== 5.4.8 Q4 本地模拟器完整索引
<q4-本地模拟器完整索引>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [定义与精确位置], [参数 → 返回/状态], [与物理模型的对应],
  [`Source`，`source/Q4/q4_local_simulator.py:8-10`],
  [channel、position、radius、directional、heading、phase。],
  [冻结真值记录；heading为弧度，可见半平面法向方向。],
  [`Simulator`，`source/Q4/q4_local_simulator.py:12-36`],
  [隐藏源与动作计时环境。],
  [提供策略需要的measure/clear接口。],
  [`Simulator.__init__`，`source/Q4/q4_local_simulator.py:13-15`],
  [sources → 对象。],
  [建源字典、已清除集合、位置/频道/时间与里程/次数统计。],
  [`Simulator._move`，`source/Q4/q4_local_simulator.py:16-17`],
  [p → 无返回。],
  [里程增加，移动时间\=距离/5，更新位置。],
  [`Simulator._visible`，`source/Q4/q4_local_simulator.py:18-20`],
  [源s、站p → bool。],
  [全向源直接True；定向源检验 `(p-g)·u(heading)>=-1e-10`。],
  [`Simulator._error`，`source/Q4/q4_local_simulator.py:21-22`],
  [源、站 → 角误差。],
  [.61sin+.39cos的确定性位置相关误差，夹在±1°。],
  [`Simulator.measure`，`source/Q4/q4_local_simulator.py:23-31`],
  [p/ch → 公共结果字典。],
  [先移动、测量5秒、按需换台1秒；不存在/已清除/太远/不可见任一成立即无信号；之后才判near和direction。],
  [`Simulator.clear`，`source/Q4/q4_local_simulator.py:32-36`],
  [p/ch → 成功或范围内无目标。],
  [只看真实距离\<\=20和未清除状态，#strong[不调用\_visible]；成功5秒、失败3秒。],
  [`make_case`，`source/Q4/q4_local_simulator.py:38-43`],
  [seed → 源列表。],
  [10–16个源、无重复频道、场地内面积均匀位置、1000–1500接收半径；定向数量1至n−1，确保本地样本同时有两类源。],
  [`_average`，`source/Q4/q4_local_simulator.py:45-65`],
  [多局结果 → 汇总或None。],
  [与Q3两种每源时间和时间分解相同，另统计每局定向源数；sources局部变量同样未用于返回。],
  [`_print_average`，`source/Q4/q4_local_simulator.py:67-80`],
  [标题、汇总 → 打印。],
  [展示定向源数、全清数、两个均值口径与时间分解。],
  [`main`，`source/Q4/q4_local_simulator.py:82-116`],
  [参数/用户局数 → 批量结果JSON。],
  [118行脚本入口；按模拟器真清除数评估每局，保留异常。],
)
]

`_visible`
定义的是以源为边界点、heading向量为内法向的#strong[闭半平面]，不是“机器人自身朝向”。测站位于边界时也算可见，阈值略放宽处理浮点。

`measure`
第27行先判不可见再判第28行near：一个离源5m以内、但在其背向半平面的站，仍得到no\_signal。清除则没有方向门槛，正是为什么集合足够小时可以按20m距离证书直接清除。

`main`
83–86行解析并记录批次seed；87–94行生成每局子seed与混合源、运行策略、捕获异常、累计真清除/距离/测量/换台/失败清除；96–107分别汇总全部局和成功局；108–109写JSON；111–116打印结果。这个本地生成分布只是测试设计，不是正式未知源的概率分布承诺。

== 5.5 Q3/Q4 正式 HTTP 客户端：逐方法对应与状态机
<q3q4-正式-http-客户端逐方法对应与状态机>
正式客户端不是额外定位算法，而是把策略的 `measure/clear`
变成可审计、串行、带预算的 HTTP 动作。Q3 与 Q4
的实现语义基本一致，Q4把一些语句压在同一行，行号不同；以下逐项列出，不能简单加一个固定行号偏移。

=== 5.5.1 所有新增类与方法的位置
<所有新增类与方法的位置>
表中 Q3 全称为 `source/Q3/q3_official_solver.py`，Q4 全称为
`source/Q4/q4_official_solver.py`。每个范围都给出完整相对文件名，便于直接跳到源文件。

#align(center)[#table(
  columns: 4,
  align: (col, row) => (auto,auto,auto,auto,).at(col),
  inset: 6pt,
  [定义], [Q3 精确范围], [Q4 精确范围], [输入 → 返回/状态],
  [`ProtocolError`],
  [`source/Q3/q3_official_solver.py:510`],
  [`source/Q4/q4_official_solver.py:215`],
  [RuntimeError子类；表达请求已明确拒绝或明确协议错误。],
  [`BudgetExceeded`],
  [`source/Q3/q3_official_solver.py:511`],
  [`source/Q4/q4_official_solver.py:216`],
  [RuntimeError子类；预算不足，停止新动作。],
  [`ResultUnknown`],
  [`source/Q3/q3_official_solver.py:512`],
  [`source/Q4/q4_official_solver.py:217`],
  [RuntimeError子类；无法确定动作是否执行/结果是什么。],
  [`OfficialClient`],
  [`source/Q3/q3_official_solver.py:514-681`],
  [`source/Q4/q4_official_solver.py:219-366`],
  [连接、日志、请求ID、时间预算与动作状态的有状态客户端。],
  [`__init__`],
  [`source/Q3/q3_official_solver.py:515-531`],
  [`source/Q4/q4_official_solver.py:220-231`],
  [base\_url、robot\_id、log\_path、timeout\=5、retries\=6 →
  建客户端。],
  [`_log`],
  [`source/Q3/q3_official_solver.py:532-537`],
  [`source/Q4/q4_official_solver.py:232-235`],
  [一个可JSON化对象 → 写一条JSONL，失败则记log\_failed/log\_error。],
  [`_disconnect`],
  [`source/Q3/q3_official_solver.py:538-542`],
  [`source/Q4/q4_official_solver.py:236-240`],
  [无参数 → 关闭当前连接并置None。],
  [`_connection`],
  [`source/Q3/q3_official_solver.py:543-550`],
  [`source/Q4/q4_official_solver.py:241-248`],
  [可选timeout → 可用HTTPConnection。],
  [`_safe_payload`],
  [`source/Q3/q3_official_solver.py:551-552`],
  [没有独立方法；等价操作在288行。],
  [复制请求字典、把robot\_id替换为`<TEAM_ID>`，用于请求日志。],
  [`_finite`],
  [`source/Q3/q3_official_solver.py:553-557`],
  [`source/Q4/q4_official_solver.py:249-253`],
  [任意值 → 是否为有限的int/float且不是bool。],
  [`_cutoff`],
  [`source/Q3/q3_official_solver.py:558-560`],
  [`source/Q4/q4_official_solver.py:254-256`],
  [path → 此类动作的现实时间截止点或None。],
  [`_attempt_timeout`],
  [`source/Q3/q3_official_solver.py:561-566`],
  [`source/Q4/q4_official_solver.py:257-262`],
  [path → 本次网络超时秒数，或抛预算异常。],
  [`_validate_success`],
  [`source/Q3/q3_official_solver.py:567-588`],
  [`source/Q4/q4_official_solver.py:263-283`],
  [path、HTTP状态、解析对象 → 无返回；无效时抛不同异常。],
  [`_request`],
  [`source/Q3/q3_official_solver.py:589-633`],
  [`source/Q4/q4_official_solver.py:284-323`],
  [path、payload、可选body → 经校验的响应字典；负责同ID重试。],
  [`action`],
  [`source/Q3/q3_official_solver.py:634-658`],
  [`source/Q4/q4_official_solver.py:324-344`],
  [path、可选位置/频道 → 响应字典；负责新ID与动作前校验。],
  [`wait_until_open`],
  [`source/Q3/q3_official_solver.py:659-665`],
  [`source/Q4/q4_official_solver.py:345-351`],
  [最多wait\_s\=300秒 → 端口可连接则返回，否则超时。],
  [`enter`],
  [`source/Q3/q3_official_solver.py:666-668`],
  [`source/Q4/q4_official_solver.py:352-355`],
  [无参数 → /enter响应，并设置deadline/max\_virtual/entered。],
  [`measure`],
  [`source/Q3/q3_official_solver.py:669`],
  [`source/Q4/q4_official_solver.py:356`],
  [p,ch → `action('/measure',p,ch)`。],
  [`clear`],
  [`source/Q3/q3_official_solver.py:670`],
  [`source/Q4/q4_official_solver.py:357`],
  [p,ch → `action('/clear',p,ch)`。],
  [`exit`],
  [`source/Q3/q3_official_solver.py:671-674`],
  [`source/Q4/q4_official_solver.py:358-360`],
  [无参数 → /exit响应；已确认退出时返回缓存。],
  [`can_exit`],
  [`source/Q3/q3_official_solver.py:675`],
  [`source/Q4/q4_official_solver.py:361`],
  [无参数 → 是否可以安全尝试新退出请求。],
  [`close`],
  [`source/Q3/q3_official_solver.py:676-681`],
  [`source/Q4/q4_official_solver.py:362-366`],
  [无参数 → 关闭连接与日志；不发送/exit。],
  [`main`],
  [`source/Q3/q3_official_solver.py:683-711`],
  [`source/Q4/q4_official_solver.py:368-390`],
  [命令行/环境变量/输入 → 运行一局并返回退出码0或1。],
)
]

这三个异常类的 `pass`
不是遗漏算法：它们只通过“类型不同”让调用方走不同处理路径，继承的构造与错误消息已足够使用。

=== 5.5.2 构造、连接与日志：有哪些状态
<构造连接与日志有哪些状态>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [操作], [Q3行段 / Q4行段], [精确解释],
  [解析地址],
  [516–520 / 221–223],
  [用urlsplit；要求http、有hostname、没有其他路径/查询/片段；只允许127.0.0.1、localhost、::1。客户端目标是本机正式模拟器。],
  [校验队号],
  [521–522 / 224],
  [队号非空，UTF-8字节数\<\=64，不含Unicode类别Cc/Cf的控制/格式字符。字节长度不等于中文字符个数。],
  [初始连接状态],
  [523–524 / 225],
  [保存host/port/队号/timeout/retries；conn\=None，第一次请求才连接。],
  [请求与时间状态],
  [525–528 / 226–228],
  [随机UUID前12个十六进制字符作本次前缀，serial\=0；deadline未知；虚拟上限初值360000，入场后覆盖；初始位置原点、频道1；pending为空；退出未尝试。],
  [创建日志],
  [529–531 / 229–231],
  [`Path.parent.mkdir`建目录，`open('x')`排他创建，避免覆盖旧日志；写program与UTC时间元信息。],
  [日志实际写入],
  [534–537 / 233–235],
  [每个对象压缩JSON一行，禁NaN，立刻flush；失败标志保留并向stderr告警，但该次日志错误不直接中断已经执行中的策略动作。],
  [断开],
  [538–542 / 236–240],
  [如有连接就close，忽略关闭过程OSError，最终conn\=None，重试时可重建。],
  [建立/复用],
  [543–550 / 241–248],
  [无连接则建HTTPConnection并connect；设置TCP\_NODELAY减少小请求延迟；已有连接复用，但同步更新连接与底层socket超时。],
)
]

`_safe_payload` 和 Q4
第288行只在#strong[请求日志副本]中替换robot\_id，发送出去的payload仍有真实队号；元数据也用占位符。响应体与无效响应raw片段按收到的内容记录，所以不能从这两行推出“日志任意字符串都经过全局匿名化”。

每个新动作的请求ID形如
`随机前缀-递增序号`。它用于把一次逻辑动作与其网络重试绑定。UUID前缀降低不同进程复用ID的风险；serial只在
`action` 创建新动作时加一，重试循环没有再次加一。

=== 5.5.3 数值和预算校验
<数值和预算校验>
`_finite` 先拒绝bool，是因为Python中 `isinstance(True,int)`
为True；若直接允许int，错误的布尔时间或坐标也会通过。再将数转float做isfinite，并捕获溢出/类型/值错误。

`_cutoff`：普通动作截止点是 `deadline-8s`，退出动作是
`deadline-.25s`。8秒是为收尾退出预留的现实时间，不加到虚拟时间里。未入场、deadline未知时返回None。

`_attempt_timeout`：无deadline用配置timeout；否则算cutoff减monotonic当前值，非正即抛BudgetExceeded；正值则返回
`max(.05,min(timeout,remaining))`。注意有0.05秒下限，这不是硬实时调度的形式化截止保证；它是请求预算控制，实际网络操作仍可能受系统调度影响。

动作前虚拟预算在 Q3第644–647行 / Q4第334–337行：

$ Delta T_(u p p e r) eq frac(parallel p_(n e w) minus p_(o l d) parallel, 5) plus 5 plus cases(delim: "{", 1 comma & upright("measure且需要换台") comma, 0 comma & upright("其他") dot.basic) $

清除失败仅3秒、成功5秒，所以对clear取5秒是保守增量。若旧时间加这个增量超过
`max_virtual-.001`，不发送动作。实际时间始终以合法响应里的
`virtual_time_s` 更新，不在客户端自己加5，也不为一次测向 `sleep(5)`。

=== 5.5.4 `_validate_success` 的每一种检查
<validate_success-的每一种检查>
Q3 `source/Q3/q3_official_solver.py:567-588` 与 Q4
`source/Q4/q4_official_solver.py:263-283` 采用同样的核心校验。

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [检查], [Q3 / Q4 行段], [失败为何分类如此],
  [顶层必须为dict，accepted必须为bool],
  [568–569 / 264–265],
  [数据结构或状态不可信，抛ResultUnknown，不能据此确认成功或拒绝。],
  [real\_timestamp\_ms、virtual\_time\_s必须为有限非负数],
  [570–571 / 266–267],
  [字段缺失、bool、NaN/无穷、负值都拒绝。],
  [HTTP状态必须200，并与accepted一致],
  [572–575 / 268–271],
  [非200且明确accepted\=False为ProtocolError；非200却accepted\=True为ResultUnknown；200但accepted\=False也明确拒绝。],
  [虚拟时间不能倒退],
  [576 / 272],
  [比已确认时间低超过1e-5则ResultUnknown；不能用倒退时间继续预算。],
  [/enter额外字段],
  [577–581 / 273–277],
  [三个时限字段须有限非负；remaining\_real\_duration\_s还必须是\<\=1200的整数秒。之后使用实际remaining，而非固定1200。],
  [/measure结果],
  [582–585 / 278–281],
  [只接受no\_signal、near、direction；direction还须有0\<\=svd\_deg\<360的有限数。],
  [/clear结果],
  [586–587 / 282],
  [只接受success或no\_target\_in\_range。accepted\=True表示动作受理，不等于成功清除了源。],
  [/exit结果],
  [588 / 283],
  [exit\_reason必须为user\_exit。],
)
]

HTTP可重试错误码429/500/502/503/504在 `_request`
中更早有专门分支，不先进入这个成功校验器。它们只有在返回对象明确
`accepted is False`
且两个时间字段是有限数时，才被当作“明确拒绝、可重试”；这个专门分支做的是有限性检查，非完整成功响应的非负与单调性检查。

=== 5.5.5 `_request`：请求体为什么只序列化一次
<request请求体为什么只序列化一次>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [Q3行段], [Q4行段], [逐段执行与理由],
  [590],
  [285],
  [把payload编码为UTF-8 JSON
  bytes，禁止NaN，采用紧凑分隔符。若调用时已有body就复用它。此语句在重试循环外，保证同一逻辑动作每次发送完全相同body。],
  [591–594],
  [286–289],
  [无pending时保存path、payload副本、body，并记一条request；初始化last异常和unknown标志。pending先建立、后发送，便于保留尚未确认动作。],
  [595–600],
  [290–294],
  [`range(retries+1)`，默认6次重试意味着最多7次发送尝试；每次保存monotonic开始时刻、算超时、取连接、POST、读状态和全部响应体。],
  [601–604],
  [295–298],
  [UTF-8解码并json.loads；parse\_constant拒绝JSON中的NaN/Infinity；无效时日志保存最多1000字节原始内容的替代解码片段，再抛ResultUnknown。],
  [605],
  [299],
  [写response日志，含request\_id、attempt、耗时、HTTP状态和解析体。响应已记录不等于已通过后续校验。],
  [606–611],
  [300–305],
  [对指定临时错误码作前述accepted\=False/时间字段有限性检查；可信拒绝变成特殊`OSError('HTTP ...')`交给重试；不可信状态转ResultUnknown。],
  [612–616],
  [306–308],
  [完整校验。ProtocolError表示明确拒绝，清pending后向外抛；完全成功则更新客户端虚拟时间、清pending、返回对象。],
  [617–621],
  [309–312],
  [BudgetExceeded：若此前没有出现结果未知，清pending并记aborted\_before\_send；若已有未知发送，则保留pending。无论哪种都向外抛。],
  [622],
  [313],
  [明确协议拒绝直接向上，不进入自动重试分支。],
  [623–625],
  [314–316],
  [网络/超时/HTTP异常或ResultUnknown：保存last；累积unknown标志；断开连接；记retry日志。普通连接故障也保守归为可能未知，不声称一定没有执行。],
  [626–631],
  [317–321],
  [已到最后尝试就退出；否则retry\_count加一，指数退避0.1、0.2、0.4…最多1.5秒，并裁到剩余预算；没有等待空间则停止，否则sleep。],
  [632–633],
  [322–323],
  [若unknown曾为真，抛ResultUnknown并保留pending；否则全部都是明确未执行的临时拒绝，清pending后抛ConnectionError。],
)
]

第623–624 / 314–315行最难读的是unknown表达式：

```python
unknown = unknown or isinstance(exc, ResultUnknown) or not (
    isinstance(exc, OSError) and str(exc).startswith('HTTP ')
)
```

解释为：#strong[只要有一次尝试结果不明确，这个逻辑动作就持续保持“可能已执行”状态，直到收到同ID的可信响应。]
唯一不新增unknown的重试异常，是代码自己从“明确accepted\=False的临时HTTP错误”构造的
`OSError('HTTP ...')`。后来的某次明确拒绝不能抹掉更早一次未知执行的风险。

如果服务器依据request\_id提供幂等语义，"第一次已执行但响应丢失"后用原ID重试可以得到同一动作的结果。换新ID可能把移动、检测、清除计费再执行一次，因此策略不能绕过
`action` 手工新发请求。

=== 5.5.6 `action`：新动作与重试动作的分界
<action新动作与重试动作的分界>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [Q3行段], [Q4行段], [具体内容],
  [635–636],
  [325–326],
  [路径必须是enter/measure/clear/exit；pending不为空立即ResultUnknown，禁止创建另一个逻辑动作。],
  [637–638],
  [327–328],
  [measure/clear必须有位置与频道；enter/exit不能带这些字段。],
  [639–643],
  [329–333],
  [位置必须两维、有限且每坐标绝对值\<\=2e6，转float；频道必须是非bool的int且1–20。],
  [644–648],
  [334–338前部],
  [对移动动作检查虚拟预算，再检查现实预算。全部通过才生成ID。],
  [649–654],
  [338–340],
  [serial加一，构造arena\_id\=default、robot\_id、request\_id；按需要增加position字典和channel。],
  [655–658],
  [341–344],
  [调\_request；只有确认返回后才更新位置；只有measure改current\_channel。返回响应给Strategy。],
)
]

核心不变量是：#strong[客户端的position、current\_channel和virtual\_time只跟随已确认动作更新]。结果未知则不猜新位置，也不给下一个动作估算错误移动成本。`clear`
虽带channel指定清除对象，但不会改变用于测向换台计费的current\_channel。

`action`不是一个完整通用协议框架：它着重校验参数、pending和预算，并未在每条路径前逐一校验“必须已enter且尚未exit”的所有状态组合。当前main固定按合法顺序调用，提供了这部分执行约束。

=== 5.5.7 等待、入场、退出与关闭
<等待入场退出与关闭>
`wait_until_open`
反复尝试TCP连接：单次timeout\=.5s，失败sleep\=.25s，到wait\_s截止就抛TimeoutError。TCP端口能连接只说明服务开始监听；正式协议是否可用仍由随后的enter响应校验决定。

`enter` 在发送前记录monotonic开始时间，收到合法响应后设
`deadline=started+remaining_real_duration_s`，并读取实际max\_virtual\_duration\_s，标entered\=True。这样把入场网络耗时也保守计算在现实预算内。Q4第354行多了一次remaining数值范围检查；前面的统一校验已经更严格地排除了bool并要求整数，因此是额外防护，正常行为与Q3一致。

`exit`
先判断是否已经确认退出：是则直接返回exit\_response，不再发动作；否则把exit\_attempted设True，再调用action('/exit')，成功才标exited并缓存响应。

`can_exit`
是多个条件的逻辑与：已entered、尚未exited、尚未exit\_attempted、没有pending、距离deadline还有0.25s以上。尤其pending未知时，它返回False，避免因异常清理又用一个新ID发送exit，打破串行幂等状态。

`close`
仅清理本地连接与日志，#strong[不会发送退出动作]。日志关闭出错会设置log\_failed并打印stderr；main的返回码随后也会反映此标志。

=== 5.5.8 两种具体调用轨迹：答辩可直接跟着走
<两种具体调用轨迹答辩可直接跟着走>
#strong[正常的一次测向，以Q3为例：]

+ `Strategy._observe:282` 调用 `OfficialClient.measure:669`。
+ measure调
  `action:634-658`；假设当前位置A、下一位置B、频道变更，预算上界为
  `dist(A,B)/5+6` 秒。
+ 校验通过，serial从k变k+1，产生ID `prefix-(k+1)`。
+ `_request:591-593`存pending并记请求；599发POST；600–616解析、校验响应、更新virtual\_time并清pending。
+ action第656–657行确认位置B、测向频道；响应返回Strategy。
+ `_observe:284-309`同步策略状态，若direction则裁区域、更新圆；然后调度器继续决定下一动作。

#strong[动作可能执行了但响应超时：]

+ 原payload/body/ID保存在\_request局部变量及pending里。
+ 超时走623–631，unknown变True、断连接、退避，仍重发同一body和ID。
+ 若同ID响应最终合法，616清pending，整个策略只消费一次确认结果。
+ 若全部尝试耗尽仍未知，632抛ResultUnknown且pending保留；main捕获异常，can\_exit因pending非空为False。
+ finally仍会close本地资源；程序以失败退出码结束，日志保留原请求ID供查证。它没有“失败后改ID强行继续”的路径。

Q4同样的轨迹由
`_observe:122 → measure:356 → action:324-344 → _request:284-323` 构成。

=== 5.5.9 正式main的完整执行顺序
<正式main的完整执行顺序>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [阶段], [Q3行段 / Q4行段], [做什么与返回含义],
  [参数与队号],
  [684–689 / 369–372],
  [解析robot-id、URL、wait；队号优先命令行，再环境变量CUMCM\_ROBOT\_ID，最后交互输入。],
  [日志名与客户端],
  [690–692 / 372–373],
  [时间戳含微秒，日志置runs；建OfficialClient、初始化ok/计时。构造在try外，非法参数或日志创建失败会直接报错，不进入后面的已入场收尾流程。],
  [等待与入场],
  [693–695 / 374–376前部],
  [等接口、enter；入场后重置程序计时，打印开始。],
  [策略与正常退出],
  [696 / 376后部],
  [`run_case(api)`运行完整在线策略，然后调用exit；不是先退出再补清除。],
  [结果落盘],
  [697–700 / 377–379],
  [summary追加程序实际耗时与重试数；写.summary.json；记summary日志和退出确认；若日志不完整则仍以错误处理。],
  [人类可读结果],
  [701–703 / 380–382],
  [每源时间为None时显示N/A；打印清除数、虚拟时间和本地记录位置。],
  [异常与收尾],
  [704–710 / 383–389],
  [捕获Exception/KeyboardInterrupt；记fatal并显示未完成；只有can\_exit真才尝试退出，退出失败再记录；finally始终close。],
  [返回码],
  [711 / 390],
  [ok且日志完整返回0，否则1；Q3第712行/Q4第391行用SystemExit把它交给操作系统。],
)
]

日志失败可能发生在策略与退出实际上已经成功之后，代码仍会返回1并报告记录不完整。因此查看失败时要同时看
`strategy_complete`、`exit_confirmed`、fatal和日志标志，不能从一个非零进程码反推出“源一定没清完”。反过来，本地summary也不是官方模拟器导出的正式成绩证明。

== 5.6 六个 Windows 启动脚本：所有可执行行
<六个-windows-启动脚本所有可执行行>
启动脚本没有数学算法，但会改变工作目录、串联程序、传递参数与保存退出码，答辩时不能简单说“只是双击用的”。

=== 5.6.1 Q1/Q2 生成并求解
<q1q2-生成并求解>
`source/Q1/run.bat:1-12` 与 `source/Q2/run.bat:1-12`
结构完全相同，区别只有第5/7行调用的文件名前缀。

#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [行号与精确位置], [执行含义], [原因],
  [`source/Q1/run.bat:1`；`source/Q2/run.bat:1`],
  [`@echo off`关闭命令回显，\@使本行本身也不回显。],
  [屏幕重点展示Python输出。],
  [`source/Q1/run.bat:2`；`source/Q2/run.bat:2`],
  [`setlocal`开始局部环境作用域。],
  [脚本设置的环境状态在结束后不污染调用会话。],
  [`source/Q1/run.bat:3`；`source/Q2/run.bat:3`],
  [`chcp 65001 >nul`切到UTF-8代码页并隐藏命令自身提示。],
  [支持中文结果输出。],
  [`source/Q1/run.bat:4`；`source/Q2/run.bat:4`],
  [`pushd "%~dp0"`进入脚本目录；`|| exit /b 1`在失败时退出。],
  [相对输入、输出路径与.py文件都以脚本所在目录为基准，不受双击时工作目录影响。],
  [`source/Q1/run.bat:5`；`source/Q2/run.bat:5`],
  [运行对应generator，写`q1_input.json`或`q2_input.json`。],
  [每次启动新生成一局；未指定seed由生成器选择并记录。],
  [`source/Q1/run.bat:6`；`source/Q2/run.bat:6`],
  [若上一命令退出码\>\=1，跳到finish。],
  [生成失败时不继续拿旧输入或缺失输入求解。],
  [`source/Q1/run.bat:7`；`source/Q2/run.bat:7`],
  [用固定输入名调用solver，指定结果JSON名。],
  [启动真正的求解入口。Q2这里没有–quick，使用常规精度。],
  [`source/Q1/run.bat:8-9`；`source/Q2/run.bat:8-9`],
  [finish标签后立即保存ERRORLEVEL到RC。],
  [后续popd/pause可能改变环境或错误码，要先保留Python阶段的结果。],
  [`source/Q1/run.bat:10`；`source/Q2/run.bat:10`],
  [popd恢复原目录。],
  [与pushd配对。],
  [`source/Q1/run.bat:11`；`source/Q2/run.bat:11`],
  [pause等待按键。],
  [双击窗口不会结果一闪而过。],
  [`source/Q1/run.bat:12`；`source/Q2/run.bat:12`],
  [`exit /b %RC%`返回保存的退出码。],
  [把实际阶段结果传给上层，不把pause结果当求解结果。],
)
]

这两个脚本没有
`%*`，因此不是通用的参数转发器。想固定seed时，应直接运行生成器命令，或按需要另行显式传入；本章不修改原脚本。

=== 5.6.2 Q3/Q4 本地与正式入口
<q3q4-本地与正式入口>
四个脚本都是9行：`source/Q3/run_local.bat:1-9`、`source/Q3/run_official.bat:1-9`、`source/Q4/run_local.bat:1-9`、`source/Q4/run_official.bat:1-9`。

#align(center)[#table(
  columns: 2,
  align: (col, row) => (auto,auto,).at(col),
  inset: 6pt,
  [行段], [四份文件中的共同作用],
  [1–4],
  [依次关回显、启局部作用域、用UTF-8、进入脚本目录，语义同上。],
  [5],
  [调下面表中唯一入口，并用`%*`原样转发脚本收到的所有参数。],
  [6],
  [立即保存Python退出码到RC。],
  [7–9],
  [恢复目录、暂停窗口、以RC结束。],
)
]

#align(center)[#table(
  columns: 2,
  align: (col, row) => (auto,auto,).at(col),
  inset: 6pt,
  [精确入口行], [命令与参数去向],
  [`source/Q3/run_local.bat:5`],
  [`python q3_local_simulator.py %*`；loops/seed/output由模拟器解析。],
  [`source/Q3/run_official.bat:5`],
  [`python q3_official_solver.py %*`；robot-id/url/wait由正式main解析。],
  [`source/Q4/run_local.bat:5`],
  [`python q4_local_simulator.py %*`。],
  [`source/Q4/run_official.bat:5`],
  [`python q4_official_solver.py %*`。],
)
]

== 5.7 只讲这份源码真正用到的 Python 与标准库
<只讲这份源码真正用到的-python-与标准库>
这是“被问到语法时去哪查”的附录，不要求初学者先背完所有语法再看算法。`source/requirements.txt:1-2`说明Python\>\=3.10、不需要第三方包；代码里的泛型类型标注与`X | None`写法也对应这个版本口径。

=== 5.7.1 数据、函数和控制流
<数据函数和控制流>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [实际语法/工具], [源码例子], [初学者解释与常见误解],
  [二元组、解包],
  [`source/Q1/q1_solver.py:45`；`source/Q4/q4_local_solver.py:162`],
  [`a,b=point`拆出坐标；`return x,y`返回一个二元组，不是函数返回两个独立通道。],
  [索引、负索引、切片],
  [`source/Q1/q1_solver.py:207-210`；`source/Q2/q2_solver.py:213`],
  [`[-1]`是最后一项；`[:i]`是i以前的副本。双端队列访问首尾，MEC只回看此前已处理点。],
  [赋值与同一行多语句],
  [`source/Q4/q4_local_solver.py:112`],
  [分号只是把若干顺序语句压在一行；不是并行执行。tuple赋值右侧先求值，再写左侧，因此可安全交换q1/q2。],
  [类型标注],
  [`source/Q1/q1_solver.py:13,90`；`source/Q3/q3_local_solver.py:268`],
  [`Point`是别名，`-> Point | None`说明可能没有交点；标注主要帮助阅读，不自动验证输入数值。实际验证仍需if。],
  [`from __future__ import annotations`],
  [`source/Q1/q1_solver.py:3`等],
  [延后处理类型注解，便于类和类型引用；不改变几何运算结果。],
  [默认参数和仅关键字参数`*`],
  [`source/Q2/q2_solver.py:307-310`],
  [second可位置传入，后面first/disk\_sides等必须写名字，减少多个数值参数传错顺序。],
  [`*args`式拆包与`**dict`],
  [`source/Q3/q3_local_solver.py:17`；`source/Q3/q3_official_solver.py:699`],
  [`hypot(*a)`把二元组拆开；`**summary`把字典键值并入新字典。它们不是乘法或乘方。],
  [列表/字典推导],
  [`source/Q1/q1_solver.py:275`；`source/Q3/q3_local_solver.py:270`],
  [用规则生成容器；嵌套for的顺序从左到右。频道字典为每个i调用一次Track，得到20个独立状态。],
  [生成器表达式],
  [`source/Q3/q3_local_solver.py:23`],
  [`max(dist(...) for ...)`按需逐项生成距离；`default=0`处理空输入。],
  [`sorted/set/reversed`],
  [`source/Q1/q1_solver.py:145,157`],
  [set去重，sorted排序，reversed逆序；它们配合构造上下凸链。set本身不提供顶点环绕顺序。],
  [`enumerate/range/zip`],
  [`source/Q2/q2_solver.py:209`；`source/Q3/q3_local_solver.py:447-448`],
  [enumerate同时给下标与元素；range给整数序列；zip配对相邻点算路程。],
  [`lambda`、`key=`、`getattr`],
  [`source/Q2/q2_solver.py:393-395`；`source/Q3/q3_local_solver.py:467`],
  [lambda写很短的评分函数，min/max按key比较；getattr按字段名字符串取R/D/A，避免为每个指标复制整段搜索。],
  [条件表达式],
  [`source/Q1/q1_solver.py:188`],
  [`x if condition else y`在一个表达式内按条件择一，嵌套在这里分类点/线段/多边形。],
  [`and/or`短路],
  [`source/Q3/q3_official_solver.py:675`],
  [从左到右，结果已确定时不再算后面条件；因此部分表达式可以安全访问已有对象，也能把多个退出前提串起来。],
  [`is None`、`is True/False`],
  [`source/Q3/q3_official_solver.py:607`],
  [检查确切的空值或布尔对象，区别于数值相等。例如1\=\=True，却不应当作协议布尔accepted。],
  [`break/continue/return`],
  [`source/Q4/q4_local_solver.py:165-169,191-203`],
  [break结束当前循环；continue跳到下一轮；return离开整个函数。正测后return防止再执行旧锚点双负推理。],
  [`while ... else`],
  [`source/Q4/q4_local_solver.py:191-203`],
  [else只在循环没有被break而自然结束时运行，用于检测超过循环上限。它不是配最近的if。],
  [`raise/try/except/finally`],
  [`source/Q3/q3_official_solver.py:693-710`],
  [raise报告异常；except分类处理；finally不论成功失败都清理资源。捕获异常不代表假装成功。],
  [`assert`],
  [`source/Q2/q2_solver.py:234`],
  [表达程序内部“非空输入后应构造出圆”的断言。最终覆盖仍由235行重算距离完成，assert本身不是几何最优性证明。],
  [`if __name__=='__main__'`],
  [`source/Q1/q1_solver.py:301-302`],
  [直接运行时执行main，作为模块导入时只定义函数/类；这是本地模拟器能够调用solver而不启动另一次命令行的原因。],
)
]

=== 5.7.2 dataclass 与接口
<dataclass-与接口>
`dataclass`会按声明字段生成常用构造等方法，减少大量重复的`self.x=x`。实际例子是
`HalfPlane`（Q1:19–27）、`Metrics`（Q2:238–243）、`Config/Track`（Q3:228–265）与各模拟器Source。

- `@dataclass(frozen=True)`禁止实例字段被重新赋值；它不等价于递归冻结任何可能放进去的可变对象。本代码的Config主要是数值/布尔/字符串，适合作默认配置。
- `field(default_factory=list)`在每个实例构造时新建列表。若所有Track共享一个可变列表，一次频道更新会污染其他频道，破坏独立源状态。
- `asdict`实际用于
  `source/Q2/q2_solver.py:302`，会把包含Metrics的RobustQuality递归变成普通字典供JSON输出。
- `Protocol`用于声明最小动作接口，`Callable`标注可选audit回调，`Iterable/Sequence`描述参数可遍历/可按序访问的要求，不是新算法。
- `Actions.measure`的完整位置是
  `source/Q3/q3_local_solver.py:225`，`Actions.clear`为
  `source/Q3/q3_local_solver.py:226`；正式文件同号。它们的`...`不发送任何动作，真正实现由Simulator或OfficialClient提供。
- `@staticmethod`用于正式客户端`_finite`（Q3:553–557，Q4:249–253）；它只检查一个值，不读取self，因此不需要实例隐式参数。

=== 5.7.3 math、deque与random
<mathdeque与random>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [工具], [实际用途], [应会解释的点],
  [`math.atan2(y,x)`],
  [Q1排序、Q1/Q2生成真示向、Q2安全扇区、Q3覆盖圆弧。],
  [返回向量完整象限角；参数顺序是y在前、x在后。],
  [`radians/degrees/sin/cos/tan`],
  [各题角楔与坐标变换。],
  [三角函数吃弧度；报告角度需要转换；π与tau分别为半圈/整圈。],
  [`%360`与`%tau`],
  [Q1观测、Q2报告缓存、覆盖弧中心角。],
  [把角归入一圈；圆周差用`(a-b+180)%360-180`才能正确跨0°比较。],
  [`hypot/dist/sqrt`],
  [距离、半径、二次方程、面积均匀采样。],
  [hypot用于范数；比较平方距离时可不先开方；sqrt(U)采样半径来自面积随r²增长。],
  [`acos`和夹界],
  [Q2安全弧、Q3覆盖半角。],
  [输入必须在\[−1,1\]，浮点计算后夹界避免纯舍入导致domain error。],
  [`inf/isfinite`],
  [Track初始未知半径、线性区间无穷界、协议数字检查。],
  [inf表示尚无有限界，不是已计算出真实半径；正式JSON禁止NaN/无穷。],
  [`collections.deque`],
  [`source/Q1/q1_solver.py:205-215`。],
  [双端队列两端入/出适合按方向的半平面交；普通list头部删除要搬动元素。],
  [`random.Random(seed)`],
  [生成器、本地case、MEC打乱。],
  [独立且可复现的伪随机发生器；固定seed可以复现相同测试或增量顺序。],
  [`SystemRandom().randrange`],
  [未指定seed时选择一个批次/样例seed。],
  [从系统随机来源取seed，再在输出中保存。],
  [`sample/shuffle/uniform/randint`],
  [选不同频道、打乱点、连续半径、整数源数。],
  [sample不重复，shuffle原地改列表顺序，randint含两端。MEC先复制输入再shuffle，不改调用方点序。],
)
]

本源码没有使用`heapq`。Q3/Q4调度用列表评分与min/sorted，因此不需要为答辩补讲一个实际没有出现的优先队列实现。Q2导入的csv、time和Iterable，以及Q3正式文件额外导入的asdict在当前执行逻辑中未使用；不能据导入名声称代码会导出CSV、计Q2运行时间或调用这些功能。

=== 5.7.4 文件、JSON、命令行与时间
<文件json命令行与时间>
#align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [标准库/用法], [实际位置举例], [为什么这样用],
  [`argparse.ArgumentParser/add_argument/parse_args`],
  [Q1:283–287；Q2:521–526；Q3正式:684–688。],
  [定义参数类型、默认值、必填项、帮助文字；`action='store_true'`把–quick转成bool。],
  [`Path.read_text/write_text`],
  [Q1:288,292；Q2:527,530。],
  [明确UTF-8处理中文JSON；不依赖平台默认编码。],
  [`Path.parent.mkdir(parents=True,exist_ok=True)`],
  [Q1:291；Q3模拟器:111。],
  [创建缺失的多层目录，目录已经存在也正常。],
  [`Path.open('x')`],
  [Q3正式:530；Q4正式:230。],
  [独占创建新日志；不是覆盖模式w，也不是追加旧日志模式a。],
  [`json.loads/dumps`],
  [各main与正式\_request。],
  [JSON映射到dict/list/数字/字符串/bool/None；dumps反向序列化。它不是直接执行Python代码。],
  [`ensure_ascii=False/indent=2/separators`],
  [Q1:292；Q3正式:534,590。],
  [前者保留中文，indent用于人读结果，separators用于一行紧凑日志/请求。],
  [`allow_nan=False/parse_constant`],
  [Q3正式:534,590,601。],
  [发送与日志拒绝非标准JSON特殊数；响应解析显式拒绝NaN/Infinity标记。],
  [JSON与JSONL],
  [Q3正式:530,534,698。],
  [结果JSON是一个完整对象；JSONL是一行一个对象，便于请求/响应逐条追加。不能把整份JSONL当一个普通JSON对象读取。],
  [`flush()`],
  [Q3正式:534。],
  [把Python缓冲区内容尽快交给底层，减少异常时仍留在缓冲区的日志；它不是额外的文件系统持久化证明。],
  [`os.environ.get`],
  [Q3正式:689；Q4正式:372。],
  [从当前进程环境读队号，避免写死到源码；不读取隐藏源信息。],
  [`datetime.now/strftime/timezone.utc`],
  [Q3正式:531,690。],
  [生成记录时间和唯一性较好的文件名；这些展示时间不用来控制剩余预算。],
  [`time.monotonic`],
  [Q3正式:564,596,667。],
  [计算截止时间与等待，不受系统日历时间跳变影响。],
  [`time.perf_counter`],
  [本地模拟main与正式main。],
  [记录程序实际执行耗时，与模拟器虚拟时间分开。],
  [`time.sleep`],
  [Q3正式:631,664。],
  [只用于网络重试退避或等端口；不是模拟移动/测向的任务计时。],
  [`sys.stderr`],
  [Q3正式:537,706。],
  [把错误提示与正常结果分开；`flush=True`使提示及时显示。],
)
]

=== 5.7.5 HTTP 与辅助标准库
<http-与辅助标准库>
HTTP请求由方法、路径、头部、JSON body组成。本程序使用
`POST /enter`、`POST /measure`、`POST /clear`、`POST /exit`，头部声明
`application/json; charset=utf-8`。`http.client.HTTPConnection`负责连接和请求，`getresponse()`取响应头/状态，`read()`读body；`json.loads`解析后，仍须验证业务字段，HTTP200本身不代表源已被清除。

`socket.create_connection`用于开端口等待，`with`退出时关闭这个探测用TCP连接；正式HTTP连接由客户端另行建立并复用。`socket.TCP_NODELAY`减少小TCP请求的发送等待，不改变模拟器虚拟计时。`urllib.parse.urlsplit`拆URL；`uuid.uuid4`构造请求前缀；`unicodedata.category`识别队号中的控制/格式字符。它们均出现在两份正式文件新增导入段（Q3:505–508，Q4:211–213）并有对应实际调用。

== 5.8 任意指一段代码时的答辩练习索引
<任意指一段代码时的答辩练习索引>
每题先不看答案，在30–60秒内说出“输入、约束、状态、后续用途、限制”。

#align(center)[#table(
  columns: 2,
  align: (col, row) => (auto,auto,).at(col),
  inset: 6pt,
  [老师指向], [应回答的核心，不能只逐字翻译],
  [Q1:79],
  [已单位化同向法向量，offset更小代表更严格半平面；因此覆盖原约束交且减少冗余。],
  [Q1:120–125],
  [把新边界参数化，再把每个旧二维约束化成一维t上下界；负系数除法反向。],
  [Q1:174–176],
  [比较点到当前边的叉积高度，推进对踵点，下一段才比较真正欧氏距离。],
  [Q1:224–225],
  [防止两条半平面交出的边界点被误判为有界单点；还要检查全部原约束。],
  [Q1:262–264],
  [零角宽两侧只限定直线，第三条约束补前向射线。],
  [Q2:72–77],
  [扇区最远距离需考虑反向内部驻点；径向凸二次的最大在0或外圆弧。],
  [Q2:118],
  [外接正多边形顶点半径除以cos，保证边而不是顶点与圆相切，保留所有真实可能源。],
  [Q2:225–233],
  [MEC两固定边界点下，左右分别保留限制最强的三点圆，最后选择较小可行候选。],
  [Q2:368–391],
  [对最多8个粗峰做有限黄金分割细化，只将最终5点评价加入records；不是连续全域证书。],
  [Q2:430],
  [场地原点与首站未必重合，场地截断可破坏首示向两侧对称，必须分别搜索。],
  [Q3:84–98],
  [负观测排保证接收圆，但挖洞使集合非凸，因此用剩余顶点/边圆交点的凸包作安全松弛。],
  [Q3:198–204],
  [只检查场地边界不能排除内部孔洞，还要检查检测圆在场地内是否存在暴露弧。],
  [Q3:305–308],
  [来自角楔加投影界三角形的解析覆盖圆；再对当前多边形审核半径，作为独立候选。],
  [Q3:403、425],
  [前者确认整个可行域在保证接收范围，后者确认观测后的收缩；两条是不同不变量。],
  [Q3:463–468],
  [到下一覆盖站的绕路增加量加不确定半径，与600m阈值比较，是调度启发式。],
  [Q4:128],
  [定向源背向也会无信号，普通单次负测不能像Q3删1000m圆。],
  [Q4:158],
  [双负后投影上界减半，但U是径向界，需除cos(delta)再利用顶点距离收紧。],
  [Q4:163–169],
  [正锚点对称探测；第一点有正信息就重建锚点并终止本轮，只有两点都负才用双负定理。],
  [Q4:143–144],
  [999只保证距离，25m过滤上一次任意测量附近的重复复用；仍可能方向不可见。],
  [Q3正式:636 / Q4正式:326],
  [pending意味着上一动作未确认，生成新ID可能重复动作/计费，必须停止。],
  [Q3正式:624 / Q4正式:315],
  [一次结果未知就累积unknown，除非后来确认同ID响应；后来的明确临时拒绝不能抹去此前未知发送。],
  [Q3正式:675 / Q4正式:361],
  [退出也是动作，需要已入场、未尝试、无pending且还有现实预算；finally关闭资源不等于无条件发exit。],
)
]

=== 5.8.1 覆盖范围与有意不逐行复述的内容
<覆盖范围与有意不逐行复述的内容>
本章覆盖了十个Python文件中的所有显式类、函数、方法和嵌套函数；Q3/Q4共用核心通过逐字相同、同号映射同时覆盖本地与正式两份。六个bat的可执行语句、脚本主入口、模块常量、关键数据字段与导入库实际用法也已解释。

有意不为每一行单独写一句话的只有：空行、shebang、纯说明注释/文档字符串、已经在附录按用途解释的import，以及同一功能块中连续的输出格式化语句。输出字段和统计口径已整体解释；同一行多条非平凡赋值与困难条件分支均按执行顺序展开。注释若与实际实现不一致（例如Q3的geometry.py说明）、参数未被使用、数值结果不具备连续证书，本章明确按实际代码说明，不能用注释替代代码证据。

#pagebreak()
= 答辩追问与推导演练
<答辩追问与推导演练>
答题方法：先给一句结论，再在纸上写前提与推导，最后打开相应文件指出函数和关键分支。以下是练习答案，不是供机械背诵的万能话术。代码行号以本仓库未修改的
source/ 文件为准。

== A. 题设与模型边界
<a.-题设与模型边界>
#strong[01｜为什么不能在一个位置测很多次取平均，进而把 ±1°
当成更小误差？] \
原题规定同一地点环境误差在一段时间内固定。重复测量读的是同一环境偏差，独立同分布平均的前提不成立。必须换位置取得新的几何约束；两地误差也只能据题设做有界推理，不能未经证据假设正态独立。

#strong[02｜读数为 359.5°，误差 ±1°，为什么不能简单写区间
\[358.5°,360.5°\] 后在 360° 截断？] \
角度是模 360° 的圆周变量，允许方向包括 \[358.5°,360°) 与
\[0°,0.5°\]。应在单位方向向量或归一化角差上处理，相关角楔见 Q1 的
\_wedge（source/Q1/q1\_solver.py:257–267）及 Q3 的
bearing\_update（source/Q3/q3\_local\_solver.py:63–77）。

#strong[03｜1800、1500、1000、20、5 五个距离各有什么含义？] \
1800 是源位置域半径；某个具体源的接收半径未知但在 1000–1500；用 1000
可以给所有源的保证接收条件；20 是光学清除距离；距离 ≤5
且处于发射覆盖方向时回近场反馈而非示向度，可直接清除。不能把“听得见”直接当成“清得掉”。原题附录
1、2；本地反馈见 Q3 模拟器:20–34、Q4 模拟器:23–36。

#strong[04｜总时间怎样拆？为什么换频道顺序会改变成绩？] \
移动为路线长度除以 5 m/s，每次检测 5 s，每次实际换频道 1 s，成功清除光学
3 s 加激光 2 s；客户端由模拟器累积虚拟时间。Q3 本地
Simulator.\_move、measure、clear 在
source/Q3/q3\_local\_simulator.py:16–34；不同频道访问次序改变 1 s
换台次数，所以扫描把当前频道优先（Q3 \_scan:353–361，Q4
\_scan\_site:148–154）。

#strong[05｜算法的“安全”"完备""快"是同一个性质吗？] \
不是。安全指提交清除点时能证明真源距该点
≤20；完备指不漏掉题设范围内的频道/源并最终服务；快是同等条件下虚拟时间较小，主要由数值实验比较。三者应分别陈述，不用一个“成功率高”代替证明。

== B. Q1：几何与计算
<b.-q1几何与计算>
#strong[06｜一条示向度怎样变成约束？] \
检测点 $s$，读数 $theta$，真源 $x$ 满足方向角 $arg lr((x minus s))$ 与
$theta$ 的圆周角差不超过 $delta eq 1^compose$。在小于 180°
的角楔中，这相当于两条边界射线对应的有向叉积非负约束；每条边界是一条半平面。多次有效观测取交。Q1
\_wedge:257–267 和 solve\_localization:268–282。

#strong[07｜为何交集凸？在哪一步会退化？] \
每个半平面凸，交仍凸；三角形、线段、点都可能是结果，空集代表给定约束互相冲突或数值问题。Q1
intersect\_halfplanes:201–239 与 \_finite\_result:184–200
会处理有限区域和退化情况。Q1 求解器并未自动把半径 1800/1500
的圆加入角楔交集，讲清它求的是题设角交会区域及给定配置。

#strong[08｜旋转卡壳是什么？为什么能够求直径？] \
凸多边形最远点对是支撑线的对踵点之一。沿边依序转动平行支撑线，用叉积比较下一顶点相对该边的面积，单调推进对踵点而不用遍历全部
$n lr((n minus 1)) slash 2$ 点对。先求凸包，再沿有序顶点检查候选。Q1
\_convex\_hull:144–159、polygon\_diameter:160–183；不要把“旋转卡壳”误叫“旋转球壳”。

#strong[09｜以定位区域直径为直径的圆一定覆盖区域吗？给纸笔反例。] \
不一定。取边长 2 的正三角形，底边端点为
$lr((minus 1 comma 0)) comma lr((1 comma 0))$，顶点为
$lr((0 comma sqrt(3)))$。区域直径 $D eq 2$；以底边为直径的圆中心
$lr((0 comma 0))$、半径 1，顶点距离
$sqrt(3) gt 1$，未被覆盖。最小包围圆的半径为 $2 slash sqrt(3) gt 1$。Q1
必须另做圆包含判定，不能从直径值直接宣布覆盖。

#strong[10｜凸多边形的直径和最小包围圆有什么数量关系？] \
任意包围圆半径 $R$ 满足 $D lt.eq 2 R$，所以
$R gt.eq D slash 2$；反向不能推出
$R eq D slash 2$，正三角形反例已说明。二者对应不同目标，Q1
求最大点间距离；Q2 优先最小化包住整个后验集合的圆半径。

#strong[11｜半平面交一定是 $O lr((m log m))$ 吗？] \
标准排序加双端队列的几何核心可以达到这一量级；不能据此声称整份当前
Python 的最坏复杂度也是如此。Q1
还逐顶点验证全部约束，退化兜底会枚举相交线。回答时先区分算法思想的界与当前实现完整路径的界（source/Q1/q1\_solver.py:110–143、201–239）。

#strong[12｜线几乎平行、交集为空、共线顶点时如何解释代码？] \
浮点容差决定“平行”和“在边界内”的判断；同方向半平面可去掉较松约束；有限顶点去重和凸包排序处理退化。重点看
\_ordered、\_intersection、\_feasible\_point、\_finite\_result。不要将数值容差当成物理误差
±1°，二者单位和作用不同。

== C. Q2：安全第二站与最坏质量
<c.-q2安全第二站与最坏质量>
#strong[13｜第二站的“安全候选区域”用量词怎么写？] \
令 $F_1$ 为首测后所有可能源点，第二站为 $s$。统一接收保证集合是
$S eq brace.l s colon max_(x in F_1) parallel s minus x parallel lt.eq 1000 brace.r$。它要求无论哪一个
$x$ 是真源，第二站都在它的最小接收半径内。Q2
safe\_uniform\_1000、safe\_angle\_limit 与 optimize\_fixed\_baseline
分别在 source/Q2/q2\_solver.py:91–113、408–471。

#strong[14｜为什么不总取离第一站 1000 m 的垂线站点，形成漂亮的交角？] \
几何交角好不等于所有首测可行源都可收到：安全条件是对整片 $F_1$
的最大距离约束。候选域还与第一站、目标域边界和接收上界有关。只有通过安全域检验的点才进入质量比较；不能先挑好角度再假定能测到。

#strong[15｜什么是极小极大（minimax）？本程序优化的值是什么？] \
先固定第二站
$s$；可能真源与物理相容的第二读数形成不同后验集合；对每个后验求最小包围圆半径
$R lr((s comma z))$；质量指标取最坏
$W lr((s)) eq sup_(z upright("可行")) R lr((s comma z))$；再在安全站点中选较小
$W lr((s))$ 的候选。实际代码用有限读数样本和局部细化近似
sup，再遍历基线及角度，见
robust\_quality:307–402、optimize\_fixed\_baseline:408–471。

#strong[16｜为什么最小包围圆适合第二题，直径方案还要单独跑？] \
包围圆半径直接回答“从哪个代表点到所有可能真值最多多远”，有利于后续接近/清除；直径则直接衡量位置集合中两种可能真值的最大分离。两种指标不同，代码在
solve\_case:481–520
真正分别按两套指标选点作比较，而非在同一点只改报表列名。

#strong[17｜Q2 的数字是不是精确全局最优？] \
不是。外包络几何、离散基线、站点角网格、第二读数采样与局部细化均须说明。当前
robust\_quality
有有限评价点；报告是这些计算条件下的数值结果，没有连续域最优证书。即使某表有三位小数，也不提升其数学证明等级。

#strong[18｜Q2 为什么还保留 Q1 直径指标？] \
它是同一安全约束下的独立对照：可以展示“换目标函数会不会改变第二站”。答辩时说目标、候选点、最坏反馈三层分别如何处理，代码位置见
solve\_case。不要说是另一个论文外的新物理条件。

== D. Q3：全向源的发现、定位与清除
<d.-q3全向源的发现定位与清除>
#strong[19｜九点从哪里来？它是 TSP 最优路线吗？] \
原点加 8
个外围点形成圆盘接收覆盖骨架（Config.ring\_m\=8，ring\_sites:207–223）；覆盖检测点保证每个全向源至少在某个停靠点进入最低
1000 m 接收范围。服务中的插入点和当前状态会改变实际行走路线。静态 TSP
假定访问集合预先已知，而这里频道、位置与可清除任务随观测出现，因此代码是在线启发式，未实现或证明
TSP 最优。

#strong[20｜频道未知为什么需要扫 20 个？] \
题设说源占不同频道、总数 10–16，但不知道是 1–20
中哪一些；一个频道上的无信号不代表别的频道没有源。Strategy 初始化 20 个
Track（source/Q3/q3\_local\_solver.py:267–275）。已证实 16
个源可用总数上界提前停止未知频道扫描（\_certify\_and\_prune:332–343）。

#strong[21｜全向源的“无信号”能推出什么，为什么 Q4 不一样？] \
Q3 对存在且未清除的全向源，若距离
≤1000，必在其有效半径内，故无信号可排除该测点周围保证接收圆盘（还要考虑频道不存在/已清除的状态）。Q3
\_observe:281–310 记录负观测，exclude\_disk\_hull:78–99
作安全凸外包络。Q4 还可能由于源背向接收点，单次无信号不能排除近处位置。

#strong[22｜如何证明“所有源找到了”，又如何证明“某个源能清除”？] \
前者利用已扫描点的 999 m 圆盘覆盖整个目标域，或已发现 16 个源；Q3
covers\_arena:187–206 和
\_certify\_and\_prune:332–343。后者针对某一频道的剩余候选集，找清除点
$q$ 使所有可能源点距 $q$ ≤20；MEC 与
nearest\_certified\_clear:120–155、\_serve:409–430。两项证明对象与量词不同。

#strong[23｜为什么 19.8 m 而不是 20 m？] \
题设清除界为 20 m，程序用 19.8 m 作计算与量化裕量。若外包络集合位于中心
$c$ 半径 $r lt.eq 19.8$ 的圆，选 $q$ 满足
$parallel q minus c parallel lt.eq 19.8 minus r$，三角不等式给任意真源
$x$：$parallel q minus x parallel lt.eq parallel q minus c parallel plus r lt.eq 19.8 lt 20$。Q3
nearest\_certified\_clear:148–155、\_serve:413–415；Q4
nearest\_clear:78–83、\_service:170–178。

#strong[24｜为什么不是“圆心一到 20 米内就清除”？] \
圆心到当前位置的距离并不能覆盖不确定性；应考虑整个剩余集合。若中心距机器狗
18 m，MEC 半径 10 m，则某个源仍可能距机器狗 28
m。代码先用半径证明证书，再移动至满足最坏距离的清除点。

#strong[25｜为什么局部跟踪选左右偏一点的点？] \
两条几乎平行的示向线交会条件差。少量横向位移改变观察基线和夹角，可能更快收缩候选集；但其具体
0.10 倍半径是参数，不是唯一最优解析解。Q3
Config.offset:239、\_tracking\_point:396–407 还检查所有候选顶点距新点
≤999 m，确保可收到信号。

#strong[26｜发现一个源为什么不立刻一直追？] \
全局覆盖和局部服务共享移动路线。\_choose:454–468
用从当前位置绕访候选中心再去下一覆盖点的额外距离，加上不确定半径构造评分；小于插入阈值时顺路服务，否则继续搜索。阈值
600 m 是策略参数；运行结果支持其经验选择，不是最优性定理。

#strong[27｜为什么同一站点不重新测同一频道？] \
同一地点误差固定，重复读数不会提供新的独立方位信息，还花 5 s。Q3
\_sweep\_found:363–369 对上次有效位置做 25 m 距离筛选，并在可能集均在
999 m 内时才复用测向。

#strong[28｜代码出现 source/Q3 的
rotate、prune、speculative\_r、incidental，是不是正式方法都用了？] \
不是。Config:228–254 默认这些研究分支为 False 或
0；\_make\_plan:376–391、\_serve:416–418、\_worth\_extra\_scan:436–452
中的代码保留比较用途。回答正式策略时按默认路径讲，不能把没有运行的
2-opt、旋转优化或投机清除写成主方法。

== E. Q4：定向源与双无信号
<e.-q4定向源与双无信号>
#strong[29｜一个无信号究竟有哪些解释？] \
目标频道没有源、源已清除、测点超过该源半径、测点位于定向发射半平面外，都可能产生同一反馈。因此
UNKNOWN 状态下不能照搬 Q3 把距离 1000 m 内的位置删掉。见
source/Q4/q4\_local\_simulator.py:18–30 和
q4\_local\_solver.py:121–129。

#strong[30｜为何 25 个点的覆盖比 Q3 九点多？] \
Q4
要保证对任意源位置和任意覆盖半平面，总有合适测点落在既近又可见的一侧。原点、半径
995 m 的 8 个内圈点、半径 1838 m 的 16 个外圈点构成覆盖路线，见
coverage\_route:85–89。外圈点可位于目标源的 1800 m
圆域外；题设只限制源位置，允许机器狗走到外圈。完整几何证明见第 04
章，现场画一个三角剖分而非仅背 25。

#strong[31｜收到一个示向度以后，Q4 能否立刻把后续无信号当成位置排除？] \
仍不能。收到正反馈给了某个正锚点，说明源存在及锚点位于其发射侧；另一个位置无信号可能只是落在发射侧外。\_positive:109–112
记录锚点、读数和安全距离上界；\_pair\_round:159–169
等两侧特定点都无信号才调用
\_dual\_negative:155–158。排除公式必须连同两点几何及上界一同解释。

#strong[32｜为什么成对探测不等于两个独立随机测量？] \
两测点围绕正锚点的测向轴对称构造，$q_plus.minus eq a plus lambda U u plus.minus eta U v$；配对目的是让“两个都背向/两个都超过接收距离”的逻辑受几何约束。逻辑前提包括已知正锚点、源仍未清除、外包络上界与两次确为
no\_signal。代码 \_pair\_round:159–169；详细不等式与余量见第 04 章。

#strong[33｜Q4 什么时候可以说“未知频道没有源”？] \
若已确认 16 个不同频道有源，总数至多
16，其他未知频道必空；或者完成具备定向覆盖保证的全部停靠点扫描，未知频道在所有可见且足够近的候选测点均无响应。\_finish\_unknown\_if\_possible:131–139。若中途没有完成覆盖，不能因几次普通无信号提前判不存在。

#strong[34｜清除动作是否还受定向角度限制？] \
题设附录 2 说光学定位和清除成功只取决于距源 ≤20
m，不取决于信号方向；定向只影响发现和测向。Q4 本地 Simulator.clear:32–36
体现该语义。

== F. 实现与证据
<f.-实现与证据>
#strong[35｜为什么 q3\_official\_solver.py 要独立写策略和客户端？] \
正式程序是单文件，不导入本地模拟器、随机真值或本地
solver；其策略段与本地路径有对应实现，后半是 HTTP/JSON 通信。入口见
source/Q3/q3\_official\_solver.py:683–712，Q4 官方入口见
source/Q4/q4\_official\_solver.py:368–391。讲策略时区分本地模拟和正式环境。

#strong[36｜请求超时后直接换一个 request\_id 再试，会发生什么？] \
原请求也许已被模拟器执行，只是响应丢失；换新 ID
可能重复移动/检测/清除。客户端缓存 pending 请求并重发相同内容与同一
ID；若结果仍未知，不再发新动作或 exit。Q3
OfficialClient.\_request:589–633、action:634–658、can\_exit:675；Q4 对应
\_request:284–323、action:324–344。同一 ID
是否由服务端去重须依据完整接口协议核实；这里说明客户端采取的保护行为，不凭代码单方证明服务端幂等。

#strong[37｜20 分钟与 100 小时为何不矛盾？] \
官方接口限制程序真实运行时间并受测试窗口约束；100
小时是虚拟时间防死循环上限。评分中的平均定位清除时间是虚拟动作时间除以成功清除数，不能以真实运行时间替换。见原题第
3–4 页与客户端预算逻辑。

#strong[38｜本地 100% 清除是不是官方三次正式成绩？] \
不是。本地模拟器由源码生成随机位置、方向、接收半径及可复现误差，能检验许多状态路径；官方正式测试还涉及真正的服务端环境、时间窗口、响应与独立日志。答辩按各自来源报告，绝不将本地复算改称正式成绩。

#strong[39｜如果评委指出论文写法与运行代码不一致，怎么答？] \
先逐字确认被问的版本和条件，用当前程序的具体输入、运行结果与函数说明真实算法。若是文字誊写错误就承认并给出正确计算，不把错误强行解释成另一个算法。主动主汇报可以聚焦模型和演示，针对直接询问应如实作答。

#strong[40｜如果问你某一行没学过，如何现场处理？] \
说明该行上游数据类型、单位与下游返回值，沿调用链到实际测试输入，再区分“我能证明的数学性质”与“我需要现场核对的实现细节”。不猜
API 行为、无限接收范围或未经运行的优化分支。

== 七组现场纸笔演练
<七组现场纸笔演练>
+ 在原点读到 359.5°，画 ±1° 的角楔；说明两条边界线与点
  $lr((100 comma 0))$ 的位置关系。
+ 写出正三角形直径与最小包围圆，检验三个顶点是否在“直径圆”内。
+ 在一个半径为 $r$、中心为 $c$ 的候选圆中推导所有安全清除点的条件
  $parallel q minus c parallel plus r lt.eq 20$；再解释代码为何用 19.8。
+ 写出一个离机器狗 900 m 的定向源，却在当前点 no\_signal
  的具体方向；说明 Q4 为何不裁盘。
+ 给出三站位置，其中前两站很近且示向几乎平行；用图说明第三站横向位移怎样改善几何。
+ 取未知频道 1–20、已确认 16 个不同频道有源；证明剩余 UNKNOWN 可以判
  ABSENT。若只确认 15 个，证明该结论不能成立。
+ 在 Q3 或 Q4 正式客户端找到生成 ID、缓存 pending、重试、拒绝继续与 exit
  的五处，口述一次超时响应丢失的状态轨迹。

建议两人互换角色：一人随机指出代码与问“为什么”，另一人三分钟内写前提、公式、分支、局限，然后由提问者在源码中逐项核对。能指出限制，是掌握方法的一部分。
