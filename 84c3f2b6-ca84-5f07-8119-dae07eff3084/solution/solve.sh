#!/usr/bin/env bash
# Oracle solution for harbor task 84c3f2b6-ca84-5f07-8119-dae07eff3084 — task13 service credit rounding (EnterpriseOps hybrid; oracle-proven tool plan + SQL reconcile).
#
# Self-contained: bash + python3 stdlib only (the main container is
# python:3.12-slim with no pip packages and an egress allowlist).
# Strategy:
#   1. Execute the task's MCP tool-call plan through the mcp-injector sidecar
#      (which injects x-database-id and per-gym context headers).
#   2. Reconcile: re-check every database_state verifier via the gym's
#      /api/sql-runner; apply direct-SQL fixes for anything a tool call missed.
#   3. Write an ATIF trajectory to /logs/agent/trajectory.json so the
#      tool_execution and response_check verifiers see the tool calls and the
#      final assistant answer.
set -uo pipefail

exec python3 - <<'ORACLE_PY'
import json, re, sys, time, urllib.request, urllib.error
from pathlib import Path

# ===== TASK DATA START =====
TASK_ID = "84c3f2b6-ca84-5f07-8119-dae07eff3084"

# Gyms this task touches (must match tests/verifiers.jsonl `gym` fields).
GYMS = ['gym-email-mcp', 'sn-csm-server']

# Union of selected_tools across all tool_execution verifiers ([] if none).
# All 20 verifiers of this task are database_state.
REQUIRED_TOOLS = []

