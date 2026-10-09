#!/usr/bin/env python3
"""Verifies a prerendered PalEyes web build (non-production expectations).

Checks: every manifest route has its own HTML with a distinct title, a real
text summary and JSON-LD; non-production pages are noindex and robots.txt
disallows all; no internal route is prerendered; no sitemap in non-prod.
Usage: verify_prerender.py <build_dir> [--production]
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
build = Path(sys.argv[1])
production = "--production" in sys.argv
manifest = json.loads((ROOT / "tools/seo/public_routes.json").read_text(encoding="utf-8"))
failures: list[str] = []
titles = set()

for route in manifest["routes"]:
    path = route["path"]
    f = build / "index.html" if path == "/" else build / path.strip("/") / "index.html"
    if not f.is_file():
        failures.append(f"MISSING {path}")
        continue
    text = f.read_text(encoding="utf-8")
    m = re.search(r"<title>(.*?)</title>", text, re.S)
    title = m.group(1) if m else ""
    if title in titles or not title:
        failures.append(f"TITLE_NOT_DISTINCT {path}")
    titles.add(title)
    if "application/ld+json" not in text:
        failures.append(f"NO_JSON_LD {path}")
    if route["description_ar"] not in text:
        failures.append(f"NO_TEXT_SUMMARY {path}")
    if "flutter_bootstrap.js" not in text:
        failures.append(f"FLUTTER_SHELL_LOST {path}")
    expected = "index, follow" if production else "noindex, nofollow"
    if f'content="{expected}"' not in text:
        failures.append(f"ROBOTS_META_WRONG {path}")

for prefix in manifest["never_indexed_prefixes"]:
    if (build / prefix.strip("/") / "index.html").exists():
        failures.append(f"INTERNAL_ROUTE_PRERENDERED {prefix}")

robots = (build / "robots.txt").read_text(encoding="utf-8") if (build / "robots.txt").exists() else ""
if not production and "Disallow: /\n" not in robots:
    failures.append("NONPROD_ROBOTS_NOT_DISALLOW_ALL")
if not production and (build / "sitemap.xml").exists():
    failures.append("NONPROD_SITEMAP_PRESENT")

for f in failures:
    print("FAIL", f)
print(f"SEO_VERIFY_ROUTES={len(manifest['routes'])} FAILURES={len(failures)}")
sys.exit(1 if failures else 0)
