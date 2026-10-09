#!/usr/bin/env python3
"""PalEyes API-level E2E against a LOCAL Supabase stack (supabase start).

Real GoTrue sessions, real PostgREST, real RLS — with synthetic identities
only. Refuses any non-loopback URL so it can never touch Staging/Production.

Env: API_URL, ANON_KEY, SERVICE_ROLE_KEY, DB_URL (all from `supabase status`).
Writes a JSON report to E2E_REPORT (default api_e2e_report.json).
"""
from __future__ import annotations

import base64
import hashlib
import hmac
import json
import os
import struct
import subprocess
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

API = os.environ["API_URL"].rstrip("/")
ANON = os.environ["ANON_KEY"]
SERVICE = os.environ["SERVICE_ROLE_KEY"]
DB_URL = os.environ["DB_URL"]
REPORT = os.environ.get("E2E_REPORT", "api_e2e_report.json")

host = urllib.parse.urlparse(API).hostname
if host not in ("127.0.0.1", "localhost"):
    sys.exit(f"REFUSED_NON_LOCAL_SUPABASE={API}")
if urllib.parse.urlparse(DB_URL).hostname not in ("127.0.0.1", "localhost"):
    sys.exit("REFUSED_NON_LOCAL_DATABASE")

PASSWORD = "Synthetic-Only-" + hashlib.sha256(os.urandom(16)).hexdigest()[:16]
if os.environ.get("GITHUB_ACTIONS"):
    print(f"::add-mask::{PASSWORD}")
DOMAIN = "synthetic.example.invalid"
ROLES = {
    "no-role": [],
    "researcher": ["researcher"],
    "editor": ["editor"],
    "rights-reviewer": ["rights_reviewer"],
    "release-manager": ["release_manager"],
    "release-manager-dart": ["release_manager"],
    "system-admin": ["system_admin"],
}

results: list[dict] = []


def call(method: str, path: str, *, token: str | None = None, body=None,
         profile: bool = True, headers: dict | None = None):
    h = {"apikey": ANON, "Content-Type": "application/json"}
    if token:
        h["Authorization"] = f"Bearer {token}"
    if profile and path.startswith("/rest/"):
        h["Accept-Profile"] = "pal_eyes"
        h["Content-Profile"] = "pal_eyes"
    if headers:
        h.update(headers)
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(API + path, data=data, headers=h, method=method)
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            raw = resp.read()
            return resp.status, (json.loads(raw) if raw else None)
    except urllib.error.HTTPError as err:
        raw = err.read()
        try:
            payload = json.loads(raw) if raw else None
        except ValueError:
            payload = raw.decode(errors="replace")
        return err.code, payload


def record(name: str, ok: bool, detail=""):
    results.append({"test": name, "passed": bool(ok), "detail": str(detail)[:300]})
    print(("PASS " if ok else "FAIL ") + name + ("" if ok else f" :: {detail}"))


