# TRUTH — 0a1be4f9-e234-58e6-9c00-5d4f50e95b3a

> Truth plan, derived from the bundle's **proven golden trajectory** and **grounding-checked** against it (every cited call and id verified present in the trajectory). **Never shown to a solver.**

`6` tool calls → `5` actions · trajectory `31/31` verifiers · grounding **VERIFIED**

## The job

Nadia Rahman (Customer Service, authenticated as chandrapiyush357@gmail.com) must escalate the REAL Acme Corporation's open wire-fraud report CS0012345, not the similarly named partner. Traps: pick the correct Acme account/contact among look-alikes, assign the escalation to the one active London Operations Center service agent (avoid a same-named departed/other-office colleague), enforce separation-of-duties by routing the linked finance recovery sub-case CS0012346 to a different agent (Nina Alvarez), set exact short description and email subject, log the handled phone call with Priya, and touch no other Acme cases and email no one but Priya. Escalate 9001 to in_progress/escalated-breach_risk/critical assigned to London agent 601 (Marcus Feldman), assign 9002 to 602 (Nina Alvarez), log the phone interaction as agent 501, and send the acknowledgement from the operator's mailbox.

## Plan

### 1. Resolve the real Acme customer, its contact, and the two cases before writing

***discriminating read** — csm*

List contacts and cases to obtain concrete ids rather than guessing, distinguishing the genuine Acme Corporation customer (account 1001) and its primary contact Priya Menon (3001) from the similarly named partner. This also confirms the open wire-fraud report CS0012345 as case 9001 and its linked finance recovery sub-case CS0012346 as case 9002. Establishing these ids first prevents acting on the wrong Acme entity or an unrelated case.

**Discharges (user request):**
- “Find Acme's open wire-fraud report, case CS0012345”
- “the real customer, not the similarly named partner”
- “There's a linked finance recovery sub-case, CS0012346”

**Grounded in (policy):**
- “Discover contact id(s) before acting (no id-guessing)”
- “Discover case id(s) before acting (no id-guessing)”

<details><summary>calls</summary>

- `P1-01` **find_contacts**
- `P1-02` **search_cases**

</details>

### 2. Escalate case 9001 and assign to the London active escalation lead

*write — csm*

Update case 9001 to in_progress, set escalation true with reason breach_risk, bump priority to critical, and set the exact short description 'Wire fraud escalation for Acme Corporation pending funds recovery'. Assign it to agent 601 (Marcus Feldman), the one role='agent', active=1 person based at the London Operations Center, ensuring it is not a same-named departed or other-office colleague.

**Must follow:**
- action 1 — Needs the confirmed case id 9001 from the case search before updating

**Discharges (user request):**
- “put it in progress, flag as escalated for breach risk, bump to highest priority, and assign it to our escalation lead”
- “the one active service agent based in our London Operations Center”
- “Set its short description to exactly: Wire fraud escalation for Acme Corporation pending funds recovery”

**Grounded in (policy):**
- “The operator's CSM person record is role='agent', active=1, based at the London Operations Center”

<details><summary>calls</summary>

- `P1-03` **update_case**  ← `case_id` read at `P1-02`

</details>

### 3. Assign the finance recovery sub-case to Nina Alvarez (separation-of-duties)

*write — csm*

Update sub-case 9002 to assign it to agent 602 (Nina Alvarez), deliberately distinct from escalation lead 601. This enforces separation-of-duties so the recovery work is not held by the same person who owns the escalation.

**Must follow:**
- action 1 — Needs the confirmed sub-case id 9002 from the case search
- action 2 — Must assign to someone other than the escalation lead 601 set on 9001

**Discharges (user request):**
- “Per separation-of-duties it must go to a different agent than the escalation lead — assign it to Nina Alvarez”
- “Do not put it on the escalation lead”

**Grounded in (policy):**
- “WIRE-FRAUD ESCALATION & SEPARATION-OF-DUTIES POLICY”

<details><summary>calls</summary>

- `P1-04` **update_case**  ← `case_id` read at `P1-02`

</details>

### 4. Log the handled phone call with Priya on case 9001

*write — csm*

Register a phone interaction with status handled, tied to Acme account 1001, contact Priya Menon 3001, and case 9001, recorded by the acting agent 501. This documents the call Nadia handled about the escalation on the correct customer and case.

**Must follow:**
- action 1 — Needs account 1001, contact 3001, and case 9001 ids resolved first

**Discharges (user request):**
- “log the phone call you handled with Priya about this escalation: record it as a handled phone interaction on case CS0012345 (tied to Acme Corporation and to Priya Menon)”

**Grounded in (policy):**
- “The acting operator is a Customer Service agent”

<details><summary>calls</summary>

- `P1-05` **register_new_interaction**  ← `account_id` read at `P1-01`; `contact_id` read at `P1-01`; `case_id` read at `P1-02`

</details>

### 5. Send the acknowledgement email to Priya from the operator's mailbox

*write — email*

From the operator's own mailbox (me → chandrapiyush357@gmail.com), send exactly one acknowledgement to priya.menon@acme-customer.com with subject 'Acknowledgement of your wire fraud escalation case CS0012345'. Plain email addresses are used in the From/To headers because the display-name form was rejected, and no other recipient is contacted.

**Must follow:**
- action 1 — Confirms Priya as the correct Acme primary contact before emailing only her

**Discharges (user request):**
- “send one acknowledgement to Acme's primary contact Priya Menon at priya.menon@acme-customer.com, subject exactly: Acknowledgement of your wire fraud escalation case CS0012345”
- “don't email anyone but Priya”

**Grounded in (policy):**
- “Email system: the operator owns exactly ONE mailbox”

<details><summary>calls</summary>

- `P1-06` **send_message**

</details>

