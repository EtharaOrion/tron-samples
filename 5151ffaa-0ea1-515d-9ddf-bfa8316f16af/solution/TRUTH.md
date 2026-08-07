# TRUTH — 5151ffaa-0ea1-515d-9ddf-bfa8316f16af

> Truth plan, derived from the bundle's **proven golden trajectory** and **grounding-checked** against it (every cited call and id verified present in the trajectory). **Never shown to a solver.**

`10` tool calls → `7` actions · trajectory `30/30` verifiers · grounding **VERIFIED**

## The job

For CONFIRMED breach INC0101010 exposing employee laura.bennett@techcorp.com (ITSM user 4501, HR user 4501 — one of several same-named decoys), run DPR-1 end to end AS Daniel Cross. First a Gate-1 idempotency check: if the incident is resolved/closed/canceled, post only the halt work note and stop; otherwise classify+route to Security Incident Response, resolve the exact Laura Bennett, read the runbook to get the mandated privacy-case wording and the delegate address (never invented), open the HR privacy case, cross-link incident and case, and send exactly one plain-text breach notification from Daniel's own mailbox to ir.delegate@techcorp-secure.io with the fixed subject, citing both INC0101010 and the new HRC number, with no CC. Traps: terminal-state halt, name-collision disambiguation, delegate address must come from the KB, and breach details confined to where the runbook allows.

## Plan

### 1. Gate-1: confirm the incident is not in a terminal state

*read — itsm*

Read INC0101010 live to verify its status is not resolved, closed, or canceled before any response step runs. This is the idempotency gate that decides whether to halt with the fixed work note or proceed with the full runbook. It must precede every write.

**Discharges (user request):**
- “First, re-check the live status of INC0101010. If it's already resolved, closed, or cancelled, do NOT run any response steps”
- “just post this exact work note and stop”

**Grounded in (policy):**
- “You are the automation agent acting on behalf of Daniel Cross, a Security Incident Response Agent”

<details><summary>calls</summary>

- `P1-01` **find_incident_by_number**

</details>

### 2. Discover the IR group id and Sent label id

*read — itsm*

Resolve the Security Incident Response assignment group id (grp_sec_ir) in ITSM and the Sent label id (lbl_sent_daniel) in Email, since IDs are not portable across systems and each must be resolved in its owning domain. These lookups feed the routing write and the later notification send. No records are modified here.

**Must follow:**
- action 1 — Only gather routing/label ids once the gate confirms we proceed past Gate-1

**Discharges (user request):**
- “classify and route the incident to our security response team”

**Grounded in (policy):**
- “IDs are NOT portable between systems — a person has a different internal id in each domain and you must resolve each one in the owning system”

<details><summary>calls</summary>

- `P1-02` **find_group_by_name**
- `P1-03` **list_labels**

</details>

### 3. Classify, route, and worknote the incident, ensuring assignee membership

*write — itsm*

Set INC0101010 to in_progress with critical priority, high impact/urgency, assign to usr_daniel_cross under grp_sec_ir, and add a work note citing user 4501 and INC0101010. Then add usr_daniel_cross to grp_sec_ir so the assignee is a valid member of the response group. This performs the runbook's classification and routing to the security response team.

**Must follow:**
- action 1 — Only route if Gate-1 confirmed the incident is live
- action 2 — Uses grp_sec_ir resolved in the discovery step

**Discharges (user request):**
- “classify and route the incident to our security response team”
- “Otherwise run the whole runbook”

**Grounded in (policy):**
- “Daniel Cross | usr_daniel_cross | admin_token_daniel_2024_secure”

<details><summary>calls</summary>

- `P1-04` **update_incident**
- `P1-05` **add_new_group_member**  ← `group_id` read at `P1-02`

</details>

### 4. Disambiguate the exact Laura Bennett (HR user 4501)

***discriminating read** — hr*

Search HR by email fragment laura.bennett and by last name Bennett ordered by user_id to distinguish the real TechCorp employee laura.bennett@techcorp.com (user 4501) from same-named decoys. This ensures opened_for on the privacy case resolves unambiguously to the correct person. Both reads together pin the identity before any HR write.

**Must follow:**
- action 1 — Proceed with employee resolution only past the Gate-1 halt

**Discharges (user request):**
- “affected employee is laura.bennett@techcorp.com (only that person — there are others with the same name in our directory)”

**Grounded in (policy):**
- “a person has a different internal id in each domain and you must resolve each one in the owning system”

<details><summary>calls</summary>

- `P1-06` **list_users**
- `P1-07` **list_users**

</details>

### 5. Read the DPR-1 runbook for exact wording and delegate address

*read — itsm*

Retrieve KB0007001 (the DPR-1 runbook) to confirm the exact privacy-case short_description wording and the incident-response delegate notification address (ir.delegate@techcorp-secure.io). This guarantees the notification target is taken from the runbook and not invented. It must precede creating the case and sending the email.

**Must follow:**
- action 1 — Only read/execute runbook steps if not halted at Gate-1

**Discharges (user request):**
- “Read it first and follow it exactly; it gives the incident-response delegate's notification address and the wording to use, so don't invent an address”

**Grounded in (policy):**
- “You are the automation agent acting on behalf of Daniel Cross, a Security Incident Response Agent who additionally holds the HR Administrator role”

<details><summary>calls</summary>

- `P1-08` **retrieve_knowledge_articles**

</details>

### 6. Open the required privacy case for the employee

*write — hr*

Create the HR privacy case with the runbook's short_description, coe_type Workforce Administration, status work_in_progress, priority high, opened_for the resolved Laura Bennett (4501), assigned to and opened_by Daniel (3001), with work notes citing INC0101010 and the breach. This yields HRC0009001, which links back to the incident. Breach detail lives here per the runbook.

**Must follow:**
- action 4 — opened_for must be the disambiguated user 4501, not a decoy
- action 5 — short_description wording comes from the runbook body

**Discharges (user request):**
- “open the required privacy case for the employee”
- “link the incident and case to each other”
- “Keep the actual breach details only where the runbook says they belong”

**Grounded in (policy):**
- “who additionally holds the HR Administrator role”

<details><summary>calls</summary>

- `P1-09` **create_new_hr_case**

</details>

### 7. Send the single breach notification from Daniel's own mailbox

*write — email*

Send one plain-text email from Daniel's own mailbox (userId me) to the runbook delegate ir.delegate@techcorp-secure.io with subject exactly 'TechCorp Data Breach Response Notification', body referencing INC0101010 and HRC0009001 and containing the word breach, tagged with lbl_sent_daniel and no CC. From resolves to Daniel per the acting-identity policy. This is the sole required notification and completes the cross-linking.

**Must follow:**
- action 2 — Uses the Sent label id lbl_sent_daniel resolved in discovery
- action 5 — Delegate address must be the runbook-sourced ir.delegate@techcorp-secure.io
- action 6 — Body must cite the newly created privacy case HRC0009001

**Discharges (user request):**
- “send the single required notification from my own mailbox to the delegate named in the runbook”
- “subject exactly "TechCorp Data Breach Response Notification”
- “body referencing both the incident number and the new privacy case number and including the word breach”
- “don't copy anyone else on that email”

**Grounded in (policy):**
- “You are Daniel Cross <daniel.cross@techcorp.com>. Your session is authenticated as this account; your token belongs to it, and primary/me resolve to it.”

<details><summary>calls</summary>

- `P1-10` **send_message**

</details>

