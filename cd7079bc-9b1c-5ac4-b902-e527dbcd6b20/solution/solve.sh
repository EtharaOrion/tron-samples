#!/usr/bin/env bash
# Oracle solution for task 92 — Hi — a few things for our customer Vertex Labs (the labs company, not the similarly named systems firm):
# Auto-generated AFTER the oracle reproduced this answer key live — answer-key-reproducible, not an independent solve (5/5 verifiers, 1 repair(s)).
# Self-contained: bash + python3 stdlib only. Seeds each gym on a fresh scratch db,
# replays the tool-call plan over MCP, then checks every verifier. Exit 0 iff all pass.
set -uo pipefail

exec python3 - <<'ORACLE_PY'

import json, time, urllib.request, urllib.error

DATA = json.loads(r"""{
 "task_id": "92",
 "gyms": {
  "sn-csm-server": {
   "url": "http://localhost:8001",
   "auth_header": "x-user-email",
   "auth_val": "chandrapiyush357@gmail.com",
   "seed_sql": "-- MCP Server: sn-csm-server\nINSERT INTO location (location_id, name, city, country, active) VALUES (201, 'Vertex Labs Headquarters', 'new_york', 'usa', 1);\nINSERT INTO location (location_id, name, city, country, active) VALUES (202, 'Vertex Labs Branch Office', 'london', 'uk', 1);\nINSERT INTO user (user_id, first_name, last_name, email, phone, role, location_id, active) VALUES (101, 'Piyush', 'Chandra', 'chandrapiyush357@gmail.com', '+1-212-555-0101', 'agent', 201, 1);\nINSERT INTO user (user_id, first_name, last_name, email, phone, role, location_id, active) VALUES (999, 'Dana', 'Prakash', 'dana.prakash@vertexlabs.com', '+1-212-555-0999', 'customer', 201, 1);\nINSERT INTO user (user_id, first_name, last_name, email, phone, role, location_id, active) VALUES (998, 'Owen', 'Reyes', 'owen.reyes@vertexsystems.com', '+44-20-555-0998', 'customer', 202, 1);\nINSERT INTO account (account_id, name, account_type, email_domain, active) VALUES (5001, 'Vertex Labs', 'customer', 'vertexlabs.com', 1);\nINSERT INTO account (account_id, name, account_type, email_domain, active) VALUES (5002, 'Vertex Systems', 'customer', 'vertexsystems.com', 1);\nINSERT INTO product (product_id, name, category, lifecycle_state) VALUES (3001, 'Firewall Appliance', 'hardware', 'active');\nINSERT INTO product (product_id, name, category, lifecycle_state) VALUES (3002, 'Firewall Software Suite', 'software', 'active');\nINSERT INTO contact (contact_id, account_id, portal_user_id, active, is_primary) VALUES (6001, 5001, 999, 1, 1);\nINSERT INTO contact (contact_id, account_id, portal_user_id, active, is_primary) VALUES (6002, 5002, 998, 1, 1);\nINSERT INTO customer_case (case_id, number, account_id, contact_id, product_id, installed_product_id, channel, priority, state, short_description, assignment_group_id, assigned_to, escalation, escalation_reason, reopen_count) VALUES (9001, 'CS0009001', 5001, 6001, NULL, NULL, 'phone', 'high', 'new', 'Firewall appliance connectivity issue reported by customer.', NULL, 101, 0, NULL, 0);\nINSERT INTO customer_case (case_id, number, account_id, contact_id, product_id, installed_product_id, channel, priority, state, short_description, assignment_group_id, assigned_to, escalation, escalation_reason, reopen_count) VALUES (9002, 'CS0009002', 5001, 6001, NULL, NULL, 'email', 'moderate', 'in_progress', 'Configuration review requested for security hardware.', NULL, 101, 0, NULL, 0);\nINSERT INTO customer_case (case_id, number, account_id, contact_id, product_id, installed_product_id, channel, priority, state, short_description, assignment_group_id, assigned_to, escalation, escalation_reason, reopen_count) VALUES (9003, 'CS0009003', 5001, 6001, NULL, NULL, 'web', 'low', 'pending', 'Awaiting customer confirmation on firmware update window.', NULL, 101, 0, NULL, 0);\nINSERT INTO customer_case (case_id, number, account_id, contact_id, product_id, installed_product_id, channel, priority, state, short_description, assignment_group_id, assigned_to, escalation, escalation_reason, reopen_count, closed_on) VALUES (9004, 'CS0009004', 5001, 6001, NULL, NULL, 'email', 'low', 'closed', 'Historical billing query resolved.', NULL, NULL, 0, NULL, 0, '2025-01-15 10:00:00');\nINSERT INTO customer_case (case_id, number, account_id, contact_id, product_id, installed_product_id, channel, priority, state, short_description, assignment_group_id, assigned_to, escalation, escalation_reason, reopen_count) VALUES (9005, 'CS0009005', 5002, 6002, NULL, NULL, 'phone', 'moderate', 'new', 'Open case for the decoy account that must not be counted.', NULL, NULL, 0, NULL, 0);\n"
  }
 },
 "mcp_endpoint": "/mcp",
 "plan": [
  {
   "gym": "sn-csm-server",
   "tool": "find_contacts",
   "arguments": {},
   "note": "Discover contact id(s) before acting (no id-guessing) -> ['5001', '5001', '6001']"
  },
  {
   "gym": "sn-csm-server",
   "tool": "find_locations",
   "arguments": {},
   "note": "Discover location id(s) before acting (no id-guessing) -> ['201']"
  },
  {
   "gym": "sn-csm-server",
   "tool": "find_products",
   "arguments": {},
   "note": "Discover product id(s) before acting (no id-guessing) -> ['3001']"
  },
  {
   "gym": "sn-csm-server",
   "tool": "register_new_installed_product",
   "arguments": {
    "account_id": 5001,
    "product_id": 3001,
    "serial_number": "VTX-FW-9001",
    "status": "in_use",
    "location_id": 201
   },
   "note": "Register firewall appliance at Vertex Labs HQ"
  },
  {
   "gym": "sn-csm-server",
   "tool": "register_new_interaction",
   "arguments": {
    "channel": "phone",
    "status": "handled",
    "account_id": 5001,
    "contact_id": 6001,
    "interacted_user": 101
   },
   "note": "Log handled phone interaction with primary contact"
  }
 ],
 "verifiers": [
  {
   "name": "installed_product_created",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM installed_product WHERE account_id='5001' AND product_id='3001' AND location_id='201' AND serial_number='VTX-FW-9001' AND status='in_use';",
   "expected": 0,
   "comparison": "greater_than"
  },
  {
   "name": "no_wrong_installed_product",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM installed_product WHERE serial_number='VTX-FW-9001' AND (product_id='3002' OR account_id='5002' OR location_id='202');",
   "expected": 0,
   "comparison": "equals"
  },
  {
   "name": "interaction_created",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM interaction WHERE channel='phone' AND account_id='5001' AND contact_id='6001' AND interacted_user='101' AND status='handled' AND date(started_at)=date('now','localtime');",
   "expected": 0,
   "comparison": "greater_than"
  },
  {
   "name": "open_case_count_vertex_labs",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM customer_case WHERE account_id='5001' AND state IN ('new','in_progress','pending');",
   "expected": 3,
   "comparison": "equals"
  },
  {
   "name": "no_interaction_decoy_account",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM interaction WHERE account_id='5002' AND channel='phone' AND date(started_at)=date('now','localtime');",
   "expected": 0,
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
