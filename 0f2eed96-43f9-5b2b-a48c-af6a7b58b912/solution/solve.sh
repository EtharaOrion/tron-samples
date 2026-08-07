#!/usr/bin/env bash
# Oracle solution for task 151 — Security-offboarding a departing contractor today — need his open work handed off cleanly. The contractor is Victor Hale, corporate account victor.hale@contract
# Auto-generated AFTER the oracle reproduced this answer key live — answer-key-reproducible, not an independent solve (32/32 verifiers, 6 repair(s)).
# Self-contained: bash + python3 stdlib only. Seeds each gym on a fresh scratch db,
# replays the tool-call plan over MCP, then checks every verifier. Exit 0 iff all pass.
set -uo pipefail

exec python3 - <<'ORACLE_PY'

import json, time, urllib.request, urllib.error

DATA = json.loads(r"""{
 "task_id": "151",
 "gyms": {
  "gym-itsm-mcp": {
   "url": "http://localhost:8002",
   "auth_header": "x-itsm-user-token",
   "auth_val": "agent_token_dana_2024_secure",
   "seed_sql": "-- MCP Server: sn-itsm-internal\nINSERT INTO organization (org_id, name, active) VALUES ('org_techcorp', 'TechCorp', 1);\n\nINSERT INTO role (role_id, name) VALUES\n('ROLE_001', 'admin'),\n('ROLE_002', 'manager'),\n('ROLE_003', 'agent'),\n('ROLE_004', 'reporter');\n\nINSERT INTO permission (perm_id, resource, action) VALUES\n('PERM_001', 'users', 'read'),\n('PERM_002', 'users', 'crud'),\n('PERM_003', 'groups', 'read'),\n('PERM_004', 'groups', 'crud'),\n('PERM_005', 'services', 'read'),\n('PERM_006', 'services', 'crud'),\n('PERM_007', 'service_offerings', 'read'),\n('PERM_008', 'service_offerings', 'crud'),\n('PERM_009', 'configuration_items', 'read'),\n('PERM_010', 'configuration_items', 'crud'),\n('PERM_011', 'incident_templates', 'read'),\n('PERM_012', 'incident_templates', 'crud'),\n('PERM_013', 'problems', 'read'),\n('PERM_014', 'problems', 'crud'),\n('PERM_015', 'changes', 'read'),\n('PERM_016', 'changes', 'crud'),\n('PERM_017', 'notifications', 'read'),\n('PERM_018', 'notifications', 'crud'),\n('PERM_019', 'notification_analysis', 'read'),\n('PERM_020', 'notification_analysis', 'crud'),\n('PERM_021', 'sla_definitions', 'read'),\n('PERM_022', 'sla_definitions', 'crud'),\n('PERM_023', 'sla_metrics', 'read'),\n('PERM_024', 'sla_metrics', 'crud'),\n('PERM_025', 'incidents', 'read'),\n('PERM_026', 'incidents', 'crud'),\n('PERM_027', 'knowledge', 'read'),\n('PERM_028', 'knowledge', 'crud'),\n('PERM_029', 'locations', 'read'),\n('PERM_030', 'locations', 'crud'),\n('PERM_031', 'change_mappings', 'read'),\n('PERM_032', 'change_mappings', 'crud'),\n('PERM_033', 'incident_affected_cis', 'read'),\n('PERM_034', 'incident_affected_cis', 'crud'),\n('PERM_035', 'incident_slas', 'read'),\n('PERM_036', 'incident_slas', 'crud');\n\nINSERT INTO role_permission (role_id, perm_id) VALUES\n('ROLE_001', 'PERM_002'), ('ROLE_001', 'PERM_004'), ('ROLE_001', 'PERM_006'), ('ROLE_001', 'PERM_008'),\n('ROLE_001', 'PERM_010'), ('ROLE_001', 'PERM_012'), ('ROLE_001', 'PERM_014'), ('ROLE_001', 'PERM_016'),\n('ROLE_001', 'PERM_018'), ('ROLE_001', 'PERM_020'), ('ROLE_001', 'PERM_022'), ('ROLE_001', 'PERM_024'),\n('ROLE_001', 'PERM_026'), ('ROLE_001', 'PERM_028'), ('ROLE_001', 'PERM_030'), ('ROLE_001', 'PERM_032'),\n('ROLE_001', 'PERM_034'), ('ROLE_001', 'PERM_036');\n\nINSERT INTO role_permission (role_id, perm_id) VALUES\n('ROLE_002', 'PERM_002'), ('ROLE_002', 'PERM_004'), ('ROLE_002', 'PERM_006'), ('ROLE_002', 'PERM_008'),\n('ROLE_002', 'PERM_010'), ('ROLE_002', 'PERM_012'), ('ROLE_002', 'PERM_014'), ('ROLE_002', 'PERM_016'),\n('ROLE_002', 'PERM_018'), ('ROLE_002', 'PERM_020'), ('ROLE_002', 'PERM_022'), ('ROLE_002', 'PERM_024'),\n('ROLE_002', 'PERM_026'), ('ROLE_002', 'PERM_028'), ('ROLE_002', 'PERM_030'), ('ROLE_002', 'PERM_032'),\n('ROLE_002', 'PERM_034'), ('ROLE_002', 'PERM_036');\n\nINSERT INTO role_permission (role_id, perm_id) VALUES\n('ROLE_003', 'PERM_001'), ('ROLE_003', 'PERM_003'), ('ROLE_003', 'PERM_005'), ('ROLE_003', 'PERM_007'),\n('ROLE_003', 'PERM_010'), ('ROLE_003', 'PERM_011'), ('ROLE_003', 'PERM_014'), ('ROLE_003', 'PERM_016'),\n('ROLE_003', 'PERM_017'), ('ROLE_003', 'PERM_019'), ('ROLE_003', 'PERM_021'), ('ROLE_003', 'PERM_023'),\n('ROLE_003', 'PERM_026'), ('ROLE_003', 'PERM_028'), ('ROLE_003', 'PERM_030'), ('ROLE_003', 'PERM_031'),\n('ROLE_003', 'PERM_033'), ('ROLE_003', 'PERM_035');\n\nINSERT INTO role_permission (role_id, perm_id) VALUES\n('ROLE_004', 'PERM_001'), ('ROLE_004', 'PERM_003'), ('ROLE_004', 'PERM_005'), ('ROLE_004', 'PERM_007'),\n('ROLE_004', 'PERM_009'), ('ROLE_004', 'PERM_011'), ('ROLE_004', 'PERM_013'), ('ROLE_004', 'PERM_015'),\n('ROLE_004', 'PERM_017'), ('ROLE_004', 'PERM_019'), ('ROLE_004', 'PERM_021'), ('ROLE_004', 'PERM_023'),\n('ROLE_004', 'PERM_025'), ('ROLE_004', 'PERM_027'), ('ROLE_004', 'PERM_029'), ('ROLE_004', 'PERM_031'),\n('ROLE_004', 'PERM_033'), ('ROLE_004', 'PERM_035');\n\nINSERT INTO location (location_id, name, org_id, city, state, country, active) VALUES\n('loc_hq_sf', 'TechCorp HQ', 'org_techcorp', 'San Francisco', 'published', 'USA', 1);\n\nINSERT INTO users (user_id, user_name, first_name, last_name, email, phone, role, active, static_token, org_id, location_id) VALUES\n('u_whitfield_dana', 'dana.whitfield', 'Dana', 'Whitfield', 'dana.whitfield@techcorp.com', '+1-415-555-0101', 'admin', 1, 'agent_token_dana_2024_secure', 'org_techcorp', 'loc_hq_sf'),\n('u_hale_victor_ctr', 'victor.hale.ctr', 'Victor', 'Hale', 'victor.hale@contractor.techcorp.com', '+1-415-555-0102', 'reporter', 1, 'reporter_token_victorctr_2024_secure', 'org_techcorp', 'loc_hq_sf'),\n('u_hale_victor_emp', 'victor.hale', 'Victor', 'Hale', 'victor.hale@techcorp.com', '+1-415-555-0103', 'agent', 1, 'agent_token_victor_2024_secure', 'org_techcorp', 'loc_hq_sf');\n\nINSERT INTO user_group (group_id, name, type, active, email, description, manager_id, org_id) VALUES\n('grp_sec_oncall', 'Security On-Call', 'IT Support', 1, 'security-oncall@techcorp.com', 'Primary security on-call rotation', 'u_whitfield_dana', 'org_techcorp'),\n('grp_sec_review', 'Security Review Board', 'IT Support', 1, 'security-review@techcorp.com', 'Security policy review group', 'u_whitfield_dana', 'org_techcorp'),\n('grp_field_support', 'Field Support', 'Field Support Technicians', 1, 'field-support@techcorp.com', 'Field support technicians', 'u_whitfield_dana', 'org_techcorp');\n\nINSERT INTO user_group_member (member_id, group_id, user_id, org_id) VALUES\n('mem_001', 'grp_field_support', 'u_hale_victor_ctr', 'org_techcorp'),\n('mem_002', 'grp_sec_oncall', 'u_whitfield_dana', 'org_techcorp');\n\nINSERT INTO user_role (user_id, role_id, org_id) VALUES\n('u_whitfield_dana', 'ROLE_001', 'org_techcorp'),\n('u_hale_victor_ctr', 'ROLE_004', 'org_techcorp'),\n('u_hale_victor_emp', 'ROLE_003', 'org_techcorp');\n\nINSERT INTO incident (incident_id, number, short_description, caller_id, assigned_to, assignment_group, status, category, channel, org_id, impact, urgency, priority) VALUES\n('inc_open_001', 'INC0012001', 'Contractor VPN access anomaly review', 'u_whitfield_dana', 'u_hale_victor_ctr', 'grp_field_support', 'in_progress', 'network', 'email', 'org_techcorp', 'medium', 'medium', 'moderate'),\n('inc_open_002', 'INC0012002', 'Contractor endpoint credential rotation', 'u_whitfield_dana', 'u_hale_victor_ctr', 'grp_field_support', 'new', 'password-reset', 'phone', 'org_techcorp', 'medium', 'medium', 'moderate'),\n('inc_closed_003', 'INC0012003', 'Contractor laptop reimage completed', 'u_whitfield_dana', 'u_hale_victor_ctr', 'grp_field_support', 'closed', 'hardware', 'web', 'org_techcorp', 'low', 'low', 'low'),\n('inc_other_004', 'INC0012004', 'Firewall rule change request follow-up', 'u_whitfield_dana', 'u_hale_victor_emp', 'grp_field_support', 'in_progress', 'network', 'chat', 'org_techcorp', 'high', 'high', 'high');"
  },
  "gym-email-mcp": {
   "url": "http://localhost:8007",
   "auth_header": "x-email-user-token",
   "auth_val": "tok_dana_2025_x9k2p7",
   "seed_sql": "-- MCP Server: email_v4\nINSERT INTO users (id, token, primary_email, name, messages_total, threads_total, history_id_current, created_at, updated_at) VALUES ('email_user_dana_whitfield', 'tok_dana_2025_x9k2p7', 'dana.whitfield@techcorp.com', 'Dana Whitfield', 0, 0, 1000, '2026-01-05T09:00:00Z', '2026-07-20T09:00:00Z');\nINSERT INTO users (id, token, primary_email, name, messages_total, threads_total, history_id_current, created_at, updated_at) VALUES ('email_user_victor_hale', 'tok_victor_2025_qq81zz', 'victor.hale@techcorp.com', 'Victor Hale', 0, 0, 1000, '2026-01-05T09:00:00Z', '2026-07-20T09:00:00Z');\nINSERT INTO send_as_aliases (id, user_id, send_as_email, display_name, reply_to_address, signature, is_primary, is_default, treat_as_alias, smtp_msa, verification_status, verification_token, verification_token_expires, created_at, updated_at) VALUES ('sa_dana_primary', 'email_user_dana_whitfield', 'dana.whitfield@techcorp.com', 'Dana Whitfield', NULL, 'Dana Whitfield, TechCorp', 'true', 'true', 'false', NULL, 'accepted', NULL, NULL, '2026-01-05T09:00:00Z', '2026-07-20T09:00:00Z');\nINSERT INTO send_as_aliases (id, user_id, send_as_email, display_name, reply_to_address, signature, is_primary, is_default, treat_as_alias, smtp_msa, verification_status, verification_token, verification_token_expires, created_at, updated_at) VALUES ('sa_victor_primary', 'email_user_victor_hale', 'victor.hale@techcorp.com', 'Victor Hale', NULL, 'Victor Hale, TechCorp', 'true', 'true', 'false', NULL, 'accepted', NULL, NULL, '2026-01-05T09:00:00Z', '2026-07-20T09:00:00Z');"
  }
 },
 "mcp_endpoint": "/mcp",
 "plan": [
  {
   "gym": "gym-itsm-mcp",
   "tool": "update_incident",
   "arguments": {
    "incident_id": "inc_open_001",
    "assignment_group": "grp_sec_oncall",
    "worknotes": "Security offboarding of contractor Victor Hale (internal user id u_hale_victor_ctr). Ticket ownership moved to Security On-Call group as part of his offboarding. Audit trail reference: u_hale_victor_ctr."
   },
   "note": "Reassign INC0012001 to Security On-Call + offboarding worknote citing contractor id"
  },
  {
   "gym": "gym-itsm-mcp",
   "tool": "update_incident",
   "arguments": {
    "incident_id": "inc_open_002",
    "assignment_group": "grp_sec_oncall",
    "worknotes": "Security offboarding of contractor Victor Hale (internal user id u_hale_victor_ctr). Ticket ownership moved to Security On-Call group as part of his offboarding. Audit trail reference: u_hale_victor_ctr."
   },
   "note": "Reassign INC0012002 to Security On-Call + offboarding worknote citing contractor id"
  },
  {
   "gym": "gym-email-mcp",
   "tool": "send_message",
   "arguments": {
    "userId": "me",
    "payload": {
     "mimeType": "text/plain",
     "filename": "notice.txt",
     "headers": [
      {
       "name": "From",
       "value": "dana.whitfield@techcorp.com"
      },
      {
       "name": "To",
       "value": "security-oncall@techcorp.com"
      },
      {
       "name": "Subject",
       "value": "Contractor Security Offboarding Notice"
      }
     ],
     "body": {
      "data": "Contractor Victor Hale is being offboarded today. His open tickets INC0012001 and INC0012002 have been reassigned to the on-call security team at security-oncall@techcorp.com. Thanks!",
      "size": 185
     }
    }
   },
   "note": "Send the offboarding notice from Dana's mailbox. Move filename to the payload/part level (top-level) since the server requires a non-empty filename whenever body.data is present."
  }
 ],
 "verifiers": [
  {
   "name": "inc001_group_oncall",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE incident_id='inc_open_001' AND assignment_group='grp_sec_oncall';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "inc002_group_oncall",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE incident_id='inc_open_002' AND assignment_group='grp_sec_oncall';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "exactly_two_reassigned",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE assignment_group='grp_sec_oncall';",
   "expected": 2,
   "comparison": "equals"
  },
  {
   "name": "inc001_worknote_cites_ctr",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE incident_id='inc_open_001' AND worknotes IS NOT NULL AND LENGTH(worknotes)>=20 AND worknotes LIKE '%u_hale_victor_ctr%';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "inc002_worknote_cites_ctr",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE incident_id='inc_open_002' AND worknotes IS NOT NULL AND LENGTH(worknotes)>=20 AND worknotes LIKE '%u_hale_victor_ctr%';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "inc001_worknote_offboard",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE incident_id='inc_open_001' AND worknotes LIKE '%offboard%';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "inc002_worknote_offboard",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE incident_id='inc_open_002' AND worknotes LIKE '%offboard%';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "both_open_worknoted",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE incident_id IN ('inc_open_001','inc_open_002') AND LENGTH(worknotes)>=20 AND worknotes LIKE '%u_hale_victor_ctr%';",
   "expected": 2,
   "comparison": "equals"
  },
  {
   "name": "no_open_ctr_on_field_support",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE assigned_to='u_hale_victor_ctr' AND status IN ('in_progress','new') AND assignment_group='grp_field_support';",
   "expected": 0,
   "comparison": "equals"
  },
  {
   "name": "open_ctr_incidents_now_oncall",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE assigned_to='u_hale_victor_ctr' AND status IN ('in_progress','new') AND assignment_group='grp_sec_oncall';",
   "expected": 2,
   "comparison": "equals"
  },
  {
   "name": "closed_incident_group_untouched",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE incident_id='inc_closed_003' AND assignment_group='grp_field_support';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "closed_incident_no_worknote",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE incident_id='inc_closed_003' AND (worknotes IS NULL OR worknotes NOT LIKE '%offboard%');",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "emp_incident_group_untouched",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE incident_id='inc_other_004' AND assignment_group='grp_field_support';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "emp_incident_no_worknote",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE incident_id='inc_other_004' AND (worknotes IS NULL OR worknotes NOT LIKE '%offboard%');",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "emp_incident_assignee_untouched",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE incident_id='inc_other_004' AND assigned_to='u_hale_victor_emp';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "no_incident_on_review_board",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE assignment_group='grp_sec_review';",
   "expected": 0,
   "comparison": "equals"
  },
  {
   "name": "inc001_assignee_unchanged",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE incident_id='inc_open_001' AND assigned_to='u_hale_victor_ctr';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "inc002_assignee_unchanged",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE incident_id='inc_open_002' AND assigned_to='u_hale_victor_ctr';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "closed_assignee_untouched",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE incident_id='inc_closed_003' AND assigned_to='u_hale_victor_ctr';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "employee_decoy_user_intact",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM users WHERE user_id='u_hale_victor_emp' AND email='victor.hale@techcorp.com' AND active= 1;",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "contractor_user_intact",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM users WHERE user_id='u_hale_victor_ctr' AND email='victor.hale@contractor.techcorp.com';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "inc001_worknote_not_cite_emp",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE incident_id='inc_open_001' AND worknotes LIKE '%u_hale_victor_ctr%' AND worknotes NOT LIKE '%u_hale_victor_emp%';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "inc002_worknote_not_cite_emp",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE incident_id='inc_open_002' AND worknotes LIKE '%u_hale_victor_ctr%' AND worknotes NOT LIKE '%u_hale_victor_emp%';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "closed_status_untouched",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE incident_id='inc_closed_003' AND status='closed';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "email_subject_from_dana",
   "gym": "gym-email-mcp",
   "query": "SELECT COUNT(*) FROM messages m JOIN message_parts mp ON mp.message_id=m.id JOIN message_headers h ON h.message_part_id=mp.id WHERE m.user_id='email_user_dana_whitfield' AND h.name='Subject' AND h.value='Contractor Security Offboarding Notice';",
   "expected": 0,
   "comparison": "greater_than"
  },
  {
   "name": "email_to_security_oncall",
   "gym": "gym-email-mcp",
   "query": "SELECT COUNT(*) FROM messages m JOIN message_parts mp ON mp.message_id=m.id JOIN message_headers h ON h.message_part_id=mp.id WHERE m.user_id='email_user_dana_whitfield' AND h.name='To' AND h.value LIKE '%security-oncall@techcorp.com%';",
   "expected": 0,
   "comparison": "greater_than"
  },
  {
   "name": "email_sent_label_dana",
   "gym": "gym-email-mcp",
   "query": "SELECT COUNT(*) FROM messages m JOIN message_labels ml ON ml.message_id=m.id JOIN labels l ON l.id=ml.label_id WHERE m.user_id='email_user_dana_whitfield' AND l.name IN ('Sent','SENT') AND m.id IN (SELECT mp.message_id FROM message_parts mp JOIN message_headers h ON h.message_part_id=mp.id WHERE h.name='Subject' AND h.value='Contractor Security Offboarding Notice');",
   "expected": 0,
   "comparison": "greater_than"
  },
  {
   "name": "email_not_from_victor",
   "gym": "gym-email-mcp",
   "query": "SELECT COUNT(*) FROM messages m JOIN message_parts mp ON mp.message_id=m.id JOIN message_headers h ON h.message_part_id=mp.id WHERE m.user_id='email_user_victor_hale' AND h.name='Subject' AND h.value='Contractor Security Offboarding Notice';",
   "expected": 0,
   "comparison": "equals"
  },
  {
   "name": "email_not_to_victor",
   "gym": "gym-email-mcp",
   "query": "SELECT COUNT(*) FROM messages m JOIN message_parts mp ON mp.message_id=m.id JOIN message_headers h ON h.message_part_id=mp.id WHERE h.name='To' AND h.value LIKE '%victor.hale@techcorp.com%' AND m.id IN (SELECT mp2.message_id FROM message_parts mp2 JOIN message_headers h2 ON h2.message_part_id=mp2.id WHERE h2.name='Subject' AND h2.value='Contractor Security Offboarding Notice');",
   "expected": 0,
   "comparison": "equals"
  },
  {
   "name": "email_single_notice_from_dana",
   "gym": "gym-email-mcp",
   "query": "SELECT COUNT(*) FROM messages m WHERE m.user_id='email_user_dana_whitfield' AND m.id IN (SELECT mp.message_id FROM message_parts mp JOIN message_headers h ON h.message_part_id=mp.id WHERE h.name='Subject' AND h.value='Contractor Security Offboarding Notice') AND m.id IN (SELECT ml.message_id FROM message_labels ml JOIN labels l ON l.id=ml.label_id WHERE l.name IN ('Sent','SENT'));",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "inc001_status_untouched",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE incident_id='inc_open_001' AND status='in_progress';",
   "expected": 1,
   "comparison": "equals"
  },
  {
   "name": "inc002_status_untouched",
   "gym": "gym-itsm-mcp",
   "query": "SELECT COUNT(*) FROM incident WHERE incident_id='inc_open_002' AND status='new';",
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
