#!/usr/bin/env bash
# Oracle solution for task 91 — We just renegotiated with our customer Stellar Systems (note: Stellar Solutions is a different account — ours is on the stellarsystems.com email domain). A few 
# Auto-generated AFTER the oracle reproduced this answer key live — answer-key-reproducible, not an independent solve (5/5 verifiers, 1 repair(s)).
# Self-contained: bash + python3 stdlib only. Seeds each gym on a fresh scratch db,
# replays the tool-call plan over MCP, then checks every verifier. Exit 0 iff all pass.
set -uo pipefail

exec python3 - <<'ORACLE_PY'

import json, time, urllib.request, urllib.error

DATA = json.loads(r"""{
 "task_id": "91",
 "gyms": {
  "sn-csm-server": {
   "url": "http://localhost:8001",
   "auth_header": "x-user-email",
   "auth_val": "chandrapiyush357@gmail.com",
   "seed_sql": "-- MCP Server: sn-csm-server\nINSERT INTO location (location_id, name, city, country, active) VALUES (1, 'HQ New York', 'new_york', 'usa', 1);\nINSERT INTO user (user_id, first_name, last_name, email, phone, role, location_id, active) VALUES (1001, 'Piyush', 'Chandra', 'chandrapiyush357@gmail.com', '+1-555-0001', 'admin', 1, 1);\nINSERT INTO user (user_id, first_name, last_name, email, phone, role, location_id, active) VALUES (1101, 'Dana', 'Okoro', 'dana.okoro@stellarsystems.com', '+1-555-0100', 'customer', 1, 1);\nINSERT INTO user (user_id, first_name, last_name, email, phone, role, location_id, active) VALUES (1102, 'Marco', 'Vega', 'marco.vega@stellarsystems.com', '+1-555-0101', 'customer', 1, 1);\nINSERT INTO account (account_id, name, account_type, email_domain, active) VALUES (201, 'Stellar Systems', 'customer', 'stellarsystems.com', 1);\nINSERT INTO account (account_id, name, account_type, email_domain, active) VALUES (202, 'Stellar Solutions', 'customer', 'stellarsolutions.com', 1);\nINSERT INTO product (product_id, name, category, product_price, lifecycle_state) VALUES (601, 'OrbitSuite Pro', 'software', 5000, 'active');\nINSERT INTO product (product_id, name, category, product_price, lifecycle_state) VALUES (602, 'OrbitSuite Lite', 'software', 2000, 'active');\nINSERT INTO contact (contact_id, account_id, portal_user_id, active, is_primary) VALUES (401, 201, 1101, 1, 1);\nINSERT INTO contact (contact_id, account_id, portal_user_id, active, is_primary) VALUES (402, 201, 1102, 1, 0);\nINSERT INTO contract (contract_id, account_id, contract_type, status, contract_price, start_date, end_date) VALUES (301, 201, 'support', 'active', 45000, '2024-01-01', '2026-12-31');\nINSERT INTO contract (contract_id, account_id, contract_type, status, contract_price, start_date, end_date) VALUES (302, 201, 'warranty', 'expired', 12000, '2022-01-01', '2023-12-31');\nINSERT INTO entitlement (entitlement_id, account_id, product_id, contract_id, support_level, coverage_hours, max_cases_per_month, active) VALUES (501, 201, 601, 301, 'premium', 'h24x7', 20, 1);\nINSERT INTO entitlement (entitlement_id, account_id, product_id, contract_id, support_level, coverage_hours, max_cases_per_month, active) VALUES (502, 201, 602, 302, 'standard', 'h8x5', 5, 0);\n"
  }
 },
 "mcp_endpoint": "/mcp",
 "plan": [
  {
   "gym": "sn-csm-server",
   "tool": "find_contacts",
   "arguments": {},
   "note": "Discover contact id(s) before acting (no id-guessing) -> ['1101']"
  },
  {
   "gym": "sn-csm-server",
   "tool": "find_contracts",
   "arguments": {},
   "note": "Discover contract id(s) before acting (no id-guessing) -> ['301']"
  },
  {
   "gym": "sn-csm-server",
   "tool": "update_contract",
   "arguments": {
    "contract_id": 301,
    "contract_price": 60000,
    "end_date": "2027-12-31"
   },
   "note": "Amend support contract: +1yr end date, $60k value"
  },
  {
   "gym": "sn-csm-server",
   "tool": "update_user_details",
   "arguments": {
    "user_id": 1101,
    "phone": "+1-555-0199"
   },
   "note": "Update primary contact Dana Okoro's cell"
  }
 ],
 "verifiers": [
  {
   "name": "contract_updated",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM contract WHERE contract_id=301 AND contract_price=60000 AND date(end_date)=date('2027-12-31');",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "primary_user_phone_updated",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM user WHERE user_id=1101 AND phone='+1-555-0199';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "entitlement_still_active",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM entitlement WHERE entitlement_id=501 AND contract_id=301 AND active= 1;",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "decoy_contract_untouched",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM contract WHERE contract_id=302 AND contract_price=12000 AND date(end_date)=date('2023-12-31') AND status='expired';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "decoy_user_phone_untouched",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM user WHERE user_id=1102 AND phone<>'+1-555-0101';",
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