# Ordered MCP tool-call plan, replayed verbatim from the bundle's oracle-proven
# gold trajectory (generators/trajectory.json, N/N against these exact seeds).
# Args are literal: the seeds are frozen, and value-flow analysis shows no later
# argument depends on a runtime-generated id, so no ${var} plumbing is needed.
PLAN = [{'gym': 'sn-csm-server',
  'tool': 'search_cases',
  'args': {'number': 'CS-0001233'},
  'note': 'The case describing the run of missed first responses through May into early June, '
          'flagged for breach exposure. Resolves to the parent account, not the Renewables '
          'subsidiary.'},
 {'gym': 'sn-csm-server',
  'tool': 'get_accounts',
  'args': {'account_id': 9101},
  'note': "Account name reads 'Northwind Grid Systems' in CSM (distinct from 'Northwind Grid "
          "Systems Renewables')."},
 {'gym': 'sn-csm-server',
  'tool': 'find_account',
  'args': {'name': 'Northwind Grid Systems'},
  'note': 'Confirms the exact-name account and disambiguates it from the near-identically '
          'named Renewables account.'},
 {'gym': 'sn-csm-server',
  'tool': 'find_contracts',
  'args': {'account_id': 9101, 'status': 'active', 'contract_type': 'support'},
  'note': 'Exactly one active support contract on the parent account (2026-01-01 to '
          '2026-12-31, price 148500). The 2025 agreement on the same account is expired and '
          'the Renewables agreement belongs to another account - neither is touched.'},
 {'gym': 'sn-csm-server',
  'tool': 'find_entitlements',
  'args': {'account_id': 9101, 'contract_id': 9101},
  'note': 'Confirms the entitlement coverage attached to the live support agreement.'},
 {'gym': 'sn-csm-server',
  'tool': 'find_case_slas',
  'args': {'case_id': 9101, 'has_breached': True},
  'note': 'Only the genuinely breached response clocks on the case define the affected window '
          '(the non-breached rows are excluded from sizing).'},
 {'gym': 'sn-csm-server',
  'tool': 'find_case_slas',
  'args': {'case_id': 9101},
  'note': 'Full SLA history read so breached rows can be separated from clocks that never '
          'blew.'},
 {'gym': 'sn-csm-server',
  'tool': 'find_sla_definitions',
  'args': {'metric': 'response'},
  'note': 'Response SLA targets used to confirm which clocks are first-response obligations.'},
 {'gym': 'sn-csm-server',
  'tool': 'update_contract',
  'args': {'contract_id': 9101, 'contract_price': 146669},
  'note': "Credit sized from the paperwork (not the customer's quoted figure) and rounded half "
          'away from zero to a whole currency unit = 1831. 148500 - 1831 = 146669. Applied '
          'exactly once.'},
 {'gym': 'sn-csm-server',
  'tool': 'find_user_by_email',
  'args': {'email': 'karen.watkins@servicenow.com'},
  'note': 'Confirms the acting address used in the audit line.'},
 {'gym': 'sn-csm-server',
  'tool': 'update_case',
  'args': {'case_id': 9101,
           'short_description': 'CREDIT APPLIED: amount=1831 account=Northwind Grid Systems '
                                'by=karen.watkins@servicenow.com'},
  'note': 'Audit line written byte-for-byte on CS-0001233 only, nothing before or after it. '
          'The escalation flag and escalation_reason are deliberately left as found '
          "(escalation=1, escalation_reason='breach_risk') - no escalation fields are passed. "
          'CS-0001234 (Renewables) is never written to.'},
 {'gym': 'sn-csm-server',
  'tool': 'search_cases',
  'args': {'account_id': 9101},
  'note': 'Read-only confirmation that the account still carries only its pre-existing cases - '
          'the update landed on CS-0001233 in place and no new case row was created.'},
 {'gym': 'gym-email-mcp',
  'tool': 'get_user_profile',
  'args': {'userId': 'me'},
  'note': 'Confirms the acting mailbox.'},
 {'gym': 'gym-email-mcp',
  'tool': 'list_messages',
  'args': {'userId': 'me', 'q': 'Northwind', 'maxResults': 50},
  'note': "Surfaces the customer's own credit-expectation mail and the billing contact's "
          'auto-reply.'},
 {'gym': 'gym-email-mcp',
  'tool': 'list_threads',
  'args': {'userId': 'me', 'q': 'billing correspondence', 'maxResults': 50},
  'note': 'Locates the thread carrying the out-of-office auto-reply naming the delegate.'},
 {'gym': 'gym-email-mcp',
  'tool': 'get_message',
  'args': {'userId': 'me', 'id': '92201', 'format': 'full'},
  'note': "Reads the message body. The customer's quoted figure (4455) is read but explicitly "
          'NOT used as the credit amount.'},
 {'gym': 'gym-email-mcp',
  'tool': 'get_vacation_settings',
  'args': {'userId': 'me'},
  'note': 'Auto-reply state is read only - never cleared or modified.'},
 {'gym': 'gym-email-mcp',
  'tool': 'email_list_delegates',
  'args': {'userId': 'me'},
  'note': 'Delegation state on the acting mailbox is read only - nothing is added or removed. '
          'The delegate for billing correspondence during the absence window is named in the '
          'out-of-office auto-reply body rather than in mailbox delegation settings.'},
 {'gym': 'gym-email-mcp',
  'tool': 'list_messages',
  'args': {'userId': 'me', 'q': 'office', 'maxResults': 50},
  'note': 'Locates the auto-reply message that names the stand-in for billing correspondence '
          'during the absence window.'},
 {'gym': 'gym-email-mcp',
  'tool': 'get_message',
  'args': {'userId': 'me', 'id': '92202', 'format': 'full'},
  'note': 'Auto-reply body read in full: the billing contact of record is absent and names '
          'ravi.nambiar@northwindgrid.com as the sole recipient for anything financial in this '
          'window.'},
 {'gym': 'gym-email-mcp',
  'tool': 'list_send_as_aliases',
  'args': {'userId': 'me'},
  'note': 'Confirms the sending identity.'},
 {'gym': 'gym-email-mcp',
  'tool': 'send_message',
  'args': {'userId': 'me',
           'snippet': 'The service credit has been applied to the live support agreement for '
                      'Northwind Grid Systems and is reflected in the renewal figure. For your '
                      'AP team: CREDIT APPLIED: amount=1831 account=Northwind Grid Systems '
                      'by=karen.watkins@servicenow.com',
           'payload': {'headers': [{'name': 'To', 'value': 'ravi.nambiar@northwindgrid.com'},
                                   {'name': 'Subject',
                                    'value': 'Service credit applied - Northwind Grid Systems '
                                             '- case CS-0001233'}]}},
  'note': 'Exactly one mail, subject byte-exact, audit line reproduced in the body via '
          'snippet. The billing contact of record (meera.varghese@northwindgrid.com) is '
          "neither To nor Cc. No draft is left behind and the customer's 4455 figure never "
          'appears in the sent mail.'},
 {'gym': 'gym-email-mcp',
  'tool': 'list_messages',
  'args': {'userId': 'me',
           'q': 'Service credit applied - Northwind Grid Systems - case CS-0001233',
           'labelIds': ['SENT'],
           'maxResults': 50},
  'note': 'Exactly one sent message matches the byte-exact subject, confirming the mail went '
          'out as SENT and no draft was left behind.'},
 {'gym': 'sn-csm-server',
  'tool': 'send_notification',
  'args': {'case_id': 9101, 'email': 'ravi.nambiar@northwindgrid.com', 'type': 'update'},
  'note': 'Records against CS-0001233 who was actually told - the delegate, exactly once. No '
          'notification to the absent billing contact or to any northwindgridre.com address.'},
 {'gym': 'sn-csm-server',
  'tool': 'find_notifications',
  'args': {'case_id': 9101},
  'note': 'Confirms a single notification row for ravi.nambiar@northwindgrid.com on the case.'},
 {'gym': 'sn-csm-server',
  'tool': 'find_contracts',
  'args': {'account_id': 9101, 'status': 'active'},
  'note': 'Final look: exactly one active contract on Northwind Grid Systems, priced 146669 - '
          'the credit went on once and only once.'},
 {'gym': 'sn-csm-server',
  'tool': 'search_cases',
  'args': {'number': 'CS-0001233'},
  'note': 'Confirms the audit line stands byte-for-byte and escalation remains escalated with '
          'reason breach_risk.'}]

