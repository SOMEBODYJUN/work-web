#!/usr/bin/env python3
"""Build the seven-day teaching text from the new Markdown chapters.

Usage: COURSE_CJK_FONT_DIR=/path/to/static-cjk-fonts python3 tools/build_textbook_v2.py
"""
from __future__ import annotations

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
from xml.sax.saxutils import escape


ROOT = Path(__file__).resolve().parents[1]
BOOK = ROOT / "textbook_v2"
CHAPTERS = [BOOK / name for name in (
    "00_前言.md",
    "01_测向误差与凸区域.md",
    "02_包围圆与最坏选址.md",
    "03_覆盖与集合定位.md",
    "04_定向接收与双负测量.md",
    "05_路线与启发式.md",
    "06_七日训练与答案.md",
)]
OUTPUT = BOOK / "从普通例题学会四问_七天教材.pdf"


def checked(args: list[str], env: dict[str, str], cwd: Path) -> None:
    result = subprocess.run(args, cwd=cwd, env=env, text=True, capture_output=True)
    if result.returncode:
        lines = result.stdout + result.stderr
        errors = "\n".join(s for s in lines.splitlines() if s.startswith("!"))
        raise RuntimeError(f"{args[0]} failed ({result.returncode}):\n{errors}\n{lines[-2500:]}")


def main() -> None:
    missing = [p.name for p in CHAPTERS if not p.is_file()]
    if missing:
        raise SystemExit("尚待完成的章节：" + "、".join(missing))
    for program in ("pandoc", "xelatex", "fc-match"):
        if not shutil.which(program):
            raise SystemExit(f"缺少排版程序 {program}")
    with tempfile.TemporaryDirectory(prefix="_textbook_build_", dir=BOOK) as temporary:
        work = Path(temporary)
        env = os.environ.copy()
        env["TMPDIR"] = str(work)
        font_dir = os.environ.get("COURSE_CJK_FONT_DIR")
        if font_dir:
            directory = Path(font_dir).resolve()
            if not directory.is_dir():
                raise SystemExit("中文字体目录不存在：" + str(directory))
            config = work / "fontconfig.xml"
            config.write_text(
                '<?xml version="1.0"?><!DOCTYPE fontconfig SYSTEM "fonts.dtd">\n'
                '<fontconfig><include ignore_missing="yes">/etc/fonts/fonts.conf</include>'
                f'<dir>{escape(str(directory))}</dir>'
                f'<cachedir>{escape(str(work / "font_cache"))}</cachedir></fontconfig>',
                encoding="utf-8",
            )
            env["FONTCONFIG_FILE"] = str(config)
            checked(["fc-cache", "-f", str(directory)], env, work)
        for font in ("Noto Serif CJK SC", "Noto Sans CJK SC"):
            match = subprocess.run(["fc-match", "-f", "%{family}", font],
                                   env=env, text=True, capture_output=True, check=True).stdout
            if font not in match:
                raise SystemExit("找不到中文字体：" + font)
        if not subprocess.run(["kpsewhich", "article.cls"], capture_output=True).stdout.strip():
            env["TEXMF"] = "{/usr/share/texmf,/usr/share/texlive/texmf-dist}"
        if not subprocess.run(["kpsewhich", "xelatex.fmt"], capture_output=True, env=env).stdout.strip():
            latex_init = Path("/usr/share/texlive/texmf-dist/tex/latex/base/latex.ltx")
            checked(["xetex", "-ini", "-etex", "-jobname=xelatex", "-progname=xelatex",
                     rf"\input {latex_init}"], env, work)
            env["TEXFORMATS"] = f"{work}//:"

        header = work / "header.tex"
        header.write_text(
            '\\XeTeXlinebreaklocale "zh"\n'
            "\\XeTeXlinebreakskip = 0pt plus 1pt\n"
            "\\setmonofont{Noto Sans CJK SC}\n"
            "\\usepackage{fancyhdr}\n"
            "\\pagestyle{fancy}\\fancyhf{}\\fancyfoot[C]{\\thepage}\\renewcommand{\\headrulewidth}{0pt}\n",
            encoding="utf-8",
        )
        tex = work / "textbook.tex"
        checked([
            "pandoc", *(str(p) for p in CHAPTERS),
            "-f", "markdown+tex_math_single_backslash+tex_math_dollars",
            "-s", "-t", "latex", "-o", str(tex),
            "--resource-path", str(BOOK),
            "--top-level-division=chapter", "--toc", "--toc-depth=1",
            "-H", str(header),
            "-V", "documentclass=report", "-V", "papersize=a4",
            "-V", "geometry:margin=20mm", "-V", "fontsize=11pt",
            "-V", "linestretch=1.2", "-V", "mainfont=Noto Serif CJK SC",
            "-V", "sansfont=Noto Sans CJK SC", "-M", "lang=zh-CN",
            "-M", "title=从普通例题学会四问", "-M", "subtitle=七天纸笔与程序教材",
        ], env, work)
        figures = BOOK / "figures"
        if figures.is_dir():
            (work / "figures").symlink_to(figures, target_is_directory=True)
        for _ in range(3):
            checked(["xelatex", "-interaction=nonstopmode", "-halt-on-error", tex.name], env, work)
        shutil.copy2(work / "textbook.pdf", OUTPUT)
    print("已生成：" + str(OUTPUT))


if __name__ == "__main__":
    main()
