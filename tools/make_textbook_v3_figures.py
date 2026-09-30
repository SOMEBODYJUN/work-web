#!/usr/bin/env python3
"""Rebuild exact schematic figures for the new theory text (not simulation data)."""
from pathlib import Path
import math
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Circle, Polygon, Wedge

OUT = Path(__file__).resolve().parents[1] / 'textbook_v3' / 'figures'
OUT.mkdir(parents=True, exist_ok=True)
BLUE, RED, GREEN = '#235a9f', '#a83244', '#2b785b'

def save(fig, name):
    fig.savefig(OUT/name, dpi=200, bbox_inches='tight', facecolor='white')
    plt.close(fig)

def axes(ax, lim):
    ax.set_aspect('equal')
    ax.set_xlim(*lim[0]); ax.set_ylim(*lim[1])
    ax.axhline(0, color='0.8', lw=.7); ax.axvline(0, color='0.8', lw=.7)
    ax.grid(alpha=.15)

fig, ax = plt.subplots(figsize=(6, 3.5))
axes(ax, ((-1, 6), (-3, 3)))
ax.add_patch(Wedge((0,0), 6, -20, 20, color=BLUE, alpha=.14))
ax.add_patch(Wedge((4,0), 6, 160, 200, color=RED, alpha=.14))
for x, color, lab in [(0, BLUE, r'$s_1$'), (4, RED, r'$s_2$')]:
    ax.scatter([x],[0], color=color, zorder=5); ax.text(x, -.35, lab, ha='center')
for a in [-20,20]:
    ax.plot([0,6*math.cos(math.radians(a))],[0,6*math.sin(math.radians(a))],color=BLUE,lw=1)
for a in [160,200]:
    ax.plot([4,4+6*math.cos(math.radians(a))],[0,6*math.sin(math.radians(a))],color=RED,lw=1)
ax.text(1.7,1.2, r'$W_1\cap W_2$')
ax.set_xlabel('$x$'); ax.set_ylabel('$y$')
save(fig,'01_wedges.png')

fig, ax = plt.subplots(figsize=(5.2, 4.2))
axes(ax, ((-1.2, 6.5), (-3.5, 4.5)))
ax.add_patch(Wedge((0,0),5, -18,18, color=BLUE,alpha=.13))
ax.add_patch(Circle((2.6,.7),3.4,fill=False,color=GREEN,lw=1.6))
ax.plot([0,5*math.cos(math.radians(-18))],[0,5*math.sin(math.radians(-18))],color=BLUE)
ax.plot([0,5*math.cos(math.radians(18))],[0,5*math.sin(math.radians(18))],color=BLUE)
ax.scatter([0,2.6],[0,.7],color=[BLUE,GREEN]); ax.text(-.25,-.3,'$s_1$'); ax.text(2.75,.8,'$s$')
ax.plot([0,2.6],[0,.7],ls='--',color='0.5')
ax.text(1.8,.2,r'$b$'); ax.text(3.8,3.4,r'$B(s,\rho_-)$',color=GREEN)
ax.set_xlabel('$x$'); ax.set_ylabel('$y$')
save(fig,'03_safe_station.png')

fig, ax = plt.subplots(figsize=(5.0, 5.0))
axes(ax, ((-1950,1950),(-1950,1950)))
ax.add_patch(Circle((0,0),1800,fill=False,color=RED,lw=2))
ax.add_patch(Circle((0,0),995,fill=False,color='0.55',ls='--'))
a=1800*math.cos(math.pi/8)-math.sqrt(995**2-(1800*math.sin(math.pi/8))**2)+1
for k in range(8):
    p=(a*math.cos(k*math.pi/4),a*math.sin(k*math.pi/4))
    ax.add_patch(Circle(p,995,fill=False,color=BLUE,alpha=.23,lw=1))
    ax.scatter(*p,s=22,color=BLUE)
ax.scatter([0],[0],s=30,color=GREEN)
ax.text(0,-150,'$0$',ha='center'); ax.text(1440,1440,r'$\Omega$',color=RED)
ax.set_xlabel('$x$ (m)'); ax.set_ylabel('$y$ (m)')
save(fig,'05_nine_sites.png')

fig, ax = plt.subplots(figsize=(6,3.8))
axes(ax, ((-1, 11),(-3,4)))
a=np.array([0.,0.]); g=np.array([9.,.6]); q1=np.array([5.,.5]); q2=np.array([5.,-.5]); q0=np.array([5.,1/3])
ax.add_patch(Wedge((0,0),10,-12,12,color=BLUE,alpha=.1))
ax.plot([a[0],g[0]],[a[1],g[1]],color=GREEN,lw=2)
ax.plot([q2[0],q1[0]],[q2[1],q1[1]],color=RED,lw=2)
for p,label,col,offset in [(a,'$a$',BLUE,(-.4,-.4)),(g,'$g$',GREEN,(.2,.2)),(q1,'$q_+$',RED,(.2,.2)),(q2,'$q_-$',RED,(.2,-.4)),(q0,'$q_0$',GREEN,(.18,-.48))]:
    ax.scatter(*p,color=col,zorder=5,s=24); ax.text(p[0]+offset[0],p[1]+offset[1],label)
ax.axvline(5,color='0.5',ls='--',lw=1)
ax.text(4.7,-2.6,r'$t=\lambda U$')
ax.set_xlabel('$u$ direction'); ax.set_ylabel('$v$ direction')
save(fig,'07_pair_crossing.png')

fig, ax = plt.subplots(figsize=(6,2.8))
axes(ax, ((-1,11),(-1,4.8)))
p=np.array([0,0]); b=np.array([10,0]); x=np.array([4,3])
ax.plot([p[0],b[0]],[p[1],b[1]],color='0.45',lw=2,label=r'$d(p,b)$')
ax.plot([p[0],x[0],b[0]],[p[1],x[1],b[1]],color=BLUE,lw=2,label=r'$d(p,x)+d(x,b)$')
for v,label in [(p,'$p$'),(x,'$x$'),(b,'$b$')]:
    ax.scatter(*v,color=RED,zorder=5);ax.text(v[0]+.15,v[1]+.15,label)
ax.legend(loc='upper right',frameon=False)
ax.set_xlabel('$x$'); ax.set_ylabel('$y$')
save(fig,'08_insertion.png')
print('figures:', len(list(OUT.glob('*.png'))))
