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
ATLAS_OUTPUT = COURSE / "四问源码逐行伴读_练习与答案.pdf"
LESSONS = [
    COURSE / "00_怎样使用这本教材.md",
    COURSE / "10_四问统一题设与模型总图.md",
    COURSE / "08_七天训练与标准解答.md",
    COURSE / "01_从坐标到凸包与角楔.md",
    COURSE / "02_直径包围圆与鲁棒选址.md",
    COURSE / "03_覆盖路径与在线决策.md",
    COURSE / "04_集合定位与定向盲区.md",
    COURSE / "09_从模型到程序的逐行追踪.md",
    COURSE / "11_关键循环的执行轨迹与答案.md",
    COURSE / "12_真实复算与动作计时.md",
    COURSE / "05_答辩练习与代码导航.md",
]
ATLASES = [COURSE / "code_atlas" / f"Q{i}_逐行伴读.md" for i in range(1, 5)]


def run(args: list[str], *, env: dict[str, str], cwd: Path) -> None:
    result = subprocess.run(args, cwd=cwd, env=env, text=True, capture_output=True)
    if result.returncode:
        errors = "\n".join(
            line for line in (result.stdout + result.stderr).splitlines()
            if line.startswith("!") or "Error producing PDF" in line or "Fatal error" in line
        )
        raise RuntimeError(
            f"{args[0]} 失败 (exit {result.returncode})：\n" + errors + "\n"
            + (result.stdout + result.stderr)[:2200] + "\n...\n"
            + (result.stdout + result.stderr)[-800:]
        )


def main() -> int:
    missing = [str(p.relative_to(ROOT)) for p in LESSONS + ATLASES if not p.is_file()]
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
        def available_font(candidates: list[str]) -> str:
            for candidate in candidates:
                match = subprocess.run(
                    ["fc-match", "-f", "%{family}", candidate],
                    capture_output=True, text=True, env=env, check=True
                ).stdout
                if candidate in match:
                    return candidate
            raise SystemExit("缺少中文 Noto 字体；请设置 COURSE_CJK_FONT_DIR。")

        # Static CJK OTFs work with XeTeX/xdvipdfmx; the variable SC TTFs may
        # match fontconfig but fail when embedded into the final PDF.
        serif_font = available_font(["Noto Serif CJK SC"])
        sans_font = available_font(["Noto Sans CJK SC"])

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
        atlas_header = work / "atlas_header.tex"
        atlas_header.write_text(
            header.read_text(encoding="utf-8")
            + "\\usepackage{fvextra}\n\\setmonofont{Noto Sans CJK SC}\n"
            + "\\sloppy\n\\emergencystretch=3em\n",
            encoding="utf-8",
        )
        # Relative links inside a separately downloaded PDF should still open
        # the exact repository file. Images remain relative to course/.
        for chapters, output, title, subtitle in [
            (LESSONS, OUTPUT, "从经典例题到 B 题：七天答辩入门教材", "先学方法，再做赛题，最后读源码"),
            (ATLASES, ATLAS_OUTPUT, "四问源码逐行伴读", "公式链、程序语句与带答案练习"),
        ]:
            is_atlas = output == ATLAS_OUTPUT
            normalized = []
            for original in chapters:
                content = original.read_text(encoding="utf-8")
                content = re.sub(
                    r"\]\(\.\./(source|examples|book)/",
                    r"](https://github.com/SOMEBODYJUN/work-web/blob/main/\1/",
                    content,
                )
                target = work / original.name
                target.write_text(content, encoding="utf-8")
                normalized.append(target)
            if is_atlas:
                # The atlas explanations cite physical line numbers. Include
                # the exact source text as a searchable appendix so this PDF
                # remains usable without an editor or a network connection.
                appendix = work / "source_listing.md"
                groups = {
                    1: ["q1_solver.py", "q1_generator.py", "run.bat"],
                    2: ["q2_solver.py", "q2_generator.py", "run.bat"],
                    3: ["q3_local_solver.py", "q3_official_solver.py", "q3_local_simulator.py",
                        "run_local.bat", "run_official.bat"],
                    4: ["q4_local_solver.py", "q4_official_solver.py", "q4_local_simulator.py",
                        "run_local.bat", "run_official.bat"],
                }
                listing = ["# 附录　带物理行号的原始源码", "",
                           "前面每个 `[Lxxx]` 对应这里的原始物理行。空行也列出；"
                           "Q3/Q4 正式版与本地版相同的前缀只印一次。",
                           "长行在纸面折行时仍属于同一物理行。", ""]
                for q, filenames in groups.items():
                    for filename in filenames:
                        source = ROOT / "source" / f"Q{q}" / filename
                        start = (503 if q == 3 else 209) if filename.endswith("official_solver.py") else 1
                        physical = source.read_text(encoding="utf-8").splitlines()
                        if start > 1:
                            listing.append(
                                f"## `source/Q{q}/{filename}`（第 {start} 行起；前缀见本地版）"
                            )
                        else:
                            listing.append(f"## `source/Q{q}/{filename}`")
                        listing += ["", r"\begin{Verbatim}[fontsize=\scriptsize,breaklines=true,breakanywhere=true]"]
                        listing.extend(f"{i:04d} | {line}" for i, line in enumerate(physical, 1) if i >= start)
                        listing += [r"\end{Verbatim}", ""]
                dep = ROOT / "source" / "requirements.txt"
                listing += ["## `source/requirements.txt`", "",
                            r"\begin{Verbatim}[fontsize=\scriptsize,breaklines=true,breakanywhere=true]"]
                listing.extend(f"{i:04d} | {line}" for i, line in enumerate(dep.read_text(encoding="utf-8").splitlines(), 1))
                listing += [r"\end{Verbatim}", ""]
                appendix.write_text("\n".join(listing), encoding="utf-8")
                normalized.append(appendix)
            pandoc = [
                "pandoc", *(str(p) for p in normalized),
                "-f", "markdown+tex_math_single_backslash+tex_math_dollars",
                "--resource-path", str(COURSE),
                "--top-level-division=chapter",
                "--toc", "--toc-depth=1",
                "--pdf-engine=xelatex", "-H", str(atlas_header if is_atlas else header),
                "-V", "documentclass=report",
                "-V", "papersize=a4",
                "-V", "geometry:margin=20mm",
                "-V", f"fontsize={'10pt' if is_atlas else '11pt'}",
                "-V", f"linestretch={'1.15' if is_atlas else '1.2'}",
                "-V", f"mainfont={serif_font}",
                "-V", f"sansfont={sans_font}",
                "-M", "lang=zh-CN",
                "-M", f"title={title}",
                "-M", f"subtitle={subtitle}",
                "-o", str(output),
            ]
            run(pandoc, env=env, cwd=ROOT)
            print(f"已生成：{output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
