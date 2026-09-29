#!/usr/bin/env python3
"""Check physical nonblank line coverage in the four code atlases.

This is a completeness check for line references, not a correctness review of
their explanations. Q3/Q4 official solvers duplicate their local solver prefix,
so only their appended client sections are required a second time.
"""
from __future__ import annotations

from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
ATLAS = ROOT / "course" / "code_atlas"
FILES = {
    "Q1": [("q1_solver.py", 1), ("q1_generator.py", 1), ("run.bat", 1)],
    "Q2": [("q2_solver.py", 1), ("q2_generator.py", 1), ("run.bat", 1)],
    "Q3": [("q3_local_solver.py", 1), ("q3_official_solver.py", 503),
           ("q3_local_simulator.py", 1), ("run_local.bat", 1), ("run_official.bat", 1)],
    "Q4": [("q4_local_solver.py", 1), ("q4_official_solver.py", 209),
           ("q4_local_simulator.py", 1), ("run_local.bat", 1), ("run_official.bat", 1)],
}
MARKER = re.compile(r"\[L(\d+)(?:[–—-]L?(\d+))?\]")


def sections(text: str, filenames: list[str]) -> dict[str, str]:
    output = {filename: [] for filename in filenames}
    current = None
    for line in text.splitlines():
        if line.startswith("## ") or line.startswith("### "):
            candidates = [name for name in filenames if name in line]
            # Longest match first prevents a hypothetical file suffix collision.
            if candidates:
                current = max(candidates, key=len)
            elif line.startswith("## "):
                current = None
        if current is not None:
            output[current].append(line)
    return {key: "\n".join(value) for key, value in output.items()}


def main() -> int:
    failed = False
    for q, files in FILES.items():
        path = ATLAS / f"{q}_逐行伴读.md"
        if not path.is_file():
            print(f"{q}: missing {path.relative_to(ROOT)}")
            failed = True
            continue
        chapter = sections(path.read_text(encoding="utf-8"), [n for n, _ in files])
        for filename, start in files:
            source = ROOT / "source" / q / filename
            lines = source.read_text(encoding="utf-8").splitlines()
            required = {i for i in range(start, len(lines) + 1) if lines[i - 1].strip()}
            covered = set()
            for a, b in MARKER.findall(chapter[filename]):
                first, last = int(a), int(b or a)
                if last < first or last > len(lines):
                    print(f"{q}/{filename}: invalid marker [{first},{last}]")
                    failed = True
                    continue
                covered.update(range(first, last + 1))
            missing = sorted(required - covered)
            print(f"{q}/{filename}: {len(required) - len(missing)}/{len(required)} nonblank lines covered")
            if missing:
                print("  missing:", missing[:60], "..." if len(missing) > 60 else "")
                failed = True
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
