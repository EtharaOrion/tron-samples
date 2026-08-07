#!/usr/bin/env bash
# Oracle solution for task 910 — hey can you check my POP settings — is POP even on right now? if it's off, turn it on for ALL mail (not just new stuff), and set downloaded messages to get arch
# Auto-generated AFTER the oracle reproduced this answer key live — answer-key-reproducible, not an independent solve (5/5 verifiers, 1 repair(s)).
# Self-contained: bash + python3 stdlib only. Seeds each gym on a fresh scratch db,
# replays the tool-call plan over MCP, then checks every verifier. Exit 0 iff all pass.
set -uo pipefail

exec python3 - <<'ORACLE_PY'

import json, time, urllib.request, urllib.error

DATA = json.loads(r"""{
 "task_id": "910",
 "gyms": {
  "gym-email-mcp": {
   "url": "http://localhost:8007",
   "auth_header": "x-email-user-token",
   "auth_val": "tok_piyush_2025_a1b2",
   "seed_sql": "-- MCP Server: email_v4\nINSERT INTO users (id, token, primary_email, name, messages_total, threads_total, history_id_current, created_at, updated_at) VALUES ('user_piyush_001', 'tok_piyush_2025_a1b2', 'chandrapiyush357@gmail.com', 'Piyush Chandra', 0, 0, 1000, '2026-01-10T09:00:00Z', '2026-07-20T09:00:00Z');\nINSERT INTO pop_settings (id, user_id, access_window, disposition, created_at, updated_at) VALUES ('pop_piyush_001', 'user_piyush_001', 'disabled', 'leaveInInbox', '2026-01-10T09:00:00Z', '2026-07-20T09:00:00Z');\nINSERT INTO imap_settings (id, user_id, enabled, auto_expunge, expunge_behavior, max_folder_size, created_at, updated_at) VALUES ('imap_piyush_001', 'user_piyush_001', 'true', 'true', 'archive', 0, '2026-01-10T09:00:00Z', '2026-07-20T09:00:00Z');\nINSERT INTO auto_forwarding (id, user_id, enabled, email_address, disposition, created_at, updated_at) VALUES ('autofwd_piyush_001', 'user_piyush_001', 'false', NULL, 'leaveInInbox', '2026-01-10T09:00:00Z', '2026-07-20T09:00:00Z');\nINSERT INTO vacation_settings (id, user_id, enable_auto_reply, response_subject, response_body_plain_text, response_body_html, restrict_to_contacts, restrict_to_domain, start_time, end_time, created_at, updated_at) VALUES ('vac_piyush_001', 'user_piyush_001', 'false', NULL, NULL, NULL, 'false', 'false', NULL, NULL, '2026-01-10T09:00:00Z', '2026-07-20T09:00:00Z');\n"
  }
 },
 "mcp_endpoint": "/mcp",
 "plan": [
  {
   "gym": "gym-email-mcp",
   "tool": "get_pop_settings",
   "arguments": {
    "userId": "me"
   },
   "note": "Read current POP settings before modifying (verified-records-only)."
  },
  {
   "gym": "gym-email-mcp",
   "tool": "update_pop_settings",
   "arguments": {
    "userId": "me",
    "accessWindow": "allMail",
    "disposition": "archive"
   },
   "note": "Turn POP on for all mail and archive downloaded copies."
  }
 ],
 "verifiers": [
  {
   "name": "pop_disposition_archive",
   "gym": "gym-email-mcp",
   "query": "SELECT COUNT(*) FROM pop_settings WHERE id='pop_piyush_001' AND user_id='user_piyush_001' AND disposition='archive';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "pop_both_final",
   "gym": "gym-email-mcp",
   "query": "SELECT COUNT(*) FROM pop_settings WHERE user_id='user_piyush_001' AND access_window='allMail' AND disposition='archive';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "pop_not_disabled",
   "gym": "gym-email-mcp",
   "query": "SELECT COUNT(*) FROM pop_settings WHERE user_id='user_piyush_001' AND access_window='disabled';",
   "expected": 0,
   "comparison": "equals"
  },
  {
   "name": "autofwd_untouched",
   "gym": "gym-email-mcp",
   "query": "SELECT COUNT(*) FROM auto_forwarding WHERE id='autofwd_piyush_001' AND user_id='user_piyush_001' AND enabled='false' AND disposition='leaveInInbox';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "imap_untouched",
   "gym": "gym-email-mcp",
   "query": "SELECT COUNT(*) FROM imap_settings WHERE id='imap_piyush_001' AND user_id='user_piyush_001' AND enabled='true' AND expunge_behavior='archive';",
   "expected": 1,
   "comparison": "equals"
  }
 ]
}""")

