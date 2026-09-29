#!/usr/bin/env python3
"""Draw original teaching diagrams for the beginner course, not textbook reproductions."""
from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import Circle, Polygon, Wedge, FancyArrowPatch

OUT = Path(__file__).resolve().parents[1] / "course" / "figures"
OUT.mkdir(exist_ok=True, parents=True)
INK = "#18334b"
BLUE = "#2674b8"
ORANGE = "#e28a35"
GREEN = "#37856b"


def finish(fig, ax, name, xlim, ylim):
    ax.set_xlim(*xlim)
    ax.set_ylim(*ylim)
    ax.set_aspect("equal", adjustable="box")
    ax.spines[["top", "right"]].set_visible(False)
    ax.tick_params(labelsize=9, colors=INK)
    ax.grid(alpha=.13)
    fig.tight_layout()
    fig.savefig(OUT / name, dpi=220, bbox_inches="tight")
    plt.close(fig)


fig, ax = plt.subplots(figsize=(6, 4))
s = np.array([0., 0.])
ax.add_patch(Wedge(s, 3.7, 20, 40, color=BLUE, alpha=.16))
for a in (20, 30, 40):
    d = np.deg2rad(a)
    ax.plot([0, 3.7*np.cos(d)], [0, 3.7*np.sin(d)],
            ls="-" if a == 30 else "--", lw=2 if a == 30 else 1.5, c=INK if a == 30 else BLUE)
ax.scatter([0, 2.3*np.cos(np.deg2rad(34))], [0, 2.3*np.sin(np.deg2rad(34))], c=[INK, ORANGE], zorder=4)
ax.text(-.25, -.22, "S", fontsize=12)
ax.text(2.3*np.cos(np.deg2rad(34))+.08, 2.3*np.sin(np.deg2rad(34))+.08, "P", fontsize=12)
ax.text(3.05, .55, "20°", color=BLUE)
ax.text(2.9, 1.52, "40°", color=BLUE)
ax.text(2.5, 1.2, "30°", color=INK)
ax.set_xlabel("x"); ax.set_ylabel("y")
finish(fig, ax, "01_wedge.png", (-.4, 4), (-.4, 2.9))

fig, ax = plt.subplots(figsize=(6, 4))
p = np.array([[0,0],[1,-.35],[3,-.4],[4,1],[3.4,2.8],[1.1,3.2],[-.4,1.7],[1.6,.9],[2.5,1.5],[.7,1.7]])
outer = p[[0,1,2,3,4,5,6]]
ax.add_patch(Polygon(outer, fill=False, color=BLUE, lw=2.2))
ax.scatter(p[:,0],p[:,1], c=[BLUE]*7+[ORANGE]*3,zorder=4)
for i, (x,y) in enumerate(p): ax.text(x+.08,y+.07,chr(65+i), fontsize=10)
ax.set_xlabel("x"); ax.set_ylabel("y")
finish(fig, ax, "02_hull.png", (-.7,4.5),(-.8,3.7))

fig, ax = plt.subplots(figsize=(6,4))
square=np.array([[0,0],[4,0],[4,3],[0,3]])
cut=np.array([[2.8,0],[4,0],[4,3],[1.6,3]])
ax.add_patch(Polygon(square, fill=False, ls="--", lw=1.8, ec=INK))
ax.add_patch(Polygon(cut, facecolor=BLUE, alpha=.19, ec=BLUE, lw=2.5))
ax.plot([2.96,1.24],[-.4,3.9],c=ORANGE,lw=2)
ax.text(.1,3.45,"x + 0.4y = 2.8",c=ORANGE,fontsize=10)
ax.text(.2,2.8,"discard",c=ORANGE); ax.text(3.1,1.5,"keep",c=BLUE)
ax.set_xlabel("x");ax.set_ylabel("y")
finish(fig, ax, "03_clip.png", (-.5,4.5),(-.4,3.9))

