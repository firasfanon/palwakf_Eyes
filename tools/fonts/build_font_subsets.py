#!/usr/bin/env python3
"""Reproducible font subsetting for PalEyes (fontTools).

* Amiri (OFL, no Reserved Font Name) -> Arabic + Latin + punctuation subset.
* Engine fallback fonts that Flutter web otherwise downloads from
  fonts.gstatic.com are hosted locally under web/fonts/fallback/, at the
  exact relative paths the engine requests (it parses the bytes, not the
  extension): Roboto (OFL) and Noto Sans Arabic (OFL), pinned to wght 400 and
  subset.
* IBM Plex Sans Arabic carries the Reserved Font Name "Plex" and is therefore
  shipped UNMODIFIED.

Usage: build_font_subsets.py <google-fonts-checkout> <repo-root>
"""
from __future__ import annotations

import hashlib
import sys
from pathlib import Path

from fontTools import subset
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer

ARABIC = [(0x0600, 0x06FF), (0x0750, 0x077F), (0x08A0, 0x08FF),
          (0xFB50, 0xFDFF), (0xFE70, 0xFEFF)]
LATIN = [(0x0020, 0x007E), (0x00A0, 0x00FF), (0x2000, 0x206F), (0x20AC, 0x20AC),
         (0x2190, 0x2193), (0x2212, 0x2212), (0x25CC, 0x25CC)]


def unicodes(ranges):
    return [cp for lo, hi in ranges for cp in range(lo, hi + 1)]


def build(src: Path, dst: Path, ranges, pin: dict | None = None) -> None:
    font = TTFont(src)
    if pin and "fvar" in font:
        font = instancer.instantiateVariableFont(font, pin)
    options = subset.Options()
    options.layout_features = ["*"]
    options.name_IDs = ["*"]
    options.name_languages = ["*"]
    options.notdef_outline = True
    options.glyph_names = False
    options.hinting = False
    sub = subset.Subsetter(options)
    sub.populate(unicodes=unicodes(ranges))
    sub.subset(font)
    dst.parent.mkdir(parents=True, exist_ok=True)
    font.save(dst)
    digest = hashlib.sha256(dst.read_bytes()).hexdigest()
    print(f"{dst} {dst.stat().st_size} {digest}")


def main() -> int:
    gf, repo = Path(sys.argv[1]), Path(sys.argv[2])
    for weight in ("Regular", "Bold"):
        build(gf / f"ofl/amiri/Amiri-{weight}.ttf",
              repo / f"assets/fonts/amiri/Amiri-{weight}.ttf", ARABIC + LATIN)
    fallback = repo / "web/fonts/fallback"
    build(gf / "ofl/roboto/Roboto[wdth,wght].ttf",
          fallback / "roboto/v32/KFOmCnqEu92Fr1Me4GZLCzYlKw.woff2",
          LATIN, {"wght": 400, "wdth": 100})
    build(gf / "ofl/notosansarabic/NotoSansArabic[wdth,wght].ttf",
          fallback / "notosansarabic/v28/nwpxtLGrOAZMl5nJ_wfgRg3DrWFZWsnVBJ_sS6tlqHHFlhQ5l3sQWIHPqzCfyGyvvnCBFQLaig.woff2",
          ARABIC + [(0x0020, 0x0040)], {"wght": 400, "wdth": 100})
    for name in ("roboto", "notosansarabic"):
        (fallback / name / "OFL.txt").write_bytes((gf / f"ofl/{name}/OFL.txt").read_bytes())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
