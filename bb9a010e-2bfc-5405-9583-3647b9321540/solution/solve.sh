#!/usr/bin/env bash
# Oracle solution for task 914 — Hi, I'm Piyush Chandra (chandrapiyush357@gmail.com) — first confirm I'm allowed to do this, then set up a new lifecycle flow for our Mentorship Program (keep ev
# Auto-generated AFTER the oracle reproduced this answer key live — answer-key-reproducible, not an independent solve (5/5 verifiers, 1 repair(s)).
# Self-contained: bash + python3 stdlib only. Seeds each gym on a fresh scratch db,
# replays the tool-call plan over MCP, then checks every verifier. Exit 0 iff all pass.
set -uo pipefail

exec python3 - <<'ORACLE_PY'

import json, time, urllib.request, urllib.error

DATA = json.loads(r"""{
 "task_id": "914",
 "gyms": {
  "sn-hr-internal": {
   "url": "http://localhost:8003",
   "auth_header": "x-hr-user-token",
   "auth_val": "hr_token_piyush_chandra_001",
   "seed_sql": "-- MCP Server: sn-hr-internal\nINSERT INTO organization (org_id, name, active, created_at, updated_at) VALUES (1, 'Globex Corporation', 1, '2023-01-01 00:00:00', '2023-01-01 00:00:00');\n\nINSERT INTO role (role_id, name, created_at, updated_at) VALUES\n(1, 'admin', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(2, 'manager', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(3, 'agent', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(4, 'employee', '2023-01-01 00:00:00', '2023-01-01 00:00:00');\n\nINSERT INTO permission (perm_id, resource, action, created_at, updated_at) VALUES\n(1, 'users', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(2, 'users', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(3, 'groups', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(4, 'groups', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(5, 'hr_services', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(6, 'hr_services', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(7, 'hr_cases', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(8, 'hr_cases', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(9, 'hr_profiles', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(10, 'hr_profiles', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(11, 'topic_categories', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(12, 'topic_categories', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(13, 'topic_details', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(14, 'topic_details', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(15, 'service_templates', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(16, 'service_templates', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(17, 'hr_criteria', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(18, 'hr_criteria', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(19, 'skills', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(20, 'skills', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(21, 'knowledge', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(22, 'knowledge', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(23, 'surveys', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(24, 'surveys', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(25, 'assignment_rules', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(26, 'assignment_rules', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(27, 'escalation_rules', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(28, 'escalation_rules', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(29, 'notifications', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(30, 'notifications', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(31, 'checklists', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(32, 'checklists', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(33, 'survey_instances', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(34, 'survey_instances', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(35, 'reports', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(36, 'reports', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(37, 'hr_case_tasks', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(38, 'hr_case_tasks', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00');\n\nINSERT INTO role_permission (role_id, perm_id, created_at, updated_at) VALUES\n(1, 2, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 4, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 6, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 8, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 10, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 12, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 14, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 16, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 18, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 20, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 22, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 24, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 26, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 28, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 30, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 32, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 34, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 36, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 38, '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(2, 2, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 4, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 6, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 8, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 10, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 12, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 14, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 16, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 18, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 20, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 22, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 24, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 26, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 28, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 30, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 32, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 34, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 36, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 38, '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(3, 1, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 3, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 5, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 8, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 9, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 11, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 13, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 15, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 17, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 19, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 21, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 23, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 25, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 27, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 29, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 31, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 33, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 35, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 37, '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(4, 1, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 3, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 5, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 7, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 9, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 11, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 13, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 15, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 17, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 19, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 21, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 23, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 25, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 27, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 29, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 31, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 33, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 35, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 37, '2023-01-01 00:00:00', '2023-01-01 00:00:00');\n\nINSERT INTO user (user_id, first_name, last_name, email, phone, role, active, org_id, static_token, created_at, updated_at) VALUES\n(1, 'Piyush', 'Chandra', 'chandrapiyush357@gmail.com', '+1-555-0101', 'admin', 1, 1, 'hr_token_piyush_chandra_001', '2023-01-01 00:00:00', '2023-01-01 00:00:00');\n\nINSERT INTO user_role (user_id, role_id, org_id, created_at, updated_at) VALUES\n(1, 1, 1, '2023-01-01 00:00:00', '2023-01-01 00:00:00');\n\nINSERT INTO topic_category (topic_category_id, active, name, coe_type, org_id, created_at, updated_at) VALUES\n(51, 1, 'Career Growth', 'Talent Management', 1, '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(52, 1, 'Workforce Development', 'Workforce Administration', 1, '2023-01-01 00:00:00', '2023-01-01 00:00:00');\n\nINSERT INTO topic_detail (topic_detail_id, active, name, topic_category, org_id, created_at, updated_at) VALUES\n(77, 1, 'Mentorship Program', 51, 1, '2023-01-01 00:00:00', '2023-01-01 00:00:00');\n\nINSERT INTO hr_service (hr_service_id, service_name, fulfillment_type, topic_detail, service_template, hr_criteria, active, org_id, created_at, updated_at) VALUES\n(90, 'Mentorship Enrollment', 'lifecycle event', 77, NULL, NULL, 1, 1, '2023-01-01 00:00:00', '2023-01-01 00:00:00');\n"
  }
 },
 "mcp_endpoint": "/mcp",
 "plan": [
  {
   "gym": "sn-hr-internal",
   "tool": "get_user",
   "arguments": {
    "user_id": "1"
   },
   "note": "Confirm acting user Piyush Chandra role (must be admin/hr_manager) and org scope before any write."
  },
  {
   "gym": "sn-hr-internal",
   "tool": "add_new_topic_category",
   "arguments": {
    "name": "Career Development",
    "coe_type": "Workforce Administration",
    "active": true
   },
   "note": "Create brand-new topic category, exact name, correct COE enum. Satisfies topic_category_created."
  },
  {
   "gym": "sn-hr-internal",
   "tool": "add_new_topic_detail",
   "arguments": {
    "name": "Mentorship Enrollment",
    "active": true,
    "topic_category": "Career Development"
   },
   "note": "Create topic detail hung off the NEW category by exact name. Satisfies topic_detail_linked."
  },
  {
   "gym": "sn-hr-internal",
   "tool": "create_new_hr_service",
   "arguments": {
    "service_name": "Mentorship Enrollment Request",
    "fulfillment_type": "manual",
    "active": true,
    "topic_detail": "Mentorship Enrollment"
   },
   "note": "Create the new manual HR service linked to the new detail (not the decoy id 77, not lifecycle event). Satisfies hr_service_created."
  }
 ],
 "verifiers": [
  {
   "name": "topic_category_created",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM topic_category WHERE name = 'Career Development' AND coe_type = 'Workforce Administration' AND org_id = 1;",
   "expected": 0,
   "comparison": "greater_than"
  },
  {
   "name": "topic_detail_linked",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM topic_detail td JOIN topic_category tc ON td.topic_category = tc.topic_category_id WHERE td.name = 'Mentorship Enrollment' AND tc.name = 'Career Development' AND tc.coe_type = 'Workforce Administration' AND td.org_id = 1;",
   "expected": 0,
   "comparison": "greater_than"
  },
  {
   "name": "hr_service_created",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM hr_service hs JOIN topic_detail td ON hs.topic_detail = td.topic_detail_id JOIN topic_category tc ON td.topic_category = tc.topic_category_id WHERE hs.service_name = 'Mentorship Enrollment Request' AND hs.fulfillment_type = 'manual' AND td.name = 'Mentorship Enrollment' AND tc.name = 'Career Development' AND hs.org_id = 1;",
   "expected": 0,
   "comparison": "greater_than"
  },
  {
   "name": "no_wrong_coe_category",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM topic_category WHERE name = 'Career Development' AND coe_type <> 'Workforce Administration';",
   "expected": 0,
   "comparison": "equals"
  },
  {
   "name": "no_reuse_decoy_detail",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM hr_service WHERE service_name = 'Mentorship Enrollment Request' AND topic_detail = 77;",
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
