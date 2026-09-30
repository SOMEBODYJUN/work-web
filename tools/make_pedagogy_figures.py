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

# Q2: a safe station must lie in every candidate source's reception disk.
fig, ax = plt.subplots(figsize=(6.4, 4.5))
xx, yy = np.meshgrid(np.linspace(-3.1, 3.1, 420), np.linspace(-2.5, 2.5, 340))
g1, g2, radius = np.array((-1., 0.)), np.array((1., 0.)), 2.
safe = ((xx-g1[0])**2+(yy-g1[1])**2 <= radius**2) & ((xx-g2[0])**2+(yy-g2[1])**2 <= radius**2)
ax.contourf(xx, yy, safe.astype(float), levels=[.5, 1.5], colors=["#d9eee9"])
for g, label, color in [(g1, "g1", blue), (g2, "g2", orange)]:
    ax.add_patch(Circle(g, radius, fill=False, ec=color, lw=2))
    ax.scatter(*g, color=color, s=50, zorder=4)
    ax.annotate(label, g, xytext=(7, 8), textcoords="offset points", fontsize=11)
ax.scatter([0.], [0.], c=green, s=60, zorder=5)
ax.annotate("safe station s", (0,0), (.23,.28), arrowprops={"arrowstyle":"->"}, color=green)
ax.annotate("intersection of disks", (0,-1.5), (-2.5,-2.25),
            arrowprops={"arrowstyle":"->"}, color=green)
ax.set(xlim=(-3.1,3.1), ylim=(-2.5,2.5), xlabel="x", ylabel="y")
ax.set_aspect("equal"); ax.grid(alpha=.12)
fig.tight_layout(); fig.savefig(OUT/"04_q2_safe_stations.png",dpi=180,bbox_inches="tight"); plt.close(fig)
print(OUT/"04_q2_safe_stations.png")

# Q2: the far source on the opposite wedge edge determines the worst angle.
fig, ax = plt.subplots(figsize=(7.3, 4.5))
L, far_r, psi, eta = 1000., 1500., np.deg2rad(32.), np.deg2rad(-1.)
s = L*np.array((np.cos(psi), np.sin(psi)))
g = far_r*np.array((np.cos(eta), np.sin(eta)))
for angle in [-1., 1.]:
    unit=np.array((np.cos(np.deg2rad(angle)),np.sin(np.deg2rad(angle))))
    ax.plot([0,1600*unit[0]],[0,1600*unit[1]],ls="--",c=green,lw=1.5)
ax.plot([0,s[0]],[0,s[1]],color=blue,lw=2,label="baseline L")
ax.plot([0,g[0]],[0,g[1]],color=orange,lw=2,label="source range r")
ax.plot([s[0],g[0]],[s[1],g[1]],color="#bd3434",lw=2,label="reception distance")
ax.scatter([0,s[0],g[0]],[0,s[1],g[1]],c=[green,blue,orange],s=60,zorder=5)
ax.annotate("first site",(0,0),(95,-240));ax.annotate("second site s",s,(s[0]-330,s[1]+80))
ax.annotate("far source g",g,(g[0]-250,g[1]-230))
theta=np.linspace(0,psi,70);ax.plot(320*np.cos(theta),320*np.sin(theta),color=blue)
ax.annotate("psi",(300,100),(365,115),color=blue)
ax.annotate("opposite edge: |psi| + 1 deg",(800,-15),(470,-410),
            arrowprops={"arrowstyle":"->"},fontsize=9)
ax.set(xlim=(-150,1850),ylim=(-520,850),xlabel="x (m)",ylabel="y (m)")
ax.set_aspect("equal");ax.grid(alpha=.12);ax.legend(frameon=False,fontsize=8,loc="upper left")
fig.tight_layout();fig.savefig(OUT/"04_q2_worst_angle.png",dpi=180,bbox_inches="tight");plt.close(fig)
print(OUT/"04_q2_worst_angle.png")

# Q4: the elementary two-negative proof, before introducing the B-problem notation.
fig, ax = plt.subplots(figsize=(7.2, 3.5))
a = np.array((0.,0.)); g = np.array((8.,.1)); top = np.array((5.,.5)); bottom=np.array((5.,-.5))
z = a + (5/8)*(g-a)
ax.fill([0,10,10],[0,-.2,.2],color=pale,alpha=.55)
ax.plot([a[0],g[0]],[a[1],g[1]],color=blue,lw=2)
ax.plot([top[0],bottom[0]],[top[1],bottom[1]],color=orange,lw=3)
for name,pt,offset in [("a: positive",a,(5,15)),("q+: negative",top,(6,4)),("q-: negative",bottom,(6,-16)),("g: assumed far",g,(-12,15)),("z",z,(-23,6))]:
    ax.scatter(*pt,s=42,c=green if name.startswith("a") else orange if name.startswith("q") else blue,zorder=4)
    ax.annotate(name,pt,xytext=offset,textcoords="offset points",fontsize=9)
ax.annotate("z lies on both segments", (5,.0625), (5.55,-1.1),
            arrowprops={"arrowstyle":"->"},fontsize=9)
ax.set(xlim=(-.65,9.5),ylim=(-1.55,1.2),xlabel="x",ylabel="y")
ax.grid(alpha=.12)
fig.tight_layout();fig.savefig(OUT/"07_pair_negative_intro.png",dpi=180,bbox_inches="tight");plt.close(fig)
print(OUT/"07_pair_negative_intro.png")
