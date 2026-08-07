#!/usr/bin/env bash
# Oracle solution for task 07b2292d-4b61-59c5-b329-f73c09c00317 — # Regulated edge escalation
# Auto-generated AFTER the oracle reproduced this answer key live — answer-key-reproducible, not an independent solve (11/11 verifiers, 2 repair(s)).
# Self-contained: bash + python3 stdlib only. Seeds each gym on a fresh scratch db,
# replays the tool-call plan over MCP, then checks every verifier. Exit 0 iff all pass.
set -uo pipefail

exec python3 - <<'ORACLE_PY'

import json, time, urllib.request, urllib.error

DATA = json.loads(r"""{
 "task_id": "07b2292d-4b61-59c5-b329-f73c09c00317",
 "gyms": {
  "gym-google-drive-mcp": {
   "url": "http://localhost:8009",
   "auth_header": "x-auth-token",
   "auth_val": "drive_v12_escalation_token",
   "seed_sql": "INSERT INTO users (id, display_name, email, photo_url, auth_token, created_time, kind, permission_id, me) VALUES\n('DRV_USER_V12_ESC', 'Rina Shah', 'rina.shah@northstar.example', NULL, 'drive_v12_escalation_token', '2026-07-20 09:00:00', 'drive#user', 'DRV_PERM_USER_V12_ESC', TRUE);\n\nINSERT INTO drives (\n  id, name, color_rgb, theme_id, background_image_link, hidden,\n  restricted_to_domain, trashed, created_time, modified_time,\n  copy_requires_writer_permission, domain_users_only, drive_members_only,\n  admin_managed_restrictions, sharing_folders_requires_organizer_permission,\n  download_restricted_for_readers, download_restricted_for_writers,\n  org_unit_id, kind\n) VALUES\n('DRV_V12_ESC', 'Operations Standards', '#4285F4', NULL, NULL, FALSE, TRUE, FALSE,\n '2026-07-20 09:00:00', '2026-07-20 09:00:00', FALSE, FALSE, FALSE, FALSE,\n FALSE, FALSE, FALSE, NULL, 'drive#drive');\n\nINSERT INTO drive_memberships (id, drive_id, type, user_id, group_id, domain, role, created_time) VALUES\n('DRV_MEM_V12_ESC', 'DRV_V12_ESC', 'user', 'DRV_USER_V12_ESC', NULL, NULL, 'organizer', '2026-07-20 09:05:00');\n\nINSERT INTO files (\n  id, drive_id, name, mime_type, size_bytes, description, parent_id, parent_ids,\n  starred, trashed, created_by, modified_by, created_time, modified_time,\n  properties, app_properties, is_shortcut, shortcut_target_id,\n  shortcut_target_mime, kind, shared, owned_by_me, viewed_by_me,\n  modified_by_me, explicitly_trashed, writers_can_share, version,\n  quota_bytes_used, space\n) VALUES\n('DRV_FILE_V12_STANDARD_27', 'DRV_V12_ESC', 'V12 Change Routing Standard 27',\n 'text/plain', 1240,\n 'R1 Select the configuration item serial from appProperties.selected_serial. R2 For a regulated edge target, the in-scope incident set is every incident on that resolved configuration item whose status is new, in_progress, or on_hold. R3 R2 overrides any single-container shortcut and incidents on another configuration item or in resolved status are excluded. R4 Create exactly one change with short description Regulated edge maintenance for selected configuration item, status assess, impact high, risk high, priority critical, category hardware, and cab_required true. R5 Update every in-scope incident with the created change reference and work note Escalated under V12 Change Routing Standard 27. R6 Send exactly one Teams channel message to team TEAM_V12_ESC and channel CHAN_V12_ESC with content Regulated edge escalation target <resolved_serial>, replacing the token with the byte-exact ITSM-returned serial. For this selected file the exact rendered message is Regulated edge escalation target SRV-EDGE-417.',\n NULL, '[]', FALSE, FALSE, 'DRV_USER_V12_ESC', 'DRV_USER_V12_ESC',\n '2026-07-20 09:10:00', '2026-07-20 09:10:00', '{}',\n '{\"selected_serial\":\"SRV-EDGE-417\",\"team_id\":\"TEAM_V12_ESC\",\"channel_id\":\"CHAN_V12_ESC\"}',\n FALSE, NULL, NULL, 'drive#file', TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, 1, 1240, 'drive');\n\nINSERT INTO file_owners (file_id, user_id, created_time) VALUES\n('DRV_FILE_V12_STANDARD_27', 'DRV_USER_V12_ESC', '2026-07-20 09:10:00');\n\nINSERT INTO change_tokens (scope, last_token) VALUES\n('user', '1'),\n('DRV_V12_ESC', '1');\n"
  },
  "gym-itsm-mcp": {
   "url": "http://localhost:8002",
   "auth_header": "x-itsm-user-token",
   "auth_val": "itsm_v12_escalation_token",
   "seed_sql": "INSERT INTO organization (org_id, name, active, created_at, updated_at) VALUES\n('ORG_V12_ESC', 'Northstar Edge Operations', TRUE, '2026-07-20 09:00:00', '2026-07-20 09:00:00');\n\nINSERT INTO role (role_id, name) VALUES\n('ROLE_V12_ESC_ADMIN', 'admin');\n\nINSERT INTO permission (perm_id, resource, action) VALUES\n('PERM_V12_ESC_CI_READ', 'configuration_items', 'read'),\n('PERM_V12_ESC_CHANGE_CRUD', 'changes', 'crud'),\n('PERM_V12_ESC_INC_READ', 'incidents', 'read'),\n('PERM_V12_ESC_INC_CRUD', 'incidents', 'crud');\n\nINSERT INTO role_permission (role_id, perm_id) VALUES\n('ROLE_V12_ESC_ADMIN', 'PERM_V12_ESC_CI_READ'),\n('ROLE_V12_ESC_ADMIN', 'PERM_V12_ESC_CHANGE_CRUD'),\n('ROLE_V12_ESC_ADMIN', 'PERM_V12_ESC_INC_READ'),\n('ROLE_V12_ESC_ADMIN', 'PERM_V12_ESC_INC_CRUD');\n\nINSERT INTO location (\n  location_id, name, org_id, plot_no, street, city, state, country,\n  active, created_on, updated_on\n) VALUES\n('LOC_V12_ESC', 'Northstar Edge Site', 'ORG_V12_ESC', '417', 'Relay Way',\n 'Pune', 'Maharashtra', 'India', TRUE, '2026-07-20 09:00:00', '2026-07-20 09:00:00');\n\nINSERT INTO users (\n  user_id, user_name, first_name, last_name, email, phone, role, active,\n  static_token, org_id, location_id, created_on, updated_on\n) VALUES\n('USER_V12_ESC', 'rina.shah', 'Rina', 'Shah', 'rina.shah@northstar.example',\n '+91-90000-00417', 'admin', TRUE, 'itsm_v12_escalation_token',\n 'ORG_V12_ESC', 'LOC_V12_ESC', '2026-07-20 09:00:00', '2026-07-20 09:00:00');\n\nINSERT INTO user_role (user_id, role_id, org_id) VALUES\n('USER_V12_ESC', 'ROLE_V12_ESC_ADMIN', 'ORG_V12_ESC');\n\nINSERT INTO configuration_item (\n  configuration_item_id, name, serial_number, owner_id, location_id, org_id,\n  status, cost, created_on, updated_on\n) VALUES\n('CI_V12_EDGE_417', 'Regulated Edge Gateway 417', 'SRV-EDGE-417',\n 'USER_V12_ESC', 'LOC_V12_ESC', 'ORG_V12_ESC', 'in_use', 41700.00,\n '2026-07-20 09:00:00', '2026-07-20 09:00:00'),\n('CI_V12_EDGE_410', 'Neighbour Edge Gateway 410', 'SRV-EDGE-410',\n 'USER_V12_ESC', 'LOC_V12_ESC', 'ORG_V12_ESC', 'in_use', 41000.00,\n '2026-07-20 09:00:00', '2026-07-20 09:00:00');\n\nINSERT INTO incident (\n  incident_id, number, short_description, caller_id, configuration_item, org_id,\n  channel, contact_type, status, category, description, worknotes, impact,\n  urgency, priority, on_hold_reason, created_at, updated_at\n) VALUES\n('INC_V12_ESC_NEW', 'INC-V12-0417-A', 'Edge telemetry loss', 'USER_V12_ESC',\n 'CI_V12_EDGE_417', 'ORG_V12_ESC', 'web', 'portal', 'new', 'network',\n 'Regulated edge telemetry is intermittent', '', 'high', 'high', 'critical',\n NULL, '2026-07-20 09:15:00', '2026-07-20 09:15:00'),\n('INC_V12_ESC_PROGRESS', 'INC-V12-0417-B', 'Edge routing degradation', 'USER_V12_ESC',\n 'CI_V12_EDGE_417', 'ORG_V12_ESC', 'phone', 'phone', 'in_progress', 'network',\n 'Regulated edge routes are degrading', '', 'high', 'high', 'critical',\n NULL, '2026-07-20 09:20:00', '2026-07-20 09:20:00'),\n('INC_V12_ESC_HOLD', 'INC-V12-0417-C', 'Edge maintenance prerequisite', 'USER_V12_ESC',\n 'CI_V12_EDGE_417', 'ORG_V12_ESC', 'email', 'email', 'on_hold', 'hardware',\n 'Regulated edge awaits coordinated maintenance', '', 'medium', 'high', 'high',\n 'Awaiting Change', '2026-07-20 09:25:00', '2026-07-20 09:25:00'),\n('INC_V12_ESC_RESOLVED', 'INC-V12-0417-D', 'Historical edge alert', 'USER_V12_ESC',\n 'CI_V12_EDGE_417', 'ORG_V12_ESC', 'web', 'portal', 'resolved', 'network',\n 'Historical alert is already resolved', 'Closed before this escalation', 'low',\n 'low', 'low', NULL, '2026-07-18 09:00:00', '2026-07-19 09:00:00'),\n('INC_V12_ESC_NEIGHBOUR', 'INC-V12-0410-A', 'Neighbour gateway alert', 'USER_V12_ESC',\n 'CI_V12_EDGE_410', 'ORG_V12_ESC', 'web', 'portal', 'new', 'network',\n 'Neighbouring edge alert', 'Neighbour must remain untouched', 'medium', 'medium',\n 'moderate', NULL, '2026-07-20 09:30:00', '2026-07-20 09:30:00');\n"
  },
  "gym-teams-mcp": {
   "url": "http://localhost:8010",
   "auth_header": "x-teams-access-token",
   "auth_val": "teams_v12_escalation_token",
   "seed_sql": "INSERT INTO teams_orgs (\n  org_id, tenant_id, display_name, domain_name, country_letter_code,\n  preferred_language, created_at, updated_at, soft_deleted\n) VALUES\n('TEAMS_ORG_V12_ESC', 'TENANT_V12_ESC', 'Northstar Operations',\n 'northstar.example', 'IN', 'en-IN', '2026-07-20 09:00:00',\n '2026-07-20 09:00:00', FALSE);\n\nINSERT INTO teams_users (\n  org_id, user_id, display_name, mail, static_token, job_title, department,\n  account_enabled, soft_deleted, created_at, updated_at\n) VALUES\n('TEAMS_ORG_V12_ESC', 'TEAMS_USER_V12_ESC', 'Rina Shah',\n 'rina.shah@northstar.example', 'teams_v12_escalation_token',\n 'Edge Operations Lead', 'Operations', TRUE, FALSE,\n '2026-07-20 09:00:00', '2026-07-20 09:00:00');\n\nINSERT INTO permissions_catalog (\n  id, name, type, admin_consent_required, description, resource, operation,\n  category, permission_level_rank, requires_resource_ownership,\n  applies_to_scope, created_at, updated_at\n) VALUES\n('ChannelMessage.Send:delegated', 'ChannelMessage.Send', 'delegated', FALSE,\n 'Send channel messages', 'ChannelMessage', 'Send', 'communication', 30, TRUE,\n 'own',\n '2026-07-20 09:00:00', '2026-07-20 09:00:00');\n\nINSERT INTO user_permissions (\n  org_id, user_id, permission_id, granted_at, granted_by\n) VALUES\n('TEAMS_ORG_V12_ESC', 'TEAMS_USER_V12_ESC', 'ChannelMessage.Send:delegated',\n '2026-07-20 09:00:00', 'system');\n\nINSERT INTO module_permissions (module_name, permission_id, created_at) VALUES\n('channels', 'ChannelMessage.Send:delegated', '2026-07-20 09:00:00');\n\nINSERT INTO teams_user_roles (\n  org_id, user_id, role_id, role_name, assigned_at, assigned_by\n) VALUES\n('TEAMS_ORG_V12_ESC', 'TEAMS_USER_V12_ESC', 'member', 'member',\n '2026-07-20 09:00:00', 'system');\n\nINSERT INTO teams (\n  org_id, team_id, display_name, description, visibility, specialization,\n  internal_id, is_archived, migration_mode, created_date_time,\n  updated_date_time, soft_delete\n) VALUES\n('TEAMS_ORG_V12_ESC', 'TEAM_V12_ESC', 'Regulated Edge Operations',\n 'Regulated edge coordination', 'private', 'none', 'TEAM_V12_ESC_INTERNAL',\n FALSE, 'none', '2026-07-20 09:00:00', '2026-07-20 09:00:00', FALSE);\n\nINSERT INTO channels (\n  channel_id, org_id, team_id, display_name, description, membership_type,\n  is_favorite_by_default, is_archived, migration_mode, created_date_time,\n  soft_delete\n) VALUES\n('CHAN_V12_ESC', 'TEAMS_ORG_V12_ESC', 'TEAM_V12_ESC', 'escalations',\n 'Regulated edge escalation channel', 'standard', TRUE, FALSE, NULL,\n '2026-07-20 09:00:00', FALSE);\n\nINSERT INTO channel_members (\n  channel_id, user_id, roles, display_name, email, tenant_id, added_at\n) VALUES\n('CHAN_V12_ESC', 'TEAMS_USER_V12_ESC', 'owner', 'Rina Shah',\n 'rina.shah@northstar.example', 'TENANT_V12_ESC', '2026-07-20 09:00:00');\n"
  }
 },
 "mcp_endpoint": "/mcp",
 "plan": [
  {
   "gym": "gym-itsm-mcp",
   "tool": "list_incidents",
   "arguments": {},
   "note": "Discover incident id(s) before acting (no id-guessing) -> ['INC_V12_ESC_NEW', 'INC_V12_ESC_PROGRESS', 'INC_V12_ESC_HOLD']"
  },
  {
   "gym": "gym-itsm-mcp",
   "tool": "find_configuration_item_by_serial_number",
   "arguments": {
    "serial_number": "SRV-EDGE-417"
   },
   "note": "Resolve selected serial through ITSM to get byte-exact serial and CI id"
  },
  {
   "gym": "gym-itsm-mcp",
   "tool": "create_change",
   "arguments": {
    "short_description": "Regulated edge maintenance for selected configuration item",
    "status": "assess",
    "impact": "high",
    "risk": "high",
    "priority": "critical",
    "category": "hardware",
    "cab_required": true,
    "configuration_item": "CI_V12_EDGE_417"
   },
   "note": "R4 create exactly one change for resolved CI"
  },
  {
   "gym": "gym-teams-mcp",
   "tool": "send_channel_message",
   "arguments": {
    "teamId": "TEAM_V12_ESC",
    "channelId": "CHAN_V12_ESC",
    "body": {
     "contentType": "text",
     "content": "Regulated edge escalation target SRV-EDGE-417"
    }
   },
   "note": "R6 exactly one channel message with byte-exact ITSM serial"
  },
  {
   "gym": "gym-itsm-mcp",
   "tool": "update_incident",
   "arguments": {
    "incident_id": "INC_V12_ESC_NEW",
    "change_request": "CHG_001",
    "worknotes": "Escalated under V12 Change Routing Standard 27"
   },
   "note": "Update new incident with change reference and worknote"
  },
  {
   "gym": "gym-itsm-mcp",
   "tool": "update_incident",
   "arguments": {
    "incident_id": "INC_V12_ESC_PROGRESS",
    "change_request": "CHG_001",
    "worknotes": "Escalated under V12 Change Routing Standard 27"
   },
   "note": "Update in_progress incident"
  },
  {
   "gym": "gym-itsm-mcp",
   "tool": "update_incident",
   "arguments": {
    "incident_id": "INC_V12_ESC_HOLD",
    "change_request": "CHG_001",
    "worknotes": "Escalated under V12 Change Routing Standard 27"
   },
   "note": "Update on_hold incident"
  }
 ],
 "verifiers": [
  {
   "name": "one_exact_change",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM change WHERE configuration_item='CI_V12_EDGE_417' AND short_description='Regulated edge maintenance for selected configuration item' AND status='assess' AND impact='high' AND risk='high' AND priority='critical' AND category='hardware' AND cab_required=1",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "single_change",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM change WHERE configuration_item='CI_V12_EDGE_417'",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "new_incident_updated",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident i JOIN change c ON c.change_id=i.change_request WHERE i.incident_id='INC_V12_ESC_NEW' AND i.worknotes='Escalated under V12 Change Routing Standard 27' AND c.configuration_item='CI_V12_EDGE_417'",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "progress_incident_updated",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident i JOIN change c ON c.change_id=i.change_request WHERE i.incident_id='INC_V12_ESC_PROGRESS' AND i.worknotes='Escalated under V12 Change Routing Standard 27' AND c.configuration_item='CI_V12_EDGE_417'",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "hold_incident_updated",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident i JOIN change c ON c.change_id=i.change_request WHERE i.incident_id='INC_V12_ESC_HOLD' AND i.worknotes='Escalated under V12 Change Routing Standard 27' AND c.configuration_item='CI_V12_EDGE_417'",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "resolved_incident_untouched",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE incident_id='INC_V12_ESC_RESOLVED' AND change_request IS NULL AND worknotes='Closed before this escalation' AND status='resolved'",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "neighbour_incident_untouched",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE incident_id='INC_V12_ESC_NEIGHBOUR' AND configuration_item='CI_V12_EDGE_410' AND change_request IS NULL AND worknotes='Neighbour must remain untouched'",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "target_ci_unchanged",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM configuration_item WHERE configuration_item_id='CI_V12_EDGE_417' AND serial_number='SRV-EDGE-417' AND status='in_use'",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "teams_message_exact",
   "gym": "gym-teams-mcp",
   "query": "SELECT COUNT(*) FROM channel_messages WHERE team_id='TEAM_V12_ESC' AND channel_id='CHAN_V12_ESC' AND body_json LIKE '%Regulated edge escalation target SRV-EDGE-417%' AND body_json LIKE '%text%'",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "teams_message_single",
   "gym": "gym-teams-mcp",
   "query": "SELECT COUNT(*) FROM channel_messages WHERE team_id='TEAM_V12_ESC' AND channel_id='CHAN_V12_ESC'",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "drive_policy_unchanged",
   "gym": "gym-google-drive-mcp",
   "query": "SELECT COUNT(*) FROM files WHERE id='DRV_FILE_V12_STANDARD_27' AND name='V12 Change Routing Standard 27' AND app_properties LIKE '%selected_serial%' AND app_properties LIKE '%SRV-EDGE-417%' AND trashed=0",
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
