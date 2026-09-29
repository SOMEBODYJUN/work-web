#!/usr/bin/env python3
"""Exact coordinates for the course's independent paired-probe teaching figure."""
from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

out = Path(__file__).resolve().parents[1] / "course" / "figures" / "q4_pair_probe.png"
out.parent.mkdir(exist_ok=True, parents=True)
delta = np.deg2rad(1.0051)
upper = 1000 * np.tan(delta)
fig, ax = plt.subplots(figsize=(8, 3.2))
ax.fill([0, 1000, 1000], [0, -upper, upper], color="#2674b8", alpha=.13)
ax.plot([0, 1000], [0, 0], color="#18334b", lw=.8, ls="--")
ax.plot([0, 1000], [0, upper], color="#2674b8", lw=1.2)
ax.plot([0, 1000], [0, -upper], color="#2674b8", lw=1.2)
ax.plot([500, 500], [-50, 50], color="#e28a35", lw=2.4)
ax.plot([0, 800], [0, 8], color="#37856b", lw=2.0)
ax.scatter([0, 800, 500, 500, 500], [0, 8, 50, -50, 5], c=["#18334b", "#37856b", "#e28a35", "#e28a35", "#37856b"], zorder=4)
for x, y, label, dy in [(0, 0, "anchor a", -13), (800, 8, "hypothetical g", 10), (500, 50, "q+", 10), (500, -50, "q-", -14), (500, 5, "z", 10)]:
    ax.annotate(label, (x, y), xytext=(5, dy), textcoords="offset points", fontsize=10)
ax.text(780, -42, "U = 1000\nq+/q-: (500, +/-50)", fontsize=9, color="#18334b")
ax.set_xlim(-80, 1080)
ax.set_ylim(-85, 85)
ax.set_xlabel("forward coordinate x (m)")
ax.set_ylabel("lateral y (m)")
ax.set_title("Probe segment crosses every ray in the bearing wedge", fontsize=11)
ax.spines[["top", "right"]].set_visible(False)
ax.grid(alpha=.15)
fig.text(.54, .015, "Vertical scale enlarged; use axis values for distances.", fontsize=8, ha="center")
fig.tight_layout(rect=[0, .045, 1, 1])
fig.savefig(out, dpi=220)
plt.close(fig)
print(out)