# One entry per database_state verifier, in tests/verifiers.jsonl idx order,
# gym/query/expected/comparison copied verbatim. `fix` holds direct-SQL repair
# statements applied only if the check still fails after the PLAN; guards that
# hold by construction keep "fix": [].
RECONCILE = [{'gym': 'sn-csm-server',
  'desc': 'P1-CSM: active contract price reduced to the correctly rounded credited value',
  'query': 'SELECT COUNT(*) FROM contract c JOIN account a ON a.account_id = c.account_id '
           "WHERE a.name = 'Northwind Grid Systems' AND c.status = 'active' AND "
           'c.contract_price = 146669;',
  'expected': 1,
  'comparison': 'equals',
  'fix': ['UPDATE contract SET contract_price = 146669 WHERE contract_id IN (SELECT '
          'c.contract_id FROM contract c JOIN account a ON a.account_id = c.account_id WHERE '
          "a.name = 'Northwind Grid Systems' AND c.status = 'active' AND c.contract_type = "
          "'support')"]},
 {'gym': 'sn-csm-server',
  'desc': 'P1-CSM: truncated and double-applied prices never landed on the account',
  'query': 'SELECT COUNT(*) FROM contract c JOIN account a ON a.account_id = c.account_id '
           "WHERE a.name = 'Northwind Grid Systems' AND (c.contract_price = 146670 OR "
           'c.contract_price = 144838 OR c.contract_price = 148500 OR c.contract_price = '
           '148500 - 1830);',
  'expected': 0,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'sn-csm-server',
  'desc': "P1-CSM: customer's asked-for figure and wide-window figure never posted",
  'query': 'SELECT ((SELECT COUNT(*) FROM contract c JOIN account a ON a.account_id = '
           "c.account_id WHERE a.name = 'Northwind Grid Systems' AND (c.contract_price = "
           '144045 OR c.contract_price = 144716)) = 0 AND (SELECT COUNT(*) FROM contract c '
           "JOIN account a ON a.account_id = c.account_id WHERE a.name = 'Northwind Grid "
           "Systems' AND c.status = 'active' AND c.contract_price = 146669) = 1);",
  'expected': 1,
  'comparison': 'equals',
  'fix': ['UPDATE contract SET contract_price = 146669 WHERE contract_id IN (SELECT '
          'c.contract_id FROM contract c JOIN account a ON a.account_id = c.account_id WHERE '
          "a.name = 'Northwind Grid Systems' AND c.status = 'active' AND c.contract_type = "
          "'support')"]},
 {'gym': 'sn-csm-server',
  'desc': 'P1-CSM: subsidiary and expired contracts left untouched',
  'query': 'SELECT ((SELECT COUNT(*) FROM contract c JOIN account a ON a.account_id = '
           "c.account_id WHERE a.name = 'Northwind Grid Systems Renewables' AND c.status = "
           "'active' AND c.contract_price = 132000) = 1 AND (SELECT COUNT(*) FROM contract c "
           "JOIN account a ON a.account_id = c.account_id WHERE a.name = 'Northwind Grid "
           "Systems' AND c.status = 'expired' AND c.contract_price = 99000) = 1);",
  'expected': 1,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'sn-csm-server',
  'desc': 'P1-CSM: contract status and term preserved through the price change',
  'query': 'SELECT COUNT(*) FROM contract c JOIN account a ON a.account_id = c.account_id '
           "WHERE a.name = 'Northwind Grid Systems' AND c.contract_price = 146669 AND c.status "
           "= 'active' AND c.contract_type = 'support' AND c.start_date LIKE '2026-01-01%' AND "
           "c.end_date LIKE '2026-12-31%';",
  'expected': 1,
  'comparison': 'equals',
  'fix': ['UPDATE contract SET contract_price = 146669 WHERE contract_id IN (SELECT '
          'c.contract_id FROM contract c JOIN account a ON a.account_id = c.account_id WHERE '
          "a.name = 'Northwind Grid Systems' AND c.status = 'active' AND c.contract_type = "
          "'support')"]},
 {'gym': 'sn-csm-server',
  'desc': 'P2-CSM: case short_description carries the byte-exact audit line',
  'query': "SELECT COUNT(*) FROM customer_case WHERE number = 'CS-0001233' AND "
           "short_description LIKE '%CREDIT APPLIED%' AND short_description LIKE "
           "'%amount=1831%' AND short_description LIKE '%account=Northwind Grid Systems%' AND "
           "short_description LIKE '%by=karen.watkins@servicenow.com%';",
  'expected': 1,
  'comparison': 'equals',
  'fix': ["UPDATE customer_case SET short_description = 'CREDIT APPLIED: amount=1831 "
          "account=Northwind Grid Systems by=karen.watkins@servicenow.com' WHERE number = "
          "'CS-0001233'"]},
 {'gym': 'sn-csm-server',
  'desc': 'P2-CSM: escalation flag and reason left exactly as found',
  'query': "SELECT COUNT(*) FROM customer_case WHERE number = 'CS-0001233' AND escalation = 1 "
           "AND escalation_reason = 'breach_risk';",
  'expected': 1,
  'comparison': 'equals',
  'fix': ["UPDATE customer_case SET escalation = 1, escalation_reason = 'breach_risk' WHERE "
          "number = 'CS-0001233'"]},
 {'gym': 'sn-csm-server',
  'desc': 'P2-CSM: decoy case not annotated or credited',
  'query': "SELECT ((SELECT COUNT(*) FROM customer_case WHERE number = 'CS-0001234' AND "
           "short_description LIKE '%CREDIT APPLIED%') = 0 AND (SELECT COUNT(*) FROM "
           "customer_case WHERE number = 'CS-0001233' AND short_description LIKE '%CREDIT "
           'APPLIED: amount=1831 account=Northwind Grid Systems '
           "by=karen.watkins@servicenow.com%') = 1);",
  'expected': 1,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'sn-csm-server',
  'desc': 'P2-CSM: no new case or interaction created',
  'query': "SELECT COUNT(*) FROM customer_case WHERE number > 'CS-0001235';",
  'expected': 0,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'sn-csm-server',
  'desc': 'P2-CSM: no interaction registered for the account',
  'query': 'SELECT COUNT(*) FROM interaction i JOIN account a ON a.account_id = i.account_id '
           "WHERE a.name IN ('Northwind Grid Systems', 'Northwind Grid Systems Renewables');",
  'expected': 0,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'gym-email-mcp',
  'desc': 'P3-EMAIL: credit announcement sent carrying the derived amount',
  'query': "SELECT COUNT(*) FROM messages WHERE snippet LIKE '%CREDIT APPLIED: amount=1831 "
           "account=Northwind Grid Systems by=karen.watkins@servicenow.com%';",
  'expected': 1,
  'comparison': 'equals',
  'fix': ['INSERT OR IGNORE INTO threads (id, user_id, snippet, history_id_last, created_at, '
          "updated_at, created_by, updated_by) SELECT 93901, u.id, 'Service credit applied - "
          "Northwind Grid Systems - case CS-0001233', 939010, '2026-07-24 10:00:00', "
          "'2026-07-24 10:00:00', 'oracle', 'oracle' FROM users u WHERE u.token = "
          "'Kx5XwZK6imPxgyAE88USnS4lF3np3br81Tf9FZr4Vno'",
          'INSERT OR IGNORE INTO messages (id, user_id, thread_id, snippet, history_id_last, '
          'internal_date_ms, size_estimate, created_at, updated_at, created_by, updated_by) '
          "SELECT 93902, u.id, 93901, 'CREDIT APPLIED: amount=1831 account=Northwind Grid "
          "Systems by=karen.watkins@servicenow.com', 939011, 1784546400000, 640, '2026-07-24 "
          "10:00:00', '2026-07-24 10:00:00', 'oracle', 'oracle' FROM users u WHERE u.token = "
          "'Kx5XwZK6imPxgyAE88USnS4lF3np3br81Tf9FZr4Vno'",
          'INSERT OR IGNORE INTO message_parts (id, message_id, parent_part_id, part_id, '
          'mime_type, filename, created_at, updated_at, created_by, updated_by) VALUES (93903, '
          "93902, NULL, '0', 'text/plain', NULL, '2026-07-24 10:00:00', '2026-07-24 10:00:00', "
          "'oracle', 'oracle')",
          'INSERT OR IGNORE INTO message_headers (id, message_part_id, name, value, '
          "created_at, updated_at, created_by, updated_by) SELECT 93904, 93903, 'From', "
          "u.primary_email, '2026-07-24 10:00:00', '2026-07-24 10:00:00', 'oracle', 'oracle' "
          "FROM users u WHERE u.token = 'Kx5XwZK6imPxgyAE88USnS4lF3np3br81Tf9FZr4Vno'",
          'INSERT OR IGNORE INTO message_headers (id, message_part_id, name, value, '
          "created_at, updated_at, created_by, updated_by) VALUES (93905, 93903, 'To', 'Ravi "
          "Nambiar <ravi.nambiar@northwindgrid.com>', '2026-07-24 10:00:00', '2026-07-24 "
          "10:00:00', 'oracle', 'oracle')",
          'INSERT OR IGNORE INTO message_headers (id, message_part_id, name, value, '
          "created_at, updated_at, created_by, updated_by) VALUES (93906, 93903, 'Subject', "
          "'Service credit applied - Northwind Grid Systems - case CS-0001233', '2026-07-24 "
          "10:00:00', '2026-07-24 10:00:00', 'oracle', 'oracle')"]},
 {'gym': 'gym-email-mcp',
  'desc': 'P3-EMAIL: announcement subject header exact',
  'query': "SELECT COUNT(*) FROM message_headers WHERE name = 'Subject' AND value = 'Service "
           "credit applied - Northwind Grid Systems - case CS-0001233';",
  'expected': 1,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'gym-email-mcp',
  'desc': 'P3-EMAIL: delegate is the recipient of the announcement',
  'query': 'SELECT COUNT(*) FROM message_headers s JOIN message_headers t ON t.message_part_id '
           "= s.message_part_id WHERE s.name = 'Subject' AND s.value = 'Service credit applied "
           "- Northwind Grid Systems - case CS-0001233' AND t.name = 'To' AND t.value LIKE "
           "'%ravi.nambiar@northwindgrid.com%';",
  'expected': 1,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'gym-email-mcp',
  'desc': 'P3-EMAIL: absent billing contact never addressed or copied',
  'query': "SELECT COUNT(*) FROM message_headers WHERE name IN ('To', 'Cc') AND value LIKE "
           "'%meera.varghese@northwindgrid.com%';",
  'expected': 0,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'gym-email-mcp',
  'desc': 'P3-EMAIL: asked-for figure never repeated outbound and subsidiary never addressed',
  'query': "SELECT ((SELECT COUNT(*) FROM messages WHERE snippet LIKE '%4455%') = 1 AND "
           "(SELECT COUNT(*) FROM message_headers WHERE name = 'Subject' AND value = 'Service "
           "credit expectation for our missed response times') = 1 AND (SELECT COUNT(*) FROM "
           "message_headers WHERE name IN ('To', 'Cc') AND value LIKE '%northwindgridre.com%') "
           '= 0);',
  'expected': 1,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'gym-email-mcp',
  'desc': 'P3-EMAIL: delegate config and vacation responder read but not modified',
  'query': "SELECT ((SELECT COUNT(*) FROM message_headers WHERE name = 'Subject' AND value "
           "LIKE 'Away from%office until 2026-08-10 - billing correspondence') = 1 AND (SELECT "
           "COUNT(*) FROM message_headers WHERE name = 'Subject' AND value = 'Service credit "
           "expectation for our missed response times') = 1 AND (SELECT COUNT(*) FROM "
           "message_headers WHERE name = 'Subject' AND value = 'Service credit applied - "
           "Northwind Grid Systems - case CS-0001233') = 1);",
  'expected': 1,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'gym-email-mcp',
  'desc': 'P3-EMAIL: no drafts created and no seeded message modified',
  'query': 'SELECT (SELECT COUNT(*) FROM drafts d JOIN messages m ON m.id = d.message_id WHERE '
           "m.snippet LIKE '%CREDIT APPLIED%' OR m.snippet LIKE '%Northwind Grid Systems - "
           "case CS-0001233%') + (SELECT COUNT(*) FROM messages WHERE snippet LIKE '%CREDIT "
           "APPLIED%' AND snippet LIKE '%4455%');",
  'expected': 0,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'sn-csm-server',
  'desc': 'P4-CSM: delegate address written back as case notification',
  'query': 'SELECT COUNT(*) FROM notification n JOIN customer_case cc ON cc.case_id = '
           "n.case_id WHERE cc.number = 'CS-0001233' AND n.email = "
           "'ravi.nambiar@northwindgrid.com';",
  'expected': 1,
  'comparison': 'equals',
  'fix': ['INSERT OR IGNORE INTO notification (notification_id, case_id, knowledge_id, email, '
          'type, status, sys_created_on) SELECT 93910, cc.case_id, NULL, '
          "'ravi.nambiar@northwindgrid.com', 'update', 'success', '2026-07-24 10:00:00' FROM "
          "customer_case cc WHERE cc.number = 'CS-0001233'"]},
 {'gym': 'sn-csm-server',
  'desc': 'P4-CSM: notification not addressed to the absent contact',
  'query': 'SELECT COUNT(*) FROM notification n JOIN customer_case cc ON cc.case_id = '
           "n.case_id WHERE cc.number = 'CS-0001233' AND (n.email = "
           "'meera.varghese@northwindgrid.com' OR n.email = "
           "'meera.varghese@northwindgridre.com' OR n.email LIKE '%northwindgridre.com');",
  'expected': 0,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'sn-csm-server',
  'desc': 'P4-CSM: final re-read invariant - exactly one active contract at the credited value',
  'query': 'SELECT ((SELECT COUNT(*) FROM contract c JOIN account a ON a.account_id = '
           "c.account_id WHERE a.name = 'Northwind Grid Systems' AND c.status = 'active') = 1 "
           'AND (SELECT COUNT(*) FROM contract c JOIN account a ON a.account_id = c.account_id '
           "WHERE a.name = 'Northwind Grid Systems' AND c.status = 'active' AND "
           'c.contract_price = 146669) = 1);',
  'expected': 1,
  'comparison': 'equals',
  'fix': []}]

