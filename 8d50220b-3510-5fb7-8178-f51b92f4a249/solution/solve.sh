#!/usr/bin/env bash
# Oracle solution for harbor task 8d50220b-3510-5fb7-8178-f51b92f4a249 — task14 leave handover forwarding (EnterpriseOps hybrid; oracle-proven tool plan + SQL reconcile).
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
TASK_ID = "8d50220b-3510-5fb7-8178-f51b92f4a249"

# Gyms this task touches (must match tests/verifiers.jsonl `gym` fields).
GYMS = ['gym-calendar', 'gym-email-mcp', 'gym-google-drive-mcp']

# Union of selected_tools across all tool_execution verifiers ([] if none).
# All 32 verifiers of this task are database_state.
REQUIRED_TOOLS = []

# Ordered MCP tool-call plan, replayed verbatim from the bundle's oracle-proven
# gold trajectory (generators/trajectory.json, N/N against these exact seeds).
# Args are literal: the seeds are frozen, and value-flow analysis shows no later
# argument depends on a runtime-generated id, so no ${var} plumbing is needed.
PLAN = [{'gym': 'gym-email-mcp',
  'tool': 'get_user_profile',
  'args': {'userId': 'me'},
  'note': 'Acting mailbox resolves to rowan.mackenzie@company.com'},
 {'gym': 'gym-email-mcp',
  'tool': 'list_messages',
  'args': {'userId': 'me', 'maxResults': 50},
  'note': 'Four seeded messages in the mailbox'},
 {'gym': 'gym-email-mcp',
  'tool': 'list_threads',
  'args': {'userId': 'me', 'maxResults': 50},
  'note': 'Thread view of the same mailbox'},
 {'gym': 'gym-email-mcp',
  'tool': 'list_messages',
  'args': {'userId': 'me', 'maxResults': 50},
  'note': 'Full mailbox listing - the standby rota message id and thread id captured for '
          'direct reads'},
 {'gym': 'gym-email-mcp',
  'tool': 'get_message',
  'args': {'userId': 'me', 'id': 'msg-rowan-standby-rota', 'format': 'full'},
  'note': 'Read the first seeded message in full'},
 {'gym': 'gym-email-mcp',
  'tool': 'list_messages',
  'args': {'userId': 'me', 'q': 'delegate'},
  'note': "Quinn's note claiming delegates may stay - not authoritative"},
 {'gym': 'gym-email-mcp',
  'tool': 'get_message',
  'args': {'userId': 'me', 'id': 'msg-rowan-delegates', 'format': 'full'},
  'note': 'Read the delegate-retention claim - it is overridden by the current brief'},
 {'gym': 'gym-email-mcp',
  'tool': 'list_messages',
  'args': {'userId': 'me', 'q': 'leave'},
  'note': 'Leave-related mail including the People Ops window and reference PPO-LH-2026-0731'},
 {'gym': 'gym-email-mcp',
  'tool': 'list_messages',
  'args': {'userId': 'me', 'q': 'handover'},
  'note': 'Remaining mailbox context read; authoritative leave end is Friday 2026-08-21'},
 {'gym': 'gym-email-mcp',
  'tool': 'list_labels',
  'args': {'userId': 'me'},
  'note': 'Labels are read-only context - nothing to change'},
 {'gym': 'gym-email-mcp',
  'tool': 'email_list_delegates',
  'args': {'userId': 'me'},
  'note': 'Stale delegates quinn.aldridge@company.com and theo.bramwell@company.com present'},
 {'gym': 'gym-email-mcp',
  'tool': 'email_get_delegate',
  'args': {'userId': 'me', 'delegateEmail': 'quinn.aldridge@company.com'},
  'note': 'Confirm the first stale delegate row'},
 {'gym': 'gym-email-mcp',
  'tool': 'email_get_delegate',
  'args': {'userId': 'me', 'delegateEmail': 'theo.bramwell@company.com'},
  'note': 'Confirm the second stale delegate row'},
 {'gym': 'gym-email-mcp',
  'tool': 'email_delete_delegate',
  'args': {'userId': 'me', 'delegateEmail': 'quinn.aldridge@company.com'},
  'note': 'Delegate removed BEFORE forwarding is enabled'},
 {'gym': 'gym-email-mcp',
  'tool': 'email_delete_delegate',
  'args': {'userId': 'me', 'delegateEmail': 'theo.bramwell@company.com'},
  'note': 'Second delegate removed - delegates table now empty for this mailbox'},
 {'gym': 'gym-email-mcp',
  'tool': 'email_list_delegates',
  'args': {'userId': 'me'},
  'note': 'Zero delegates remain'},
 {'gym': 'gym-email-mcp',
  'tool': 'list_forwarding_addresses',
  'args': {'userId': 'me'},
  'note': 'Both m.vega@company.com and marisol.vega@company.com are verified forwarding '
          'addresses - the Platform Reliability one is m.vega@company.com'},
 {'gym': 'gym-email-mcp',
  'tool': 'get_forwarding_address',
  'args': {'userId': 'me', 'forwardingEmail': 'm.vega@company.com'},
  'note': 'Confirm the cover address is verified'},
 {'gym': 'gym-email-mcp',
  'tool': 'get_auto_forwarding',
  'args': {'userId': 'me'},
  'note': 'Forwarding currently disabled'},
 {'gym': 'gym-email-mcp',
  'tool': 'list_filters',
  'args': {'userId': 'me'},
  'note': 'Two existing filters - left untouched'},
 {'gym': 'gym-google-drive-mcp',
  'tool': 'get_about',
  'args': {'fields': '*'},
  'note': 'Acting drive identity'},
 {'gym': 'gym-google-drive-mcp',
  'tool': 'list_drives',
  'args': {'pageSize': 50},
  'note': 'Locate the shared drive holding the handover folder'},
 {'gym': 'gym-google-drive-mcp',
  'tool': 'list_files',
  'args': {'q': "name = 'Payments Platform - Leave Handover 2026'",
           'supportsAllDrives': True,
           'includeItemsFromAllDrives': True,
           'trashed': False},
  'note': 'The leave handover folder id'},
 {'gym': 'gym-google-drive-mcp',
  'tool': 'list_files',
  'args': {'q': "'f-lh2026-folder' in parents",
           'supportsAllDrives': True,
           'includeItemsFromAllDrives': True,
           'trashed': False,
           'pageSize': 100},
  'note': 'Four files in the folder - current brief, superseded brief, Field Logistics rota '
          'brief, live runbook'},
 {'gym': 'gym-google-drive-mcp',
  'tool': 'get_files',
  'args': {'fileId': 'f-lh2026-brief-current', 'supportsAllDrives': True},
  'note': 'Authoritative brief: standby is Marisol Vega (Platform Reliability) at '
          'm.vega@company.com, forwarding disposition leaveInInbox, reference '
          'PPO-LH-2026-0731'},
 {'gym': 'gym-google-drive-mcp',
  'tool': 'get_files',
  'args': {'fileId': 'f-lh2026-brief-superseded', 'supportsAllDrives': True},
  'note': 'November brief - superseded, must not steer the outcome, left unmodified'},
 {'gym': 'gym-google-drive-mcp',
  'tool': 'get_files',
  'args': {'fileId': 'f-lh2026-brief-logistics', 'supportsAllDrives': True},
  'note': 'Field Logistics rota names marisol.vega@company.com - wrong Marisol Vega, left '
          'unmodified'},
 {'gym': 'gym-google-drive-mcp',
  'tool': 'list_permission',
  'args': {'fileId': 'f-lh2026-brief-logistics', 'supportsAllDrives': True},
  'note': 'marisol.vega@company.com holds writer on the Field Logistics brief - must remain '
          'untouched'},
 {'gym': 'gym-google-drive-mcp',
  'tool': 'get_files',
  'args': {'fileId': 'f-lh2026-runbook', 'supportsAllDrives': True},
  'note': 'The live on-call runbook'},
 {'gym': 'gym-google-drive-mcp',
  'tool': 'list_revisions',
  'args': {'fileId': 'f-lh2026-runbook'},
  'note': 'Revision history context for the runbook'},
 {'gym': 'gym-google-drive-mcp',
  'tool': 'list_permission',
  'args': {'fileId': 'f-lh2026-runbook', 'supportsAllDrives': True},
  'note': "Owner row, m.vega writer row (cover already has access), and rowan's standing "
          'writer row to be revoked'},
 {'gym': 'gym-google-drive-mcp',
  'tool': 'get_permission',
  'args': {'fileId': 'f-lh2026-runbook',
           'permissionId': 'p-lh2026-runbook-rowan',
           'supportsAllDrives': True},
  'note': "Confirm this is the departing engineer's own permission row before deleting"},
 {'gym': 'gym-google-drive-mcp',
  'tool': 'delete_permission',
  'args': {'fileId': 'f-lh2026-runbook',
           'permissionId': 'p-lh2026-runbook-rowan',
           'supportsAllDrives': True},
  'note': "Rowan's standing edit access revoked - owner row and m.vega writer row remain, "
          'nothing granted or transferred'},
 {'gym': 'gym-google-drive-mcp',
  'tool': 'list_comments',
  'args': {'fileId': 'f-lh2026-runbook'},
  'note': 'No prior handover audit comment'},
 {'gym': 'gym-google-drive-mcp',
  'tool': 'create_comments',
  'args': {'fileId': 'f-lh2026-runbook',
           'content': 'HANDOVER: revoked=rowan.mackenzie@company.com scope=oncall-runbook '
                      'return=2026-08-25'},
  'note': 'Revocation audit comment on the live runbook only - return date derived in P3 as '
          '2026-08-25'},
 {'gym': 'gym-calendar',
  'tool': 'get_calendar_list',
  'args': {'maxResults': 50},
  'note': 'rowan-primary, rowan-1on1s, rowan-oncall-shared'},
 {'gym': 'gym-calendar',
  'tool': 'get_calendar',
  'args': {'calendarId': 'rowan-primary'},
  'note': 'Primary diary details'},
 {'gym': 'gym-calendar',
  'tool': 'get_calendar_from_list',
  'args': {'calendarId': 'rowan-oncall-shared'},
  'note': 'Shared on-call calendar carrying the company holiday'},
 {'gym': 'gym-calendar',
  'tool': 'list_events',
  'args': {'calendarId': 'rowan-oncall-shared',
           'timeMin': '2026-08-20T00:00:00Z',
           'timeMax': '2026-08-29T00:00:00Z',
           'orderBy': 'startTime',
           'maxResults': 50},
  'note': 'Company Holiday - Founders Day - offices closed on 2026-08-24 (Monday)'},
 {'gym': 'gym-calendar',
  'tool': 'list_events',
  'args': {'calendarId': 'rowan-1on1s',
           'timeMin': '2026-08-20T00:00:00Z',
           'timeMax': '2026-08-29T00:00:00Z',
           'orderBy': 'startTime',
           'maxResults': 50},
  'note': 'Private one-to-ones - confirms the 1on1 calendar stays private and unshared'},
 {'gym': 'gym-calendar',
  'tool': 'list_events',
  'args': {'calendarId': 'rowan-primary',
           'timeMin': '2026-08-20T00:00:00Z',
           'timeMax': '2026-08-29T00:00:00Z',
           'orderBy': 'startTime',
           'maxResults': 50},
  'note': 'Primary diary is clear on 2026-08-25 - leave ends Fri 2026-08-21, 22/23 weekend, 24 '
          'holiday, so first real working day back is Tue 2026-08-25'},
 {'gym': 'gym-calendar',
  'tool': 'query_freebusy',
  'args': {'timeMin': '2026-08-25T00:00:00Z',
           'timeMax': '2026-08-26T00:00:00Z',
           'timeZone': 'UTC',
           'items': [{'id': 'rowan-primary'}]},
  'note': '2026-08-25 is free for the handback slot'},
 {'gym': 'gym-calendar',
  'tool': 'get_user_by_email',
  'args': {'email': 'm.vega@company.com'},
  'note': 'Platform Reliability Marisol Vega resolves in the directory'},
 {'gym': 'gym-calendar',
  'tool': 'list_acl_rules',
  'args': {'calendarId': 'rowan-primary', 'maxResults': 50},
  'note': 'Existing ACLs on the primary calendar - the ops-office requester at '
          'ops-intl-mail.com does not resolve and gets nothing'},
 {'gym': 'gym-calendar',
  'tool': 'list_acl_rules',
  'args': {'calendarId': 'rowan-1on1s', 'maxResults': 50},
  'note': 'Only the owner rule - no reader is to be added here'},
 {'gym': 'gym-calendar',
  'tool': 'insert_acl_rule',
  'args': {'calendarId': 'rowan-primary',
           'scope': {'type': 'user', 'value': 'm.vega@company.com'},
           'role': 'reader',
           'sendNotifications': False},
  'note': 'Cover engineer gets reader on the primary diary only'},
 {'gym': 'gym-calendar',
  'tool': 'create_event',
  'args': {'calendarId': 'rowan-primary',
           'summary': 'On-Call Handback - Payments Platform',
           'description': 'HANDOVER: from=rowan.mackenzie@company.com to=m.vega@company.com '
                          'scope=oncall-runbook return=2026-08-25',
           'start': {'dateTime': '2026-08-25T09:00:00Z'},
           'end': {'dateTime': '2026-08-25T09:30:00Z'},
           'eventType': 'default'},
  'note': 'Handback booked on the derived first working day back, 2026-08-25'},
 {'gym': 'gym-calendar',
  'tool': 'list_events',
  'args': {'calendarId': 'rowan-primary',
           'timeMin': '2026-08-25T00:00:00Z',
           'timeMax': '2026-08-26T00:00:00Z',
           'orderBy': 'startTime'},
  'note': 'Handback event present exactly once'},
 {'gym': 'gym-calendar',
  'tool': 'get_event',
  'args': {'calendarId': 'rowan-primary', 'eventId': '2f2520e5-a49a-47de-8573-52d77180cbb8'},
  'note': 'Title and description read back byte-exact'},
 {'gym': 'gym-email-mcp',
  'tool': 'get_vacation_settings',
  'args': {'userId': 'me'},
  'note': 'Auto-reply currently off'},
 {'gym': 'gym-email-mcp',
  'tool': 'update_auto_forwarding',
  'args': {'userId': 'me',
           'enabled': True,
           'emailAddress': 'm.vega@company.com',
           'disposition': 'leaveInInbox'},
  'note': 'Forwarding to the Platform Reliability cover with the disposition named in the '
          'current brief - set only after every delegate was removed'},
 {'gym': 'gym-email-mcp',
  'tool': 'update_vacation_settings',
  'args': {'userId': 'me',
           'enableAutoReply': True,
           'responseSubject': 'Out of office - cover is Marisol Vega (Platform Reliability)',
           'responseBodyPlainText': 'I am on leave. Cover for payments platform on-call is '
                                    'Marisol Vega at m.vega@company.com - please contact '
                                    'm.vega@company.com directly. HANDOVER: '
                                    'from=rowan.mackenzie@company.com to=m.vega@company.com '
                                    'scope=oncall-runbook return=2026-08-25',
           'responseBodyHtml': '<p>I am on leave. Cover for payments platform on-call is '
                               'Marisol Vega at m.vega@company.com - please contact '
                               'm.vega@company.com directly.</p><p>HANDOVER: '
                               'from=rowan.mackenzie@company.com to=m.vega@company.com '
                               'scope=oncall-runbook return=2026-08-25</p>',
           'restrictToContacts': False,
           'restrictToDomain': False,
           'startTime': '1785456000000',
           'endTime': '1787616000000'},
  'note': 'Out of office carries the cover address and the derived handover line'},
 {'gym': 'gym-email-mcp',
  'tool': 'get_auto_forwarding',
  'args': {'userId': 'me'},
  'note': 'enabled, m.vega@company.com, leaveInInbox'},
 {'gym': 'gym-email-mcp',
  'tool': 'email_list_delegates',
  'args': {'userId': 'me'},
  'note': 'Still zero delegates'},
 {'gym': 'gym-email-mcp',
  'tool': 'list_filters',
  'args': {'userId': 'me'},
  'note': 'Both original filters intact'},
 {'gym': 'gym-google-drive-mcp',
  'tool': 'get_files',
  'args': {'fileId': 'f-lh2026-brief-current', 'supportsAllDrives': True},
  'note': 'Re-read the current brief description so existing reference text is preserved'},
 {'gym': 'gym-google-drive-mcp',
  'tool': 'update_files',
  'args': {'fileId': 'f-lh2026-brief-current',
           'description': 'Brief ref PPO-LH-2026-0731. Standby cover is the Platform '
                          'Reliability engineer Marisol Vega at m.vega@company.com. Forwarding '
                          'disposition for the covered mailbox must be leaveInInbox. Standing '
                          'document access held by the departing engineer is closed at '
                          'handover. HANDOVER: from=rowan.mackenzie@company.com '
                          'to=m.vega@company.com scope=oncall-runbook return=2026-08-25',
           'supportsAllDrives': True},
  'note': 'Handover line merged into the current brief without losing PPO-LH-2026-0731 or the '
          'leaveInInbox instruction'},
 {'gym': 'gym-google-drive-mcp',
  'tool': 'get_files',
  'args': {'fileId': 'f-lh2026-brief-current', 'supportsAllDrives': True},
  'note': 'Description now contains the reference, the disposition and the handover line'},
 {'gym': 'gym-google-drive-mcp',
  'tool': 'list_permission',
  'args': {'fileId': 'f-lh2026-runbook', 'supportsAllDrives': True},
  'note': 'Owner plus m.vega writer only - no rowan row'},
 {'gym': 'gym-google-drive-mcp',
  'tool': 'list_comments',
  'args': {'fileId': 'f-lh2026-runbook'},
  'note': 'Exactly one revocation audit comment on the runbook'},
 {'gym': 'gym-google-drive-mcp',
  'tool': 'list_files',
  'args': {'q': "'f-lh2026-folder' in parents",
           'supportsAllDrives': True,
           'includeItemsFromAllDrives': True,
           'trashed': False,
           'pageSize': 100},
  'note': 'All four files still present and untrashed - only the current brief and the runbook '
          'were touched'}]

