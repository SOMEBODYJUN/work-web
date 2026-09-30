#!/usr/bin/env python3
"""Rebuild the coordinate diagrams for the new beginner textbook."""
from pathlib import Path
import math
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import Circle, Polygon
from matplotlib.font_manager import FontProperties

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "textbook_v2" / "figures"
OUT.mkdir(parents=True, exist_ok=True)
FONT = Path("/workspace/scratch/ce9fe12cfde5/cjk-build-fonts/NotoSansCJKsc-Regular.otf")
CN = FontProperties(fname=str(FONT)) if FONT.exists() else None
BLUE, GREEN, ORANGE = "#235478", "#14816f", "#d37936"

def label(ax, value, xy, shift=(5,5), **kwargs):
    ax.annotate(value, xy, xytext=shift, textcoords="offset points", fontproperties=CN, **kwargs)

def finish(fig, ax, name):
    ax.set_aspect("equal"); ax.grid(alpha=.12)
    ax.set_xlabel("x"); ax.set_ylabel("y")
    fig.tight_layout(); fig.savefig(OUT / name, dpi=200, bbox_inches="tight")
    plt.close(fig)

# Chapter 1: two angle intervals leave a quadrilateral, not a single ray crossing.
fig, ax = plt.subplots(figsize=(6.9, 4.5))
mlo, mhi = math.tan(math.pi/6), math.tan(math.pi/3)
polygon=[]
for left,right in ((mlo,mlo),(mlo,mhi),(mhi,mhi),(mhi,mlo)):
    x=4*right/(left+right)
    polygon.append((x,left*x))
ax.add_patch(Polygon(polygon, facecolor="#d9eee9", edgecolor=GREEN, lw=2, alpha=.8))
xx=np.linspace(0,4,80)
for slope,color,origin in ((mlo,BLUE,0),(mhi,BLUE,0),(mlo,ORANGE,4),(mhi,ORANGE,4)):
    yy=slope*(xx-origin) if origin==0 else slope*(origin-xx)
    ax.plot(xx, yy, ls="--", c=color, alpha=.65)
ax.scatter([0,4],[0,0],s=55,c=[BLUE,ORANGE],zorder=5)
label(ax,"A：45°±15°",(0,0),(8,-15),color=BLUE)
label(ax,"B：135°±15°",(4,0),(-95,-15),color=ORANGE)
label(ax,"同时相容的位置",(2,2.25),(8,4),color=GREEN)
ax.set(xlim=(-.45,4.45),ylim=(-.4,4.4))
finish(fig,ax,"01_两次角楔.png")

# Chapter 2: the diameter circle misses a third point; the circumcircle covers all.
fig, axes=plt.subplots(1,2,figsize=(10.2,4.5))
points=np.array([[0.,0.],[4.,0.],[2.,3.]])
for ax,center,radius,title in zip(axes,[(2.,0.),(2.,5/6)],[2.,13/6],
                                   ["最长边的直径圆", "覆盖三点的最小圆"]):
    ax.add_patch(Circle(center,radius,fill=False,ec=GREEN,lw=2))
    ax.scatter(points[:,0],points[:,1],c=BLUE,s=50,zorder=4)
    ax.scatter(*center,c=ORANGE,s=45,zorder=4)
    for name,point in zip("ABC",points): label(ax,name,point)
    label(ax,"圆心",center,(6,-16),color=ORANGE)
    ax.set_title(title,fontproperties=CN); ax.set(xlim=(-.6,4.6),ylim=(-.55,3.65))
    ax.set_aspect("equal");ax.grid(alpha=.12);ax.set_xlabel("x / km");ax.set_ylabel("y / km")
fig.tight_layout();fig.savefig(OUT/"02_三村庄包围圆.png",dpi=200,bbox_inches="tight");plt.close(fig)