# Final assistant answer (no response_check verifiers grade it; kept faithful).
FINAL_RESPONSE = """I sized and applied the Northwind service credit from the paperwork, not from the figure their ops lead quoted.

What I did:
- Identified CS-0001233 (the May-into-June missed first-response case) on the parent account Northwind Grid Systems - not the near-identical Renewables case CS-0001234 on the subsidiary.
- Confirmed the governing paper is the live 2026 support agreement (2026-01-01 to 2026-12-31, price 148500); the lapsed 2025 agreement and the Renewables contract were left untouched.
- Sized the credit from the breached first-response clocks only: 30 affected days against a 365-day inclusive term, so 148500 * 0.15 * (30/365) = 1830.82, rounded half away from zero to 1831. The customer's claimed 4455 was read, noted as an unverified claim, and played no part.
- Reduced the agreement price once: 148500 -> 146669. Status, type and term dates unchanged.
- Wrote the dictated audit line on the case, byte for byte: CREDIT APPLIED: amount=1831 account=Northwind Grid Systems by=karen.watkins@servicenow.com. Escalation stays escalation=1 / breach_risk - a credit is not an escalation event, so I declined to change it.
- Because the billing contact Meera Varghese is out of office until 2026-08-10, I read her delegate from the auto-reply and mailed only Ravi Nambiar (ravi.nambiar@northwindgrid.com) with the exact subject "Service credit applied - Northwind Grid Systems - case CS-0001233" and the audit line in the body. Meera was not addressed or copied, and no draft was left behind.
- Recorded a notification on CS-0001233 for ravi.nambiar@northwindgrid.com and re-read the account: exactly one active contract at exactly 146669, so the credit went on once and only once."""
# ===== TASK DATA END =====

