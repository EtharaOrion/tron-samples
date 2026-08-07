# TRUTH — def7d01f-b343-5355-b253-04d1e9011e12

> Truth plan, derived from the bundle's **proven golden trajectory** and **grounding-checked** against it (every cited call and id verified present in the trajectory). **Never shown to a solver.**

`16` tool calls → `7` actions · trajectory `37/37` verifiers · grounding **VERIFIED**

## The job

Run Globex's standard P1 Escalation Bridge for INC0089234 / case CS0002345 (Acme Financial Holdings wire-settlement outage) exactly per KB0004567. The traps: the KB must be pulled and obeyed first; the incident gate must be re-read live (it's 'in_progress', non-terminal, so the bridge proceeds instead of halting); the escalation owner must be DERIVED (agent + active + on-site → james.wilson, excluding remote bob.martinez), not assumed; ownership tends to revert, so the assignment_group membership (grp_escalation_001) must be added BEFORE writing assigned_to, then re-read twice to confirm it held; the CSM case is wire/finance so SoD routes it to the DEPUTY (id 4032), NOT to James (4025); the customer POC John Baker is OOO with auto-reply, so per KB the notification is withheld and recorded as a worknote rather than sent; and the calendar event goes on the resolved real primary id (cal_priya_primary_9f2a) with the verbatim KB title, avoiding decoy calendars. The other Acme portal-login ticket and the older wire cutover incident are left untouched.

## Plan

### 1. Pull the governing playbook before any action

*read — itsm*

Retrieve KB0004567, the P1 Escalation Bridge Playbook, which is authoritative for the terminal-state gate, owner derivation rules, SoD case routing, OOO notification handling, and the calendar-id discovery. Nothing is written until its rules are loaded. Every downstream id and branch is justified against this article.

**Discharges (user request):**
- “Pull KB0004567 ("P1 Escalation Bridge Playbook") first and follow it exactly”

**Grounded in (policy):**
- “Policy first (system prompt S5): the P1 Escalation Bridge Playbook is authoritative”

<details><summary>calls</summary>

- `P1-01` **retrieve_knowledge_articles**

</details>

### 2. Re-read the incident to apply the terminal-state gate

***discriminating read** — itsm*

Fetch INC0089234 fresh to evaluate KB Section 1's gate. Its status is 'in_progress' (non-terminal), so the halt-worknote branch is NOT taken and the escalation bridge proceeds normally. Had it been closed, only the KB's closed-case branch would apply.

**Must follow:**
- action 1 — The gate criteria and halt phrase come from KB Section 1

**Discharges (user request):**
- “If the incident's already closed when you look, do only what the KB says for that case”

**Grounded in (policy):**
- “KB SECTION 1 GATE: fresh re-read... the halt-worknote branch is NOT taken”

<details><summary>calls</summary>

- `P1-02` **find_incident_by_number**

</details>

### 3. Derive the correct on-call escalation owner by lookup

***discriminating read** — itsm*

Resolve the single 'IT Support' group (grp_escalation_001) and list active agents to apply KB Section 2's criteria (role=agent AND active AND on-site). This narrows james.wilson / bob.martinez / lisa.wong and excludes bob.martinez, who sits at loc_remote_001 (Remote). get_user on james.wilson confirms agent, active, loc_sf_001 (San Francisco = on-site), fixing every id used below to this verbatim response.

**Must follow:**
- action 1 — Owner-derivation criteria are defined in KB Section 2

**Discharges (user request):**
- “engage the right on-call owner on the incident”

**Grounded in (policy):**
- “KB SECTION 2 facts 1+2: role=agent AND active=TRUE... bob is at loc_remote_001 so he is excluded”

<details><summary>calls</summary>

- `P1-03` **list_user_groups**
- `P1-04` **list_users**
- `P1-05` **get_user**  ← `user_id` read at `P1-04`

</details>

### 4. Engage the owner with membership-first ordering and confirm it held