# Chapter 3, ordinary counterexample: the outside boundary is covered,
# yet an inner exposed arc and the center stay uncovered.
fig,ax=plt.subplots(figsize=(5.5,5.2))
stations=np.array([(math.sqrt(3)*math.cos(k*math.pi/3),
                    math.sqrt(3)*math.sin(k*math.pi/3)) for k in range(6)])
ax.add_patch(Circle((0,0),2,fill=False,ec=BLUE,lw=2.2))
for point in stations:
    ax.add_patch(Circle(point,1,fill=False,ec=ORANGE,lw=1.3,alpha=.7))
ax.scatter(stations[:,0],stations[:,1],c=ORANGE,s=31,zorder=4)
ax.scatter([0],[0],c=BLUE,s=42,zorder=4)
t=np.linspace(2.78,3.5,50)
ax.plot(math.sqrt(3)+np.cos(t),np.sin(t),c="#be3f52",lw=3.8)
label(ax,"中心没有涂色",(0,0),(8,-15),color=BLUE)
label(ax,"暴露的内侧圆弧",(math.sqrt(3)-1,0),(9,10),color="#be3f52")
label(ax,"场地外圆周",(0,2),(8,-10),color=BLUE)
ax.set(xlim=(-2.35,2.35),ylim=(-2.35,2.4),xlabel="x / m",ylabel="y / m")
ax.set_aspect("equal");ax.grid(alpha=.12);ax.set_title("只覆盖场地边界，内部仍可能有洞",fontproperties=CN)
fig.tight_layout();fig.savefig(OUT/"03_圆周覆盖但有洞.png",dpi=200,bbox_inches="tight");plt.close(fig)

# Chapter 3: nine sites and the outer midpoint direction.
fig,axes=plt.subplots(1,2,figsize=(10.4,4.7))
a=945.973419;arena=1800.;radius=995.
ring=np.array([(a*math.cos(k*math.pi/4),a*math.sin(k*math.pi/4)) for k in range(8)])
ax=axes[0]
ax.add_patch(Circle((0,0),arena,fill=False,ec=BLUE,lw=2.2))
ax.add_patch(Circle((0,0),radius,fill=False,ec=GREEN,lw=1.4,ls='--'))
for point in ring:
    ax.add_patch(Circle(point,radius,fill=False,ec=ORANGE,lw=.65,alpha=.48))
ax.scatter(ring[:,0],ring[:,1],c=ORANGE,s=33,zorder=3)
ax.scatter([0],[0],c=GREEN,s=65,zorder=4)
label(ax,"中心站",(0,0),(6,5),color=GREEN)
label(ax,"八个环站",(a,0),(6,-18),color=ORANGE)
label(ax,"目标圆域",(0,arena),(8,-12),color=BLUE)
ax.set(xlim=(-2050,2050),ylim=(-2050,2050),xlabel="x / m",ylabel="y / m")
ax.set_aspect("equal");ax.grid(alpha=.12);ax.set_title("圆盘并集覆盖场地",fontproperties=CN)
ax=axes[1]
w=math.pi/8;g=np.array((arena*math.cos(w),arena*math.sin(w)))
s0=np.array((a,0.));s1=np.array((a/math.sqrt(2),a/math.sqrt(2)))
ax.add_patch(Circle((0,0),arena,fill=False,ec=BLUE,lw=2))
ax.plot([0,g[0]],[0,g[1]],c=BLUE,ls='--')
ax.plot([s0[0],g[0]],[s0[1],g[1]],c=ORANGE,lw=2)
ax.plot([s1[0],g[0]],[s1[1],g[1]],c=ORANGE,lw=2)
for point,name,shift,color in [(np.array((0.,0.)),"O",(2,-18),GREEN),
                                (s0,"站0",(-15,-18),ORANGE),(s1,"站1",(-28,8),ORANGE),
                                (g,"中间方向 G",(-83,10),BLUE)]:
    ax.scatter(*point,c=color,s=50,zorder=4);label(ax,name,point,shift,color=color)