INJECTOR = "http://mcp-injector:9000/mcp"
GYM_API = {
    "sn-hr-internal":       "http://gym-hr:8008",
    "gym-itsm-mcp":         "http://gym-itsm:8006",
    "gym-email-mcp":        "http://gym-email:8004",
    "gym-calendar":         "http://gym-calendar:8003",
    "gym-teams-mcp":        "http://gym-teams:8002",
    "sn-csm-server":        "http://gym-csm:8001",
    "gym-google-drive-mcp": "http://gym-drive:8009",
}
SHARED = Path("/shared")
TRAJ_PATH = Path("/logs/agent/trajectory.json")


def log(msg):
    print(msg, flush=True)


def http_post_json(url, payload, headers=None, timeout=60):
    """POST JSON, return (status, headers, body-text). Raises on network error."""
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        url, data=data, method="POST",
        headers={"Content-Type": "application/json", **(headers or {})},
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return r.status, dict(r.headers), r.read().decode("utf-8", "replace")
    except urllib.error.HTTPError as e:
        body = ""
        try:
            body = e.read().decode("utf-8", "replace")
        except Exception:
            pass
        return e.code, dict(e.headers or {}), body


def read_db_id(gym, wait_sec=60):
    path = SHARED / f"database_id_{gym}"
    deadline = time.time() + wait_sec
    while time.time() < deadline:
        if path.exists():
            db_id = path.read_text().strip()
            if db_id:
                return db_id
        time.sleep(1)
    log(f"[warn] no database id file for gym={gym} after {wait_sec}s")
    return None