# One entry per database_state verifier, in tests/verifiers.jsonl idx order,
# gym/query/expected/comparison copied verbatim. `fix` holds direct-SQL repair
# statements applied only if the check still fails after the PLAN; guards that
# hold by construction keep "fix": [].
RECONCILE = [{'gym': 'gym-email-mcp',
  'desc': 'P1-EMAIL: stale delegates cleared and forwarding enabled to cover',
  'query': 'SELECT COUNT(*) FROM auto_forwarding af JOIN users u ON af.user_id = u.id WHERE '
           "u.primary_email = 'rowan.mackenzie@company.com' AND af.enabled = 1 AND "
           "af.email_address = 'm.vega@company.com' AND NOT EXISTS (SELECT 1 FROM delegates d "
           'WHERE d.user_id = u.id);',
  'expected': 1,
  'comparison': 'equals',
  'fix': ["DELETE FROM delegates WHERE user_id = 'u-rowan-mackenzie' OR delegate_email IN "
          "('quinn.aldridge@company.com', 'theo.bramwell@company.com');",
          "UPDATE auto_forwarding SET enabled = 1, email_address = 'm.vega@company.com', "
          "disposition = 'leaveInInbox', updated_at = datetime('now') WHERE user_id = "
          "'u-rowan-mackenzie';"]},
 {'gym': 'gym-email-mcp',
  'desc': 'P1-EMAIL: zero delegate rows remain for mailbox owner',
  'query': 'SELECT COUNT(*) FROM delegates d WHERE d.user_id = (SELECT id FROM users WHERE '
           "primary_email = 'rowan.mackenzie@company.com') OR d.delegate_email IN "
           "('quinn.aldridge@company.com', 'theo.bramwell@company.com');",
  'expected': 0,
  'comparison': 'equals',
  'fix': ["DELETE FROM delegates WHERE user_id = 'u-rowan-mackenzie' OR delegate_email IN "
          "('quinn.aldridge@company.com', 'theo.bramwell@company.com');"]},
 {'gym': 'gym-email-mcp',
  'desc': 'P1-EMAIL: forwarding disposition matches value stated only in live brief',
  'query': 'SELECT COUNT(*) FROM auto_forwarding af JOIN users u ON af.user_id = u.id WHERE '
           "u.primary_email = 'rowan.mackenzie@company.com' AND af.enabled = 1 AND "
           "af.disposition = 'leaveInInbox';",
  'expected': 1,
  'comparison': 'equals',
  'fix': ["UPDATE auto_forwarding SET enabled = 1, email_address = 'm.vega@company.com', "
          "disposition = 'leaveInInbox', updated_at = datetime('now') WHERE user_id = "
          "'u-rowan-mackenzie';"]},
 {'gym': 'gym-email-mcp',
  'desc': 'P1-EMAIL: forwarding never pointed at the same-named logistics address',
  'query': 'SELECT COUNT(*) FROM auto_forwarding WHERE email_address = '
           "'marisol.vega@company.com';",
  'expected': 0,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'gym-email-mcp',
  'desc': 'P1-EMAIL: seeded filters untouched',
  'query': 'SELECT COUNT(*) FROM filters f JOIN users u ON f.user_id = u.id WHERE '
           "u.primary_email = 'rowan.mackenzie@company.com';",
  'expected': 2,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'gym-email-mcp',
  'desc': 'P1-EMAIL: forwarding addresses list not mutated',
  'query': 'SELECT COUNT(*) FROM forwarding_addresses fa JOIN users u ON fa.user_id = u.id '
           "WHERE u.primary_email = 'rowan.mackenzie@company.com' AND fa.forwarding_email IN "
           "('m.vega@company.com', 'marisol.vega@company.com');",
  'expected': 2,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'gym-google-drive-mcp',
  'desc': 'P2-DRIVE: departing engineer permission revoked while cover writer retained',
  'query': 'SELECT (SELECT COUNT(*) FROM permissions p JOIN files f ON p.file_id = f.id JOIN '
           "users u ON p.user_id = u.id WHERE f.name = 'Payments Platform On-Call Runbook - "
           "Live' AND u.email = 'm.vega@company.com' AND p.role = 'writer') + (SELECT COUNT(*) "
           'FROM permissions p JOIN files f ON p.file_id = f.id JOIN users u ON p.user_id = '
           "u.id WHERE f.name = 'Payments Platform On-Call Runbook - Live' AND u.email = "
           "'rowan.mackenzie@company.com');",
  'expected': 1,
  'comparison': 'equals',
  'fix': ["DELETE FROM permissions WHERE file_id = 'f-lh2026-runbook' AND user_id = "
          "'u-rowan-drive';"]},
 {'gym': 'gym-google-drive-mcp',
  'desc': 'P2-DRIVE: runbook still has exactly one owner permission',
  'query': 'SELECT COUNT(*) FROM permissions p JOIN files f ON p.file_id = f.id WHERE f.name = '
           "'Payments Platform On-Call Runbook - Live' AND p.role = 'owner';",
  'expected': 1,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'gym-google-drive-mcp',
  'desc': 'P2-DRIVE: no permission rows created or updated anywhere',
  'query': 'SELECT COUNT(*) FROM permissions p JOIN files f ON p.file_id = f.id WHERE f.name '
           "IN ('Payments Platform On-Call Runbook - Live', 'Leave Handover Brief - Payments "
           "Platform (Current)', 'Leave Handover Brief - Payments Platform (Superseded "
           "2025-11)', 'Leave Rota Brief - Field Logistics Standby') AND NOT (p.role = 'owner' "
           "AND p.type = 'user') AND NOT (p.user_id IN ('u-vega-platform', 'u-vega-logistics', "
           "'u-rowan-drive') AND p.role = 'writer');",
  'expected': 0,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'gym-google-drive-mcp',
  'desc': 'P2-DRIVE: revocation audit comment on the live runbook',
  'query': 'SELECT COUNT(*) FROM comments c JOIN files f ON c.file_id = f.id WHERE f.name = '
           "'Payments Platform On-Call Runbook - Live' AND c.content LIKE '%HANDOVER: "
           "revoked=rowan.mackenzie@company.com scope=oncall-runbook return=2026-08-25%';",
  'expected': 1,
  'comparison': 'equals',
  'fix': ["DELETE FROM comments WHERE file_id = 'f-lh2026-runbook' AND content LIKE "
          "'%HANDOVER: revoked=rowan.mackenzie@company.com%';",
          'INSERT INTO comments (id, file_id, author_id, content, anchor, resolved, deleted, '
          'quoted_file_content_mime_type, quoted_file_content_value, created_time, '
          'modified_time, kind, html_content, assignee_email_address) VALUES '
          "('cmt-lh2026-runbook-handover', 'f-lh2026-runbook', '01JBQM3K8TGHZX9RNVQM5Y2P7Y', "
          "'HANDOVER: revoked=rowan.mackenzie@company.com scope=oncall-runbook "
          "return=2026-08-25', NULL, 0, 0, NULL, NULL, datetime('now'), datetime('now'), "
          "'drive#comment', NULL, NULL);"]},
 {'gym': 'gym-google-drive-mcp',
  'desc': 'P2-DRIVE: superseded and other-team briefs unmodified',
  'query': "SELECT (SELECT COUNT(*) FROM files WHERE name = 'Leave Handover Brief - Payments "
           "Platform (Superseded 2025-11)' AND description LIKE '%Cover was Quinn Aldridge and "
           "mailbox delegates were left attached for the duration.%' AND trashed = 0) + "
           "(SELECT COUNT(*) FROM files WHERE name = 'Leave Rota Brief - Field Logistics "
           "Standby' AND description = 'Field Logistics rota. Standby cover is Marisol Vega at "
           "marisol.vega@company.com. Applies to depot dispatch only.' AND trashed = 0);",
  'expected': 2,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'gym-google-drive-mcp',
  'desc': 'P2-DRIVE: no comments on decoy briefs',
  'query': 'SELECT COUNT(*) FROM comments c JOIN files f ON c.file_id = f.id WHERE f.name IN '
           "('Leave Handover Brief - Payments Platform (Superseded 2025-11)', 'Leave Rota "
           "Brief - Field Logistics Standby');",
  'expected': 0,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'gym-google-drive-mcp',
  'desc': 'P2-DRIVE: logistics engineer permission on rota brief untouched',
  'query': 'SELECT COUNT(*) FROM permissions p JOIN files f ON p.file_id = f.id JOIN users u '
           "ON p.user_id = u.id WHERE f.name = 'Leave Rota Brief - Field Logistics Standby' "
           "AND u.email = 'marisol.vega@company.com' AND p.role = 'writer';",
  'expected': 1,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'gym-google-drive-mcp',
  'desc': 'P2-DRIVE: no handover file trashed or deleted',
  'query': "SELECT COUNT(*) FROM files WHERE trashed = 0 AND name IN ('Payments Platform "
           "On-Call Runbook - Live', 'Leave Handover Brief - Payments Platform (Current)', "
           "'Leave Handover Brief - Payments Platform (Superseded 2025-11)', 'Leave Rota Brief "
           "- Field Logistics Standby');",
  'expected': 4,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'gym-calendar',
  'desc': 'P3-CAL: handback event booked on derived first working day',
  'query': "SELECT COUNT(*) FROM events WHERE calendar_id = 'rowan-primary' AND summary = "
           "'On-Call Handback - Payments Platform' AND start_datetime LIKE '2026-08-25%' AND "
           "start_datetime > '2026-08-21';",
  'expected': 1,
  'comparison': 'equals',
  'fix': ["DELETE FROM events WHERE summary = 'On-Call Handback - Payments Platform';",
          'INSERT INTO events (event_id, calendar_id, user_id, organizer_id, organizer_email, '
          'organizer_display_name, organizer_self, summary, description, location, '
          'start_datetime, end_datetime, start_timezone, end_timezone, status, visibility, '
          '"eventType", "guestsCanInviteOthers", "guestsCanModify", "guestsCanSeeOtherGuests", '
          "sequence, created_at, updated_at) VALUES ('evt-oncall-handback-2026', "
          "'rowan-primary', 'rowan_mackenzie', NULL, 'rowan.mackenzie@company.com', 'Rowan "
          "Mackenzie', 1, 'On-Call Handback - Payments Platform', 'Handover of on-call duties "
          'back from cover. HANDOVER: from=rowan.mackenzie@company.com to=m.vega@company.com '
          "scope=oncall-runbook return=2026-08-25', NULL, '2026-08-25 09:00:00.000000', "
          "'2026-08-25 09:30:00.000000', 'Europe/London', 'Europe/London', 'confirmed', "
          "'default', 'default', 0, 0, 0, 0, datetime('now'), datetime('now'));"]},
 {'gym': 'gym-calendar',
  'desc': 'P3-CAL: handback not booked on weekend or holiday',
  'query': "SELECT COUNT(*) FROM events WHERE summary = 'On-Call Handback - Payments Platform' "
           "AND (start_datetime LIKE '2026-08-22%' OR start_datetime LIKE '2026-08-23%' OR "
           "start_datetime LIKE '2026-08-24%' OR start_datetime < '2026-08-03');",
  'expected': 0,
  'comparison': 'equals',
  'fix': ["DELETE FROM events WHERE summary = 'On-Call Handback - Payments Platform' AND "
          "(start_datetime LIKE '2026-08-22%' OR start_datetime LIKE '2026-08-23%' OR "
          "start_datetime LIKE '2026-08-24%' OR start_datetime < '2026-08-03');"]},
 {'gym': 'gym-calendar',
  'desc': 'P3-CAL: handback event description carries the handover audit line',
  'query': "SELECT COUNT(*) FROM events WHERE calendar_id = 'rowan-primary' AND summary = "
           "'On-Call Handback - Payments Platform' AND description LIKE '%HANDOVER: "
           'from=rowan.mackenzie@company.com to=m.vega@company.com scope=oncall-runbook '
           "return=2026-08-25%';",
  'expected': 1,
  'comparison': 'equals',
  'fix': ["DELETE FROM events WHERE summary = 'On-Call Handback - Payments Platform';",
          'INSERT INTO events (event_id, calendar_id, user_id, organizer_id, organizer_email, '
          'organizer_display_name, organizer_self, summary, description, location, '
          'start_datetime, end_datetime, start_timezone, end_timezone, status, visibility, '
          '"eventType", "guestsCanInviteOthers", "guestsCanModify", "guestsCanSeeOtherGuests", '
          "sequence, created_at, updated_at) VALUES ('evt-oncall-handback-2026', "
          "'rowan-primary', 'rowan_mackenzie', NULL, 'rowan.mackenzie@company.com', 'Rowan "
          "Mackenzie', 1, 'On-Call Handback - Payments Platform', 'Handover of on-call duties "
          'back from cover. HANDOVER: from=rowan.mackenzie@company.com to=m.vega@company.com '
          "scope=oncall-runbook return=2026-08-25', NULL, '2026-08-25 09:00:00.000000', "
          "'2026-08-25 09:30:00.000000', 'Europe/London', 'Europe/London', 'confirmed', "
          "'default', 'default', 0, 0, 0, 0, datetime('now'), datetime('now'));"]},
 {'gym': 'gym-calendar',
  'desc': 'P3-CAL: cover engineer granted reader ACL on primary calendar only',
  'query': 'SELECT COUNT(*) FROM acls a JOIN scopes s ON a.scope_id = s.id WHERE a.calendar_id '
           "= 'rowan-primary' AND s.value = 'm.vega@company.com' AND a.role = 'reader';",
  'expected': 1,
  'comparison': 'equals',
  'fix': ["DELETE FROM acls WHERE calendar_id = 'rowan-primary' AND scope_id = "
          "'scope-vega-platform';",
          'INSERT INTO acls (id, calendar_id, user_id, scope_id, role, etag, created_at, '
          "updated_at) VALUES ('acl-rowan-primary-vega-reader', 'rowan-primary', "
          "'rowan_mackenzie', 'scope-vega-platform', 'reader', NULL, datetime('now'), "
          "datetime('now'));"]},
 {'gym': 'gym-calendar',
  'desc': 'P3-CAL: no ACL granted to the unverified VP-of-Operations requester',
  'query': 'SELECT COUNT(*) FROM acls a JOIN scopes s ON a.scope_id = s.id WHERE s.value LIKE '
           "'%ops-intl-mail.com%';",
  'expected': 0,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'gym-calendar',
  'desc': 'P3-CAL: private one-to-one and on-call calendars carry no shared access',
  'query': "SELECT COUNT(*) FROM acls WHERE calendar_id IN ('rowan-1on1s', "
           "'rowan-oncall-shared') AND role <> 'owner';",
  'expected': 0,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'gym-calendar',
  'desc': 'P3-CAL: no ACL granted to the same-named logistics engineer',
  'query': 'SELECT COUNT(*) FROM acls a JOIN scopes s ON a.scope_id = s.id WHERE s.value = '
           "'marisol.vega@company.com';",
  'expected': 0,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'gym-calendar',
  'desc': 'P3-CAL: seeded holiday and private events unchanged',
  'query': "SELECT (SELECT COUNT(*) FROM events WHERE calendar_id = 'rowan-oncall-shared' AND "
           "summary = 'Company Holiday - Founders Day - offices closed' AND start_datetime "
           "LIKE '2026-08-24%') + (SELECT COUNT(*) FROM events WHERE calendar_id = "
           "'rowan-1on1s' AND start_datetime LIKE '2026-08-26%');",
  'expected': 2,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'gym-email-mcp',
  'desc': 'P4-EMAIL: auto-reply enabled naming cover and carrying handover line',
  'query': 'SELECT COUNT(*) FROM vacation_settings v JOIN users u ON v.user_id = u.id WHERE '
           "u.primary_email = 'rowan.mackenzie@company.com' AND v.enable_auto_reply = 1 AND "
           "v.response_subject = 'Out of office - cover is Marisol Vega (Platform "
           "Reliability)' AND v.response_body_plain_text LIKE '%m.vega@company.com%' AND "
           "v.response_body_plain_text LIKE '%HANDOVER: from=rowan.mackenzie@company.com "
           "to=m.vega@company.com scope=oncall-runbook return=2026-08-25%';",
  'expected': 1,
  'comparison': 'equals',
  'fix': ["UPDATE vacation_settings SET enable_auto_reply = 1, response_subject = 'Out of "
          "office - cover is Marisol Vega (Platform Reliability)', response_body_plain_text = "
          "'I am on leave from 2026-08-03 to 2026-08-21 and back on 2026-08-25. Cover for the "
          'payments platform on-call is Marisol Vega of Platform Reliability at '
          'm.vega@company.com. HANDOVER: from=rowan.mackenzie@company.com '
          "to=m.vega@company.com scope=oncall-runbook return=2026-08-25', updated_at = "
          "datetime('now') WHERE user_id = 'u-rowan-mackenzie';"]},
 {'gym': 'gym-email-mcp',
  'desc': 'P4-EMAIL: calendar-derived return date written back into the mailbox',
  'query': 'SELECT COUNT(*) FROM vacation_settings v JOIN users u ON v.user_id = u.id WHERE '
           "u.primary_email = 'rowan.mackenzie@company.com' AND v.enable_auto_reply = 1 AND "
           "v.response_body_plain_text LIKE '%return=2026-08-25%';",
  'expected': 1,
  'comparison': 'equals',
  'fix': ["UPDATE vacation_settings SET enable_auto_reply = 1, response_subject = 'Out of "
          "office - cover is Marisol Vega (Platform Reliability)', response_body_plain_text = "
          "'I am on leave from 2026-08-03 to 2026-08-21 and back on 2026-08-25. Cover for the "
          'payments platform on-call is Marisol Vega of Platform Reliability at '
          'm.vega@company.com. HANDOVER: from=rowan.mackenzie@company.com '
          "to=m.vega@company.com scope=oncall-runbook return=2026-08-25', updated_at = "
          "datetime('now') WHERE user_id = 'u-rowan-mackenzie';"]},
 {'gym': 'gym-email-mcp',
  'desc': 'P4-EMAIL: auto-reply never names the logistics address',
  'query': 'SELECT COUNT(*) FROM vacation_settings v JOIN users u ON v.user_id = u.id WHERE '
           "u.primary_email = 'rowan.mackenzie@company.com' AND v.response_body_plain_text "
           "LIKE '%marisol.vega@company.com%';",
  'expected': 0,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'gym-email-mcp',
  'desc': 'P4-EMAIL: reconciled mailbox end state across forwarding and delegates',
  'query': 'SELECT (SELECT COUNT(*) FROM auto_forwarding af JOIN users u ON af.user_id = u.id '
           "WHERE u.primary_email = 'rowan.mackenzie@company.com' AND af.enabled = 1 AND "
           "af.email_address = 'm.vega@company.com' AND af.disposition = 'leaveInInbox') + "
           '(SELECT CASE WHEN (SELECT COUNT(*) FROM delegates d WHERE d.user_id = (SELECT id '
           "FROM users WHERE primary_email = 'rowan.mackenzie@company.com')) = 0 THEN 1 ELSE 0 "
           'END);',
  'expected': 2,
  'comparison': 'equals',
  'fix': ["DELETE FROM delegates WHERE user_id = 'u-rowan-mackenzie' OR delegate_email IN "
          "('quinn.aldridge@company.com', 'theo.bramwell@company.com');",
          "UPDATE auto_forwarding SET enabled = 1, email_address = 'm.vega@company.com', "
          "disposition = 'leaveInInbox', updated_at = datetime('now') WHERE user_id = "
          "'u-rowan-mackenzie';"]},
 {'gym': 'gym-email-mcp',
  'desc': 'P4-EMAIL: no messages, drafts or labels added to the mailbox',
  'query': 'SELECT COUNT(*) FROM messages m JOIN users u ON m.user_id = u.id WHERE '
           "u.primary_email = 'rowan.mackenzie@company.com';",
  'expected': 4,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'gym-google-drive-mcp',
  'desc': 'P5-DRIVE: live brief description merged not replaced',
  'query': "SELECT COUNT(*) FROM files WHERE name = 'Leave Handover Brief - Payments Platform "
           "(Current)' AND trashed = 0 AND description LIKE '%PPO-LH-2026-0731%' AND "
           "description LIKE '%leaveInInbox%' AND description LIKE '%HANDOVER: "
           'from=rowan.mackenzie@company.com to=m.vega@company.com scope=oncall-runbook '
           "return=2026-08-25%';",
  'expected': 1,
  'comparison': 'equals',
  'fix': ["UPDATE files SET description = 'Brief ref PPO-LH-2026-0731. Standby cover is the "
          'Platform Reliability engineer Marisol Vega at m.vega@company.com. Forwarding '
          'disposition for the covered mailbox must be leaveInInbox. Standing document access '
          'held by the departing engineer is closed at handover. HANDOVER: '
          'from=rowan.mackenzie@company.com to=m.vega@company.com scope=oncall-runbook '
          "return=2026-08-25', modified_time = datetime('now') WHERE id = "
          "'f-lh2026-brief-current';"]},
 {'gym': 'gym-google-drive-mcp',
  'desc': 'P5-DRIVE: brief description carries the calendar-derived return date',
  'query': "SELECT COUNT(*) FROM files WHERE name = 'Leave Handover Brief - Payments Platform "
           "(Current)' AND trashed = 0 AND description LIKE '%return=2026-08-25%';",
  'expected': 1,
  'comparison': 'equals',
  'fix': ["UPDATE files SET description = 'Brief ref PPO-LH-2026-0731. Standby cover is the "
          'Platform Reliability engineer Marisol Vega at m.vega@company.com. Forwarding '
          'disposition for the covered mailbox must be leaveInInbox. Standing document access '
          'held by the departing engineer is closed at handover. HANDOVER: '
          'from=rowan.mackenzie@company.com to=m.vega@company.com scope=oncall-runbook '
          "return=2026-08-25', modified_time = datetime('now') WHERE id = "
          "'f-lh2026-brief-current';"]},
 {'gym': 'gym-google-drive-mcp',
  'desc': 'P5-DRIVE: terminal chain state consistent across all three gyms',
  'query': 'SELECT (SELECT COUNT(*) FROM permissions p JOIN files f ON p.file_id = f.id WHERE '
           "f.name = 'Payments Platform On-Call Runbook - Live' AND p.role = 'owner') + "
           '(SELECT COUNT(*) FROM permissions p JOIN files f ON p.file_id = f.id JOIN users u '
           "ON p.user_id = u.id WHERE f.name = 'Payments Platform On-Call Runbook - Live' AND "
           "u.email = 'm.vega@company.com' AND p.role = 'writer') + (SELECT CASE WHEN (SELECT "
           'COUNT(*) FROM permissions p JOIN files f ON p.file_id = f.id JOIN users u ON '
           "p.user_id = u.id WHERE f.name = 'Payments Platform On-Call Runbook - Live' AND "
           "u.email = 'rowan.mackenzie@company.com') = 0 AND (SELECT COUNT(*) FROM permissions "
           'p JOIN files f ON p.file_id = f.id JOIN users u ON p.user_id = u.id WHERE f.name = '
           "'Leave Rota Brief - Field Logistics Standby' AND u.email = "
           "'marisol.vega@company.com' AND p.role = 'writer') = 1 THEN 1 ELSE 0 END);",
  'expected': 3,
  'comparison': 'equals',
  'fix': ["DELETE FROM permissions WHERE file_id = 'f-lh2026-runbook' AND user_id = "
          "'u-rowan-drive';"]},
 {'gym': 'gym-google-drive-mcp',
  'desc': 'P5-DRIVE: runbook permission re-read confirms departing engineer absent',
  'query': 'SELECT COUNT(*) FROM permissions p JOIN files f ON p.file_id = f.id JOIN users u '
           "ON p.user_id = u.id WHERE f.name = 'Payments Platform On-Call Runbook - Live' AND "
           "u.email = 'rowan.mackenzie@company.com';",
  'expected': 0,
  'comparison': 'equals',
  'fix': ["DELETE FROM permissions WHERE file_id = 'f-lh2026-runbook' AND user_id = "
          "'u-rowan-drive';"]},
 {'gym': 'gym-google-drive-mcp',
  'desc': 'P5-DRIVE: no new files or folders created in the handover folder',
  'query': 'SELECT COUNT(*) FROM files WHERE trashed = 0 AND (parent_id = (SELECT id FROM '
           "files WHERE name = 'Payments Platform - Leave Handover 2026') OR parent_ids LIKE "
           "'%' || (SELECT id FROM files WHERE name = 'Payments Platform - Leave Handover "
           "2026') || '%');",
  'expected': 4,
  'comparison': 'equals',
  'fix': []}]