ax.set(xlim=(-100,2050),ylim=(-180,1800),xlabel="x / m",ylabel="y / m")
ax.set_aspect("equal");ax.grid(alpha=.12);ax.set_title("最不利方向距相邻站各 22.5°",fontproperties=CN)
fig.tight_layout();fig.savefig(OUT/"03_九站覆盖.png",dpi=200,bbox_inches="tight");plt.close(fig)

# Chapter 4: two probes cross the whole wedge, and the anchor-to-far-source
# segment intersects the probe segment inside it.
fig, ax=plt.subplots(figsize=(8.2,3.8))
triangle=np.array([[0.,0.],[12.,.6],[12.,-.6]])
ax.add_patch(Polygon(triangle,facecolor="#d9eee9",edgecolor=GREEN,lw=1.5,alpha=.6))
anchor=np.array((0.,0.));far=np.array((10.,.2));top=np.array((6.,1.));bottom=np.array((6.,-1.))
z=anchor+(6/10)*(far-anchor)
ax.plot([0,far[0]],[0,far[1]],c=BLUE,lw=2)
ax.plot([6,6],[-1,1],c=ORANGE,lw=3)
for point,name,shift in [(anchor,"正锚点 a",(5,8)),(far,"假设的远端 g",(-55,10)),
                         (top,"负探点 q+",(7,2)),(bottom,"负探点 q-",(7,-15)),
                         (z,"交点 z",(-50,6))]:
    ax.scatter(*point,s=44,c=GREEN if name.startswith("正") else BLUE if name.startswith("假") else ORANGE,zorder=4)
    label(ax,name,point,shift)
ax.set(xlim=(-.5,13.2),ylim=(-1.8,1.8))
finish(fig,ax,"04_成对负探测.png")

# Chapter 4: the directional discovery stations and one triangulated sector.
fig,ax=plt.subplots(figsize=(6.5,6.0))
inner=np.array([(995*math.cos(k*math.pi/4),995*math.sin(k*math.pi/4)) for k in range(8)])
outer=np.array([(1838*math.cos(k*math.pi/8),1838*math.sin(k*math.pi/8)) for k in range(16)])
ax.add_patch(Circle((0,0),1800,fill=False,ec=BLUE,lw=2,ls='--'))
ax.plot(*(np.vstack((outer,outer[0])).T),c=GREEN,lw=1.6)
ax.scatter(inner[:,0],inner[:,1],c=ORANGE,s=35,zorder=4)
ax.scatter(outer[:,0],outer[:,1],c=GREEN,s=27,zorder=4)
ax.scatter([0],[0],c=BLUE,s=55,zorder=4)
for points in ((np.array((0.,0.)),inner[0],inner[1]),
               (inner[0],outer[0],outer[1]),(inner[0],inner[1],outer[1]),
               (inner[1],outer[1],outer[2])):
    ax.add_patch(Polygon(points,fill=False,edgecolor=ORANGE,lw=1.8))
label(ax,"内环 8 点",inner[2],(8,5),color=ORANGE)
label(ax,"外环 16 点",outer[4],(-85,5),color=GREEN)
ax.text(-1700,-1300,"橙色：一个扇区的四个三角形",fontproperties=CN,color=ORANGE)
ax.set(xlim=(-2100,2100),ylim=(-2100,2150),xlabel="x / m",ylabel="y / m")
ax.set_aspect("equal");ax.grid(alpha=.12);ax.set_title("定向发现：位置落在某个小三角形内",fontproperties=CN)
fig.tight_layout();fig.savefig(OUT/"04_二十五站.png",dpi=200,bbox_inches="tight");plt.close(fig)

for name in ("01_两次角楔.png","02_三村庄包围圆.png","03_圆周覆盖但有洞.png","03_九站覆盖.png",
             "04_成对负探测.png","04_二十五站.png"):
    print(OUT/name)
