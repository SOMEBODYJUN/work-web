#!/usr/bin/env python3
"""Draw three first-reading diagrams used in Lessons 5–7."""
from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import Circle, Polygon, Wedge

OUT = Path(__file__).resolve().parents[1] / "course" / "figures"
OUT.mkdir(parents=True, exist_ok=True)
blue, green, orange, pale = "#235478", "#14816f", "#d37936", "#d7e7ed"

# Q3: disk coverage and the worst angular gap between adjacent ring sites.
fig, axes = plt.subplots(1, 2, figsize=(10.2, 4.4))
D, a, r0 = 1800, 945.9734, 999
ring = np.array([[a*np.cos(k*np.pi/4), a*np.sin(k*np.pi/4)] for k in range(8)])
ax = axes[0]
ax.add_patch(Circle((0, 0), D, fill=False, ec=blue, lw=2))
ax.add_patch(Circle((0, 0), r0, facecolor=pale, edgecolor=green, lw=1.5, alpha=.55))
ax.scatter(ring[:,0],ring[:,1],s=33,c=orange,zorder=4)
ax.scatter([0],[0],s=50,c=green,zorder=4)
for xy in ring:
    ax.add_patch(Circle(xy, r0, fill=False, ec=orange, lw=.65, alpha=.42))
ax.annotate("O", (0,0), (80,-250), fontsize=11)
ax.annotate("arena", (0,D), (80,D+120),fontsize=11,color=blue)
ax.set_title("Eight ring sites and one central site")
ax.set_xlim(-2950,2950);ax.set_ylim(-2950,2950);ax.set_aspect("equal");ax.grid(alpha=.13)
ax = axes[1]
ang=np.linspace(0,np.pi/4,90)
ax.plot(D*np.cos(ang),D*np.sin(ang),color=blue,lw=2,label="arena boundary")
ax.scatter([0,a,a*np.cos(np.pi/4)],[0,0,a*np.sin(np.pi/4)],c=[green,orange,orange],s=60)
mid=(D*np.cos(np.pi/8),D*np.sin(np.pi/8))
ax.scatter([mid[0]],[mid[1]],color="#bd3434",s=65,zorder=5)
ax.plot([0,mid[0]],[0,mid[1]],ls=":",c=blue,lw=1.5)
ax.plot([a,mid[0]],[0,mid[1]],color=orange,lw=2)
ax.annotate("O", (0,0), (-80,-180));ax.annotate("S0",(a,0),(a+50,-190))
ax.annotate("S1",(a*np.cos(np.pi/4),a*np.sin(np.pi/4)),(a*np.cos(np.pi/4)-100,a*np.sin(np.pi/4)+80))
ax.annotate("G: half-gap 22.5 deg",mid,(mid[0]-800,mid[1]+270),arrowprops={"arrowstyle":"->"})
ax.set_title("Worst boundary direction between S0 and S1")
ax.set_xlim(-150,2150);ax.set_ylim(-300,1550);ax.set_aspect("equal");ax.grid(alpha=.13)
for ax in axes:ax.set_xlabel("x (m)");ax.set_ylabel("y (m)")
fig.tight_layout();fig.savefig(OUT/"05_q3_nine_sites.png",dpi=180,bbox_inches="tight");plt.close(fig)

# Q3 set-membership: removing a disk is exact; a convex outer hull fills its hole.
fig, axes=plt.subplots(1,3,figsize=(10.5,3.8))
square=np.array([[-2,-2],[2,-2],[2,2],[-2,2]])
titles=["Initial candidates P","Exact P outside a disk","Convex outer hull"]
for ax,title in zip(axes,titles):
    ax.add_patch(Polygon(square,facecolor=pale,edgecolor=blue,lw=2))
    ax.set_title(title);ax.set_xlim(-2.7,2.7);ax.set_ylim(-2.7,2.7)
    ax.set_aspect("equal");ax.grid(alpha=.12);ax.set_xlabel("x");ax.set_ylabel("y")
axes[1].add_patch(Circle((0,0),1.05,facecolor="white",edgecolor=orange,lw=2))
axes[1].annotate("removed",(0,0),(-.83,.15),color=orange)
axes[2].add_patch(Circle((0,0),1.05,fill=False,ec=orange,ls="--",lw=1.2))
axes[2].annotate("hole filled",(0,0),(-1.05,.15),color=orange)
fig.tight_layout();fig.savefig(OUT/"06_negative_outer_hull.png",dpi=180,bbox_inches="tight");plt.close(fig)