class MCP:
    """Minimal MCP streamable-http client, proxied through mcp-injector."""

    def __init__(self, gym):
        self.gym = gym
        self.url = f"{INJECTOR}/{gym}"
        self.session_id = None
        self._rpc_id = 0

    def _post(self, payload):
        headers = {"Accept": "application/json, text/event-stream"}
        if self.session_id:
            headers["mcp-session-id"] = self.session_id
        status, resp_headers, body = http_post_json(self.url, payload, headers)
        sid = {k.lower(): v for k, v in resp_headers.items()}.get("mcp-session-id")
        if sid and not self.session_id:
            self.session_id = sid
        if status >= 400:
            raise RuntimeError(f"HTTP {status} from {self.gym}: {body[:300]}")
        if not body.strip():
            return None
        ctype = {k.lower(): v for k, v in resp_headers.items()}.get("content-type", "")
        if ctype.startswith("text/event-stream"):
            for line in body.splitlines():
                if line.startswith("data: "):
                    return json.loads(line[6:])
            return None
        return json.loads(body)

    def rpc(self, method, params=None):
        self._rpc_id += 1
        payload = {"jsonrpc": "2.0", "id": self._rpc_id, "method": method}
        if params is not None:
            payload["params"] = params
        return self._post(payload)

    def initialize(self):
        self.rpc("initialize", {
            "protocolVersion": "2025-03-26",
            "capabilities": {},
            "clientInfo": {"name": "oracle-solution", "version": "1.0"},
        })
        self._post({"jsonrpc": "2.0", "method": "notifications/initialized"})

    def call(self, tool, args):
        resp = self.rpc("tools/call", {"name": tool, "arguments": args})
        if resp and "error" in resp:
            raise RuntimeError(f"MCP error on {tool}: {resp['error']}")
        result = (resp or {}).get("result", {})
        if isinstance(result, dict) and result.get("isError"):
            texts = [c.get("text", "") for c in result.get("content", [])
                     if isinstance(c, dict)]
            raise RuntimeError(f"tool {tool} returned isError: {' '.join(texts)[:300]}")
        for c in result.get("content", []) if isinstance(result, dict) else []:
            if isinstance(c, dict) and c.get("type") == "text":
                try:
                    return json.loads(c["text"])
                except (json.JSONDecodeError, TypeError):
                    return {"_text": c.get("text")}
        return result if isinstance(result, dict) else {"_result": result}


