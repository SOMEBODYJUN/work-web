#!/usr/bin/env python3
"""Original hand-calculation figure for course/02; no copied textbook artwork."""
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.patches import Polygon


out = Path(__file__).resolve().parents[1] / "course" / "figures"
out.mkdir(parents=True, exist_ok=True)
points = np.array([[0.0, 0.0], [4.0, 0.0], [3.0, 3.0], [0.0, 2.0]])
ink, blue, orange = "#18334b", "#2674b8", "#e28a35"
fig, axes = plt.subplots(1, 2, figsize=(9.2, 4.4))
xs = np.linspace(-0.55, 4.5, 100)

for ax in axes:
    ax.add_patch(Polygon(points, facecolor=blue, alpha=0.09, edgecolor="none"))
    ax.add_patch(Polygon(points, fill=False, edgecolor=ink, linewidth=1.8))
    ax.scatter(points[:, 0], points[:, 1], color=ink, s=26, zorder=5)
    for name, (x, y) in zip("ABCD", points):
        offset = (-0.3, 0.11) if name in "AD" else (0.08, 0.11)
        ax.text(x + offset[0], y + offset[1], name, color=ink, fontsize=12)
    ax.set_xlim(-0.55, 4.55)
    ax.set_ylim(-1.8, 3.8)
    ax.set_aspect("equal")
    ax.grid(alpha=0.15)
    ax.spines[["top", "right"]].set_visible(False)
    ax.tick_params(labelsize=9)
    ax.set_xlabel("x")
    ax.set_ylabel("y")

axes[0].axhline(0, color=blue, linewidth=2.1)
axes[0].axhline(3, color=blue, linewidth=2.1)
axes[0].plot([3, 3], [0, 3], color=orange, linestyle="--", linewidth=1.5)
axes[0].text(3.14, 1.37, "height = 3", color=orange, fontsize=10)
axes[0].set_title("Edge AB: far support at C", color=ink, fontsize=12)

axes[1].plot(xs, xs / 3 + 2, color=blue, linewidth=2.1)
axes[1].plot(xs, (xs - 4) / 3, color=blue, linewidth=2.1)
# The perpendicular foot from B onto the line CD, x - 3y + 6 = 0.
foot = np.array([3.0, 3.0])
axes[1].plot([4, foot[0]], [0, foot[1]], color=orange, linestyle="--", linewidth=1.5)
axes[1].set_title("Edge CD: far support at B", color=ink, fontsize=12)
fig.tight_layout()
fig.savefig(out / "08_calipers.png", dpi=220, bbox_inches="tight")
plt.close(fig)
print(out / "08_calipers.png")