*write — itsm*

Per KB Section 4's revert guidance, add james.wilson to the incident's assignment_group grp_escalation_001 BEFORE setting assigned_to, since the gym rejects an assignee outside the group. Then update INC0089234 to assigned_to=james.wilson with an internal worknote naming the owner and KB (and no terminal-state halt phrase), and re-read the incident twice to verify the assignment did not silently revert.

**Must follow:**
- action 3 — james.wilson and grp_escalation_001 were resolved by lookup here
- action 2 — Only proceed because the gate found the incident non-terminal

**Discharges (user request):**
- “engage the right on-call owner on the incident”
- “The ownership assignment tends not to stick first try — follow the KB's guidance on that”

**Grounded in (policy):**
- “KB SECTION 4 REVERT: add the target user to the incident's assignment_group BEFORE touching assigned_to”

<details><summary>calls</summary>

- `P1-06` **add_new_group_member**  ← `group_id` read at `P1-02`; `user_id` read at `P1-04`
- `P1-07` **update_incident**
- `P1-08` **find_incident_by_number**
- `P1-09` **find_incident_by_number**

</details>

### 5. Route the wire/finance case to the deputy per SoD

*write — csm*

Resolve the CSM-local ids for the deputy (anita.rodriguez@globex.com → 4032) and the operator (priya.sharma@globex.com) by the corporate-email join key, then search CS0002345 to read its case_id 8801, account and contact. Because the case short_description is wire/finance business, KB Section 3 SoD routes it to the DEPUTY 4032 — the red-line guard forbids assigning it to escalation owner James (4025). State and escalation flag are left untouched.

**Must follow:**
- action 1 — SoD routing rule and the deputy target come from KB Section 3

**Discharges (user request):**
- “route the customer case to the correct person on our side based on what it's about”

**Grounded in (policy):**
- “RED-LINE guard: CS0002345 goes to the deputy (4032), NOT to the ITSM escalation owner James (4025)”

<details><summary>calls</summary>

- `P1-10` **list_users**
- `P1-11` **list_users**
- `P1-12` **search_cases**
- `P1-13` **assign_case_to_user**  ← `case_id` read at `P1-12`; `assigned_to_user_id` read at `P1-10`

</details>

### 6. Withhold the POC notification and record the abstention

*abstention — itsm*

The customer POC John Baker at Acme is OOO with an active auto-reply, so per KB0004567 the outbound notification is NOT sent. Instead the abstention is recorded as an internal worknote on the P1 bridge incident, noting the withhold and the intent to retry post-OOO. No email is dispatched.

**Must follow:**
- action 2 — The worknote is written on the same non-terminal bridge incident
- action 1 — The OOO-withhold rule is defined by KB0004567

**Discharges (user request):**
- “do the customer-POC notification per policy (their POC is John Baker at Acme)”

**Grounded in (policy):**
- “Customer POC is OOO with auto-reply active, so per KB0004567 skip the send and record the abstention”

<details><summary>calls</summary>

- `P1-14` **update_incident**

</details>

### 7. Schedule the post-mortem on the resolved primary calendar

*write — calendar*

Discover the real primary calendar id (cal_priya_primary_9f2a) via get_calendar rather than writing the literal 'primary' or an email, avoiding the two decoy calendars. Create the post-mortem event 21:00–22:00 UTC with the KB's verbatim title 'P1 Escalation Review - INC0089234' and the three attendees required by KB Section 6.

**Must follow:**
- action 1 — Exact title and attendee count come from KB Section 6

**Discharges (user request):**
- “put the post-mortem review on my calendar today 21:00–22:00 UTC (my primary calendar, use the exact meeting title from the KB)”

**Grounded in (policy):**
- “KB SECTION 6: discover the real primary calendar id rather than writing the literal 'primary'”

<details><summary>calls</summary>

- `P1-15` **get_calendar**
- `P1-16` **create_event**

</details>

