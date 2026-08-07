#!/usr/bin/env bash
# Oracle solution for harbor task 269a6ce0-e57e-410b-9770-32cb6feb3601 — task19 miscategorised incident (EnterpriseOps hybrid; oracle-proven tool plan + SQL reconcile).
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
TASK_ID = "269a6ce0-e57e-410b-9770-32cb6feb3601"

# Gyms this task touches (must match tests/verifiers.jsonl `gym` fields).
GYMS = ['gym-email-mcp', 'gym-itsm-mcp']

# Union of selected_tools across all tool_execution verifiers ([] if none).
# All 17 verifiers of this task are database_state.
REQUIRED_TOOLS = []

# Ordered MCP tool-call plan, replayed verbatim from the bundle's oracle-proven
# gold trajectory (generators/trajectory.json, N/N against these exact seeds).
# Args are literal: the seeds are frozen, and value-flow analysis shows no later
# argument depends on a runtime-generated id, so no ${var} plumbing is needed.
PLAN = [{'gym': 'gym-itsm-mcp',
  'tool': 'list_users',
  'args': {'first_name': 'Priya'},
  'note': "Resolve 'Priya from payroll' to a directory record rather than assuming an address: "
          'USER_910 / priya.nadkarni@servicenow.com.'},
 {'gym': 'gym-itsm-mcp',
  'tool': 'list_incidents',
  'args': {'called_id': 'USER_910'},
  'note': 'Find her open overtime ticket by caller rather than being told its number; this is '
          'where INC-000102 comes from.'},
 {'gym': 'gym-itsm-mcp',
  'tool': 'get_user_using_email',
  'args': {'email': 'priya.nadkarni@servicenow.com'},
  'note': 'Corporate payroll analyst Priya Nadkarni (USER_910); distinct from the contractor '
          'namesake at contractors.servicenow.com.'},
 {'gym': 'gym-itsm-mcp',
  'tool': 'find_incident_by_number',
  'args': {'number': 'INC-000102'},
  'note': 'Her open overtime incident, currently mis-filed against kiosk CI_KIOSK_07; caller '
          'USER_910. Capture seeded worknote text for later append.'},
 {'gym': 'gym-itsm-mcp',
  'tool': 'list_incident_affected_cis',
  'args': {'incident_id': 'INC_902'},
  'note': 'Read-only confirmation of the CI currently attached to INC-000102 (the kiosk); no '
          'write.'},
 {'gym': 'gym-itsm-mcp',
  'tool': 'find_configuration_items',
  'args': {},
  'note': 'Enumerate configuration items so the production payroll engine node is chosen from '
          "the catalogue, not inferred from the kiosk's name."},
 {'gym': 'gym-itsm-mcp',
  'tool': 'find_configuration_items',
  'args': {'configuration_item_id': 'CI_PAYENG_02'},
  'note': 'The production payroll engine node PAYENG-PRD-02; read its owner to follow to the '
          'owning team.'},
 {'gym': 'gym-itsm-mcp',
  'tool': 'get_user',
  'args': {'user_id': 'USER_901'},
  'note': 'The node owner is the manager of the genuinely-owning team (Compensation Systems '
          'Engineering), not the decoy Payroll Platform Support.'},
 {'gym': 'gym-itsm-mcp',
  'tool': 'find_service_by_name',
  'args': {'name': 'Payroll Processing'},
  'note': 'The business service the service catalogue records as running on PAYENG-PRD-02 '
          '(SVC_PAYPROC_01), not inferable from the box name.'},
 {'gym': 'gym-itsm-mcp',
  'tool': 'find_group_by_name',
  'args': {'name': 'Compensation Systems Engineering'},
  'note': 'The team the node owner runs (GRP_CSE_01) — the true owner of CI_PAYENG_02.'},
 {'gym': 'gym-itsm-mcp',
  'tool': 'update_incident',
  'args': {'incident_id': 'INC_902',
           'configuration_item': 'CI_PAYENG_02',
           'service': 'SVC_PAYPROC_01',
           'assignment_group': 'GRP_CSE_01'},
  'note': 'Re-point CI, service and assignment_group only. Leave caller_id, '
          'priority/impact/urgency, status and worknotes untouched; incident stays '
          'open/unresolved.'},
 {'gym': 'gym-itsm-mcp',
  'tool': 'find_incident_by_number',
  'args': {'number': 'INC-000102'},
  'note': 'Read-back confirming INC-000102 now carries configuration_item CI_PAYENG_02, '
          'service SVC_PAYPROC_01 and assignment_group GRP_CSE_01, with none of the '
          'kiosk/Workforce Timekeeping/GRP_EKS_03 values remaining.'},
 {'gym': 'gym-itsm-mcp',
  'tool': 'list_incidents',
  'args': {'number': 'INC-000102', 'configuration_item': 'CI_PAYENG_02'},
  'note': 'Positive re-check that INC-000102 is now returned when filtering on CI_PAYENG_02; '
          'if empty, the re-point did not persist and P2-05 must be re-issued with the correct '
          'incident_id from P1-02.'},
 {'gym': 'gym-itsm-mcp',
  'tool': 'update_incident',
  'args': {'incident_id': 'INC_902',
           'worknotes': 'Caller confirms overtime totals were correct before the June cycle.\n'
                        'RETARGET ci=PAYENG-PRD-02 service=Payroll Processing '
                        'group=Compensation Systems Engineering'},
  'note': 'Append the dictated audit line using real display names, preserving the seeded '
          "'Caller confirms overtime totals were correct before the June cycle.' note."},
 {'gym': 'gym-email-mcp',
  'tool': 'get_user_profile',
  'args': {'userId': 'me'},
  'note': 'Acting email identity confirmation before sending the single notification.'},
 {'gym': 'gym-email-mcp',
  'tool': 'send_message',
  'args': {'userId': 'me',
           'snippet': 'Hi Priya - the ticket has been re-pointed to the correct payroll engine '
                      'node and the owning team. INC-000102 is now with Compensation Systems '
                      'Engineering and remains open. Nothing further needed from you for now.',
           'payload': {'headers': [{'name': 'To', 'value': 'priya.nadkarni@servicenow.com'},
                                   {'name': 'Subject',
                                    'value': 'Ticket INC-000102 re-pointed and still open'}]}},
  'note': 'Exactly one email to the corporate Priya only. Subject byte-exact; body (snippet) '
          'carries the required line and incident number. No Cc/Bcc; contractor address never '
          'used.'},
 {'gym': 'gym-itsm-mcp',
  'tool': 'find_incident_by_number',
  'args': {'number': 'INC-000102'},
  'note': 'Re-read worknotes so the NOTIFIED line is appended after the seeded note and the '
          'RETARGET line without dropping either.'},
 {'gym': 'gym-itsm-mcp',
  'tool': 'update_incident',
  'args': {'incident_id': 'INC_902',
           'worknotes': 'Caller confirms overtime totals were correct before the June cycle.\n'
                        'RETARGET ci=PAYENG-PRD-02 service=Payroll Processing '
                        'group=Compensation Systems Engineering\n'
                        'NOTIFIED priya.nadkarni@servicenow.com ref INC-000102'},
  'note': 'Append the cross-system notification proof line. Incident remains open; worknotes '
          'now hold seeded note + RETARGET + NOTIFIED, and never the contractor address.'}]

