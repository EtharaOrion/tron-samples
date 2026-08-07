#!/usr/bin/env bash
# Oracle solution for task d6e96910-5aa6-5edc-8bbc-b00e3fa6537d — # Manager handoff for Nora Patel
# Auto-generated AFTER the oracle reproduced this answer key live — answer-key-reproducible, not an independent solve (12/12 verifiers, 4 repair(s)).
# Self-contained: bash + python3 stdlib only. Seeds each gym on a fresh scratch db,
# replays the tool-call plan over MCP, then checks every verifier. Exit 0 iff all pass.
set -uo pipefail

exec python3 - <<'ORACLE_PY'

import json, time, urllib.request, urllib.error

DATA = json.loads(r"""{
 "task_id": "d6e96910-5aa6-5edc-8bbc-b00e3fa6537d",
 "gyms": {
  "sn-hr-internal": {
   "url": "http://localhost:8003",
   "auth_header": "x-hr-token-access",
   "auth_val": "hr_v12_handoff_admin_token",
   "seed_sql": "INSERT INTO organization (org_id, name, active, created_at, updated_at) VALUES (1200, 'Northstar HR', 1, '2026-07-01 08:00:00', '2026-07-01 08:00:00');\nINSERT INTO role (role_id, name, created_at, updated_at) VALUES (1200, 'admin', '2026-07-01 08:00:00', '2026-07-01 08:00:00');\nINSERT INTO role (role_id, name, created_at, updated_at) VALUES (1201, 'employee', '2026-07-01 08:00:00', '2026-07-01 08:00:00');\nINSERT INTO permission (perm_id, resource, action, created_at, updated_at) VALUES (1200, 'users', 'crud', '2026-07-01 08:00:00', '2026-07-01 08:00:00');\nINSERT INTO permission (perm_id, resource, action, created_at, updated_at) VALUES (1201, 'hr_profiles', 'crud', '2026-07-01 08:00:00', '2026-07-01 08:00:00');\nINSERT INTO permission (perm_id, resource, action, created_at, updated_at) VALUES (1202, 'knowledge', 'crud', '2026-07-01 08:00:00', '2026-07-01 08:00:00');\nINSERT INTO permission (perm_id, resource, action, created_at, updated_at) VALUES (1203, 'hr_cases', 'crud', '2026-07-01 08:00:00', '2026-07-01 08:00:00');\nINSERT INTO role_permission (role_id, perm_id, created_at, updated_at) VALUES (1200, 1200, '2026-07-01 08:00:00', '2026-07-01 08:00:00');\nINSERT INTO role_permission (role_id, perm_id, created_at, updated_at) VALUES (1200, 1201, '2026-07-01 08:00:00', '2026-07-01 08:00:00');\nINSERT INTO role_permission (role_id, perm_id, created_at, updated_at) VALUES (1200, 1202, '2026-07-01 08:00:00', '2026-07-01 08:00:00');\nINSERT INTO role_permission (role_id, perm_id, created_at, updated_at) VALUES (1200, 1203, '2026-07-01 08:00:00', '2026-07-01 08:00:00');\nINSERT INTO user (user_id, first_name, last_name, email, phone, role, active, org_id, static_token, created_at, updated_at) VALUES (1200, 'Dana', 'Wu', 'dana.wu@northstar.example', '+1-555-1200', 'admin', 1, 1200, 'hr_v12_handoff_admin_token', '2026-07-01 08:00:00', '2026-07-01 08:00:00');\nINSERT INTO user (user_id, first_name, last_name, email, phone, role, active, org_id, static_token, created_at, updated_at) VALUES (1201, 'Elena', 'Morris', 'elena.morris@northstar.example', '+1-555-1201', 'employee', 1, 1200, 'hr_v12_handoff_manager_token', '2026-07-01 08:00:00', '2026-07-01 08:00:00');\nINSERT INTO user (user_id, first_name, last_name, email, phone, role, active, org_id, static_token, created_at, updated_at) VALUES (1202, 'Nora', 'Patel', 'nora.patel@northstar.example', '+1-555-1202', 'employee', 1, 1200, 'hr_v12_handoff_nora_token', '2026-07-01 08:00:00', '2026-07-01 08:00:00');\nINSERT INTO user (user_id, first_name, last_name, email, phone, role, active, org_id, static_token, created_at, updated_at) VALUES (1203, 'Omar', 'Patel', 'omar.patel@northstar.example', '+1-555-1203', 'employee', 1, 1200, 'hr_v12_handoff_omar_token', '2026-07-01 08:00:00', '2026-07-01 08:00:00');\nINSERT INTO user_role (user_id, role_id, org_id, created_at, updated_at) VALUES (1200, 1200, 1200, '2026-07-01 08:00:00', '2026-07-01 08:00:00');\nINSERT INTO user_role (user_id, role_id, org_id, created_at, updated_at) VALUES (1201, 1201, 1200, '2026-07-01 08:00:00', '2026-07-01 08:00:00');\nINSERT INTO user_role (user_id, role_id, org_id, created_at, updated_at) VALUES (1202, 1201, 1200, '2026-07-01 08:00:00', '2026-07-01 08:00:00');\nINSERT INTO user_role (user_id, role_id, org_id, created_at, updated_at) VALUES (1203, 1201, 1200, '2026-07-01 08:00:00', '2026-07-01 08:00:00');\nINSERT INTO hr_profile (hr_profile_id, number, gender, user_id, personal_email, marital_status, type, nationality, employment_start_date, manager, location_type, national_tax_id, position, org_id, created_at, updated_at) VALUES (1200, 'HR-V12-1200', 'Female', 1200, 'dana.wu.private@northstar.example', 'Single', 'full-time', 'US', '2020-01-06 09:00:00', NULL, 'Office Based', 'TAX-V12-1200', 'HR', 1200, '2026-07-01 08:00:00', '2026-07-01 08:00:00');\nINSERT INTO hr_profile (hr_profile_id, number, gender, user_id, personal_email, marital_status, type, nationality, employment_start_date, manager, location_type, national_tax_id, position, org_id, created_at, updated_at) VALUES (1201, 'HR-V12-1201', 'Female', 1201, 'elena.morris@northstar.example', 'Single', 'full-time', 'US', '2019-03-11 09:00:00', 1200, 'Office Based', 'TAX-V12-1201', 'Manager', 1200, '2026-07-01 08:00:00', '2026-07-01 08:00:00');\nINSERT INTO hr_profile (hr_profile_id, number, gender, user_id, personal_email, marital_status, type, nationality, employment_start_date, manager, location_type, national_tax_id, position, org_id, created_at, updated_at) VALUES (1202, 'HR-V12-1202', 'Female', 1202, 'nora.patel.private@northstar.example', 'Single', 'full-time', 'US', '2022-04-04 09:00:00', 1201, 'Office Based', 'TAX-V12-1202', 'IT Support', 1200, '2026-07-01 08:00:00', '2026-07-01 08:00:00');\nINSERT INTO hr_profile (hr_profile_id, number, gender, user_id, personal_email, marital_status, type, nationality, employment_start_date, manager, location_type, national_tax_id, position, org_id, created_at, updated_at) VALUES (1203, 'HR-V12-1203', 'Male', 1203, 'omar.patel.private@northstar.example', 'Single', 'full-time', 'US', '2022-04-04 09:00:00', 1201, 'Office Based', 'TAX-V12-1203', 'IT Support', 1200, '2026-07-01 08:00:00', '2026-07-01 08:00:00');\nINSERT INTO knowledge (knowledge_id, kb_number, title, body, state, visibility, owner_id, created_at, updated_at, org_id) VALUES (1242, 'KB-HR-HANDOFF-042', 'Manager Handoff Selection Standard', 'R1 For an Office Based employee select calendar cal_hr_handoff_42 event evt_handoff_core_42 named Manager Handoff - Core. R2 For an IT Support employee select calendar cal_hr_handoff_42 event evt_handoff_restricted_42 named Manager Handoff - Restricted. R3 R2 overrides R1. R4 Patch only the selected event so its sole attendee is the reporting manager email, then read the event back before sending email. R5 Open one case with short description Manager handoff for Nora Patel, status ready, priority high, source email, and Center of Excellence Workforce Administration.', 'published', 'internal', 1200, '2026-07-01 08:00:00', '2026-07-01 08:00:00', 1200);\n"
  },
  "gym-calendar": {
   "url": "http://localhost:8008",
   "auth_header": "x-access-token",
   "auth_val": "cal_v12_handoff_token",
   "seed_sql": "INSERT INTO users (user_id, email, name, given_name, family_name, timezone, is_active, is_verified, static_token, created_at, updated_at) VALUES ('dana.wu', 'dana.wu@northstar.example', 'Dana Wu', 'Dana', 'Wu', 'America/New_York', 1, 1, 'cal_v12_handoff_token', '2026-07-01 08:00:00', '2026-07-01 08:00:00');\nINSERT INTO users (user_id, email, name, given_name, family_name, timezone, is_active, is_verified, static_token, created_at, updated_at) VALUES ('elena.morris', 'elena.morris@northstar.example', 'Elena Morris', 'Elena', 'Morris', 'America/New_York', 1, 1, 'cal_v12_manager_token', '2026-07-01 08:00:00', '2026-07-01 08:00:00');\nINSERT INTO users (user_id, email, name, given_name, family_name, timezone, is_active, is_verified, static_token, created_at, updated_at) VALUES ('omar.patel', 'omar.patel@northstar.example', 'Omar Patel', 'Omar', 'Patel', 'America/New_York', 1, 1, 'cal_v12_omar_token', '2026-07-01 08:00:00', '2026-07-01 08:00:00');\nINSERT INTO calendars (calendar_id, user_id, summary, description, time_zone, is_primary, hidden, selected, deleted, created_at, updated_at) VALUES ('cal_hr_handoff_42', 'dana.wu', 'HR Manager Handoffs', 'Northstar manager handoff calendar', 'America/New_York', 1, 0, 1, 0, '2026-07-01 08:00:00', '2026-07-01 08:00:00');\nINSERT INTO events (event_id, calendar_id, user_id, organizer_id, organizer_email, organizer_display_name, organizer_self, summary, description, start_datetime, end_datetime, start_timezone, end_timezone, status, visibility, eventType, guestsCanInviteOthers, guestsCanModify, guestsCanSeeOtherGuests, sequence, transparency, created_at, updated_at) VALUES ('evt_handoff_core_42', 'cal_hr_handoff_42', 'dana.wu', 'dana.wu', 'dana.wu@northstar.example', 'Dana Wu', 1, 'Manager Handoff - Core', 'General manager handoff event', '2026-08-03T14:00:00-04:00', '2026-08-03T14:30:00-04:00', 'America/New_York', 'America/New_York', 'confirmed', 'default', 'default', 1, 0, 1, 0, 'opaque', '2026-07-01 08:00:00', '2026-07-01 08:00:00');\nINSERT INTO events (event_id, calendar_id, user_id, organizer_id, organizer_email, organizer_display_name, organizer_self, summary, description, start_datetime, end_datetime, start_timezone, end_timezone, status, visibility, eventType, guestsCanInviteOthers, guestsCanModify, guestsCanSeeOtherGuests, sequence, transparency, created_at, updated_at) VALUES ('evt_handoff_restricted_42', 'cal_hr_handoff_42', 'dana.wu', 'dana.wu', 'dana.wu@northstar.example', 'Dana Wu', 1, 'Manager Handoff - Restricted', 'Restricted manager handoff event', '2026-08-03T15:00:00-04:00', '2026-08-03T15:30:00-04:00', 'America/New_York', 'America/New_York', 'confirmed', 'private', 'default', 1, 0, 1, 0, 'opaque', '2026-07-01 08:00:00', '2026-07-01 08:00:00');\n"
  },
  "gym-email-mcp": {
   "url": "http://localhost:8007",
   "auth_header": "x-email-user-token",
   "auth_val": "email_v12_handoff_token",
   "seed_sql": "INSERT INTO users (id, token, primary_email, name, messages_total, threads_total, history_id_current, created_at, updated_at) VALUES ('email_v12_handoff_actor', 'email_v12_handoff_token', 'dana.wu@northstar.example', 'Dana Wu', 0, 0, '1200', '2026-07-01 08:00:00', '2026-07-01 08:00:00');\n"
  }
 },
 "mcp_endpoint": "/mcp",
 "plan": [
  {
   "gym": "sn-hr-internal",
   "tool": "create_new_hr_case",
   "arguments": {
    "short_description": "Manager handoff for Nora Patel",
    "coe_type": "Workforce Administration",
    "status": "ready",
    "priority": "high",
    "source": "email",
    "opened_for": "Nora Patel"
   },
   "note": "Open exactly one HR case for Nora (user_id 1202, org 1200)"
  },
  {
   "gym": "gym-calendar",
   "tool": "patch_event",
   "arguments": {
    "calendarId": "cal_hr_handoff_42",
    "eventId": "evt_handoff_restricted_42",
    "attendees": [
     {
      "email": "elena.morris@northstar.example"
     }
    ]
   },
   "note": "Set restricted event attendee to HR-derived manager address only"
  },
  {
   "gym": "gym-calendar",
   "tool": "get_event",
   "arguments": {
    "calendarId": "cal_hr_handoff_42",
    "eventId": "evt_handoff_restricted_42"
   },
   "note": "Read back confirmed manager attendee address"
  },
  {
   "gym": "gym-email-mcp",
   "tool": "send_message",
   "arguments": {
    "userId": "me",
    "payload": {
     "filename": "body.txt",
     "mimeType": "text/plain",
     "headers": [
      {
       "name": "From",
       "value": "dana.wu@northstar.example"
      },
      {
       "name": "To",
       "value": "elena.morris@northstar.example"
      },
      {
       "name": "Subject",
       "value": "Manager handoff confirmed for Nora Patel"
      }
     ],
     "body": {
      "data": "The restricted manager handoff for Nora Patel is confirmed.",
      "size": 59
     }
    },
    "snippet": "The restricted manager handoff for Nora Patel is confirmed."
   },
   "note": "filename belongs at the part/payload level as a sibling of body (Gmail Part schema), not inside body \u2014 this satisfies the validator's 'filename can't be empty when data present in payload body' rule while storing body data and headers."
  }
 ],
 "verifiers": [
  {
   "name": "hr_case_exact",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM hr_case WHERE opened_for=1202 AND short_description='Manager handoff for Nora Patel' AND coe_type='Workforce Administration' AND status='ready' AND priority='high' AND source='email' AND org_id=1200",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "hr_case_single",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM hr_case WHERE short_description='Manager handoff for Nora Patel' AND org_id=1200",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "no_case_for_omar",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM hr_case WHERE opened_for=1203 AND org_id=1200",
   "expected": 0,
   "comparison": "equals"
  },
  {
   "name": "nora_profile_unchanged",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM hr_profile WHERE hr_profile_id=1202 AND manager=1201 AND location_type='Office Based' AND position='IT Support'",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "omar_profile_unchanged",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM hr_profile WHERE hr_profile_id=1203 AND manager=1201 AND location_type='Office Based' AND position='IT Support'",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "selected_event_manager_attendee",
   "gym": "gym-calendar",
   "query": "SELECT COUNT(*) FROM attendees a JOIN users u ON u.user_id=a.user_id WHERE a.event_id='evt_handoff_restricted_42' AND u.email='elena.morris@northstar.example'",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "selected_event_single_attendee",
   "gym": "gym-calendar",
   "query": "SELECT COUNT(*) FROM attendees WHERE event_id='evt_handoff_restricted_42'",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "lookalike_event_untouched",
   "gym": "gym-calendar",
   "query": "SELECT COUNT(*) FROM attendees WHERE event_id='evt_handoff_core_42'",
   "expected": 0,
   "comparison": "equals"
  },
  {
   "name": "email_to_confirmed_manager",
   "gym": "gym-email-mcp",
   "query": "SELECT COUNT(*) FROM message_headers t JOIN message_headers s ON s.message_part_id=t.message_part_id AND s.name='Subject' WHERE t.name='To' AND t.value='elena.morris@northstar.example' AND s.value='Manager handoff confirmed for Nora Patel'",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "email_body_exact",
   "gym": "gym-email-mcp",
   "query": "SELECT COUNT(*) FROM message_part_bodies WHERE data='The restricted manager handoff for Nora Patel is confirmed.'",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "email_single",
   "gym": "gym-email-mcp",
   "query": "SELECT COUNT(*) FROM message_headers WHERE name='Subject' AND value='Manager handoff confirmed for Nora Patel'",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "no_email_to_omar",
   "gym": "gym-email-mcp",
   "query": "SELECT COUNT(*) FROM message_headers WHERE name='To' AND value='omar.patel@northstar.example'",
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
