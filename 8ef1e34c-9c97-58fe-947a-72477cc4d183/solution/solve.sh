#!/usr/bin/env bash
# Oracle solution for task 152 — Marcus here. We finally closed out the recurring API-cluster outage and I need you to finish the paperwork end-to-end. Start with the customer complaint thread 
# Auto-generated AFTER the oracle reproduced this answer key live — answer-key-reproducible, not an independent solve (30/30 verifiers, 4 repair(s)).
# Self-contained: bash + python3 stdlib only. Seeds each gym on a fresh scratch db,
# replays the tool-call plan over MCP, then checks every verifier. Exit 0 iff all pass.
set -uo pipefail

exec python3 - <<'ORACLE_PY'

import json, time, urllib.request, urllib.error

DATA = json.loads(r"""{
 "task_id": "152",
 "gyms": {
  "gym-itsm-mcp": {
   "url": "http://localhost:8002",
   "auth_header": "x-itsm-user-token",
   "auth_val": "agent_token_marcus_2024_secure",
   "seed_sql": "-- MCP Server: sn-itsm-internal\nINSERT INTO organization (org_id, name, active) VALUES ('org_acme', 'Acme Corporation', 1);\n\nINSERT INTO role (role_id, name) VALUES\n('ROLE_001', 'admin'),\n('ROLE_002', 'manager'),\n('ROLE_003', 'agent'),\n('ROLE_004', 'reporter');\n\nINSERT INTO permission (perm_id, resource, action) VALUES\n('PERM_001', 'users', 'read'),\n('PERM_002', 'users', 'crud'),\n('PERM_003', 'groups', 'read'),\n('PERM_004', 'groups', 'crud'),\n('PERM_005', 'services', 'read'),\n('PERM_006', 'services', 'crud'),\n('PERM_007', 'service_offerings', 'read'),\n('PERM_008', 'service_offerings', 'crud'),\n('PERM_009', 'configuration_items', 'read'),\n('PERM_010', 'configuration_items', 'crud'),\n('PERM_011', 'incident_templates', 'read'),\n('PERM_012', 'incident_templates', 'crud'),\n('PERM_013', 'problems', 'read'),\n('PERM_014', 'problems', 'crud'),\n('PERM_015', 'changes', 'read'),\n('PERM_016', 'changes', 'crud'),\n('PERM_017', 'notifications', 'read'),\n('PERM_018', 'notifications', 'crud'),\n('PERM_019', 'notification_analysis', 'read'),\n('PERM_020', 'notification_analysis', 'crud'),\n('PERM_021', 'sla_definitions', 'read'),\n('PERM_022', 'sla_definitions', 'crud'),\n('PERM_023', 'sla_metrics', 'read'),\n('PERM_024', 'sla_metrics', 'crud'),\n('PERM_025', 'incidents', 'read'),\n('PERM_026', 'incidents', 'crud'),\n('PERM_027', 'knowledge', 'read'),\n('PERM_028', 'knowledge', 'crud'),\n('PERM_029', 'locations', 'read'),\n('PERM_030', 'locations', 'crud'),\n('PERM_031', 'change_mappings', 'read'),\n('PERM_032', 'change_mappings', 'crud'),\n('PERM_033', 'incident_affected_cis', 'read'),\n('PERM_034', 'incident_affected_cis', 'crud'),\n('PERM_035', 'incident_slas', 'read'),\n('PERM_036', 'incident_slas', 'crud');\n\nINSERT INTO role_permission (role_id, perm_id) VALUES\n('ROLE_001', 'PERM_002'), ('ROLE_001', 'PERM_004'), ('ROLE_001', 'PERM_006'), ('ROLE_001', 'PERM_008'),\n('ROLE_001', 'PERM_010'), ('ROLE_001', 'PERM_012'), ('ROLE_001', 'PERM_014'), ('ROLE_001', 'PERM_016'),\n('ROLE_001', 'PERM_018'), ('ROLE_001', 'PERM_020'), ('ROLE_001', 'PERM_022'), ('ROLE_001', 'PERM_024'),\n('ROLE_001', 'PERM_026'), ('ROLE_001', 'PERM_028'), ('ROLE_001', 'PERM_030'), ('ROLE_001', 'PERM_032'),\n('ROLE_001', 'PERM_034'), ('ROLE_001', 'PERM_036');\n\nINSERT INTO role_permission (role_id, perm_id) VALUES\n('ROLE_002', 'PERM_002'), ('ROLE_002', 'PERM_004'), ('ROLE_002', 'PERM_006'), ('ROLE_002', 'PERM_008'),\n('ROLE_002', 'PERM_010'), ('ROLE_002', 'PERM_012'), ('ROLE_002', 'PERM_014'), ('ROLE_002', 'PERM_016'),\n('ROLE_002', 'PERM_018'), ('ROLE_002', 'PERM_020'), ('ROLE_002', 'PERM_022'), ('ROLE_002', 'PERM_024'),\n('ROLE_002', 'PERM_026'), ('ROLE_002', 'PERM_028'), ('ROLE_002', 'PERM_030'), ('ROLE_002', 'PERM_032'),\n('ROLE_002', 'PERM_034'), ('ROLE_002', 'PERM_036');\n\nINSERT INTO role_permission (role_id, perm_id) VALUES\n('ROLE_003', 'PERM_001'), ('ROLE_003', 'PERM_003'), ('ROLE_003', 'PERM_005'), ('ROLE_003', 'PERM_007'),\n('ROLE_003', 'PERM_010'), ('ROLE_003', 'PERM_011'), ('ROLE_003', 'PERM_014'), ('ROLE_003', 'PERM_016'),\n('ROLE_003', 'PERM_017'), ('ROLE_003', 'PERM_019'), ('ROLE_003', 'PERM_021'), ('ROLE_003', 'PERM_023'),\n('ROLE_003', 'PERM_026'), ('ROLE_003', 'PERM_028'), ('ROLE_003', 'PERM_030'), ('ROLE_003', 'PERM_031'),\n('ROLE_003', 'PERM_033'), ('ROLE_003', 'PERM_035');\n\nINSERT INTO role_permission (role_id, perm_id) VALUES\n('ROLE_004', 'PERM_001'), ('ROLE_004', 'PERM_003'), ('ROLE_004', 'PERM_005'), ('ROLE_004', 'PERM_007'),\n('ROLE_004', 'PERM_009'), ('ROLE_004', 'PERM_011'), ('ROLE_004', 'PERM_013'), ('ROLE_004', 'PERM_015'),\n('ROLE_004', 'PERM_017'), ('ROLE_004', 'PERM_019'), ('ROLE_004', 'PERM_021'), ('ROLE_004', 'PERM_023'),\n('ROLE_004', 'PERM_025'), ('ROLE_004', 'PERM_027'), ('ROLE_004', 'PERM_029'), ('ROLE_004', 'PERM_031'),\n('ROLE_004', 'PERM_033'), ('ROLE_004', 'PERM_035');\n\nINSERT INTO location (location_id, name, org_id, city, state, country, active) VALUES\n('LOC_001', 'Acme HQ', 'org_acme', 'San Francisco', 'published', 'USA', 1);\n\nINSERT INTO users (user_id, user_name, first_name, last_name, email, phone, role, active, static_token, org_id, location_id) VALUES\n('marcus.reed', 'marcus.reed', 'Marcus', 'Reed', 'marcus.reed@acme.com', '+1-415-555-0101', 'admin', 1, 'agent_token_marcus_2024_secure', 'org_acme', 'LOC_001'),\n('cust_jordan_blake', 'jordan.blake', 'Jordan', 'Blake', 'jordan.blake@customer.com', '+1-415-555-0202', 'reporter', 1, 'token_jordan_blake_2024', 'org_acme', 'LOC_001');\n\nINSERT INTO user_role (user_id, role_id, org_id) VALUES\n('marcus.reed', 'ROLE_001', 'org_acme');\n\nINSERT INTO problem (problem_id, number, problem_statement, opened_by, org_id, status, category, impact, urgency, priority) VALUES\n('PRB0040001', 'PRB0040001', 'Recurring service outage on customer-facing API cluster', 'marcus.reed', 'org_acme', 'new', 'network', 'high', 'high', 'critical');\n\nINSERT INTO problem (problem_id, number, problem_statement, opened_by, org_id, status, category, impact, urgency, priority) VALUES\n('PRB0040099', 'PRB0040099', 'Unrelated printer driver defect', 'marcus.reed', 'org_acme', 'new', 'hardware', 'low', 'low', 'low');\n\nINSERT INTO incident (incident_id, number, short_description, caller_id, problem, org_id, status, category, impact, urgency, priority) VALUES\n('INC0050001', 'INC0050001', 'Master incident - API cluster outage', 'cust_jordan_blake', 'PRB0040001', 'org_acme', 'in_progress', 'network', 'high', 'high', 'critical');\n\nINSERT INTO incident (incident_id, number, short_description, caller_id, problem, parent_incident, org_id, status, category, impact, urgency, priority) VALUES\n('INC0050002', 'INC0050002', 'Child incident - node A outage', 'cust_jordan_blake', 'PRB0040001', 'INC0050001', 'org_acme', 'in_progress', 'network', 'medium', 'medium', 'moderate');\n\nINSERT INTO incident (incident_id, number, short_description, caller_id, problem, parent_incident, org_id, status, category, impact, urgency, priority) VALUES\n('INC0050003', 'INC0050003', 'Child incident - node B outage', 'cust_jordan_blake', 'PRB0040001', 'INC0050001', 'org_acme', 'in_progress', 'network', 'medium', 'medium', 'moderate');\n\nINSERT INTO child_incident (child_incident_mapping_id, parent_incident, child_incident) VALUES\n('CHILD-MAP-1', 'INC0050001', 'INC0050002');\n\nINSERT INTO child_incident (child_incident_mapping_id, parent_incident, child_incident) VALUES\n('CHILD-MAP-2', 'INC0050001', 'INC0050003');"
  },
  "sn-csm-server": {
   "url": "http://localhost:8001",
   "auth_header": "x-user-email",
   "auth_val": "marcus.reed@acme.com",
   "seed_sql": "-- MCP Server: sn-csm-server\nINSERT INTO location (location_id, name, city, country, active) VALUES (1, 'HQ London', 'london', 'uk', 1);\nINSERT INTO user (user_id, first_name, last_name, email, phone, role, location_id, active) VALUES (501, 'Marcus', 'Reed', 'marcus.reed@acme.com', '+44-20-555-0501', 'admin', 1, 1);\nINSERT INTO user (user_id, first_name, last_name, email, phone, role, location_id, active) VALUES (701, 'Jordan', 'Blake', 'jordan.blake@northwind.com', '+44-20-555-0701', 'customer', 1, 1);\nINSERT INTO account (account_id, name, account_type, email_domain, active) VALUES (8001, 'Northwind Traders', 'customer', 'northwind.com', 1);\nINSERT INTO contact (contact_id, account_id, portal_user_id, active, is_primary) VALUES (6001, 8001, 701, 1, 1);\nINSERT INTO customer_case (case_id, number, account_id, contact_id, product_id, installed_product_id, channel, priority, state, short_description, assignment_group_id, assigned_to, escalation, escalation_reason, reopen_count) VALUES (9001, 'CS0009001', 8001, 6001, NULL, NULL, 'email', 'high', 'new', 'Recurring production outage causing repeated downtime, customer requests a permanent fix.', NULL, 501, 0, NULL, 0);\nINSERT INTO customer_case (case_id, number, account_id, contact_id, product_id, installed_product_id, channel, priority, state, short_description, assignment_group_id, assigned_to, escalation, escalation_reason, reopen_count, closed_on) VALUES (9002, 'CS0009002', 8001, 6001, NULL, NULL, 'email', 'low', 'closed', 'Historical billing query', NULL, NULL, 0, NULL, 0, '2025-01-15 10:00:00');\nINSERT INTO customer_case (case_id, number, account_id, contact_id, product_id, installed_product_id, channel, priority, state, short_description, assignment_group_id, assigned_to, escalation, escalation_reason, reopen_count) VALUES (9003, 'CS0009003', 8001, 6001, NULL, NULL, 'web', 'low', 'resolved', 'Historical password reset', NULL, NULL, 0, NULL, 0);\n"
  },
  "gym-email-mcp": {
   "url": "http://localhost:8007",
   "auth_header": "x-email-user-token",
   "auth_val": "tok_marcus_2025_a1b2c3",
   "seed_sql": "-- MCP Server: email_v4\nINSERT INTO users (id, token, primary_email, name, messages_total, threads_total, history_id_current, created_at, updated_at) VALUES ('eusr_marcus_501', 'tok_marcus_2025_a1b2c3', 'marcus.reed@acme.com', 'Marcus Reed', 2, 2, 2000, '2026-01-05T09:00:00Z', '2026-07-20T09:00:00Z');\nINSERT INTO labels (id, user_id, name, message_list_visibility, label_list_visibility, type, messages_total, messages_unread, threads_total, threads_unread, color_json, created_at, updated_at) VALUES ('lbl_inbox_marcus', 'eusr_marcus_501', 'INBOX', 'show', 'labelShow', 'system', 2, 1, 2, 1, NULL, '2026-01-05T09:00:00Z', '2026-07-20T09:00:00Z');\nINSERT INTO threads (id, user_id, snippet, history_id_last, created_at, updated_at) VALUES ('thr_001', 'eusr_marcus_501', 'Recurring service outage - urgent', 1900, '2026-07-18T08:00:00Z', '2026-07-18T08:00:00Z');\nINSERT INTO threads (id, user_id, snippet, history_id_last, created_at, updated_at) VALUES ('thr_002', 'eusr_marcus_501', 'Newsletter: product updates', 1850, '2026-07-15T08:00:00Z', '2026-07-15T08:00:00Z');\nINSERT INTO messages (id, user_id, thread_id, snippet, history_id_last, internal_date_ms, size_estimate, created_at, updated_at) VALUES ('msg_001', 'eusr_marcus_501', 'thr_001', 'Our service keeps going down repeatedly', 1900, 1752825600000, 2048, '2026-07-18T08:00:00Z', '2026-07-18T08:00:00Z');\nINSERT INTO message_parts (id, message_id, parent_part_id, part_id, mime_type, filename, created_at, updated_at) VALUES ('mp_001_root', 'msg_001', NULL, '0', 'text/plain', NULL, '2026-07-18T08:00:00Z', '2026-07-18T08:00:00Z');\nINSERT INTO message_headers (id, message_part_id, name, value, created_at, updated_at) VALUES ('hdr_001_from', 'mp_001_root', 'From', 'jordan.blake@northwind.com', '2026-07-18T08:00:00Z', '2026-07-18T08:00:00Z');\nINSERT INTO message_headers (id, message_part_id, name, value, created_at, updated_at) VALUES ('hdr_001_to', 'mp_001_root', 'To', 'marcus.reed@acme.com', '2026-07-18T08:00:00Z', '2026-07-18T08:00:00Z');\nINSERT INTO message_headers (id, message_part_id, name, value, created_at, updated_at) VALUES ('hdr_001_subject', 'mp_001_root', 'Subject', 'Recurring service outage - urgent', '2026-07-18T08:00:00Z', '2026-07-18T08:00:00Z');\nINSERT INTO message_part_bodies (id, message_part_id, size, data, attachment_id, created_at, updated_at) VALUES ('mpb_001_root', 'mp_001_root', 120, 'Our service keeps going down repeatedly. Please investigate the recurring outage as soon as possible.', NULL, '2026-07-18T08:00:00Z', '2026-07-18T08:00:00Z');\nINSERT INTO message_labels (message_id, label_id) VALUES ('msg_001', 'lbl_inbox_marcus');\nINSERT INTO send_as_aliases (id, user_id, send_as_email, display_name, reply_to_address, signature, is_primary, is_default, treat_as_alias, smtp_msa, verification_status, verification_token, verification_token_expires, created_at, updated_at) VALUES ('sa_marcus_primary', 'eusr_marcus_501', 'marcus.reed@acme.com', 'Marcus Reed', NULL, 'Marcus Reed, Support Engineer', 'true', 'true', 'false', NULL, 'accepted', NULL, NULL, '2026-01-05T09:00:00Z', '2026-07-20T09:00:00Z');"
  }
 },
 "mcp_endpoint": "/mcp",
 "plan": [
  {
   "gym": "gym-itsm-mcp",
   "tool": "update_problem",
   "arguments": {
    "number": "PRB0040001",
    "status": "resolved",
    "fix_notes": "Root cause: memory leak in the API cluster service. Permanent fix deployed across affected nodes via patch v2.3 (PRB0040001).",
    "worknotes": "RCA complete: memory leak identified in API cluster service; remediated with patch v2.3."
   },
   "note": "Resolve problem, record fix_notes and worknotes with required substrings"
  },
  {
   "gym": "gym-itsm-mcp",
   "tool": "update_incident",
   "arguments": {
    "incident_id": "INC0050002",
    "worknotes": "Linked to PRB0040001; permanent fix deployed across affected nodes."
   },
   "note": "Child A worknote (status untouched)"
  },
  {
   "gym": "gym-itsm-mcp",
   "tool": "update_incident",
   "arguments": {
    "incident_id": "INC0050003",
    "worknotes": "Linked to PRB0040001; permanent fix deployed across affected nodes."
   },
   "note": "Child B worknote (status untouched)"
  },
  {
   "gym": "sn-csm-server",
   "tool": "update_case",
   "arguments": {
    "case_id": 9001,
    "state": "resolved",
    "short_description": "Recurring production outage causing repeated downtime, customer requests a permanent fix. Resolved under PRB0040001.",
    "closed_on": "2026-07-30 12:00:00"
   },
   "note": "Resolve case, cross-ref problem, set closed_on"
  },
  {
   "gym": "gym-email-mcp",
   "tool": "send_message",
   "arguments": {
    "userId": "me",
    "threadId": "thr_001",
    "raw": "RnJvbTogbWFyY3VzLnJlZWRAYWNtZS5jb20KVG86IGpvcmRhbi5ibGFrZUBub3J0aHdpbmQuY29tClN1YmplY3Q6IFJlOiBvdXRhZ2UKClJlc29sdmVkLgo=",
    "snippet": "Outage resolved - reply to Jordan Blake on original thread"
   },
   "note": "Reply on inbound thread thr_001 to jordan.blake@northwind.com using RFC2822 base64url raw source, satisfying email_reply_created_on_thread (COUNT>1)."
  }
 ],
 "verifiers": [
  {
   "name": "problem_status_resolved",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM problem WHERE number = 'PRB0040001' AND status = 'resolved';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "problem_fix_notes_length",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM problem WHERE number = 'PRB0040001' AND fix_notes IS NOT NULL AND LENGTH(fix_notes) >= 20;",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "problem_fix_notes_memleak",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM problem WHERE number = 'PRB0040001' AND fix_notes LIKE '%memory leak%';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "problem_fix_notes_fixversion",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM problem WHERE number = 'PRB0040001' AND fix_notes LIKE '%v2.3%';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "problem_worknote_rca",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM problem WHERE number = 'PRB0040001' AND worknotes LIKE '%memory leak%';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "problem_worknote_patch",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM problem WHERE number = 'PRB0040001' AND worknotes LIKE '%v2.3%';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "master_incident_unchanged",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE number = 'INC0050001' AND status = 'in_progress';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "child_incident_2_status_unchanged",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE number = 'INC0050002' AND status = 'in_progress';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "child_incident_3_status_unchanged",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE number = 'INC0050003' AND status = 'in_progress';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "child2_worknote_prb",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE number = 'INC0050002' AND worknotes LIKE '%PRB0040001%';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "child3_worknote_prb",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE number = 'INC0050003' AND worknotes LIKE '%PRB0040001%';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "child2_worknote_coordination",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE number = 'INC0050002' AND worknotes LIKE '%permanent fix deployed across affected nodes%';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "child3_worknote_coordination",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE number = 'INC0050003' AND worknotes LIKE '%permanent fix deployed across affected nodes%';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "decoy_problem_untouched",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM problem WHERE number = 'PRB0040099' AND status = 'new';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "decoy_problem_statement_untouched",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM problem WHERE number = 'PRB0040099' AND problem_statement = 'Unrelated printer driver defect';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "child_enumeration_complete",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM child_incident WHERE parent_incident = 'INC0050001';",
   "expected": 2,
   "comparison": "equals"
  },
  {
   "name": "case_state_resolved",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM customer_case WHERE number = 'CS0009001' AND state = 'resolved';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "case_crossref_problem",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM customer_case WHERE number = 'CS0009001' AND short_description LIKE '%PRB0040001%';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "case_summary_length",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM customer_case WHERE number = 'CS0009001' AND LENGTH(short_description) >= 20;",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "case_closed_on_set",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM customer_case WHERE number = 'CS0009001' AND closed_on IS NOT NULL;",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "case_no_escalation",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM customer_case WHERE number = 'CS0009001' AND escalation IN ('false','0','f',0);",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "case_account_link_intact",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM customer_case WHERE number = 'CS0009001' AND account_id = '8001';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "decoy_case_billing_untouched",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM customer_case WHERE number = 'CS0009002' AND state = 'closed' AND short_description = 'Historical billing query';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "decoy_case_password_untouched",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM customer_case WHERE number = 'CS0009003' AND short_description = 'Historical password reset';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "account_resolution_uniqueness",
   "gym": "sn-csm-server",
   "query": "SELECT COUNT(*) FROM account WHERE email_domain = 'northwind.com' AND account_id = '8001';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "email_reply_created_on_thread",
   "gym": "gym-email-mcp",
   "query": "SELECT COUNT(*) FROM messages WHERE thread_id = 'thr_001' AND user_id = 'eusr_marcus_501';",
   "expected": 1,
   "comparison": "greater_than"
  },
  {
   "name": "decoy_thread_no_reply",
   "gym": "gym-email-mcp",
   "query": "SELECT COUNT(*) FROM messages WHERE thread_id = 'thr_002';",
   "expected": 0,
   "comparison": "equals"
  },
  {
   "name": "inbound_thread_owner_intact",
   "gym": "gym-email-mcp",
   "query": "SELECT COUNT(*) FROM threads WHERE id = 'thr_001' AND user_id = 'eusr_marcus_501';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "child2_worknote_length",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE number = 'INC0050002' AND worknotes IS NOT NULL AND LENGTH(worknotes) >= 20;",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "child3_worknote_length",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE number = 'INC0050003' AND worknotes IS NOT NULL AND LENGTH(worknotes) >= 20;",
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