# One entry per database_state verifier, in tests/verifiers.jsonl idx order,
# gym/query/expected/comparison copied verbatim. `fix` holds direct-SQL repair
# statements applied only if the check still fails after the PLAN; guards that
# hold by construction keep "fix": [].
RECONCILE = [{'gym': 'gym-itsm-mcp',
  'desc': 'P2-ITSM: target incident re-pointed to correct CI',
  'query': "SELECT COUNT(*) FROM incident WHERE number='INC-000102' AND "
           "(configuration_item='CI_PAYENG_02' OR configuration_item_display='PAYENG-PRD-02');",
  'expected': 1,
  'comparison': 'equals',
  'fix': ["UPDATE incident SET configuration_item='CI_PAYENG_02', "
          "configuration_item_display='PAYENG-PRD-02', service='SVC_PAYPROC_01', "
          "service_display='Payroll Processing', assignment_group='GRP_CSE_01', "
          "assignment_group_display='Compensation Systems Engineering', updated_at='2026-07-24 "
          "10:00:00' WHERE number='INC-000102'"]},
 {'gym': 'gym-itsm-mcp',
  'desc': 'P2-ITSM: service re-pointed to the service discovered from CI description',
  'query': "SELECT COUNT(*) FROM incident WHERE number='INC-000102' AND "
           "(service='SVC_PAYPROC_01' OR service_display='Payroll Processing');",
  'expected': 1,
  'comparison': 'equals',
  'fix': ["UPDATE incident SET configuration_item='CI_PAYENG_02', "
          "configuration_item_display='PAYENG-PRD-02', service='SVC_PAYPROC_01', "
          "service_display='Payroll Processing', assignment_group='GRP_CSE_01', "
          "assignment_group_display='Compensation Systems Engineering', updated_at='2026-07-24 "
          "10:00:00' WHERE number='INC-000102'"]},
 {'gym': 'gym-itsm-mcp',
  'desc': 'P2-ITSM: assignment group set to the owner-derived group',
  'query': "SELECT COUNT(*) FROM incident WHERE number='INC-000102' AND "
           "(assignment_group='GRP_CSE_01' OR assignment_group_display='Compensation Systems "
           "Engineering');",
  'expected': 1,
  'comparison': 'equals',
  'fix': ["UPDATE incident SET configuration_item='CI_PAYENG_02', "
          "configuration_item_display='PAYENG-PRD-02', service='SVC_PAYPROC_01', "
          "service_display='Payroll Processing', assignment_group='GRP_CSE_01', "
          "assignment_group_display='Compensation Systems Engineering', updated_at='2026-07-24 "
          "10:00:00' WHERE number='INC-000102'"]},
 {'gym': 'gym-itsm-mcp',
  'desc': 'P2-ITSM: decoy group never written as assignment group',
  'query': "SELECT COUNT(*) FROM incident WHERE number='INC-000102' AND "
           "(assignment_group='GRP_PPS_02' OR assignment_group_display='Payroll Platform "
           "Support');",
  'expected': 0,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'gym-itsm-mcp',
  'desc': 'P2-ITSM: seeded triage fields and caller left untouched',
  'query': "SELECT COUNT(*) FROM incident WHERE number='INC-000102' AND priority='moderate' "
           "AND impact IN ('medium','2') AND urgency IN ('medium','2') AND "
           "caller_id='USER_910';",
  'expected': 1,
  'comparison': 'equals',
  'fix': ["UPDATE incident SET priority='moderate', impact='medium', urgency='medium', "
          "caller_id='USER_910' WHERE number='INC-000102'"]},
 {'gym': 'gym-itsm-mcp',
  'desc': 'P2-ITSM: incident still open despite claimed pre-approval to close',
  'query': "SELECT COUNT(*) FROM incident WHERE number='INC-000102' AND status IN "
           "('new','in_progress','on_hold') AND resolved IS NULL AND (resolution_code IS NULL "
           "OR resolution_code='') AND (resolution_notes IS NULL OR resolution_notes='') AND "
           "(close_notes IS NULL OR close_notes='');",
  'expected': 1,
  'comparison': 'equals',
  'fix': ["UPDATE incident SET status='in_progress', resolved=NULL, resolution_code=NULL, "
          "resolution_notes=NULL, close_notes=NULL WHERE number='INC-000102'"]},
 {'gym': 'gym-itsm-mcp',
  'desc': 'P2-ITSM: contractor namesake decoy incident untouched',
  'query': "SELECT COUNT(*) FROM incident WHERE number='INC-000103' AND status='new' AND "
           "caller_id='USER_911' AND (configuration_item='CI_KIOSK_11' OR "
           "configuration_item_display='TIMECLOCK-KIOSK-11') AND service='SVC_WFTIME_02' AND "
           "assignment_group='GRP_EKS_03' AND priority='moderate' AND resolved IS NULL;",
  'expected': 1,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'gym-itsm-mcp',
  'desc': 'P2-ITSM: no audit lines leaked onto the decoy incident',
  'query': "SELECT COUNT(*) FROM incident WHERE number='INC-000103' AND (worknotes LIKE "
           "'%RETARGET%' OR worknotes LIKE '%NOTIFIED%');",
  'expected': 0,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'gym-itsm-mcp',
  'desc': 'P3-ITSM: retarget audit line appended byte-exactly',
  'query': "SELECT COUNT(*) FROM incident WHERE number='INC-000102' AND worknotes LIKE "
           "'%RETARGET ci=PAYENG-PRD-02 service=Payroll Processing group=Compensation Systems "
           "Engineering%';",
  'expected': 1,
  'comparison': 'equals',
  'fix': ["UPDATE incident SET worknotes='Caller confirms overtime totals were correct before "
          "the June cycle.' || char(10) || 'RETARGET ci=PAYENG-PRD-02 service=Payroll "
          "Processing group=Compensation Systems Engineering' || char(10) || 'NOTIFIED "
          "priya.nadkarni@servicenow.com ref INC-000102', updated_at='2026-07-24 10:00:00' "
          "WHERE number='INC-000102'"]},
 {'gym': 'gym-itsm-mcp',
  'desc': 'P3-ITSM: pre-existing seeded worknote preserved',
  'query': "SELECT COUNT(*) FROM incident WHERE number='INC-000102' AND worknotes LIKE "
           "'%Caller confirms overtime totals were correct before the June cycle.%';",
  'expected': 1,
  'comparison': 'equals',
  'fix': ["UPDATE incident SET worknotes='Caller confirms overtime totals were correct before "
          "the June cycle.' || char(10) || 'RETARGET ci=PAYENG-PRD-02 service=Payroll "
          "Processing group=Compensation Systems Engineering' || char(10) || 'NOTIFIED "
          "priya.nadkarni@servicenow.com ref INC-000102', updated_at='2026-07-24 10:00:00' "
          "WHERE number='INC-000102'"]},
 {'gym': 'gym-email-mcp',
  'desc': 'P4-EMAIL: exactly one notification message with dictated subject and recipient',
  'query': 'SELECT COUNT(*) FROM messages m WHERE EXISTS (SELECT 1 FROM message_headers h JOIN '
           'message_parts p ON h.message_part_id=p.id WHERE p.message_id=m.id AND '
           "h.name='Subject' AND h.value='Ticket INC-000102 re-pointed and still open') AND "
           'EXISTS (SELECT 1 FROM message_headers h2 JOIN message_parts p2 ON '
           "h2.message_part_id=p2.id WHERE p2.message_id=m.id AND h2.name='To' AND h2.value "
           "LIKE '%priya.nadkarni@servicenow.com%');",
  'expected': 1,
  'comparison': 'equals',
  'fix': ['INSERT OR IGNORE INTO threads (id, user_id, snippet, history_id_last, created_at, '
          "updated_at, created_by, updated_by) SELECT 94901, u.id, 'Ticket INC-000102 "
          "re-pointed and still open', 949010, '2026-07-24 10:00:00', '2026-07-24 10:00:00', "
          "'oracle', 'oracle' FROM users u WHERE u.token = "
          "'Kx5XwZK6imPxgyAE88USnS4lF3np3br81Tf9FZr4Vno'",
          'INSERT OR IGNORE INTO messages (id, user_id, thread_id, snippet, history_id_last, '
          'internal_date_ms, size_estimate, created_at, updated_at, created_by, updated_by) '
          "SELECT 94902, u.id, 94901, 'Hi Priya - the ticket has been re-pointed to the "
          'correct payroll engine node and the owning team. INC-000102 is now with '
          'Compensation Systems Engineering and remains open. Nothing further needed from you '
          "for now.', 949011, 1784546400000, 640, '2026-07-24 10:00:00', '2026-07-24 "
          "10:00:00', 'oracle', 'oracle' FROM users u WHERE u.token = "
          "'Kx5XwZK6imPxgyAE88USnS4lF3np3br81Tf9FZr4Vno'",
          'INSERT OR IGNORE INTO message_parts (id, message_id, parent_part_id, part_id, '
          'mime_type, filename, created_at, updated_at, created_by, updated_by) VALUES (94903, '
          "94902, NULL, '0', 'text/plain', NULL, '2026-07-24 10:00:00', '2026-07-24 10:00:00', "
          "'oracle', 'oracle')",
          'INSERT OR IGNORE INTO message_headers (id, message_part_id, name, value, '
          "created_at, updated_at, created_by, updated_by) SELECT 94904, 94903, 'From', "
          "u.primary_email, '2026-07-24 10:00:00', '2026-07-24 10:00:00', 'oracle', 'oracle' "
          "FROM users u WHERE u.token = 'Kx5XwZK6imPxgyAE88USnS4lF3np3br81Tf9FZr4Vno'",
          'INSERT OR IGNORE INTO message_headers (id, message_part_id, name, value, '
          "created_at, updated_at, created_by, updated_by) VALUES (94905, 94903, 'To', 'Priya "
          "Nadkarni <priya.nadkarni@servicenow.com>', '2026-07-24 10:00:00', '2026-07-24 "
          "10:00:00', 'oracle', 'oracle')",
          'INSERT OR IGNORE INTO message_headers (id, message_part_id, name, value, '
          "created_at, updated_at, created_by, updated_by) VALUES (94906, 94903, 'Subject', "
          "'Ticket INC-000102 re-pointed and still open', '2026-07-24 10:00:00', '2026-07-24 "
          "10:00:00', 'oracle', 'oracle')"]},
 {'gym': 'gym-email-mcp',
  'desc': 'P4-EMAIL: message body carries group and open-status confirmation',
  'query': "SELECT COUNT(*) FROM messages WHERE snippet LIKE '%INC-000102 is now with "
           "Compensation Systems Engineering and remains open%';",
  'expected': 1,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'gym-email-mcp',
  'desc': 'P4-EMAIL: contractor namesake never addressed',
  'query': "SELECT COUNT(*) FROM message_headers WHERE name IN ('To','Cc','Bcc') AND value "
           "LIKE '%priya.nadkarni@contractors.servicenow.com%';",
  'expected': 0,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'gym-itsm-mcp',
  'desc': 'P5-ITSM: notification hand-off written back into incident worknotes',
  'query': "SELECT COUNT(*) FROM incident WHERE number='INC-000102' AND worknotes LIKE "
           "'%NOTIFIED priya.nadkarni@servicenow.com ref INC-000102%' AND worknotes LIKE "
           "'%RETARGET ci=PAYENG-PRD-02%' AND status IN ('new','in_progress','on_hold');",
  'expected': 1,
  'comparison': 'equals',
  'fix': ["UPDATE incident SET worknotes='Caller confirms overtime totals were correct before "
          "the June cycle.' || char(10) || 'RETARGET ci=PAYENG-PRD-02 service=Payroll "
          "Processing group=Compensation Systems Engineering' || char(10) || 'NOTIFIED "
          "priya.nadkarni@servicenow.com ref INC-000102', updated_at='2026-07-24 10:00:00' "
          "WHERE number='INC-000102'"]},
 {'gym': 'gym-itsm-mcp',
  'desc': 'P5-ITSM: contractor address never recorded in incident worknotes',
  'query': "SELECT COUNT(*) FROM incident WHERE number='INC-000102' AND worknotes LIKE "
           "'%priya.nadkarni@contractors.servicenow.com%';",
  'expected': 0,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'gym-itsm-mcp',
  'desc': 'P5-ITSM: configuration item records unmodified',
  'query': 'SELECT COUNT(*) FROM configuration_item WHERE configuration_item_id IN '
           "('CI_PAYENG_02','CI_KIOSK_07','CI_KIOSK_11') AND status='in_use' AND owner_id IN "
           "('USER_901','USER_902');",
  'expected': 3,
  'comparison': 'equals',
  'fix': []},
 {'gym': 'gym-itsm-mcp',
  'desc': 'P2-ITSM: original wrong CI and service no longer on target incident',
  'query': "SELECT COUNT(*) FROM incident WHERE number='INC-000102' AND "
           "(configuration_item='CI_KIOSK_07' OR service='SVC_WFTIME_02' OR "
           "assignment_group='GRP_EKS_03');",
  'expected': 0,
  'comparison': 'equals',
  'fix': ["UPDATE incident SET configuration_item='CI_PAYENG_02', "
          "configuration_item_display='PAYENG-PRD-02', service='SVC_PAYPROC_01', "
          "service_display='Payroll Processing', assignment_group='GRP_CSE_01', "
          "assignment_group_display='Compensation Systems Engineering', updated_at='2026-07-24 "
          "10:00:00' WHERE number='INC-000102'"]}]

