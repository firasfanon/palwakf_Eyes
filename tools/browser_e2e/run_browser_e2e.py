#!/usr/bin/env python3
"""Real-browser E2E for PalEyes Flutter web builds (Playwright Chromium).

Profiles: desktop 1440x900 and true mobile emulation 390x844 (DPR 3, touch,
mobile UA). Each journey asserts the final URL, zero uncaught page errors,
no Google Fonts CDN dependency, and a non-blank screenshot.

Usage: run_browser_e2e.py <build_dir> <out_dir> <label> <journeys.json>
"""
from __future__ import annotations

import functools
import http.server
import json
import os
import socket
import sys
import threading
import time
from pathlib import Path

from playwright.sync_api import sync_playwright

try:
    from PIL import Image, ImageStat
except ImportError:  # pragma: no cover
    Image = None

build_dir, out_dir, label, journeys_path = sys.argv[1:5]
out = Path(out_dir)
out.mkdir(parents=True, exist_ok=True)
journeys = json.loads(Path(journeys_path).read_text(encoding="utf-8"))


class SpaHandler(http.server.SimpleHTTPRequestHandler):
    def send_head(self):
        path = self.translate_path(self.path.split("?")[0])
        if os.path.isdir(path) and os.path.exists(os.path.join(path, "index.html")):
            self.path = self.path.split("?")[0].rstrip("/") + "/index.html"
        elif not os.path.exists(path):
            last = self.path.split("?")[0].rstrip("/").rsplit("/", 1)[-1]
            if "." in last:
                # A missing asset is a real 404, never the SPA shell.
                self.send_error(404)
                return None
            self.path = "/index.html"
        return super().send_head()

    def log_message(self, *args):
        pass


sock = socket.socket()
sock.bind(("127.0.0.1", 0))
port = sock.getsockname()[1]
sock.close()
server = http.server.ThreadingHTTPServer(
    ("127.0.0.1", port), functools.partial(SpaHandler, directory=build_dir)
)
threading.Thread(target=server.serve_forever, daemon=True).start()
base = f"http://127.0.0.1:{port}"

PROFILES = {
    "desktop": dict(viewport={"width": 1440, "height": 900}, device_scale_factor=1),
    "mobile390": dict(
        viewport={"width": 390, "height": 844},
        device_scale_factor=3,
        is_mobile=True,
        has_touch=True,
        user_agent=(
            "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 "
            "(KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        ),
    ),
}

results = []
allowed_external = tuple(journeys.get("allowed_external_prefixes", []))

with sync_playwright() as p:
    browser = p.chromium.launch()
    for profile, options in PROFILES.items():
        context = browser.new_context(locale="ar", **options)
        external: list[str] = []

        def make_router(sink: list[str]):
            def handle(r):
                url = r.request.url
                if url.startswith(base):
                    return r.continue_()
                sink.append(url)
                return r.abort()
            return handle

        context.route("**/*", make_router(external))
        for j in journeys["journeys"]:
            page = context.new_page()
            errors: list[str] = []
            missing: list[str] = []
            page.on("response", (lambda sink: lambda r: sink.append(f"{r.status} {r.url}")
                                 if r.url.startswith(base) and r.status >= 400 else None)(missing))
            page.on("pageerror", (lambda sink: lambda e: sink.append(str(e)))(errors))
            start = time.time()
            page.goto(base + j["path"], wait_until="load")
            try:
                page.wait_for_selector("flutter-view, flt-glass-pane", timeout=30000)
            except Exception:  # noqa: BLE001
                errors.append("FLUTTER_VIEW_NOT_MOUNTED")
            page.wait_for_timeout(j.get("settle_ms", 6000))
            name = f"{label}_{profile}_{j['id']}.png"
            page.screenshot(path=str(out / name))
            final_path = page.url[len(base):] or "/"
            expected = j.get("expect_path", j["path"])
            blank = False
            if Image is not None:
                stat = ImageStat.Stat(Image.open(out / name).convert("L"))
                blank = stat.stddev[0] < 4
            checks = {
                "final_path": final_path.split("#")[0] == expected,
                "no_page_errors": not errors,
                "not_blank": not blank,
                "no_same_origin_4xx": not missing,
            }
            results.append({
                "label": label, "profile": profile, "journey": j["id"],
                "path": j["path"], "final_path": final_path, "expected_path": expected,
                "seconds": round(time.time() - start, 1), "screenshot": name,
                "page_errors": errors[:5], "same_origin_4xx": missing[:10], "checks": checks,
                "passed": all(checks.values()),
            })
            print(("PASS " if all(checks.values()) else "FAIL ") + f"{profile} {j['id']} -> {final_path} {checks}")
            page.close()
        bad_external = sorted({u for u in external if not u.startswith(allowed_external)})
        cdn_fonts = sorted({u for u in external if "fonts.gstatic.com" in u or "fonts.googleapis.com" in u})
        results.append({
            "label": label, "profile": profile, "journey": "network-policy",
            "external_requests_blocked": sorted(set(external))[:60],
            "disallowed_external": bad_external[:60],
            "google_fonts_requests": cdn_fonts,
            "passed": not cdn_fonts and not bad_external,
        })
        print(("PASS " if not cdn_fonts and not bad_external else "FAIL ")
              + f"{profile} network-policy fonts={len(cdn_fonts)} disallowed={len(bad_external)}")
        context.close()
    browser.close()

server.shutdown()
failed = [r for r in results if not r["passed"]]
(out / f"{label}_browser_e2e.json").write_text(
    json.dumps({"total": len(results), "failed": len(failed), "results": results},
               ensure_ascii=False, indent=2),
    encoding="utf-8",
)
print(f"BROWSER_E2E_{label.upper()}_TOTAL={len(results)} FAILED={len(failed)}")
sys.exit(1 if failed else 0)