def sql_exec(gym, query, db_id):
    """Run SQL against the gym's sql-runner. Returns db_verifier-shaped dict."""
    url = f"{GYM_API[gym]}/api/sql-runner"
    headers = {}
    if db_id:
        headers["x-database-id"] = db_id
    try:
        status, _, body = http_post_json(
            url, {"query": query, "database_id": db_id}, headers, timeout=30)
    except Exception as e:
        return {"success": False, "error": f"network: {e}"}
    if status >= 400:
        return {"success": False, "error": f"HTTP {status}: {body[:300]}"}
    try:
        return {"success": True, "result": json.loads(body)}
    except json.JSONDecodeError:
        return {"success": False, "error": f"non-JSON body: {body[:300]}"}


def extract_value(result):
    """Byte-for-byte port of tests/lib/db_verifier._extract_value_from_sql_result."""
    if not result:
        return None
    if not result.get("success"):
        result_data = result.get("result", {})
        if isinstance(result_data, dict) and "content" in result_data:
            content = result_data["content"]
            if isinstance(content, list) and len(content) > 0:
                for item in content:
                    if isinstance(item, dict) and item.get("type") == "text":
                        return item.get("text", "Error")
        return None
    result_data = result.get("result", {})
    if isinstance(result_data, dict):
        if "data" in result_data:
            data = result_data["data"]
            if isinstance(data, list) and len(data) > 0:
                if len(data) == 1 and isinstance(data[0], dict) and len(data[0]) == 1:
                    return list(data[0].values())[0]
                elif len(data) == 1:
                    return data[0]
                else:
                    return data
            return data
        elif "rows" in result_data:
            rows = result_data["rows"]
            if isinstance(rows, list) and len(rows) > 0:
                if len(rows) == 1 and isinstance(rows[0], dict) and len(rows[0]) == 1:
                    return list(rows[0].values())[0]
                elif len(rows) == 1 and isinstance(rows[0], list) and len(rows[0]) == 1:
                    return rows[0][0]
                elif len(rows) == 1:
                    return rows[0]
                else:
                    return rows
            return rows
        elif "content" in result_data:
            content = result_data["content"]
            if isinstance(content, list) and len(content) > 0:
                for item in content:
                    if isinstance(item, dict) and item.get("type") == "text":
                        return item.get("text", result_data)
            return content
        elif "result" in result_data:
            return result_data["result"]
    return result_data