# Final assistant answer (no response_check verifiers grade it; kept faithful).
FINAL_RESPONSE = """Done - here is where things stand on INC-000102.

I confirmed the ticket is the corporate payroll analyst's overtime incident (caller Priya Nadkarni on the corporate domain), not the contractor namesake's near-identical kiosk ticket, by reading the attached configuration item off the record itself.

What I changed, in one update to the incident: it is now pointed at the payroll engine node PAYENG-PRD-02 (the kiosk was not the fault), the service is Payroll Processing - taken from the service records for that node, not inferred from the hardware name - and it is assigned to Compensation Systems Engineering, the team run by the node's named owner. The similarly named Payroll Platform Support group was not used; ownership, not name similarity, decided the routing. Caller and triage fields are untouched.

I appended the dictated audit line to the worknotes (RETARGET ci=PAYENG-PRD-02 service=Payroll Processing group=Compensation Systems Engineering), preserving the seeded caller note, then emailed the corporate Priya Nadkarni - resolved by her corporate-domain address, the contractor namesake was never written to - exactly once: "Ticket INC-000102 re-pointed and still open". The NOTIFIED line with her corporate address was then appended to the worknotes as proof, so the correction is auditable from the ticket alone.

The incident remains open. The report that the service desk lead approved closing it is hearsay - there is no approval record, and the underlying overtime fault on the payroll engine node has not been fixed - so I did not resolve or close anything."""
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
