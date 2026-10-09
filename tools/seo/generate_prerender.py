#!/usr/bin/env python3
"""Build-time prerender of indexable HTML for PalEyes public routes (D5).

For each public route in tools/seo/public_routes.json, and for every
PUBLISHED record supplied with --published-json (rows exported from
pal_eyes.public_sites_v1), writes <build>/<route>/index.html: the same Flutter
shell with route-specific <title>, description, canonical, Open Graph,
JSON-LD and a real-text <noscript> summary. The Flutter app still boots on
top, so there is one public platform, not two.

Unpublished content is never written: the only content inputs are the static
route manifest and the published export. Non-production builds are
`noindex` and robots.txt disallows everything.

Usage:
  generate_prerender.py --build-dir build/web --environment staging
  generate_prerender.py --build-dir build/web --environment production \
      --site-url https://example.org --published-json published_sites.json
"""
from __future__ import annotations

import argparse
import html
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / "tools/seo/public_routes.json"


def page(shell: str, *, title: str, description: str, canonical: str | None,
         noindex: bool, json_ld: dict, summary_html: str, alternate_en: str | None) -> str:
    head = [
        f"<title>{html.escape(title)}</title>",
        f'<meta name="description" content="{html.escape(description, quote=True)}">',
        f'<meta property="og:title" content="{html.escape(title, quote=True)}">',
        f'<meta property="og:description" content="{html.escape(description, quote=True)}">',
        '<meta property="og:type" content="website">',
        '<meta property="og:locale" content="ar_PS">',
        f'<meta name="robots" content="{"noindex, nofollow" if noindex else "index, follow"}">',
    ]
    if canonical:
        head.append(f'<link rel="canonical" href="{html.escape(canonical, quote=True)}">')
        head.append(f'<meta property="og:url" content="{html.escape(canonical, quote=True)}">')
        head.append(f'<link rel="alternate" hreflang="ar" href="{html.escape(canonical, quote=True)}">')
        head.append(f'<link rel="alternate" hreflang="x-default" href="{html.escape(canonical, quote=True)}">')
    if alternate_en:
        head.append(f'<meta name="pal-eyes:title-en" content="{html.escape(alternate_en, quote=True)}">')
    head.append('<script type="application/ld+json">'
                + json.dumps(json_ld, ensure_ascii=False).replace("</", "<\\/")
                + "</script>")
    out = re.sub(r"<title>.*?</title>", "", shell, flags=re.S)
    out = re.sub(r'<meta name="description"[^>]*>', "", out)
    out = re.sub(r'<meta property="og:(title|description)"[^>]*>', "", out)
    out = out.replace("</head>", "  " + "\n  ".join(head) + "\n</head>", 1)
    out = re.sub(r"<noscript>.*?</noscript>",
                 f"<noscript>{summary_html}</noscript>", out, count=1, flags=re.S)
    return out


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--build-dir", required=True)
    ap.add_argument("--environment", required=True, choices=["local", "staging", "production"])
    ap.add_argument("--site-url", default="")
    ap.add_argument("--published-json", default="")
    args = ap.parse_args()

    build = Path(args.build_dir)
    shell_path = build / "index.html"
    if not shell_path.is_file():
        sys.exit("BUILD_INDEX_MISSING")
    shell = shell_path.read_text(encoding="utf-8")
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    production = args.environment == "production"
    site = args.site_url.rstrip("/")
    if production and not site.startswith("https://"):
        sys.exit("PRODUCTION_SITE_URL_REQUIRED (decision D7: final domain)")
    noindex = not production

    published = []
    if args.published_json:
        rows = json.loads(Path(args.published_json).read_text(encoding="utf-8"))
        for row in rows:
            if row.get("publication_status", "PUBLISHED") != "PUBLISHED":
                sys.exit(f"UNPUBLISHED_ROW_IN_EXPORT={row.get('slug')}")
            if row.get("slug"):
                published.append(row)

    written = []
    name_ar = manifest["site_name_ar"]
    for route in manifest["routes"]:
        path = route["path"]
        canonical = f"{site}{path}" if site else None
        ld = {"@context": "https://schema.org", "@type": "WebPage" if path != "/" else "WebSite",
              "name": route["title_ar"], "description": route["description_ar"], "inLanguage": "ar"}
        if canonical:
            ld["url"] = canonical
        summary = (f"<h1>{html.escape(route['title_ar'])}</h1>"
                   f"<p>{html.escape(route['description_ar'])}</p>"
                   f"<p lang=\"en\">{html.escape(route['description_en'])}</p>")
        content = page(shell, title=route["title_ar"], description=route["description_ar"],
                       canonical=canonical, noindex=noindex, json_ld=ld,
                       summary_html=summary, alternate_en=route["title_en"])
        target = build / "index.html" if path == "/" else build / path.strip("/") / "index.html"
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(content, encoding="utf-8")
        written.append(path)

    for row in published:
        path = f"/places/{row['slug']}"
        canonical = f"{site}{path}" if site else None
        title = f"{row.get('name_ar', '')} — {name_ar}"
        desc = (row.get("editorial_draft") or "")[:300]
        ld = {"@context": "https://schema.org", "@type": "Place", "name": row.get("name_ar", ""),
              "alternateName": row.get("name_en", ""), "description": desc,
              "address": {"@type": "PostalAddress", "addressRegion": row.get("governorate_ar", ""),
                          "addressLocality": row.get("locality_ar", ""), "addressCountry": "PS"}}
        if canonical:
            ld["url"] = canonical
        summary = f"<h1>{html.escape(row.get('name_ar', ''))}</h1><p>{html.escape(desc)}</p>"
        target = build / "places" / row["slug"] / "index.html"
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(page(shell, title=title, description=desc or title, canonical=canonical,
                               noindex=noindex, json_ld=ld, summary_html=summary, alternate_en=None),
                          encoding="utf-8")
        written.append(path)

    if production:
        robots = f"User-agent: *\nAllow: /\nDisallow: /workspace\nDisallow: /admin\nDisallow: /sign-in\nSitemap: {site}/sitemap.xml\n"
        urls = "".join(f"  <url><loc>{html.escape(site + p)}</loc></url>\n" for p in written)
        (build / "sitemap.xml").write_text(
            '<?xml version="1.0" encoding="UTF-8"?>\n'
            '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n' + urls + "</urlset>\n",
            encoding="utf-8")
    else:
        robots = "User-agent: *\nDisallow: /\n"
        stale = build / "sitemap.xml"
        if stale.exists():
            stale.unlink()
    (build / "robots.txt").write_text(robots, encoding="utf-8")

    print(f"SEO_ENVIRONMENT={args.environment}")
    print(f"SEO_NOINDEX={str(noindex).upper()}")
    print(f"SEO_ROUTES_WRITTEN={len(written)}")
    print(f"SEO_PUBLISHED_RECORDS={len(published)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
