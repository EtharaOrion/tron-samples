#!/usr/bin/env bash
# Oracle solution for task 87 — Hi, Dana Whitfield here. We're consolidating our Austin sites and I need to retire 'Meridian Site B - Austin'. First, move any installed equipment at Site B who
# Auto-generated AFTER the oracle reproduced this answer key live — answer-key-reproducible, not an independent solve (7/7 verifiers, 4 repair(s)).
# Self-contained: bash + python3 stdlib only. Seeds each gym on a fresh scratch db,
# replays the tool-call plan over MCP, then checks every verifier. Exit 0 iff all pass.
set -uo pipefail

exec python3 - <<'ORACLE_PY'

import json, time, urllib.request, urllib.error

DATA = json.loads(r"""{
 "task_id": "87",
 "gyms": {
  "sn-csm-server": {
   "url": "http://localhost:8001",
   "auth_header": "x-user-email",
   "auth_val": "chandrapiyush357@gmail.com",
   "seed_sql": "-- MCP Server: sn-csm-server\nINSERT INTO location (location_id, name, city, country, active) VALUES (3010, 'Meridian Site A - Austin', 'new_york', 'usa', 1);\nINSERT INTO location (location_id, name, city, country, active) VALUES (3011, 'Meridian Site B - Austin', 'new_york', 'usa', 1);\nINSERT INTO location (location_id, name, city, country, active) VALUES (3012, 'Meridian Site C - Austin', 'new_york', 'usa', 1);\nINSERT INTO user (user_id, first_name, last_name, email, phone, role, location_id, active) VALUES (5001, 'Dana', 'Whitfield', 'chandrapiyush357@gmail.com', '+1-512-555-5001', 'admin', 3010, 1);\nINSERT INTO account (account_id, name, account_type, email_domain, active) VALUES (7001, 'Meridian Corp', 'customer', 'meridian.com', 1);\nINSERT INTO product (product_id, name, category, product_price, lifecycle_state) VALUES (8001, 'Meridian Gateway 7731', 'hardware', 1200.00, 'active');\nINSERT INTO product (product_id, name, category, product_price, lifecycle_state) VALUES (8002, 'Meridian Router 2200', 'hardware', 800.00, 'active');\nINSERT INTO product (product_id, name, category, product_price, lifecycle_state) VALUES (8003, 'Meridian Switch 4400', 'hardware', 600.00, 'active');\nINSERT INTO installed_product (installed_product_id, account_id, product_id, location_id, serial_number, status) VALUES (9001, 7001, 8001, 3011, 'SN-7731-AX', 'in_use');\nINSERT INTO installed_product (installed_product_id, account_id, product_id, location_id, serial_number, status) VALUES (9002, 7001, 8002, 3011, 'SN-2200-BX', 'in_use');\nINSERT INTO installed_product (installed_product_id, account_id, product_id, location_id, serial_number, status) VALUES (9003, 7001, 8001, 3010, 'SN-7731-CY', 'in_use');\nINSERT INTO installed_product (installed_product_id, account_id, product_id, location_id, serial_number, status) VALUES (9004, 7001, 8003, 3011, 'SN-7731-DZ', 'retired');\n"
  }
 },
 "mcp_endpoint": "/mcp",
 "plan": [
  {
   "gym": "sn-csm-server",
   "tool": "find_locations",
   "arguments": {},
   "note": "Discover location id(s) before acting (no id-guessing) -> ['3010']"
  },
  {
   "gym": "sn-csm-server",
   "tool": "retrieve_installed_products",
   "arguments": {},
   "note": "Discover installed_product id(s) before acting (no id-guessing) -> ['9001', '9002']"
  },
  {
   "gym": "sn-csm-server",
   "tool": "update_installed_product_details",
   "arguments": {
    "installed_product_id": 9001,
    "location_id": 3010
   },
   "note": "Move SN-7731-AX (7731) from Site B (3011) to Site A (3010)"
  },
  {
   "gym": "sn-csm-server",
   "tool": "update_installed_product_details",
   "arguments": {
    "installed_product_id": 9002,
    "status": "retired"
   },
   "note": "In-use gear not being moved (no 7731) -> take out of active service"
  },
  {
   "gym": "sn-csm-server",
   "tool": "update_location",
   "arguments": {
    "location_id": 3011,
    "active": false
   },
   "note": "Deactivate Site B now that no active equipment remains"
  }
 ],
 "verifiers": [
  {
   "name": "prod_9001_moved_to_site_a",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM installed_product WHERE installed_product_id = '9001' AND location_id = '3010';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "site_b_deactivated",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM location WHERE location_id = '3011' AND active IN ('false','False','0',0);",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "site_a_still_active",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM location WHERE location_id = '3010' AND active IN ('true','True','1',1);",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "no_active_products_at_site_b",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM installed_product WHERE location_id = '3011' AND status <> 'retired';",
   "expected": 0,
   "comparison": "equals"
  },
  {
   "name": "site_c_not_deactivated",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM location WHERE location_id = '3012' AND active IN ('false','False','0',0);",
   "expected": 0,
   "comparison": "equals"
  },
  {
   "name": "decoy_9002_not_moved_to_site_a",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM installed_product WHERE installed_product_id = '9002' AND location_id = '3010';",
   "expected": 0,
   "comparison": "equals"
  },
  {
   "name": "decoy_9003_untouched_at_site_a",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM installed_product WHERE installed_product_id = '9003' AND location_id = '3010';",
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