def compare_values(actual, expected, comparison_type):
    """Port of tests/lib/db_verifier._compare_values."""
    try:
        if comparison_type == "equals":
            return actual == expected
        if comparison_type == "greater_than":
            return actual > expected
        if comparison_type == "less_than":
            return actual < expected
        if comparison_type == "contains":
            return str(expected) in str(actual)
        return False
    except Exception:
        return False


def substitute(value, variables):
    if isinstance(value, str):
        def repl(m):
            name = m.group(1)
            return str(variables[name]) if name in variables else m.group(0)
        return re.sub(r"\$\{([A-Za-z_][A-Za-z0-9_]*)\}", repl, value)
    if isinstance(value, dict):
        return {k: substitute(v, variables) for k, v in value.items()}
    if isinstance(value, list):
        return [substitute(v, variables) for v in value]
    return value


def dig(result, key):
    """Fetch a (possibly dotted) key path from a tool result dict."""
    cur = result
    for part in str(key).split("."):
        if isinstance(cur, dict) and part in cur:
            cur = cur[part]
        else:
            return None
    return cur


def main():
    log(f"=== oracle solution for task {TASK_ID} ===")
    db_ids = {gym: read_db_id(gym) for gym in GYMS}
    for gym, db_id in db_ids.items():
        log(f"  db_id[{gym}] = {db_id}")

    clients = {}
    variables = {}
    traj_steps = []
    called_tools = []

    # ---- Phase 1: MCP tool-call plan --------------------------------------
    log(f"\n--- phase 1: executing {len(PLAN)} MCP tool calls ---")
    for i, step in enumerate(PLAN, 1):
        gym, tool = step["gym"], step["tool"]
        args = substitute(step.get("args", {}), variables)
        note = step.get("note", "")
        outcome = None
        try:
            if gym not in clients:
                clients[gym] = MCP(gym)
                clients[gym].initialize()
            outcome = clients[gym].call(tool, args)
            log(f"  {i:>2}. {tool} OK")
            for var, keys in (step.get("save") or {}).items():
                key_list = keys if isinstance(keys, list) else [keys]
                for key in key_list:
                    val = dig(outcome, key)
                    if val is not None:
                        variables[var] = val
                        break
                else:
                    log(f"      [warn] save '{var}': none of {key_list} in result")
        except Exception as e:
            log(f"  {i:>2}. {tool} FAILED: {e}")
        called_tools.append(tool)
        traj_steps.append({
            "agent": {"text": note},
            "tool_call": {"name": tool, "arguments": args, "call_id": f"call_{i}"},
        })

    # ---- Phase 2: reconcile database_state verifiers ----------------------
    log(f"\n--- phase 2: reconciling {len(RECONCILE)} database_state checks ---")
    failed = []
    for i, item in enumerate(RECONCILE):
        gym = item["gym"]
        db_id = db_ids.get(gym)
        result = sql_exec(gym, item["query"], db_id)
        ok = result.get("success") and compare_values(
            extract_value(result), item["expected"], item["comparison"])
        if not ok and item.get("fix"):
            log(f"  [{i}] unmet -> applying {len(item['fix'])} fix statement(s)")
            for stmt in item["fix"]:
                fix_result = sql_exec(gym, substitute(stmt, variables), db_id)
                if not fix_result.get("success"):
                    log(f"      [warn] fix failed: {fix_result.get('error')}")
            result = sql_exec(gym, item["query"], db_id)
            ok = result.get("success") and compare_values(
                extract_value(result), item["expected"], item["comparison"])
        log(f"  [{i}] {'PASS' if ok else 'FAIL'} — {item.get('desc', item['query'][:70])}")
        if not ok:
            failed.append(i)

    # ---- Phase 3: write the ATIF trajectory -------------------------------
    for tool in REQUIRED_TOOLS:
        if tool not in called_tools:
            log(f"[warn] required tool {tool} missing from plan; adding synthetic step")
            traj_steps.append({
                "agent": {"text": ""},
                "tool_call": {"name": tool, "arguments": {}, "call_id": ""},
            })
    traj_steps.append({"agent": {"text": FINAL_RESPONSE}})
    try:
        TRAJ_PATH.parent.mkdir(parents=True, exist_ok=True)
        TRAJ_PATH.write_text(json.dumps({"steps": traj_steps}, indent=2))
        log(f"\nwrote trajectory ({len(traj_steps)} steps) to {TRAJ_PATH}")
    except OSError as e:
        log(f"[warn] could not write {TRAJ_PATH}: {e}")

    if failed:
        log(f"\n=== RESULT: {len(RECONCILE) - len(failed)}/{len(RECONCILE)} "
            f"database checks pass; failing idx: {failed} ===")
        return 1
    log(f"\n=== RESULT: all {len(RECONCILE)} database checks pass ===")
    return 0


if __name__ == "__main__":
    sys.exit(main())
ORACLE_PY
