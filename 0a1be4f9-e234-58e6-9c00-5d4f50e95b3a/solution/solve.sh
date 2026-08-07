#!/usr/bin/env bash
# Oracle solution for task 154 — Nadia Rahman here, Customer Service. Wire-fraud emergency for our customer Acme Corporation (the real customer, not the similarly named partner) — need it escal
# Auto-generated AFTER the oracle reproduced this answer key live — answer-key-reproducible, not an independent solve (31/31 verifiers, 6 repair(s)).
# Self-contained: bash + python3 stdlib only. Seeds each gym on a fresh scratch db,
# replays the tool-call plan over MCP, then checks every verifier. Exit 0 iff all pass.
set -uo pipefail

exec python3 - <<'ORACLE_PY'

import json, time, urllib.request, urllib.error

DATA = json.loads(r"""{
 "task_id": "154",
 "gyms": {
  "sn-csm-server": {
   "url": "http://localhost:8001",
   "auth_header": "x-user-email",
   "auth_val": "chandrapiyush357@gmail.com",
   "seed_sql": "-- MCP Server: sn-csm-server\nINSERT INTO location (location_id, name, city, country, active) VALUES (11, 'London Operations Center', 'london', 'uk', 1);\nINSERT INTO location (location_id, name, city, country, active) VALUES (12, 'New York Operations Center', 'new_york', 'usa', 1);\nINSERT INTO user (user_id, first_name, last_name, email, phone, role, location_id, active) VALUES (601, 'Marcus', 'Feldman', 'marcus.feldman@acme-support.example', '+44-20-555-0601', 'agent', 11, 1);\nINSERT INTO user (user_id, first_name, last_name, email, phone, role, location_id, active) VALUES (602, 'Nina', 'Alvarez', 'nina.alvarez@acme-support.example', '+1-212-555-0602', 'agent', 12, 1);\nINSERT INTO user (user_id, first_name, last_name, email, phone, role, location_id, active) VALUES (603, 'Owen', 'Blake', 'owen.blake@acme-support.example', '+1-212-555-0603', 'agent', 12, 1);\nINSERT INTO user (user_id, first_name, last_name, email, phone, role, location_id, active) VALUES (604, 'Marcus', 'Feldman', 'marcus.feldman@acme-old.example', '+44-20-555-0604', 'agent', 11, 0);\nINSERT INTO user (user_id, first_name, last_name, email, phone, role, location_id, active) VALUES (701, 'Priya', 'Menon', 'priya.menon@acme-customer.com', '+1-408-555-0701', 'customer', NULL, 1);\nINSERT INTO user (user_id, first_name, last_name, email, phone, role, location_id, active) VALUES (501, 'Nadia', 'Rahman', 'chandrapiyush357@gmail.com', '+44-20-555-0501', 'agent', 11, 1);\nINSERT INTO account (account_id, name, account_type, email_domain, active) VALUES (1001, 'Acme Corporation', 'customer', 'acme-customer.com', 1);\nINSERT INTO account (account_id, name, account_type, email_domain, active) VALUES (1002, 'Acme Holdings', 'partner', 'acmeholdings.example', 1);\nINSERT INTO contact (contact_id, account_id, portal_user_id, active, is_primary) VALUES (3001, 1001, 701, 1, 1);\nINSERT INTO customer_case (case_id, number, account_id, contact_id, product_id, installed_product_id, channel, priority, state, short_description, assignment_group_id, assigned_to, escalation, escalation_reason, reopen_count) VALUES (9001, 'CS0012345', 1001, 3001, NULL, NULL, 'phone', 'high', 'new', 'Reported wire fraud on outbound payment', NULL, NULL, 0, NULL, 0);\nINSERT INTO customer_case (case_id, number, account_id, contact_id, product_id, installed_product_id, channel, priority, state, short_description, assignment_group_id, assigned_to, escalation, escalation_reason, reopen_count) VALUES (9002, 'CS0012346', 1001, 3001, NULL, NULL, 'phone', 'high', 'new', 'Finance recovery sub-case for wire fraud', NULL, NULL, 0, NULL, 0);\nINSERT INTO customer_case (case_id, number, account_id, contact_id, product_id, installed_product_id, channel, priority, state, short_description, assignment_group_id, assigned_to, escalation, escalation_reason, reopen_count) VALUES (9003, 'CS0012347', 1001, 3001, NULL, NULL, 'email', 'moderate', 'new', 'General billing inquiry for Acme Corporation', NULL, NULL, 0, NULL, 0);\n"
  },
  "gym-email-mcp": {
   "url": "http://localhost:8007",
   "auth_header": "x-email-user-token",
   "auth_val": "tok_nadia_2025_7f3a9c",
   "seed_sql": "-- MCP Server: email_v4\nINSERT INTO users (id, token, primary_email, name, messages_total, threads_total, history_id_current, created_at, updated_at) VALUES ('usr_nadia', 'tok_nadia_2025_7f3a9c', 'chandrapiyush357@gmail.com', 'Nadia Rahman', 1, 1, 2000, '2026-01-05T09:00:00Z', '2026-07-30T09:00:00Z');\nINSERT INTO users (id, token, primary_email, name, messages_total, threads_total, history_id_current, created_at, updated_at) VALUES ('usr_priya', 'tok_priya_2025_9b2e11', 'priya.menon@acme-customer.com', 'Priya Menon', 0, 0, 1000, '2026-01-05T09:00:00Z', '2026-07-30T09:00:00Z');\nINSERT INTO labels (id, user_id, name, message_list_visibility, label_list_visibility, type, messages_total, messages_unread, threads_total, threads_unread, created_at, updated_at) VALUES ('lbl_inbox_nadia', 'usr_nadia', 'INBOX', 'show', 'labelShow', 'system', 1, 1, 1, 1, '2026-01-05T09:00:00Z', '2026-07-30T09:00:00Z');\nINSERT INTO threads (id, user_id, snippet, history_id_last, created_at, updated_at) VALUES ('thr_cust_001', 'usr_nadia', 'Request for order status update from Priya Menon', 2000, '2026-07-30T08:00:00Z', '2026-07-30T08:00:00Z');\nINSERT INTO messages (id, user_id, thread_id, snippet, history_id_last, internal_date_ms, size_estimate, created_at, updated_at) VALUES ('msg_cust_001', 'usr_nadia', 'thr_cust_001', 'Hello, could you please confirm the status of my recent order', 2000, 1753862400000, 2048, '2026-07-30T08:00:00Z', '2026-07-30T08:00:00Z');\nINSERT INTO message_parts (id, message_id, parent_part_id, part_id, mime_type, filename, created_at, updated_at) VALUES ('mp_cust_001', 'msg_cust_001', NULL, '0', 'text/plain', NULL, '2026-07-30T08:00:00Z', '2026-07-30T08:00:00Z');\nINSERT INTO message_headers (id, message_part_id, name, value, created_at, updated_at) VALUES ('hdr_from_001', 'mp_cust_001', 'From', 'Priya Menon <priya.menon@acme-customer.com>', '2026-07-30T08:00:00Z', '2026-07-30T08:00:00Z');\nINSERT INTO message_headers (id, message_part_id, name, value, created_at, updated_at) VALUES ('hdr_to_001', 'mp_cust_001', 'To', 'Nadia Rahman <chandrapiyush357@gmail.com>', '2026-07-30T08:00:00Z', '2026-07-30T08:00:00Z');\nINSERT INTO message_headers (id, message_part_id, name, value, created_at, updated_at) VALUES ('hdr_subj_001', 'mp_cust_001', 'Subject', 'Request for order status update', '2026-07-30T08:00:00Z', '2026-07-30T08:00:00Z');\nINSERT INTO message_part_bodies (id, message_part_id, size, data, attachment_id, created_at, updated_at) VALUES ('mpb_cust_001', 'mp_cust_001', 180, 'Hello Nadia, could you please confirm the status of my recent order placed last week. Thank you, Priya', NULL, '2026-07-30T08:00:00Z', '2026-07-30T08:00:00Z');\nINSERT INTO message_labels (message_id, label_id) VALUES ('msg_cust_001', 'lbl_inbox_nadia');\nINSERT INTO send_as_aliases (id, user_id, send_as_email, display_name, reply_to_address, signature, is_primary, is_default, treat_as_alias, verification_status, created_at, updated_at) VALUES ('sa_nadia_primary', 'usr_nadia', 'chandrapiyush357@gmail.com', 'Nadia Rahman', NULL, 'Best regards, Nadia Rahman', 'true', 'true', 'false', 'accepted', '2026-01-05T09:00:00Z', '2026-07-30T09:00:00Z');"
  }
 },
 "mcp_endpoint": "/mcp",
 "plan": [
  {
   "gym": "sn-csm-server",
   "tool": "find_contacts",
   "arguments": {},
   "note": "Discover contact id(s) before acting (no id-guessing) -> ['1001', '3001']"
  },
  {
   "gym": "sn-csm-server",
   "tool": "search_cases",
   "arguments": {},
   "note": "Discover case id(s) before acting (no id-guessing) -> ['9001', '9002', '9001']"
  },
  {
   "gym": "sn-csm-server",
   "tool": "update_case",
   "arguments": {
    "case_id": 9001,
    "state": "in_progress",
    "escalation": true,
    "escalation_reason": "breach_risk",
    "priority": "critical",
    "assigned_to": 601,
    "short_description": "Wire fraud escalation for Acme Corporation pending funds recovery"
   },
   "note": "Escalate case 9001, assign to London active agent 601 (Marcus Feldman)"
  },
  {
   "gym": "sn-csm-server",
   "tool": "update_case",
   "arguments": {
    "case_id": 9002,
    "assigned_to": 602
   },
   "note": "Assign finance recovery sub-case to Nina Alvarez (602), distinct from escalation lead"
  },
  {
   "gym": "sn-csm-server",
   "tool": "register_new_interaction",
   "arguments": {
    "channel": "phone",
    "status": "handled",
    "account_id": 1001,
    "contact_id": 3001,
    "case_id": 9001,
    "interacted_user": 501
   },
   "note": "Log interaction on 9001 by acting agent 501"
  },
  {
   "gym": "gym-email-mcp",
   "tool": "send_message",
   "arguments": {
    "userId": "me",
    "payload": {
     "filename": "ack.txt",
     "mimeType": "text/plain",
     "headers": [
      {
       "name": "From",
       "value": "chandrapiyush357@gmail.com"
      },
      {
       "name": "To",
       "value": "priya.menon@acme-customer.com"
      },
      {
       "name": "Subject",
       "value": "Acknowledgement of your wire fraud escalation case CS0012345"
      }
     ],
     "body": {
      "data": "Dear Priya Menon, We acknowledge receipt of your wire fraud escalation case CS0012345 for Acme Corporation. It is now escalated as a critical breach-risk matter and in progress. We will keep you updated at priya.menon@acme-customer.com regarding funds recovery. Best regards, Nadia Rahman",
      "size": 290
     }
    },
    "snippet": "Acknowledgement of your wire fraud escalation case CS0012345"
   },
   "note": "Send the acknowledgement email using plain email addresses in headers (display-name form was rejected). This satisfies all 4 failing email checks."
  }
 ],
 "verifiers": [
  {
   "name": "case9001_state_in_progress",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM customer_case WHERE case_id='9001' AND state='in_progress';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "case9001_escalation_flag",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM customer_case WHERE case_id='9001' AND escalation='1';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "case9001_escalation_reason",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM customer_case WHERE case_id='9001' AND escalation_reason='breach_risk';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "case9001_priority_critical",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM customer_case WHERE case_id='9001' AND priority='critical';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "case9001_assigned_owner601",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM customer_case WHERE case_id='9001' AND assigned_to='601';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "case9001_short_description",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM customer_case WHERE case_id='9001' AND short_description='Wire fraud escalation for Acme Corporation pending funds recovery';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "case9001_all_fields_combined",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM customer_case WHERE case_id='9001' AND state='in_progress' AND escalation='1' AND escalation_reason='breach_risk' AND priority='critical' AND assigned_to='601' AND short_description='Wire fraud escalation for Acme Corporation pending funds recovery';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "case9001_owner_is_london_active_agent",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM customer_case c JOIN user u ON c.assigned_to=u.user_id WHERE c.case_id='9001' AND u.role='agent' AND u.active='1' AND u.location_id='11';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "case9001_not_nyc_decoy603",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM customer_case WHERE case_id='9001' AND assigned_to='603';",
   "expected": 0,
   "comparison": "equals"
  },
  {
   "name": "case9001_not_inactive_namesake604",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM customer_case WHERE case_id='9001' AND assigned_to='604';",
   "expected": 0,
   "comparison": "equals"
  },
  {
   "name": "case9001_owner_active",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM customer_case c JOIN user u ON c.assigned_to=u.user_id WHERE c.case_id='9001' AND u.active='0';",
   "expected": 0,
   "comparison": "equals"
  },
  {
   "name": "interaction_case9001_exists",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM interaction WHERE case_id='9001' AND channel='phone' AND status='handled';",
   "expected": 0,
   "comparison": "greater_than"
  },
  {
   "name": "interaction_account1001",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM interaction WHERE case_id='9001' AND account_id='1001';",
   "expected": 0,
   "comparison": "greater_than"
  },
  {
   "name": "interaction_contact3001",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM interaction WHERE case_id='9001' AND contact_id='3001';",
   "expected": 0,
   "comparison": "greater_than"
  },
  {
   "name": "interaction_by_acting_agent",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM interaction WHERE case_id='9001' AND interacted_user='501';",
   "expected": 0,
   "comparison": "greater_than"
  },
  {
   "name": "interaction_full_combined",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM interaction WHERE case_id='9001' AND channel='phone' AND status='handled' AND account_id='1001' AND contact_id='3001' AND interacted_user='501';",
   "expected": 0,
   "comparison": "greater_than"
  },
  {
   "name": "subcase9002_assigned_deputy602",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM customer_case WHERE case_id='9002' AND assigned_to='602';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "subcase9002_not_owner601_SoD",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM customer_case WHERE case_id='9002' AND assigned_to='601';",
   "expected": 0,
   "comparison": "equals"
  },
  {
   "name": "subcase9002_deputy_distinct_active_agent",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM customer_case c JOIN user u ON c.assigned_to=u.user_id WHERE c.case_id='9002' AND u.role='agent' AND u.active='1' AND c.assigned_to <> (SELECT assigned_to FROM customer_case WHERE case_id='9001');",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "subcase9002_number_intact",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM customer_case WHERE case_id='9002' AND number='CS0012346' AND account_id='1001';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "subcase9002_not_escalated",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM customer_case WHERE case_id='9002' AND escalation='1';",
   "expected": 0,
   "comparison": "equals"
  },
  {
   "name": "decoy9003_billing_untouched_assign",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM customer_case WHERE case_id='9003' AND (assigned_to IS NULL OR assigned_to='');",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "decoy9003_state_new",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM customer_case WHERE case_id='9003' AND state='new' AND escalation='0';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "decoy9003_priority_untouched",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM customer_case WHERE case_id='9003' AND priority='moderate';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "inactive_namesake604_still_inactive",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM user WHERE user_id='604' AND active='0';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "email_ack_subject_from_nadia",
   "gym": "gym-email-mcp",
   "query": "SELECT COUNT(*) FROM message_headers h JOIN message_parts mp ON h.message_part_id=mp.id JOIN messages m ON mp.message_id=m.id WHERE m.user_id='usr_nadia' AND h.name='Subject' AND h.value='Acknowledgement of your wire fraud escalation case CS0012345';",
   "expected": 0,
   "comparison": "greater_than"
  },
  {
   "name": "email_ack_to_priya",
   "gym": "gym-email-mcp",
   "query": "SELECT COUNT(*) FROM message_headers h JOIN message_parts mp ON h.message_part_id=mp.id JOIN messages m ON mp.message_id=m.id WHERE m.user_id='usr_nadia' AND h.name='To' AND h.value LIKE '%priya.menon@acme-customer.com%';",
   "expected": 0,
   "comparison": "greater_than"
  },
  {
   "name": "email_ack_message_correlated",
   "gym": "gym-email-mcp",
   "query": "SELECT COUNT(*) FROM messages m WHERE m.user_id='usr_nadia' AND EXISTS (SELECT 1 FROM message_headers h JOIN message_parts mp ON h.message_part_id=mp.id WHERE mp.message_id=m.id AND h.name='Subject' AND h.value='Acknowledgement of your wire fraud escalation case CS0012345') AND EXISTS (SELECT 1 FROM message_headers h2 JOIN message_parts mp2 ON h2.message_part_id=mp2.id WHERE mp2.message_id=m.id AND h2.name='To' AND h2.value LIKE '%priya.menon@acme-customer.com%');",
   "expected": 0,
   "comparison": "greater_than"
  },
  {
   "name": "email_not_sent_from_priya_mailbox",
   "gym": "gym-email-mcp",
   "query": "SELECT COUNT(*) FROM message_headers h JOIN message_parts mp ON h.message_part_id=mp.id JOIN messages m ON mp.message_id=m.id WHERE m.user_id='usr_priya' AND h.name='Subject' AND h.value='Acknowledgement of your wire fraud escalation case CS0012345';",
   "expected": 0,
   "comparison": "equals"
  },
  {
   "name": "email_exactly_one_ack",
   "gym": "gym-email-mcp",
   "query": "SELECT COUNT(*) FROM message_headers h JOIN message_parts mp ON h.message_part_id=mp.id JOIN messages m ON mp.message_id=m.id WHERE h.name='Subject' AND h.value='Acknowledgement of your wire fraud escalation case CS0012345';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "email_ack_not_to_self",
   "gym": "gym-email-mcp",
   "query": "SELECT COUNT(*) FROM message_headers h JOIN message_parts mp ON h.message_part_id=mp.id JOIN messages m ON mp.message_id=m.id WHERE m.user_id='usr_nadia' AND h.name='Subject' AND h.value='Acknowledgement of your wire fraud escalation case CS0012345' AND EXISTS (SELECT 1 FROM message_headers h2 JOIN message_parts mp2 ON h2.message_part_id=mp2.id WHERE mp2.message_id=m.id AND h2.name='To' AND h2.value LIKE '%chandrapiyush357@gmail.com%');",
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
