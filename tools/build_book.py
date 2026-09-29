#!/usr/bin/env python3
"""Combine the seven Markdown chapters into editable Typst, PDF and EPUB.

Requires pandoc 3.x, typst, and a locally installed Noto Sans SC font.
Set TYPST_BIN and CJK_FONT_DIR if they are not on default search paths.
No downloaded font or executable is committed to this repository.
"""
from __future__ import annotations

import os
from pathlib import Path
import re
import shutil
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[1]
BOOK = ROOT / "book"
CHAPTERS = [
    BOOK / "00_导读与七天训练.md",
    BOOK / "01_通用方法与教材例题.md",
    BOOK / "02_Q1_Q2_从角楔到选址.md",
    BOOK / "03_Q3_全向源搜索定位清除.md",
    BOOK / "04_Q4_定向盲区与成对探测.md",
    BOOK / "05_源码地图与逐段精读.md",
    BOOK / "06_答辩追问与推导演练.md",
]
OUTPUT_STEM = BOOK / "无线电干扰源定位与清除_七天答辩教材"
FONT = "Noto Sans SC"


def run(args: list[str]) -> None:
    print("+", " ".join(map(str, args)))
    subprocess.run(args, cwd=ROOT, check=True)


def main() -> int:
    absent = [str(p.relative_to(ROOT)) for p in CHAPTERS if not p.is_file()]
    if absent:
        print("缺少章节：", ", ".join(absent), file=sys.stderr)
        return 2
    pandoc = shutil.which("pandoc")
    typst = os.environ.get("TYPST_BIN") or shutil.which("typst")
    font_dir = os.environ.get("CJK_FONT_DIR")
    if not pandoc or not typst or not font_dir:
        print("需提供 pandoc、Typst，以及含 Noto Sans SC 的 CJK_FONT_DIR。", file=sys.stderr)
        return 2
    if not Path(font_dir).is_dir():
        print("CJK_FONT_DIR 不是文件夹。", file=sys.stderr)
        return 2

    md = [str(p.relative_to(ROOT)) for p in CHAPTERS]
    typ_path = OUTPUT_STEM.with_suffix(".typ")
    pdf_path = OUTPUT_STEM.with_suffix(".pdf")
    epub_path = OUTPUT_STEM.with_suffix(".epub")
    common = [pandoc, *md, "-f", "markdown+tex_math_dollars+tex_math_single_backslash", "--toc",
              "--metadata", "title=无线电干扰源定位与清除：七天答辩教材",
              "--metadata", "lang=zh-CN"]

    run([*common, "-t", "typst", "-s", "-V", f"mainfont={FONT}",
         "-o", str(typ_path)])
    typ_source = typ_path.read_text(encoding="utf-8")
    # Pandoc 3.1 emits `sect` for TeX's intersection glyph, while Typst 0.15
    # calls that symbol `inter`. Define the alias rather than dropping math.
    typ_source = "#let sect = sym.inter\n" + typ_source
    typ_source = typ_source.replace('paper: "us-letter"', 'paper: "a4"')
    typ_source = typ_source.replace('margin: (x: 1.25in, y: 1.25in)',
                                    'margin: (x: 22mm, y: 20mm)')
    typ_source = typ_source.replace('lang: "en"', 'lang: "zh"')
    typ_source = typ_source.replace('region: "US"', 'region: "CN"')
    typ_source = typ_source.replace('fontsize: 11pt', 'fontsize: 10.5pt')
    # Keep the generated title and outline, then start each subsequent chapter
    # on a new page. A chapter begins with a top-level Typst heading.
    starts = list(re.finditer(r"(?m)^= [^\n]+$", typ_source))
    for match in reversed(starts[1:]):
        typ_source = typ_source[:match.start()] + "#pagebreak()\n" + typ_source[match.start():]
    typ_path.write_text(typ_source, encoding="utf-8")

    run([typst, "compile", "--font-path", font_dir, str(typ_path), str(pdf_path)])
    run([*common, "-t", "epub3", "-o", str(epub_path)])
    print("Created:", pdf_path, epub_path, typ_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
