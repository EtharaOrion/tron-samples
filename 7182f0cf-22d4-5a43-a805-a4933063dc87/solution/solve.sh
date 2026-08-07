#!/usr/bin/env bash
# Oracle solution for task 153 — Hi, this is Maya Rodriguez in People Ops at Globex. I'm converting a contractor to full-time and need this run end to end.
# Auto-generated AFTER the oracle reproduced this answer key live — answer-key-reproducible, not an independent solve (31/31 verifiers, 5 repair(s)).
# Self-contained: bash + python3 stdlib only. Seeds each gym on a fresh scratch db,
# replays the tool-call plan over MCP, then checks every verifier. Exit 0 iff all pass.
set -uo pipefail

exec python3 - <<'ORACLE_PY'

import json, time, urllib.request, urllib.error

DATA = json.loads(r"""{
 "task_id": "153",
 "gyms": {
  "sn-hr-internal": {
   "url": "http://localhost:8003",
   "auth_header": "x-hr-user-token",
   "auth_val": "hr_token_maya_rodriguez_001",
   "seed_sql": "-- MCP Server: sn-hr-internal\nINSERT INTO organization (org_id, name, active, created_at, updated_at) VALUES (1, 'Globex Corporation', 1, '2023-01-01 00:00:00', '2023-01-01 00:00:00');\n\nINSERT INTO role (role_id, name, created_at, updated_at) VALUES\n(1, 'admin', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(2, 'manager', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(3, 'agent', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(4, 'employee', '2023-01-01 00:00:00', '2023-01-01 00:00:00');\n\nINSERT INTO permission (perm_id, resource, action, created_at, updated_at) VALUES\n(1, 'users', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(2, 'users', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(3, 'groups', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(4, 'groups', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(5, 'hr_services', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(6, 'hr_services', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(7, 'hr_cases', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(8, 'hr_cases', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(9, 'hr_profiles', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(10, 'hr_profiles', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(11, 'topic_categories', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(12, 'topic_categories', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(13, 'topic_details', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(14, 'topic_details', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(15, 'service_templates', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(16, 'service_templates', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(17, 'hr_criteria', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(18, 'hr_criteria', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(19, 'skills', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(20, 'skills', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(21, 'knowledge', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(22, 'knowledge', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(23, 'surveys', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(24, 'surveys', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(25, 'assignment_rules', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(26, 'assignment_rules', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(27, 'escalation_rules', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(28, 'escalation_rules', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(29, 'notifications', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(30, 'notifications', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(31, 'checklists', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(32, 'checklists', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(33, 'survey_instances', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(34, 'survey_instances', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(35, 'reports', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(36, 'reports', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(37, 'hr_case_tasks', 'read', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(38, 'hr_case_tasks', 'crud', '2023-01-01 00:00:00', '2023-01-01 00:00:00');\n\nINSERT INTO role_permission (role_id, perm_id, created_at, updated_at) VALUES\n(1, 2, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 4, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 6, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 8, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 10, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 12, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 14, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 16, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 18, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 20, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 22, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 24, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 26, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 28, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 30, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 32, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 34, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 36, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (1, 38, '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(2, 2, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 4, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 6, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 8, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 10, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 12, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 14, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 16, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 18, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 20, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 22, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 24, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 26, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 28, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 30, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 32, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 34, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 36, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (2, 38, '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(3, 1, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 3, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 5, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 8, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 9, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 11, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 13, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 15, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 17, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 19, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 21, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 23, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 25, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 27, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 29, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 31, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 33, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 35, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (3, 37, '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(4, 1, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 3, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 5, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 7, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 9, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 11, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 13, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 15, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 17, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 19, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 21, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 23, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 25, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 27, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 29, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 31, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 33, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 35, '2023-01-01 00:00:00', '2023-01-01 00:00:00'), (4, 37, '2023-01-01 00:00:00', '2023-01-01 00:00:00');\n\nINSERT INTO user (user_id, first_name, last_name, email, phone, role, active, org_id, static_token, created_at, updated_at) VALUES\n(501, 'Maya', 'Rodriguez', 'maya.rodriguez@globex.com', '+1-555-0501', 'admin', 1, 1, 'hr_token_maya_rodriguez_001', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(610, 'Daniel', 'Foster', 'daniel.foster@globex.com', '+1-555-0610', 'employee', 1, 1, NULL, '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(611, 'Daniel', 'Foster', 'd.foster@globex.com', '+1-555-0611', 'employee', 1, 1, NULL, '2023-01-01 00:00:00', '2023-01-01 00:00:00');\n\nINSERT INTO user_role (user_id, role_id, org_id, created_at, updated_at) VALUES\n(501, 1, 1, '2023-01-01 00:00:00', '2023-01-01 00:00:00');\n\nINSERT INTO hr_profile (hr_profile_id, number, gender, user_id, personal_email, marital_status, type, national_tax_id, position, org_id, created_at, updated_at) VALUES\n(501, 'HRP0000501', 'Female', 501, 'maya.rodriguez.personal@gmail.com', 'Single', 'full-time', 'US-501-001', 'HR', 1, '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(610, 'HRP0000610', 'Male', 610, 'daniel.foster.personal@gmail.com', 'Single', 'contractor', 'US-610-334', 'Software Engineer', 1, '2023-01-01 00:00:00', '2023-01-01 00:00:00'),\n(611, 'HRP0000611', 'Male', 611, 'dfoster.alt@gmail.com', 'Single', 'contractor', 'US-611-778', 'Sales', 1, '2023-01-01 00:00:00', '2023-01-01 00:00:00');\n\nINSERT INTO hr_service (hr_service_id, service_name, fulfillment_type, topic_detail, service_template, hr_criteria, active, org_id, created_at, updated_at) VALUES\n(100, 'employee conversion', 'lifecycle event', NULL, NULL, NULL, 1, 1, '2023-01-01 00:00:00', '2023-01-01 00:00:00');\n\nINSERT INTO hr_case (number, status, hr_service, opened_for, opened_by, priority, source, assigned_to, short_description, worknotes, coe_type, org_id, created_at, updated_at) VALUES\n('HRC0004001', 'work_in_progress', 100, 610, NULL, 'low', 'email', NULL, 'Contractor conversion inquiry - Daniel Foster', 'Initial inquiry logged for the same-name contractor decoy', 'Workforce Administration', 1, '2023-06-01 00:00:00', '2023-06-01 00:00:00');\n"
  },
  "gym-email-mcp": {
   "url": "http://localhost:8007",
   "auth_header": "x-email-user-token",
   "auth_val": "tok_maya_2025_x9f2q",
   "seed_sql": "-- MCP Server: email_v4\nINSERT INTO users (id, token, primary_email, name, messages_total, threads_total, history_id_current, created_at, updated_at) VALUES ('user_maya_rodriguez', 'tok_maya_2025_x9f2q', 'maya.rodriguez@globex.com', 'Maya Rodriguez', 2, 2, 2000, '2026-01-05T09:00:00Z', '2026-07-30T09:00:00Z');\nINSERT INTO labels (id, user_id, name, message_list_visibility, label_list_visibility, type, messages_total, messages_unread, threads_total, threads_unread, color_json, created_at, updated_at) VALUES ('label_inbox_maya', 'user_maya_rodriguez', 'INBOX', 'show', 'labelShow', 'system', 1, 0, 1, 0, NULL, '2026-01-05T09:00:00Z', '2026-07-30T09:00:00Z');\nINSERT INTO labels (id, user_id, name, message_list_visibility, label_list_visibility, type, messages_total, messages_unread, threads_total, threads_unread, color_json, created_at, updated_at) VALUES ('label_sent_maya', 'user_maya_rodriguez', 'SENT', 'show', 'labelShow', 'system', 1, 0, 1, 0, NULL, '2026-01-05T09:00:00Z', '2026-07-30T09:00:00Z');\nINSERT INTO threads (id, user_id, snippet, history_id_last, created_at, updated_at) VALUES ('thread_intro_maya', 'user_maya_rodriguez', 'Team onboarding context thread', 1900, '2026-06-01T09:00:00Z', '2026-07-30T09:00:00Z');\nINSERT INTO messages (id, user_id, thread_id, snippet, history_id_last, internal_date_ms, size_estimate, created_at, updated_at) VALUES ('msg_context_1', 'user_maya_rodriguez', 'thread_intro_maya', 'Onboarding schedule for new joiners', 1900, 1717232400000, 2048, '2026-06-01T09:00:00Z', '2026-07-30T09:00:00Z');\nINSERT INTO message_labels (message_id, label_id) VALUES ('msg_context_1', 'label_inbox_maya');\nINSERT INTO send_as_aliases (id, user_id, send_as_email, display_name, reply_to_address, signature, is_primary, is_default, treat_as_alias, smtp_msa, verification_status, verification_token, verification_token_expires, created_at, updated_at) VALUES ('sendas_maya_primary', 'user_maya_rodriguez', 'maya.rodriguez@globex.com', 'Maya Rodriguez', NULL, 'Maya Rodriguez, People Ops, Globex', 'true', 'true', 'false', NULL, 'accepted', NULL, NULL, '2026-01-05T09:00:00Z', '2026-07-30T09:00:00Z');"
  }
 },
 "mcp_endpoint": "/mcp",
 "plan": [
  {
   "gym": "sn-hr-internal",
   "tool": "update_hr_profile",
   "arguments": {
    "hr_profile_id": "610",
    "number": "HRP0000610",
    "user_id": "610",
    "type": "full-time"
   },
   "note": "Convert Daniel Foster (user 610) to full-time, keeping active"
  },
  {
   "gym": "sn-hr-internal",
   "tool": "create_new_hr_case",
   "arguments": {
    "short_description": "Contractor to FTE conversion for Daniel Foster",
    "coe_type": "Workforce Administration",
    "status": "work_in_progress",
    "hr_service": "100",
    "opened_for": "Daniel Foster",
    "priority": "moderate",
    "source": "email",
    "assigned_to": "Maya Rodriguez",
    "worknotes": "Case opened to convert contractor Daniel Foster (user 610) to full-time employee."
   },
   "note": "Create the brand-new conversion case; opened_by will be acting user 501"
  },
  {
   "gym": "sn-hr-internal",
   "tool": "update_hr_case",
   "arguments": {
    "hr_case_id": "2",
    "number": "HRC0004002",
    "status": "closed_complete",
    "worknotes": "Converted Daniel Foster to full-time; sent welcome email; resolved and closed case HRC0004002."
   },
   "note": "Close case with short worknotes (<120) referencing its own number HRC0004002"
  },
  {
   "gym": "gym-email-mcp",
   "tool": "send_message",
   "arguments": {
    "userId": "me",
    "payload": {
     "mimeType": "text/plain",
     "filename": "welcome.txt",
     "headers": [
      {
       "name": "From",
       "value": "maya.rodriguez@globex.com"
      },
      {
       "name": "To",
       "value": "daniel.foster@globex.com"
      },
      {
       "name": "Subject",
       "value": "Welcome to Globex Daniel Foster"
      }
     ],
     "body": {
      "data": "Hi Daniel, welcome to the full-time team at Globex! We are absolutely thrilled to have you join us permanently, and we look forward to all the great work ahead together.",
      "size": 168
     }
    },
    "snippet": "Welcome to the full-time team at Globex"
   },
   "note": "Send welcome email from Maya's mailbox to Daniel's corporate email with non-empty payload.filename to satisfy validator."
  }
 ],
 "verifiers": [
  {
   "name": "profile610_fulltime",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM hr_profile WHERE user_id='610' AND type='full-time';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "user610_active_kept",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM user WHERE user_id='610' AND active='1';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "user610_email_unchanged",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM user WHERE user_id='610' AND email='daniel.foster@globex.com';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "user610_firstname_unchanged",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM user WHERE user_id='610' AND first_name='Daniel' AND last_name='Foster';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "user610_role_unchanged",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM user WHERE user_id='610' AND role='employee';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "profile610_number_unchanged",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM hr_profile WHERE user_id='610' AND number='HRP0000610';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "decoy611_still_contractor",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM hr_profile WHERE user_id='611' AND type='contractor';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "decoy611_not_fulltime",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM hr_profile WHERE user_id='611' AND type='full-time';",
   "expected": 0,
   "comparison": "equals"
  },
  {
   "name": "decoy611_taxid_unchanged",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM hr_profile WHERE user_id='611' AND national_tax_id='US-611-778';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "newcase_exists_unique",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM hr_case WHERE short_description='Contractor to FTE conversion for Daniel Foster';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "newcase_opened_by_501",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM hr_case WHERE short_description='Contractor to FTE conversion for Daniel Foster' AND opened_by='501';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "newcase_assigned_to_501",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM hr_case WHERE short_description='Contractor to FTE conversion for Daniel Foster' AND assigned_to='501';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "newcase_priority_moderate",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM hr_case WHERE short_description='Contractor to FTE conversion for Daniel Foster' AND priority='moderate';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "newcase_hrservice_empconv",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM hr_case WHERE short_description='Contractor to FTE conversion for Daniel Foster' AND hr_service=(SELECT hr_service_id FROM hr_service WHERE service_name='employee conversion');",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "newcase_opened_for_610",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM hr_case WHERE short_description='Contractor to FTE conversion for Daniel Foster' AND opened_for='610';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "newcase_not_opened_for_611",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM hr_case WHERE short_description='Contractor to FTE conversion for Daniel Foster' AND opened_for='611';",
   "expected": 0,
   "comparison": "equals"
  },
  {
   "name": "newcase_status_closed_complete",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM hr_case WHERE short_description='Contractor to FTE conversion for Daniel Foster' AND status='closed_complete';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "newcase_not_left_open",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM hr_case WHERE short_description='Contractor to FTE conversion for Daniel Foster' AND status='work_in_progress';",
   "expected": 0,
   "comparison": "equals"
  },
  {
   "name": "newcase_worknotes_notempty",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM hr_case WHERE short_description='Contractor to FTE conversion for Daniel Foster' AND worknotes IS NOT NULL AND worknotes != '';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "newcase_worknotes_selfref_number",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM hr_case WHERE short_description='Contractor to FTE conversion for Daniel Foster' AND worknotes LIKE '%' || number || '%';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "newcase_worknotes_resolution_len",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM hr_case WHERE short_description='Contractor to FTE conversion for Daniel Foster' AND LENGTH(worknotes) > 20;",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "newcase_target_complete",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM hr_case WHERE short_description='Contractor to FTE conversion for Daniel Foster' AND opened_for='610' AND opened_by='501' AND assigned_to='501' AND priority='moderate' AND hr_service=(SELECT hr_service_id FROM hr_service WHERE service_name='employee conversion') AND status='closed_complete';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "decoycase_unchanged",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM hr_case WHERE number='HRC0004001' AND status='work_in_progress' AND opened_for='610';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "decoycase_not_closed",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM hr_case WHERE number='HRC0004001' AND status='closed_complete';",
   "expected": 0,
   "comparison": "equals"
  },
  {
   "name": "hrservice_still_active",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM hr_service WHERE service_name='employee conversion' AND active='1';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "acting_admin_unchanged",
   "gym": "sn-hr-internal",
   "query": "SELECT COUNT(*) FROM user WHERE user_id='501' AND role='admin' AND email='maya.rodriguez@globex.com';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "welcome_to_daniel",
   "gym": "gym-email-mcp",
   "query": "SELECT COUNT(*) FROM message_headers mh JOIN message_parts mp ON mh.message_part_id=mp.id JOIN messages m ON mp.message_id=m.id WHERE m.user_id='user_maya_rodriguez' AND mh.name='To' AND mh.value LIKE '%daniel.foster@globex.com%';",
   "expected": 0,
   "comparison": "greater_than"
  },
  {
   "name": "welcome_from_maya_mailbox",
   "gym": "gym-email-mcp",
   "query": "SELECT COUNT(*) FROM messages m WHERE m.user_id='user_maya_rodriguez' AND EXISTS (SELECT 1 FROM message_parts mp JOIN message_headers mh ON mh.message_part_id=mp.id WHERE mp.message_id=m.id AND mh.name='Subject' AND mh.value='Welcome to Globex Daniel Foster') AND EXISTS (SELECT 1 FROM message_parts mp2 JOIN message_headers mh2 ON mh2.message_part_id=mp2.id WHERE mp2.message_id=m.id AND mh2.name='To' AND mh2.value LIKE '%daniel.foster@globex.com%');",
   "expected": 0,
   "comparison": "greater_than"
  },
  {
   "name": "welcome_sent_label",
   "gym": "gym-email-mcp",
   "query": "SELECT COUNT(*) FROM messages m JOIN message_labels ml ON ml.message_id=m.id JOIN labels l ON ml.label_id=l.id WHERE m.user_id='user_maya_rodriguez' AND l.name IN ('Sent','SENT') AND EXISTS (SELECT 1 FROM message_parts mp JOIN message_headers mh ON mh.message_part_id=mp.id WHERE mp.message_id=m.id AND mh.name='Subject' AND mh.value='Welcome to Globex Daniel Foster');",
   "expected": 0,
   "comparison": "greater_than"
  },
  {
   "name": "welcome_not_from_other_mailbox",
   "gym": "gym-email-mcp",
   "query": "SELECT COUNT(*) FROM messages m JOIN message_parts mp ON mp.message_id=m.id JOIN message_headers mh ON mh.message_part_id=mp.id WHERE mh.name='Subject' AND mh.value='Welcome to Globex Daniel Foster' AND m.user_id != 'user_maya_rodriguez';",
   "expected": 0,
   "comparison": "equals"
  },
  {
   "name": "welcome_not_to_decoy",
   "gym": "gym-email-mcp",
   "query": "SELECT COUNT(*) FROM message_headers mh JOIN message_parts mp ON mh.message_part_id=mp.id JOIN messages m ON mp.message_id=m.id WHERE m.user_id='user_maya_rodriguez' AND mh.name='To' AND mh.value LIKE '%d.foster@globex.com%' AND mh.value NOT LIKE '%daniel.foster@globex.com%';",
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
