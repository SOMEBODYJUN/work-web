#!/usr/bin/env python3
"""Build the completely rewritten seven-day textbook.

Example: COURSE_CJK_FONT_DIR=/path/to/Noto-CJK-fonts python3 tools/build_textbook_v4.py
The directory must contain Noto Serif CJK SC and Noto Sans CJK SC OTF fonts.
"""
from __future__ import annotations

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
from xml.sax.saxutils import escape


ROOT = Path(__file__).resolve().parents[1]
BOOK = ROOT / "textbook_v4"
CHAPTERS = [BOOK / name for name in (
    "00_前言与问题.md",
    "01_有界观测与相容集.md",
    "02_凸区域与直径.md",
    "03_最小包围圆与选站.md",
    "04_连续目标与有限计算.md",
    "05_覆盖发现与安全清除.md",
    "06_定向源与成对探测.md",
    "07_路线启发式与在线决策.md",
    "08_七天练习与完整解答.md",
)]
OUTPUT = BOOK / "从有界观测到在线清除_七天理论教材.pdf"


def run(args: list[str], env: dict[str, str], cwd: Path) -> None:
    result = subprocess.run(args, cwd=cwd, env=env, text=True, capture_output=True)
    if result.returncode:
        lines = result.stdout + result.stderr
        errors = "\n".join(s for s in lines.splitlines() if s.startswith("!"))
        raise RuntimeError(f"{args[0]} failed:\n{errors}\n{lines[-3500:]}")


def main() -> None:
    missing = [p.name for p in CHAPTERS if not p.is_file()]
    if missing:
        raise SystemExit("Missing chapters: " + ", ".join(missing))
    for program in ("pandoc", "xelatex", "fc-match", "fc-cache"):
        if not shutil.which(program):
            raise SystemExit(f"Missing build dependency: {program}")
    with tempfile.TemporaryDirectory(prefix="v4_build_", dir=BOOK) as directory:
        work = Path(directory)
        env = os.environ.copy()
        env["TMPDIR"] = str(work)
        fonts = os.environ.get("COURSE_CJK_FONT_DIR")
        if fonts:
            path = Path(fonts).resolve()
            if not path.is_dir():
                raise SystemExit("CJK font directory does not exist")
            config = work / "fontconfig.xml"
            config.write_text(
                '<?xml version="1.0"?><!DOCTYPE fontconfig SYSTEM "fonts.dtd">\n'
                '<fontconfig><include ignore_missing="yes">/etc/fonts/fonts.conf</include>'
                f'<dir>{escape(str(path))}</dir>'
                f'<cachedir>{escape(str(work / "font_cache"))}</cachedir></fontconfig>',
                encoding="utf-8",
            )
            env["FONTCONFIG_FILE"] = str(config)
            run(["fc-cache", "-f", str(path)], env, work)
        for font in ("Noto Serif CJK SC", "Noto Sans CJK SC"):
            match = subprocess.run(["fc-match", "-f", "%{family}", font],
                                   env=env, text=True, capture_output=True, check=True).stdout
            if font not in match:
                raise SystemExit("CJK font missing: " + font)
        if not subprocess.run(["kpsewhich", "xelatex.fmt"], env=env,
                              capture_output=True).stdout.strip():
            latex_init = Path("/usr/share/texlive/texmf-dist/tex/latex/base/latex.ltx")
            run(["xetex", "-ini", "-etex", "-jobname=xelatex", "-progname=xelatex",
                 rf"\input {latex_init}"], env, work)
            env["TEXFORMATS"] = f"{work}//:"
        header = work / "header.tex"
        header.write_text(
            '\\XeTeXlinebreaklocale "zh"\n'
            '\\XeTeXlinebreakskip = 0pt plus 1pt\n'
            '\\setmonofont{Noto Sans CJK SC}\n'
            '\\usepackage{fancyhdr}\n'
            '\\pagestyle{fancy}\\fancyhf{}\\fancyfoot[C]{\\thepage}'
            '\\renewcommand{\\headrulewidth}{0pt}\n', encoding="utf-8")
        tex = work / "book.tex"
        run(["pandoc", *(str(p) for p in CHAPTERS),
             "-f", "markdown+tex_math_dollars+raw_tex", "-s", "-t", "latex",
             "-o", str(tex), "--top-level-division=chapter", "--toc", "--toc-depth=1",
             "-H", str(header), "-V", "documentclass=report", "-V", "papersize=a4",
             "-V", "geometry:margin=21mm", "-V", "fontsize=11pt", "-V", "linestretch=1.22",
             "-V", "secnumdepth=0", "-V", "mainfont=Noto Serif CJK SC",
             "-V", "sansfont=Noto Sans CJK SC", "-M", "lang=zh-CN",
             "-M", "title=从有界观测到在线清除",
             "-M", "subtitle=七天答辩理论教材：标准模型、证明与四问程序"], env, work)
        for _ in range(3):
            run(["xelatex", "-interaction=nonstopmode", "-halt-on-error", tex.name], env, work)
        shutil.copy2(work / "book.pdf", OUTPUT)
    print(OUTPUT)


if __name__ == "__main__":
    main()
