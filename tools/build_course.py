#!/usr/bin/env python3
"""Build the beginner course (Markdown -> PDF) with Pandoc and XeLaTeX.

Usage:
  COURSE_CJK_FONT_DIR=/path/to/chinese/fonts python3 tools/build_course.py

The font directory is optional when Noto Serif CJK SC is installed system-wide.
The script creates any missing XeLaTeX format and font cache in a disposable
workspace; it never changes the system TeX installation.
"""
from __future__ import annotations

import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
from xml.sax.saxutils import escape


ROOT = Path(__file__).resolve().parents[1]
COURSE = ROOT / "course"
OUTPUT = COURSE / "从经典例题到B题_七天入门教材.pdf"
LESSONS = [
    COURSE / "00_怎样使用这本教材.md",
    COURSE / "01_从坐标到凸包与角楔.md",
    COURSE / "02_直径包围圆与鲁棒选址.md",
    COURSE / "03_覆盖路径与在线决策.md",
    COURSE / "04_集合定位与定向盲区.md",
    COURSE / "05_答辩练习与代码导航.md",
]


def run(args: list[str], *, env: dict[str, str], cwd: Path) -> None:
    result = subprocess.run(args, cwd=cwd, env=env, text=True, capture_output=True)
    if result.returncode:
        raise RuntimeError(
            f"{args[0]} 失败：\n" + (result.stdout + result.stderr)[-6000:]
        )


def main() -> int:
    missing = [str(p.relative_to(ROOT)) for p in LESSONS if not p.is_file()]
    if missing:
        raise SystemExit("缺少课程文件：" + "、".join(missing))
    for program in ("pandoc", "xelatex"):
        if not shutil.which(program):
            raise SystemExit(f"缺少 {program}，请先安装再构建 PDF。")

    with tempfile.TemporaryDirectory(prefix="_course_build_", dir=COURSE) as temporary:
        work = Path(temporary)
        env = os.environ.copy()
        env["TMPDIR"] = str(work)
        # Minimal TeX Live images may have the files but lack ls-R and formats.
        if not subprocess.run(["kpsewhich", "article.cls"], capture_output=True).stdout.strip():
            env["TEXMF"] = "{/usr/share/texmf,/usr/share/texlive/texmf-dist}"
        font_dir = os.environ.get("COURSE_CJK_FONT_DIR")
        if font_dir:
            directory = Path(font_dir).resolve()
            if not directory.is_dir():
                raise SystemExit(f"字库目录不存在：{directory}")
            font_config = work / "fontconfig.xml"
            font_config.write_text(
                '<?xml version="1.0"?>\n'
                '<!DOCTYPE fontconfig SYSTEM "fonts.dtd">\n'
                '<fontconfig>\n'
                '<include ignore_missing="yes">/etc/fonts/fonts.conf</include>\n'
                f"<dir>{escape(str(directory))}</dir>\n"
                f"<cachedir>{escape(str(work / 'font_cache'))}</cachedir>\n"
                "</fontconfig>\n", encoding="utf-8"
            )
            env["FONTCONFIG_FILE"] = str(font_config)
            run(["fc-cache", "-f", str(directory)], env=env, cwd=work)
        match = subprocess.run(
            ["fc-match", "-f", "%{family}", "Noto Serif CJK SC"],
            capture_output=True, text=True, env=env, check=True
        ).stdout
        if "Noto Serif CJK SC" not in match:
            raise SystemExit("缺少 Noto Serif CJK SC 字体；请设置 COURSE_CJK_FONT_DIR。")

        available_format = subprocess.run(
            ["kpsewhich", "xelatex.fmt"], capture_output=True, env=env
        ).stdout.strip()
        if not available_format:
            tex_root = Path("/usr/share/texlive/texmf-dist")
            latex_init = tex_root / "tex/latex/base/latex.ltx"
            if not latex_init.is_file() or not shutil.which("xetex"):
                raise SystemExit("本机 XeLaTeX 格式缺失且无法在临时目录生成。")
            run(
                ["xetex", "-ini", "-etex", "-jobname=xelatex", "-progname=xelatex",
                 rf"\input {latex_init}"],
                env=env, cwd=work
            )
            env["TEXFORMATS"] = f"{work}//:"

        # Enable natural Chinese line breaking without rewriting course text.
        header = work / "cjk.tex"
        header.write_text(
            '\\XeTeXlinebreaklocale "zh"\n'
            "\\XeTeXlinebreakskip = 0pt plus 1pt\n"
            "\\usepackage{fancyhdr}\n"
            "\\pagestyle{fancy}\\fancyhf{}\n"
            "\\fancyfoot[C]{\\thepage}\n"
            "\\renewcommand{\\headrulewidth}{0pt}\n",
            encoding="utf-8"
        )
        # Relative links inside a separately downloaded PDF should still open
        # the exact repository file. Images remain relative to course/.
        normalized = []
        for original in LESSONS:
            content = original.read_text(encoding="utf-8")
            content = re.sub(
                r"\]\(\.\./(source|examples|book)/",
                r"](https://github.com/SOMEBODYJUN/work-web/blob/main/\1/",
                content,
            )
            target = work / original.name
            target.write_text(content, encoding="utf-8")
            normalized.append(target)
        pandoc = [
            "pandoc", *(str(p) for p in normalized),
            "-f", "markdown+tex_math_single_backslash+tex_math_dollars",
            "--resource-path", str(COURSE),
            "--top-level-division=chapter",
            "--toc", "--toc-depth=1",
            "--pdf-engine=xelatex", "-H", str(header),
            "-V", "documentclass=report",
            "-V", "papersize=a4",
            "-V", "geometry:margin=20mm",
            "-V", "fontsize=11pt",
            "-V", "linestretch=1.2",
            "-V", "mainfont=Noto Serif CJK SC",
            "-V", "sansfont=Noto Sans CJK SC",
            "-M", "lang=zh-CN",
            "-M", "title=从经典例题到 B 题：七天答辩入门教材",
            "-M", "subtitle=先学方法，再做赛题，最后读源码",
            "-o", str(OUTPUT),
        ]
        run(pandoc, env=env, cwd=ROOT)
    print(f"已生成：{OUTPUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