# Q4: center + two rings, with a 45-degree annular sector triangulated.
inner=np.array([[995*np.cos(k*np.pi/4),995*np.sin(k*np.pi/4)] for k in range(8)])
outer=np.array([[1838*np.cos(j*np.pi/8),1838*np.sin(j*np.pi/8)] for j in range(16)])
fig, axes=plt.subplots(1,2,figsize=(10.4,4.8))
ax=axes[0]
ax.add_patch(Circle((0,0),1800,fill=False,ec=blue,ls="--",lw=1.5))
for points,close in [(inner,True),(outer,True)]:
    closed=np.vstack([points,points[0]]) if close else points
    ax.plot(closed[:,0],closed[:,1],color=blue,lw=1.0,alpha=.62)
ax.scatter(inner[:,0],inner[:,1],s=28,c=green,label="8 inner")
ax.scatter(outer[:,0],outer[:,1],s=24,c=orange,label="16 outer")
ax.scatter([0],[0],s=48,c=blue,label="center")
ax.set_title("25 scanning sites");ax.legend(frameon=False,fontsize=8,loc="lower left")
ax.set_aspect("equal");ax.set_xlim(-2100,2100);ax.set_ylim(-2100,2100);ax.grid(alpha=.12)
ax=axes[1]
O=np.array((0.,0.));I0=inner[0];I1=inner[1];E0=outer[0];E1=outer[1];E2=outer[2]
pieces=[([O,I0,I1],"center"),([I0,E0,E1],"T1"),([I0,E1,I1],"T2"),([I1,E1,E2],"T3")]
colors=["#e6e9f4","#f8ead8","#d9eee9","#efe3f5"]
for (tri,label),color in zip(pieces,colors):
    ax.add_patch(Polygon(tri,facecolor=color,edgecolor=blue,lw=1.5))
    ctr=np.mean(tri,axis=0);ax.text(ctr[0],ctr[1],label,fontsize=9,ha="center",va="center")
for label,point in [("O",O),("I0",I0),("I1",I1),("E0",E0),("E1",E1),("E2",E2)]:
    ax.scatter(*point,color=orange if label.startswith("E") else green,s=47,zorder=4)
    ax.annotate(label,point,xytext=(7,5),textcoords="offset points",fontsize=10)
arc=np.linspace(0,np.pi/4,80)
ax.plot(1800*np.cos(arc),1800*np.sin(arc),ls="--",c="#bc3d3d",lw=1.4)
ax.set_title("One 45-degree sector: center and T1–T3")
ax.set_aspect("equal");ax.set_xlim(-150,2100);ax.set_ylim(-120,1600);ax.grid(alpha=.12)
for ax in axes:ax.set_xlabel("x (m)");ax.set_ylabel("y (m)")
fig.tight_layout();fig.savefig(OUT/"07_q4_25_stations.png",dpi=180,bbox_inches="tight");plt.close(fig)
for name in ["05_q3_nine_sites.png","06_negative_outer_hull.png","07_q4_25_stations.png"]:
    print(OUT/name)

# One-dimensional golden-section search: the excluded interval and point reuse.
fig, axes = plt.subplots(2, 1, figsize=(8.2, 5.2), gridspec_kw={"height_ratios": [2, 1.3]})
ax = axes[0]
x = np.linspace(0, 5, 400)
f = lambda z: (z-2)**2+1
c, d, new_left = 1.909830, 3.090170, 1.180340
ax.axvspan(d, 5, color="#e8e8e8", alpha=.9)
ax.plot(x, f(x), color=blue, lw=2)
ax.scatter([c,d],[f(c),f(d)],c=[green,orange],s=62,zorder=3)
ax.annotate("c = 1.909830",(c,f(c)),(1.1,3.9),arrowprops=dict(arrowstyle="->"),color=green)
ax.annotate("d = 3.090170",(d,f(d)),(3.1,7.0),arrowprops=dict(arrowstyle="->"),color=orange)
ax.text(3.45,14.8,"discard [d,5]",color="#666666")
ax.set_xlim(0,5);ax.set_ylim(0,17.5);ax.set_ylabel("f(x)");ax.grid(alpha=.13)
ax=axes[1]
rows=[(0,5,"start"),(0,d,"after first comparison"),(new_left,d,"after second comparison")]
for j,(left,right,name) in enumerate(rows):
    y=2-j
    ax.plot([left,right],[y,y],lw=5,color=blue if j==0 else green,solid_capstyle="round")
    ax.plot([left,right],[y,y],"o",color=blue if j==0 else green,ms=5)
    ax.text(5.14,y,name,va="center",fontsize=9)
    if j>0: ax.scatter([c],[y],s=64,c=orange,zorder=4)
ax.annotate("reused c",(c,0),(2.55,.3),arrowprops=dict(arrowstyle="->"),color=orange)
ax.set_xlim(-.2,6.8);ax.set_ylim(-.35,2.4);ax.set_yticks([]);ax.set_xlabel("x");ax.grid(axis="x",alpha=.13)
fig.tight_layout();fig.savefig(OUT/"12_golden_section.png",dpi=180,bbox_inches="tight");plt.close(fig)
print(OUT/"12_golden_section.png")
