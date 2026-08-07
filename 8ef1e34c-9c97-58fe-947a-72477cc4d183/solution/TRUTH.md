# TRUTH — 8ef1e34c-9c97-58fe-947a-72477cc4d183

> Truth plan, derived from the bundle's **proven golden trajectory** and **grounding-checked** against it (every cited call and id verified present in the trajectory). **Never shown to a solver.**

`9` tool calls → `7` actions · trajectory `30/30` verifiers · grounding **VERIFIED**

## The job

Marcus asked to complete the RCA closure paperwork end-to-end for the recurring API-cluster outage tied to problem PRB0040001 and the Northwind Traders customer case, then reply to the customer on the original complaint thread. The traps: reply only to the genuine sender jordan.blake@northwind.com on the existing 'Recurring service outage - urgent' thread (not the newsletter thread), touch only the OPEN Northwind case (leave old Northwind cases alone), record resolution wording on the problem and the case, leave the child incident statuses untouched (worknotes only), close the problem BEFORE the customer case, and leave the unrelated problem alone. All work stays inside Marcus's own authenticated ITSM, CSM, and mailbox capabilities.

## Plan

### 1. Resolve the Northwind account and isolate the single open case

***discriminating read** — csm*

Look up the customer account 'Northwind Traders' by name to get account_id 8001, then search that account's cases to find the OPEN outage case CS0009001 (id 9001). This disambiguates the current case from the old Northwind cases that must be left alone, so we only touch the right record. Establishes the case id needed for the later resolution write.

**Discharges (user request):**
- “there's an open Northwind customer case tied to the same outage”
- “Leave alone ... the old Northwind cases”

**Grounded in (policy):**
- “a CSM Case agent role”
- “Case agent (org_acme)”

<details><summary>calls</summary>

- `P1-01` **find_account**
- `P1-02` **search_cases**  ← `account_id` read at `P1-01`

</details>

### 2. Discover the master and child incidents linked to PRB0040001

*read — itsm*

List incidents filtered by problem PRB0040001 to enumerate the master incident INC0050001 and the two node child incidents INC0050002 and INC0050003. This confirms exactly which child incidents get worknotes (and which statuses stay untouched) and grounds the closure work in the real linked records. Establishes ids for the ITSM writes.

**Discharges (user request):**
- “its master incident and the two node child incidents”
- “don't change the child incident statuses”

**Grounded in (policy):**
- “an ITSM Problem/Incident agent role”
- “Problem + Incident agent (org_acme)”

<details><summary>calls</summary>

- `P1-03` **list_incidents**

</details>

### 3. Resolve the problem first, recording the RCA fix wording

*write — itsm*

Update PRB0040001 to status resolved and record the root-cause resolution in fix_notes and worknotes (memory-leak permanent fix via patch v2.3 across affected nodes). Per the standard RCA procedure the problem must be closed before the customer case, so this write precedes the case resolution. Only PRB0040001 is touched — the unrelated problem is left alone.

**Must follow:**
- action 2 — Confirms PRB0040001 is the correct problem with its linked incidents before writing the resolution.

**Discharges (user request):**
- “record the resolution wording on the problem”
- “close the problem before the customer case”
- “Leave alone the unrelated problem”

**Grounded in (policy):**
- “an ITSM Problem/Incident agent role”
- “Problem + Incident agent (org_acme)”

<details><summary>calls</summary>

- `P1-04` **update_problem**

</details>

### 4. Add worknotes to both child incidents without changing their status

*write — itsm*

Annotate INC0050002 and INC0050003 with worknotes noting the link to PRB0040001 and the deployed permanent fix, passing only worknotes so their statuses remain unchanged. This satisfies the requirement to keep child incident statuses untouched while still recording the closure trail. The master incident is not modified.

**Must follow:**
- action 2 — Uses the child incident ids INC0050002/INC0050003 discovered from the problem link.
- action 3 — Worknotes reference the resolved problem, so the problem resolution is recorded first.

**Discharges (user request):**
- “keep the child incident statuses untouched”
- “don't change the child incident statuses”

**Grounded in (policy):**
- “an ITSM Problem/Incident agent role”
- “Problem + Incident agent (org_acme)”

<details><summary>calls</summary>

- `P1-05` **update_incident**  ← `incident_id` read at `P1-03`
- `P1-06` **update_incident**  ← `incident_id` read at `P1-03`

</details>

### 5. Resolve the open customer case after the problem, cross-referencing PRB0040001

*write — csm*

Update case 9001 to state resolved, record the resolution wording in the short_description with an explicit cross-reference to PRB0040001, and set closed_on. This runs only after the problem is closed, honoring the required RCA ordering. Only the open case is touched, leaving the old Northwind cases untouched.

**Must follow:**
- action 1 — Uses the confirmed open case id 9001 rather than an old Northwind case.
- action 3 — Policy requires the problem to be closed before the customer case.

**Discharges (user request):**
- “record the resolution wording on ... the customer case”
- “close the problem before the customer case”

**Grounded in (policy):**
- “a CSM Case agent role”
- “Case agent (org_acme)”

<details><summary>calls</summary>

- `P1-07` **update_case**

</details>

### 6. Locate the correct inbound complaint thread by subject

***discriminating read** — email*

Search Marcus's own mailbox for 'Recurring service outage' to identify the genuine complaint thread thr_001 from jordan.blake@northwind.com, confirming the sender. This disambiguates the real customer thread from the newsletter thread that must be left alone. Establishes the threadId needed to reply on the original thread.

**Discharges (user request):**
- “confirm who actually sent it”
- “Leave alone ... the newsletter thread in my inbox”

**Grounded in (policy):**
- “self-service ownership of his OWN email mailbox”
- “use userId 'me'”

<details><summary>calls</summary>

- `P1-08` **list_threads**

</details>

### 7. Send the resolution reply to the customer on the original thread

*write — email*

Reply on thread thr_001 as marcus.reed@acme.com to jordan.blake@northwind.com using an RFC2822 base64url raw message, notifying the customer that the outage is resolved. This is the final step after all ITSM/CSM records are recorded, and stays within Marcus's own mailbox self-service scope. Only the identified customer thread is used, not the newsletter.

**Must follow:**
- action 6 — Uses the confirmed thread id thr_001 and verified sender address.
- action 4 — Case is fully resolved before notifying the customer that everything is recorded.
- action 6 — Reply targets the genuine sender jordan.blake@northwind.com identified in the thread.

**Discharges (user request):**
- “send the reply back to the customer on the original thread”
- “reply to that same address on the thread”

**Grounded in (policy):**
- “Owns mailbox marcus.reed@acme.com; use userId 'me'”
- “Email is SELF-SERVICE: you may read and reply only within Marcus's own inbox”

<details><summary>calls</summary>

- `P1-09` **send_message**

</details>