def post(url, payload, headers=None, timeout=60):
    body = json.dumps(payload).encode()
    h = {"Content-Type": "application/json"}
    if headers: h.update(headers)
    req = urllib.request.Request(url, data=body, headers=h, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return r.status, r.read().decode("utf-8", "replace")
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode("utf-8", "replace")
    except Exception as e:
        return 0, "transport error: %s" % e

def cell(text):
    try:
        data = json.loads(text).get("data")
        return float(list(data[0].values())[0]) if data else 0.0
    except Exception:
        return None

def parse_mcp(text):
    text = (text or "").strip()
    if "data:" in text and not text.startswith("{"):
        obj = None
        for line in text.splitlines():
            line = line.strip()
            if line.startswith("data:") and line[5:].strip().startswith("{"):
                try: obj = json.loads(line[5:].strip())
                except Exception: pass
        return obj
    try: return json.loads(text)
    except Exception: return None

def payload_err(obj):
    # Structural masked-error check: a gym can return transport-200 with no JSON-RPC error while
    # reporting a failure INSIDE result.content[].text as an escaped JSON string. Decode each text
    # block and flag success:false / status:error / status_code>=400. Mirrors mcp_call in the pipeline.
    try:
        result = obj.get("result") if isinstance(obj, dict) else None
        if not isinstance(result, dict): return None
        if result.get("isError"): return "isError=true"
        for block in result.get("content") or []:
            txt = block.get("text") if isinstance(block, dict) else None
            if not isinstance(txt, str) or "{" not in txt: continue
            try: inner = json.loads(txt)
            except Exception: continue
            if not isinstance(inner, dict): continue
            e = inner.get("error"); code = None
            for src in (inner, e if isinstance(e, dict) else {}):
                v = src.get("status_code")
                if isinstance(v, bool): continue
                if isinstance(v, (int, float)): code = int(v)
                elif isinstance(v, str) and v.strip().isdigit(): code = int(v)
            status = str(inner.get("status", "")).strip().lower()
            if inner.get("success") is False or (status in ("error", "failed", "failure") and (e or inner.get("message"))) or (code is not None and code >= 400):
                lbl = (e.get("error") or e.get("message")) if isinstance(e, dict) else (e if isinstance(e, str) else "")
                return "; ".join([b for b in ("HTTP %s" % code if code else "", str(lbl or ""), str(inner.get("message") or "")) if b]) or "tool reported failure"
    except Exception:
        return None
    return None

stamp = str(int(time.time()))
dbids = {}
print("== seeding gyms ==")
for sn, g in DATA["gyms"].items():
    dbid = "solve_%s_%s_%s" % (DATA["task_id"], sn.replace('-', '_'), stamp)
    dbids[sn] = dbid
    st, txt = post(g["url"] + "/api/seed-database",
                   {"database_id": dbid, "name": "solve", "description": "solve",
                    "sql_content": g["seed_sql"]})
    ok = st == 200 and "success" in txt.lower() and "failed" not in txt.lower()
    print("  %-24s %s" % (sn, "seeded" if ok else "SEED FAILED: %s" % txt[:160]))
    if not ok: raise SystemExit(2)

print("== executing solution ==")
for i, step in enumerate(DATA["plan"]):
    sn = step["gym"]; g = DATA["gyms"][sn]; dbid = dbids[sn]
    st, txt = post(g["url"] + DATA["mcp_endpoint"],
                   {"jsonrpc": "2.0", "id": i + 1, "method": "tools/call",
                    "params": {"name": step["tool"], "arguments": step.get("arguments", {})}},
                   {g["auth_header"]: g["auth_val"], "x-database-id": dbid,
                    "Accept": "application/json, text/event-stream"})
    obj = parse_mcp(txt)
    perr = payload_err(obj)
    err = (isinstance(obj, dict) and obj.get("error")) or st != 200 or perr
    detail = "ERROR: %s" % (perr or txt[:140]) if err else "ok"
    # A masked payload error is non-fatal here: the graded end-state may still be reached (the gym
    # committed before erroring). We print it honestly but let the verifiers below decide pass/fail.
    print("  step %d: %-28s %s" % (i, step["tool"], detail))

print("== checking verifiers ==")
npass = 0; total = 0
for v in DATA["verifiers"]:
    g = DATA["gyms"][v["gym"]]; dbid = dbids[v["gym"]]
    st, txt = post(g["url"] + "/api/sql-runner",
                   {"query": v["query"], "database_id": dbid},
                   {"x-database-id": dbid, g["auth_header"]: g["auth_val"]})
    val = cell(txt); exp = v["expected"]; cmp = v["comparison"]
    ok = (val is not None and (
        (cmp == "equals" and val == float(exp)) or
        (cmp == "greater_than" and val > float(exp)) or
        (cmp == "less_than" and val < float(exp))))
    total += 1; npass += 1 if ok else 0
    print("  [%s] %-40s expected %s %s, got %s" %
          ("PASS" if ok else "FAIL", v["name"], cmp, exp, val))

print("== %d/%d verifiers pass ==" % (npass, total))
raise SystemExit(0 if npass == total and total > 0 else 1)

ORACLE_PY
