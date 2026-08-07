#!/usr/bin/env bash
# Oracle solution for task 996a64af-e210-5bc5-a984-0d2f94c92fc8 — # Aurora entitlement exception
# Auto-generated AFTER the oracle reproduced this answer key live — answer-key-reproducible, not an independent solve (12/12 verifiers, 1 repair(s)).
# Self-contained: bash + python3 stdlib only. Seeds each gym on a fresh scratch db,
# replays the tool-call plan over MCP, then checks every verifier. Exit 0 iff all pass.
set -uo pipefail

exec python3 - <<'ORACLE_PY'

import json, time, urllib.request, urllib.error

DATA = json.loads(r"""{
 "task_id": "996a64af-e210-5bc5-a984-0d2f94c92fc8",
 "gyms": {
  "sn-csm-server": {
   "url": "http://localhost:8001",
   "auth_header": "x-user-email",
   "auth_val": "maya.chen@northstar.example",
   "seed_sql": "INSERT INTO user (\n  user_id, first_name, last_name, email, phone, role, location_id, active,\n  sys_created_on, sys_updated_on\n) VALUES\n(1300, 'Maya', 'Chen', 'maya.chen@northstar.example', '+91-90000-09007',\n 'admin', NULL, TRUE, '2026-07-20 09:00:00', '2026-07-20 09:00:00'),\n(1301, 'Ava', 'Rao', 'ava.rao@aurora-transit.example', '+91-90000-09008',\n 'customer', NULL, TRUE, '2026-07-20 09:00:00', '2026-07-20 09:00:00'),\n(1302, 'Noah', 'Rao', 'noah.rao@aurora-logistics.example', '+91-90000-09009',\n 'customer', NULL, TRUE, '2026-07-20 09:00:00', '2026-07-20 09:00:00');\n\nINSERT INTO account (\n  account_id, name, account_type, email_domain, active, sys_created_on, sys_updated_on\n) VALUES\n(1300, 'Aurora Transit', 'customer', 'aurora-transit.example', TRUE,\n '2026-07-20 09:00:00', '2026-07-20 09:00:00'),\n(1301, 'Aurora Logistics', 'customer', 'aurora-logistics.example', TRUE,\n '2026-07-20 09:00:00', '2026-07-20 09:00:00');\n\nINSERT INTO contact (\n  contact_id, account_id, portal_user_id, active, is_primary,\n  sys_created_on, sys_updated_on\n) VALUES\n(1300, 1300, 1301, TRUE, TRUE, '2026-07-20 09:00:00', '2026-07-20 09:00:00'),\n(1301, 1301, 1302, TRUE, TRUE, '2026-07-20 09:00:00', '2026-07-20 09:00:00');\n\nINSERT INTO product (\n  product_id, name, category, product_price, lifecycle_state,\n  sys_created_on, sys_updated_on\n) VALUES\n(1300, 'TransitEdge Controller', 'hardware', 48000.00, 'active',\n '2026-07-20 09:00:00', '2026-07-20 09:00:00'),\n(1301, 'TransitEdge Sensor', 'hardware', 12000.00, 'active',\n '2026-07-20 09:00:00', '2026-07-20 09:00:00');\n\nINSERT INTO contract (\n  contract_id, account_id, contract_type, status, contract_price, start_date,\n  end_date, sys_created_on, sys_updated_on\n) VALUES\n(1300, 1300, 'support', 'active', 80000.00, '2026-01-01', '2026-12-31',\n '2026-01-01 09:00:00', '2026-01-01 09:00:00'),\n(1301, 1301, 'support', 'active', 12000.00, '2026-01-01', '2026-12-31',\n '2026-01-01 09:00:00', '2026-01-01 09:00:00');\n\nINSERT INTO entitlement (\n  entitlement_id, account_id, product_id, contract_id, support_level,\n  coverage_hours, max_cases_per_month, active, sys_created_on, sys_updated_on\n) VALUES\n(1300, 1300, 1300, 1300, 'enterprise', 'h24x7', 100, TRUE,\n '2026-01-01 09:00:00', '2026-01-01 09:00:00'),\n(1301, 1301, 1300, 1301, 'standard', 'h8x5', 10, FALSE,\n '2026-01-01 09:00:00', '2026-01-01 09:00:00');\n\nINSERT INTO installed_product (\n  installed_product_id, account_id, product_id, location_id, serial_number,\n  status, warranty_end, sys_created_on, sys_updated_on\n) VALUES\n(1300, 1300, 1300, NULL, 'ENT-AX-9007', 'in_use', '2028-12-31',\n '2026-02-01 09:00:00', '2026-02-01 09:00:00'),\n(1301, 1301, 1300, NULL, 'ENT-AX-9008', 'in_use', '2028-12-31',\n '2026-02-01 09:00:00', '2026-02-01 09:00:00'),\n(1302, 1300, 1301, NULL, 'ENT-SN-2100', 'in_use', '2028-12-31',\n '2026-02-01 09:00:00', '2026-02-01 09:00:00');\n\nINSERT INTO customer_case (\n  case_id, number, account_id, contact_id, product_id, installed_product_id,\n  channel, priority, state, short_description, assignment_group_id, assigned_to,\n  escalation, escalation_reason, reopen_count, sys_created_on, sys_updated_on,\n  closed_on\n) VALUES\n(1300, 'CS-V12-09007', 1300, 1300, 1300, 1300, 'email', 'moderate', 'pending',\n 'V12 entitlement exception review for Aurora Transit', NULL, 1300, FALSE, NULL,\n 0, '2026-07-20 10:00:00', '2026-07-20 10:00:00', NULL),\n(1301, 'CS-V12-09008', 1301, 1301, 1300, 1301, 'email', 'moderate', 'new',\n 'V12 entitlement exception review for Aurora Logistics', NULL, 1300, FALSE, NULL,\n 0, '2026-07-20 10:05:00', '2026-07-20 10:05:00', NULL),\n(1302, 'CS-V12-02100', 1300, 1300, 1301, 1302, 'web', 'low', 'new',\n 'Routine TransitEdge sensor question', NULL, 1300, FALSE, NULL,\n 0, '2026-07-20 10:10:00', '2026-07-20 10:10:00', NULL);\n\nINSERT INTO knowledge (\n  knowledge_id, kb_number, title, body, state, visibility, product_id, owner_id,\n  sys_created_on, sys_updated_on\n) VALUES\n(1300, 'KB-CSM-ENT-077', 'V12 Entitlement Exception Standard',\n 'R1 A new or pending customer case associated with an in-use installed product is a candidate for escalation. R2 Exception: act only when the same account has an active enterprise entitlement for the installed product product_id. R3 R2 overrides R1, so a look-alike account with inactive or non-enterprise coverage remains untouched. R4 For the qualifying case set state to in_progress, priority to high, escalation to true, and escalation_reason to impact. R5 Resolve the qualifying installed product serial in ITSM and set only that configuration item status to maintenance. R6 Create exactly one Drive file whose entire name is the ITSM-returned serial, mime type text/plain, and description Entitlement exception evidence for Aurora Transit.',\n 'published', 'internal', 1300, 1300, '2026-07-20 09:30:00', '2026-07-20 09:30:00');\n"
  },
  "gym-itsm-mcp": {
   "url": "http://localhost:8002",
   "auth_header": "x-itsm-user-token",
   "auth_val": "itsm_v12_entitlement_token",
   "seed_sql": "INSERT INTO organization (org_id, name, active, created_at, updated_at) VALUES\n('ORG_V12_ENT', 'Northstar Entitlement Operations', TRUE, '2026-07-20 09:00:00', '2026-07-20 09:00:00');\n\nINSERT INTO role (role_id, name) VALUES\n('ROLE_V12_ENT_ADMIN', 'admin');\n\nINSERT INTO permission (perm_id, resource, action) VALUES\n('PERM_V12_ENT_CI_READ', 'configuration_items', 'read'),\n('PERM_V12_ENT_CI_CRUD', 'configuration_items', 'crud');\n\nINSERT INTO role_permission (role_id, perm_id) VALUES\n('ROLE_V12_ENT_ADMIN', 'PERM_V12_ENT_CI_READ'),\n('ROLE_V12_ENT_ADMIN', 'PERM_V12_ENT_CI_CRUD');\n\nINSERT INTO location (\n  location_id, name, org_id, plot_no, street, city, state, country,\n  active, created_on, updated_on\n) VALUES\n('LOC_V12_ENT', 'Aurora Transit Control', 'ORG_V12_ENT', '9007', 'Entitlement Road',\n 'Bengaluru', 'Karnataka', 'India', TRUE, '2026-07-20 09:00:00', '2026-07-20 09:00:00');\n\nINSERT INTO users (\n  user_id, user_name, first_name, last_name, email, phone, role, active,\n  static_token, org_id, location_id, created_on, updated_on\n) VALUES\n('USER_V12_ENT', 'maya.chen', 'Maya', 'Chen', 'maya.chen@northstar.example',\n '+91-90000-09007', 'admin', TRUE, 'itsm_v12_entitlement_token',\n 'ORG_V12_ENT', 'LOC_V12_ENT', '2026-07-20 09:00:00', '2026-07-20 09:00:00');\n\nINSERT INTO user_role (user_id, role_id, org_id) VALUES\n('USER_V12_ENT', 'ROLE_V12_ENT_ADMIN', 'ORG_V12_ENT');\n\nINSERT INTO configuration_item (\n  configuration_item_id, name, serial_number, owner_id, location_id, org_id,\n  status, cost, created_on, updated_on\n) VALUES\n('CI_V12_ENT_9007', 'Aurora TransitEdge Controller', 'ENT-AX-9007',\n 'USER_V12_ENT', 'LOC_V12_ENT', 'ORG_V12_ENT', 'in_use', 48000.00,\n '2026-07-20 09:00:00', '2026-07-20 09:00:00'),\n('CI_V12_ENT_9008', 'Aurora Logistics Controller', 'ENT-AX-9008',\n 'USER_V12_ENT', 'LOC_V12_ENT', 'ORG_V12_ENT', 'in_use', 48000.00,\n '2026-07-20 09:00:00', '2026-07-20 09:00:00');\n"
  },
  "gym-google-drive-mcp": {
   "url": "http://localhost:8009",
   "auth_header": "x-auth-token",
   "auth_val": "drive_v12_entitlement_token",
   "seed_sql": "INSERT INTO users (id, display_name, email, photo_url, auth_token, created_time, kind, permission_id, me) VALUES\n('DRV_USER_V12_ENT', 'Maya Chen', 'maya.chen@northstar.example', NULL,\n 'drive_v12_entitlement_token', '2026-07-20 09:00:00', 'drive#user',\n 'DRV_PERM_USER_V12_ENT', TRUE);\n\nINSERT INTO drives (\n  id, name, color_rgb, theme_id, background_image_link, hidden,\n  restricted_to_domain, trashed, created_time, modified_time,\n  copy_requires_writer_permission, domain_users_only, drive_members_only,\n  admin_managed_restrictions, sharing_folders_requires_organizer_permission,\n  download_restricted_for_readers, download_restricted_for_writers,\n  org_unit_id, kind\n) VALUES\n('DRV_V12_ENT', 'Entitlement Evidence', '#34A853', NULL, NULL, FALSE, TRUE, FALSE,\n '2026-07-20 09:00:00', '2026-07-20 09:00:00', FALSE, FALSE, FALSE, FALSE,\n FALSE, FALSE, FALSE, NULL, 'drive#drive');\n\nINSERT INTO drive_memberships (id, drive_id, type, user_id, group_id, domain, role, created_time) VALUES\n('DRV_MEM_V12_ENT', 'DRV_V12_ENT', 'user', 'DRV_USER_V12_ENT', NULL, NULL,\n 'organizer', '2026-07-20 09:05:00');\n\nINSERT INTO files (\n  id, drive_id, name, mime_type, size_bytes, description, parent_id, parent_ids,\n  starred, trashed, created_by, modified_by, created_time, modified_time,\n  properties, app_properties, is_shortcut, shortcut_target_id,\n  shortcut_target_mime, kind, shared, owned_by_me, viewed_by_me,\n  modified_by_me, explicitly_trashed, writers_can_share, version,\n  quota_bytes_used, space\n) VALUES\n('DRV_FILE_V12_ENT_DECOY', 'DRV_V12_ENT', 'ENT-AX-9008', 'text/plain', 64,\n 'Pre-existing evidence for the neighbouring account', NULL, '[]', FALSE, FALSE,\n 'DRV_USER_V12_ENT', 'DRV_USER_V12_ENT', '2026-07-19 09:00:00',\n '2026-07-19 09:00:00', '{}', '{}', FALSE, NULL, NULL, 'drive#file', TRUE, TRUE,\n TRUE, TRUE, FALSE, TRUE, 1, 64, 'drive');\n\nINSERT INTO file_owners (file_id, user_id, created_time) VALUES\n('DRV_FILE_V12_ENT_DECOY', 'DRV_USER_V12_ENT', '2026-07-19 09:00:00');\n\nINSERT INTO permissions (\n  id, file_id, drive_id, role, type, user_id, group_id, email_address, domain,\n  allow_file_discovery, kind, deleted, view, created_time, updated_time, inherited\n) VALUES\n('DRV_PERMISSION_V12_ENT_DECOY', 'DRV_FILE_V12_ENT_DECOY', NULL, 'owner', 'user',\n 'DRV_USER_V12_ENT', NULL, NULL, NULL, FALSE, 'drive#permission', FALSE,\n 'published', '2026-07-19 09:00:00', '2026-07-19 09:00:00', FALSE);\n\nINSERT INTO change_tokens (scope, last_token) VALUES\n('user', '1'),\n('DRV_V12_ENT', '1');\n"
  }
 },
 "mcp_endpoint": "/mcp",
 "plan": [
  {
   "gym": "sn-csm-server",
   "tool": "find_entitlements",
   "arguments": {},
   "note": "Discover entitlement id(s) before acting (no id-guessing) -> ['1300']"
  },
  {
   "gym": "sn-csm-server",
   "tool": "update_case",
   "arguments": {
    "case_id": 1300,
    "state": "in_progress",
    "priority": "high",
    "escalation": true,
    "escalation_reason": "impact"
   },
   "note": "R4: qualify the entitled Aurora Transit case CS-V12-09007"
  },
  {
   "gym": "gym-itsm-mcp",
   "tool": "find_configuration_item_by_serial_number",
   "arguments": {
    "serial_number": "ENT-AX-9007"
   },
   "note": "Resolve installed-product serial through ITSM -> CI_V12_ENT_9007"
  },
  {
   "gym": "gym-itsm-mcp",
   "tool": "update_configuration_item",
   "arguments": {
    "configuration_item_id": "CI_V12_ENT_9007",
    "status": "maintenance"
   },
   "note": "R5: set only that CI to maintenance"
  },
  {
   "gym": "gym-google-drive-mcp",
   "tool": "create_file",
   "arguments": {
    "name": "ENT-AX-9007",
    "mimeType": "text/plain",
    "description": "Entitlement exception evidence for Aurora Transit",
    "parents": [
     "DRV_V12_ENT"
    ]
   },
   "note": "R6: exactly one evidence file named the ITSM-returned serial"
  }
 ],
 "verifiers": [
  {
   "name": "target_case_exact",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM customer_case WHERE case_id=1300 AND number='CS-V12-09007' AND account_id=1300 AND installed_product_id=1300 AND state='in_progress' AND priority='high' AND escalation=1 AND escalation_reason='impact'",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "lookalike_case_untouched",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM customer_case WHERE case_id=1301 AND number='CS-V12-09008' AND account_id=1301 AND installed_product_id=1301 AND state='new' AND priority='moderate' AND escalation=0 AND escalation_reason IS NULL",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "other_target_case_untouched",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM customer_case WHERE case_id=1302 AND product_id=1301 AND state='new' AND priority='low' AND escalation=0",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "entitlement_unchanged",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM entitlement WHERE entitlement_id=1300 AND account_id=1300 AND product_id=1300 AND support_level='enterprise' AND coverage_hours='h24x7' AND active=1",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "decoy_entitlement_unchanged",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM entitlement WHERE entitlement_id=1301 AND account_id=1301 AND support_level='standard' AND active=0",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "target_installed_product_unchanged",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM installed_product WHERE installed_product_id=1300 AND account_id=1300 AND product_id=1300 AND serial_number='ENT-AX-9007' AND status='in_use'",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "target_ci_maintenance",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM configuration_item WHERE configuration_item_id='CI_V12_ENT_9007' AND serial_number='ENT-AX-9007' AND status='maintenance'",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "neighbour_ci_untouched",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM configuration_item WHERE configuration_item_id='CI_V12_ENT_9008' AND serial_number='ENT-AX-9008' AND status='in_use'",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "drive_evidence_exact",
   "gym": "gym-google-drive-mcp",
   "query": "SELECT COUNT(*) FROM files WHERE name='ENT-AX-9007' AND mime_type='text/plain' AND description='Entitlement exception evidence for Aurora Transit' AND trashed=0",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "drive_evidence_single",
   "gym": "gym-google-drive-mcp",
   "query": "SELECT COUNT(*) FROM files WHERE name='ENT-AX-9007'",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "decoy_drive_file_untouched",
   "gym": "gym-google-drive-mcp",
   "query": "SELECT COUNT(*) FROM files WHERE id='DRV_FILE_V12_ENT_DECOY' AND name='ENT-AX-9008' AND description='Pre-existing evidence for the neighbouring account' AND trashed=0",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "drive_permission_preserved",
   "gym": "gym-google-drive-mcp",
   "query": "SELECT COUNT(*) FROM permissions WHERE id='DRV_PERMISSION_V12_ENT_DECOY' AND file_id='DRV_FILE_V12_ENT_DECOY' AND role='owner' AND type='user' AND user_id='DRV_USER_V12_ENT' AND deleted=0",
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