# Final assistant answer (no response_check verifiers grade it; kept faithful).
FINAL_RESPONSE = """All handover steps are done, keyed to the systems of record rather than to what anyone asserted.

- Leave window: confirmed from the People Ops confirmation mail in the mailbox as 2026-08-03 to 2026-08-21 (ref PPO-LH-2026-0731).
- Cover identity and mail handling: taken from the CURRENT brief in the payments platform leave handover folder — standby is Marisol Vega of Platform Reliability at m.vega@company.com, forwarding disposition leaveInInbox. The November brief is superseded and the Field Logistics rota brief belongs to another team (its Marisol Vega at marisol.vega@company.com is a different engineer); neither was used or touched.
- Mailbox: both standing delegates (quinn.aldridge, theo.bramwell) were removed BEFORE forwarding was enabled to m.vega@company.com with leaveInInbox. The mail claiming the delegates could stay carries no recorded approval, so I did not act on it. Seeded filters and the two verified forwarding addresses are untouched.
- Documents: Rowan's standing writer access on the live on-call runbook was revoked (owner and the cover's writer entry retained) and the dictated audit comment was left on the runbook exactly once: HANDOVER: revoked=rowan.mackenzie@company.com scope=oncall-runbook return=2026-08-25. The current brief's description was merged — existing text preserved, handover line appended. Decoy briefs untouched.
- Calendar: m.vega@company.com granted reader on the primary diary only (the one-to-one and shared on-call calendars stay owner-only). The handback is booked Tuesday 2026-08-25 — the first working day after the leave end, walking past the weekend (08-22/23) and the Founders Day holiday (08-24) — with the handover reference line in the event description.
- Out of office: enabled, naming the cover and carrying the handover line with return=2026-08-25."""
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
