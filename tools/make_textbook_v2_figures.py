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

for name in ("01_两次角楔.png","02_三村庄包围圆.png","04_成对负探测.png"):
    print(OUT/name)