fig, ax = plt.subplots(figsize=(6,4))
tri=np.array([[0,0],[4,0],[2,3]])
ax.add_patch(Polygon(tri,fill=False,ec=INK,lw=2))
center=np.array([2,5/6])
r=np.linalg.norm(tri[0]-center)
ax.add_patch(Circle(center,r,fill=False,ec=BLUE,lw=2.3))
ax.add_patch(Circle((2,0),2,fill=False,ec=ORANGE,lw=1.6,ls="--"))
ax.scatter(tri[:,0],tri[:,1],c=INK,zorder=4)
for s,(x,y) in zip("ABC",tri): ax.text(x+.08,y+.09,s)
ax.scatter(*center,c=BLUE);ax.text(center[0]+.08,center[1]+.09,"O",c=BLUE)
ax.text(3.4,2.2,"MEC",color=BLUE);ax.text(2.55,-1.8,"AB diameter",color=ORANGE)
ax.set_xlabel("x");ax.set_ylabel("y")
finish(fig, ax, "04_circle.png",(-.5,4.6),(-2.2,3.5))

fig, ax = plt.subplots(figsize=(6,4))
x=np.linspace(-1,5,300)
for f,c,label in [(lambda x:(x-.4)**2+1,BLUE,"case 1"),
                  (lambda x:(x-3.8)**2+.5,ORANGE,"case 2")]:
    ax.plot(x,f(x),c=c,lw=2,label=label)
envelope=np.maximum((x-.4)**2+1,(x-3.8)**2+.5)
ax.plot(x,envelope,c=INK,lw=2.3,ls="--",label="worst case")
idx=np.argmin(envelope)
ax.scatter([x[idx]],[envelope[idx]],c=GREEN,zorder=5)
ax.legend(frameon=False,fontsize=9)
ax.set_xlabel("decision x");ax.set_ylabel("loss");ax.set_ylim(0,18)
fig.tight_layout();fig.savefig(OUT/"05_minimax.png",dpi=220,bbox_inches="tight");plt.close(fig)

fig, ax=plt.subplots(figsize=(6,4))
P=np.array([[0,0],[3,0],[3,3],[0,3]])
N=np.array([1.65,1.0])
ax.add_patch(Polygon(P,fill=False,ec=INK,lw=2))
ax.plot([P[0,0],N[0],P[1,0]],[P[0,1],N[1],P[1,1]],c=ORANGE,lw=2.2)
ax.scatter(P[:,0],P[:,1],c=BLUE,zorder=4);ax.scatter(*N,c=ORANGE,zorder=5)
for s,(x,y) in zip("ABCD",P):ax.text(x+.08,y+.08,s)
ax.text(N[0]+.08,N[1]+.08,"N",c=ORANGE)
ax.text(.7,-.3,"replace AB by A-N-B",color=ORANGE)
ax.set_xlabel("x");ax.set_ylabel("y")
finish(fig,ax,"06_insertion.png",(-.45,3.6),(-.55,3.5))

fig,ax=plt.subplots(figsize=(6,4))
src=np.array([0.,0.]); a=np.array([2.4,1.4]);b=np.array([-2.4,-1.4])
ax.add_patch(Circle(src,2.8,fill=False,ec=BLUE,ls="--",lw=1.6))
ax.add_patch(Wedge(src,2.8,-40,140,alpha=.13,color=ORANGE))
boundary=np.array([np.cos(np.deg2rad(-40)),np.sin(np.deg2rad(-40))])
ax.plot([-3*boundary[0],3*boundary[0]],[-3*boundary[1],3*boundary[1]],color=ORANGE,lw=1.5)
ax.scatter([src[0],a[0],b[0]],[src[1],a[1],b[1]],c=[INK,BLUE,BLUE],zorder=4)
ax.text(.1,.15,"source");ax.text(a[0]+.08,a[1],"A");ax.text(b[0]+.08,b[1],"B")
ax.annotate("emission side",(0,1.7),(1.0,2.65),arrowprops={"arrowstyle":"->"},color=ORANGE)
ax.set_xlabel("x");ax.set_ylabel("y")
finish(fig,ax,"07_directional.png",(-3.2,3.2),(-3.1,3.2))

print(f"Created {len(list(OUT.glob('*.png')))} diagrams in {OUT}")
