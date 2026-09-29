#!/usr/bin/env python3
"""Original diagrams for the verified OpenStax/CGAL geometry lesson data."""
from pathlib import Path
import math
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon, Arc

OUT = Path(__file__).resolve().parents[1] / "course" / "figures"
OUT.mkdir(parents=True, exist_ok=True)
BLUE, ORANGE, INK, GREEN = "#2674b8", "#e28a35", "#18334b", "#37856b"

def finish(fig, name):
    fig.tight_layout()
    fig.savefig(OUT / name, dpi=200, bbox_inches="tight")
    plt.close(fig)

def axes(ax):
    ax.set_aspect("equal", adjustable="box")
    ax.spines[["top", "right"]].set_visible(False)
    ax.grid(alpha=.15)
    ax.set_xlabel("x")
    ax.set_ylabel("y")

height = 20 * math.sin(math.radians(35)) * math.sin(math.radians(15)) / math.sin(math.radians(130))
x = height / math.tan(math.radians(15))
fig, ax = plt.subplots(figsize=(7, 3.2))
ax.plot([0, 20, x, 0], [0, 0, height, 0], color=INK, lw=2)
ax.plot([x, x], [0, height], color=BLUE, ls="--", lw=1.6)
ax.scatter([0, 20, x], [0, 0, height], color=INK)
ax.text(-.3, -.55, "A")
ax.text(20.05, -.55, "B")
ax.text(x, height+.25, "P")
ax.text(x+.25, 1.6, "h", color=BLUE)
ax.text(8.7, -.65, "20 miles")
ax.text(1.3, .12, "15°")
ax.text(17.2, .12, "35°")
ax.text(.3, 3.8, "AP / sin(35°) = 20 / sin(130°)", color=BLUE)
ax.set_xlim(-.7, 21)
ax.set_ylim(-1, 4.7)
ax.set_aspect("equal")
ax.axis("off")
finish(fig, "08_openstax_altitude.png")

P = {"A": (0, 0), "B": (10, 0), "C": (10, 10), "D": (6, 5), "E": (4, 1)}
fig, axs = plt.subplots(1, 2, figsize=(8.4, 4.2))
for ax in axs:
    for label, (px, py) in P.items():
        ax.scatter([px], [py], color=BLUE if label in "ABC" else ORANGE, zorder=4)
        ax.text(px+.25, py+.2, f"{label}({px},{py})", fontsize=9)
    axes(ax)
    ax.set_xlim(-1, 12)
    ax.set_ylim(-1, 12)
axs[0].set_title("Given five points", fontsize=11, color=INK)
axs[1].add_patch(Polygon([P[k] for k in "ABC"], fc=BLUE, alpha=.1, ec=BLUE, lw=2))
axs[1].plot([0, 10, 10, 0], [0, 0, 10, 0], color=BLUE, lw=2)
axs[1].set_title("Convex hull: A-B-C", fontsize=11, color=INK)
finish(fig, "09_cgal_hull.png")

fig, axs = plt.subplots(1, 3, figsize=(10.4, 3.7))
for ax, chain, title in zip(axs, ["AED", "AB", "ABC"], ["1. Keep A-E-D", "2. Add B: remove D, then E", "3. Add C: lower chain A-B-C"]):
    for label, (px, py) in P.items():
        ax.scatter([px], [py], color=BLUE if label in chain else "#aaa", zorder=4)
        ax.text(px+.2, py+.2, label, fontsize=10)
    ax.plot([P[k][0] for k in chain], [P[k][1] for k in chain], c=BLUE, lw=2)
    ax.set_title(title, fontsize=9, color=INK)
    axes(ax)
    ax.set_xlim(-1, 11.4)
    ax.set_ylim(-1, 11.4)
finish(fig, "10_cgal_lower_chain.png")

fig, axs = plt.subplots(1, 3, figsize=(9, 3.4))
for ax, y, title in zip(axs, [1, 0, -1], ["cross > 0: left", "cross = 0: collinear", "cross < 0: right"]):
    ax.annotate("", (3, 0), (0, 0), arrowprops={"arrowstyle": "->", "lw":2, "color":INK})
    ax.annotate("", (1.5, y), (0, 0), arrowprops={"arrowstyle": "->", "lw":2, "color":ORANGE})
    ax.text(-.12, -.28, "A")
    ax.text(3, -.28, "B")
    ax.text(1.55, y+.15, "P")
    ax.axhline(0, c="#ddd", lw=.8)
    ax.set_xlim(-.3, 3.5)
    ax.set_ylim(-1.4, 1.5)
    ax.set_aspect("equal")
    ax.set_title(title, fontsize=10, color=INK)
    ax.axis("off")
finish(fig, "11_cross_orientation.png")

print("Created the four geometry lesson diagrams.")