def totp(secret: str, at: float | None = None) -> str:
    key = base64.b32decode(secret.upper() + "=" * (-len(secret) % 8))
    counter = int((at or time.time()) // 30)
    digest = hmac.new(key, struct.pack(">Q", counter), hashlib.sha1).digest()
    offset = digest[-1] & 0x0F
    code = (struct.unpack(">I", digest[offset:offset + 4])[0] & 0x7FFFFFFF) % 1_000_000
    return f"{code:06d}"


def sign_in(alias: str) -> tuple[str, str]:
    status, body = call("POST", "/auth/v1/token?grant_type=password",
                        body={"email": f"{alias}@{DOMAIN}", "password": PASSWORD})
    if status != 200:
        raise RuntimeError(f"sign-in {alias} failed: {status} {body}")
    return body["access_token"], body["user"]["id"]


def step_up(token: str) -> str:
    status, factor = call("POST", "/auth/v1/factors", token=token,
                          body={"factor_type": "totp", "friendly_name": "synthetic-ci"})
    if status not in (200, 201):
        raise RuntimeError(f"MFA enroll failed: {status} {factor}")
    fid, secret = factor["id"], factor["totp"]["secret"]
    status, challenge = call("POST", f"/auth/v1/factors/{fid}/challenge", token=token, body={})
    if status not in (200, 201):
        raise RuntimeError(f"MFA challenge failed: {status} {challenge}")
    status, verified = call("POST", f"/auth/v1/factors/{fid}/verify", token=token,
                            body={"challenge_id": challenge["id"], "code": totp(secret)})
    if status != 200:
        raise RuntimeError(f"MFA verify failed: {status} {verified}")
    return verified["access_token"]


def psql(sql: str) -> str:
    return subprocess.run(["psql", DB_URL, "-v", "ON_ERROR_STOP=1", "-tAc", sql],
                          check=True, capture_output=True, text=True).stdout.strip()


def main() -> int:
    ids: dict[str, str] = {}
    for alias in ROLES:
        status, body = call("POST", "/auth/v1/admin/users",
                            headers={"Authorization": f"Bearer {SERVICE}", "apikey": SERVICE},
                            body={"email": f"{alias}@{DOMAIN}", "password": PASSWORD,
                                  "email_confirm": True})
        if status not in (200, 201):
            print(f"cannot create synthetic user {alias}: {status} {body}")
            return 2
        ids[alias] = body["id"]
    for alias, roles in ROLES.items():
        for role in roles:
            psql(f"insert into pal_eyes.user_roles (user_id, role_key) values ('{ids[alias]}', '{role}')")

    tok = {alias: sign_in(alias)[0] for alias in ROLES}
    site = psql("select id from pal_eyes.sites order by id limit 1")

    # Auth surface
    s, b = call("POST", "/auth/v1/signup", body={"email": f"stranger@{DOMAIN}", "password": PASSWORD})
    record("T01 public sign-up is disabled (invite-only)", s >= 400, f"{s} {b}")

    # Anonymous visitor
    s, b = call("GET", "/rest/v1/public_sites_v1?select=slug")
    record("T02 anon reads public_sites_v1: 200 and empty (nothing published)", s == 200 and b == [], f"{s} {b}")
    s, b = call("GET", "/rest/v1/public_research_v1?select=manifest_id")
    record("T03 anon reads public_research_v1: 200 and empty", s == 200 and b == [], f"{s} {b}")
    s, b = call("GET", "/rest/v1/sites?select=id,editorial_draft")
    record("T04 anon reads zero draft site rows (RLS: PUBLISHED only)", s >= 400 or (s == 200 and b == []), f"{s} {b}")
    s, b = call("GET", "/rest/v1/original_draft_layers?select=site_id")
    record("T05 anon cannot read original drafts", s >= 400, f"{s} {b}")

    # Role visibility
    s, b = call("GET", "/rest/v1/sites?select=id", token=tok["no-role"])
    record("T06 account without role sees zero internal rows", s == 200 and b == [], f"{s} {len(b or [])}")
    s, b = call("GET", "/rest/v1/sites?select=id", token=tok["researcher"])
    record("T07 researcher sees the 79 governed sites", s == 200 and len(b) == 79, f"{s} {len(b or [])}")

    # Editorial CRUD (as the app's SupabaseOperationalDataBackend runs it)
    s, b = call("GET", f"/rest/v1/sites?select=version_number&id=eq.{site}", token=tok["editor"])
    version = b[0]["version_number"]
    s, b = call("PATCH", f"/rest/v1/sites?id=eq.{site}", token=tok["editor"],
                headers={"Prefer": "return=representation"},
                body={"editorial_draft": "مسودة اصطناعية من CI", "workflow_status": "DRAFT_UPDATED",
                      "version_number": version + 1, "updated_by": ids["system-admin"]})
    record("T08 editor saves draft with version bump; updated_by is server-stamped",
           s == 200 and b and b[0]["version_number"] == version + 1 and b[0]["updated_by"] == ids["editor"],
           f"{s} {b and b[0].get('updated_by')}")
    s, b = call("PATCH", f"/rest/v1/sites?id=eq.{site}", token=tok["editor"],
                body={"editorial_draft": "stale", "version_number": version + 1})
    record("T09 stale concurrent save is rejected (VERSION_CONFLICT)", s >= 400 and "VERSION_CONFLICT" in json.dumps(b), f"{s} {b}")
    s, b = call("PATCH", f"/rest/v1/sites?id=eq.{site}", token=tok["editor"],
                body={"publication_status": "PUBLISHED"})
    record("T10 editor cannot publish", s >= 400 and "PUBLICATION_FAIL_CLOSED" in json.dumps(b), f"{s} {b}")
    s, b = call("DELETE", f"/rest/v1/sites?id=eq.{site}", token=tok["editor"])
    record("T11 editor cannot delete a site", s >= 400, f"{s} {b}")

    # Sources + audit identity
    s, b = call("POST", "/rest/v1/sources", token=tok["researcher"], headers={"Prefer": "return=representation"},
                body={"id": "ci-source-1", "title": "مصدر اصطناعي", "created_by": ids["system-admin"]})
    record("T12 researcher adds a source; created_by cannot be spoofed",
           s == 201 and b[0]["created_by"] == ids["researcher"], f"{s} {b}")
    s, b = call("POST", "/rest/v1/audit_events", token=tok["researcher"], headers={"Prefer": "return=representation"},
                body={"id": "ci-audit-1", "action": "NOTE", "entity_type": "site", "entity_id": site,
                      "actor_id": ids["system-admin"]})
    record("T13 audit actor is server-stamped", s == 201 and b[0]["actor_id"] == ids["researcher"], f"{s} {b}")
    s, b = call("PATCH", "/rest/v1/audit_events?id=eq.ci-audit-1", token=tok["system-admin"], body={"summary": "x"})
    record("T14 audit log is append-only even for system_admin", s >= 400, f"{s} {b}")

    # Review separation of duties
    s, b = call("POST", "/rest/v1/review_tasks", token=tok["editor"], headers={"Prefer": "return=representation"},
                body={"id": "ci-review-1", "entity_type": "site", "entity_id": site,
                      "title": "مراجعة اصطناعية", "review_type": "EDITORIAL"})
    record("T15 editor submits a review task", s == 201 and b[0]["created_by"] == ids["editor"], f"{s} {b}")
    s, b = call("PATCH", "/rest/v1/review_tasks?id=eq.ci-review-1", token=tok["researcher"], body={"status": "ACCEPT"})
    record("T16 researcher cannot decide a review", s >= 400 and "REVIEW_AUTHORITY_REQUIRED" in json.dumps(b), f"{s} {b}")
    s, b = call("PATCH", "/rest/v1/review_tasks?id=eq.ci-review-1", token=tok["rights-reviewer"],
                headers={"Prefer": "return=representation"}, body={"status": "ACCEPT", "decision_note": "ci"})
    record("T17 reviewer decides another author's task", s == 200 and b and b[0]["status"] == "ACCEPT", f"{s} {b}")

    # Admin directory and role administration with MFA
    s, b = call("POST", "/rest/v1/rpc/admin_list_users", token=tok["researcher"], body={})
    record("T18 researcher cannot list users", s >= 400, f"{s} {b}")
    s, b = call("POST", "/rest/v1/rpc/admin_list_users", token=tok["system-admin"], body={})
    record("T19 system admin lists synthetic users", s == 200 and len(b) >= len(ROLES), f"{s} {len(b or [])}")
    s, b = call("POST", "/rest/v1/user_roles", token=tok["system-admin"],
                body={"user_id": ids["no-role"], "role_key": "editor"})
    record("T20 role grant without MFA (aal1) is refused", s >= 400, f"{s} {b}")
    try:
        admin_aal2 = step_up(tok["system-admin"])
        record("T21 system admin completes TOTP step-up to aal2", True)
    except RuntimeError as err:
        admin_aal2 = None
        record("T21 system admin completes TOTP step-up to aal2", False, err)
    if admin_aal2:
        s, b = call("POST", "/rest/v1/user_roles", token=admin_aal2,
                    body={"user_id": ids["no-role"], "role_key": "editor"})
        record("T22 role grant with MFA (aal2) succeeds", s == 201, f"{s} {b}")
        s, b = call("POST", "/rest/v1/user_roles", token=admin_aal2,
                    body={"user_id": ids["system-admin"], "role_key": "release_manager"})
        record("T23 admin cannot grant a role to self even with MFA", s >= 400, f"{s} {b}")

    # Release authority with MFA
    s, b = call("POST", "/rest/v1/release_candidates", token=tok["release-manager"],
                body={"id": "ci-rc-1", "title": "مرشح اصطناعي"})
    record("T24 release candidate without MFA is refused", s >= 400, f"{s} {b}")
    try:
        rm_aal2 = step_up(tok["release-manager"])
    except RuntimeError as err:
        rm_aal2 = None
        record("T25 release manager step-up", False, err)
    if rm_aal2:
        s, b = call("POST", "/rest/v1/release_candidates", token=rm_aal2,
                    headers={"Prefer": "return=representation"},
                    body={"id": "ci-rc-2", "title": "مرشح اصطناعي"})
        record("T25 release candidate with MFA is created BLOCKED",
               s == 201 and b[0]["publication_status"] == "BLOCKED", f"{s} {b}")
        s, b = call("POST", "/rest/v1/release_candidates", token=rm_aal2,
                    body={"id": "ci-rc-3", "title": "x", "publication_status": "PUBLISHED"})
        record("T26 release candidate cannot be created PUBLISHED", s >= 400, f"{s} {b}")

    # Nothing became public during the run
    s, b = call("GET", "/rest/v1/public_sites_v1?select=slug")
    record("T27 after all operations the public surface is still empty", s == 200 and b == [], f"{s} {b}")

    passed = sum(r["passed"] for r in results)
    summary = {"total": len(results), "passed": passed, "failed": len(results) - passed}
    with open(REPORT, "w", encoding="utf-8") as fh:
        json.dump({"summary": summary, "results": results}, fh, ensure_ascii=False, indent=2)
    print(f"API_E2E_TOTAL={summary['total']} API_E2E_FAILED={summary['failed']}")
    # Credentials for the Dart live test (synthetic, ephemeral, local only).
    out = os.environ.get("GITHUB_ENV")
    if out:
        with open(out, "a", encoding="utf-8") as fh:
            fh.write(f"PAL_EYES_LIVE_PASSWORD={PASSWORD}\n")
            fh.write(f"PAL_EYES_LIVE_DOMAIN={DOMAIN}\n")
    return 0 if summary["failed"] == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
