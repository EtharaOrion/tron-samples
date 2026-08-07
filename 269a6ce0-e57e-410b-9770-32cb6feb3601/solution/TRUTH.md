# TRUTH — task19_miscategorised_incident

> Truth plan, derived from the bundle's oracle-proven trajectory and checked against it by the K-code fidelity gate. **Never shown to a solver.**

`15` tool calls → `7` actions · trajectory `17/17` verifiers · fidelity gate **PASS**

## The job

A payroll analyst's incident about missing overtime hours is filed against a timeclock kiosk, but the real fault is on the production payroll engine node, so the ticket must be re-pointed to that node, to the business service the service catalogue records as running on it, and to the team owned by that node's owner. After the re-point, a dictated RETARGET audit line goes into the worknotes, a single notification email goes to the corporate Priya Nadkarni (not her contractor namesake), and a NOTIFIED line is appended to the worknotes as proof. The incident stays open throughout — the hearsay that the service desk lead approved closing it is not an approval record and the fault itself is untouched.

## Plan

### 1. Confirm which configuration item the overtime ticket is actually attached to today before changing anything

***discriminating read** — itsm*

The requester says the ticket is on 'TIMECLOCK-KIOSK-07', but there are two near-identical overtime tickets in flight — the corporate analyst's and the contractor's, each against a different kiosk. Reading the attached CI off the incident itself establishes that this record carries the kiosk CI the requester described, so the re-point that follows lands on the corporate ticket and not the contractor's genuinely-kiosk-related one. Assuming the CI from the prompt text would leave no evidence that the right record was selected.

**Discharges (user request):**
- “The ticket is currently filed against the kiosk 'TIMECLOCK-KIOSK-07'”

**Grounded in (policy):**
- “Before writing to any record you confirm you have the right one using at least one secondary key beyond the shared attribute.”

<details><summary>calls</summary>

- `P1-03` **list_incident_affected_cis**  ← `incident_id` read at `P1-02`

</details>

### 2. Follow the payroll engine node's owner record through to the person who manages the owning team

***discriminating read** — itsm*

This is where the routing trap sits. There is a group whose name contains 'payroll' — Payroll Platform Support — which looks like the obvious destination for a payroll complaint, and a second team, Compensation Systems Engineering, which is the one the node's named owner actually manages. Resolving the owner's user record is what distinguishes them: the chain runs node record to owner to the team that owner runs, so name similarity never enters the decision. Reading this before the update means the assignment group written later is derived, not guessed.

**Discharges (user request):**
- “the team that genuinely owns that node rather than the one whose name happens to have "payroll" in it”
- “The node's own record will tell you who owns it and that person runs the team it should go to.”

**Grounded in (policy):**
- “The assignment group for an incident is derived from ownership, not from name similarity.”

<details><summary>calls</summary>

- `P2-02` **get_user**  ← `user_id` read at `P2-01`

</details>

### 3. Re-point the incident onto the payroll engine node, the service the catalogue says runs there, and the team that owns the node

*write — itsm*

This is the substantive correction. Three lookups feed it: the incident's own record (for its internal identifier and its seeded worknote text, which must survive later appends), the payroll engine node, the business service the service records state runs on that node — deliberately looked up by what the catalogue says rather than inferred from the box's name — and the group resolved from the owner in the previous action. All three fields are changed in one write, and nothing else is: the caller stays the corporate analyst, triage attributes stay as found, and the status stays open because re-routing is an administrative correction, not a fix. Doing this before the worknote append matters because the audit line asserts the values now present on the record.

**Must follow:**
- action 1 — The attached-CI check identifies this as the corporate ticket rather than the contractor's look-alike, so it must clear before any field on it is written.
- action 2 — The assignment group written here is the team resolved from the node owner's user record; without that read the group would be a name-similarity guess.

**Discharges (user request):**
- “that ticket to end up pointed at the right hardware”
- “don't go by the name of the box, check what the service catalogue says runs there”

**Grounded in (policy):**
- “The service on an incident is the service that the service records themselves state runs on that configuration item - it is never inferred from the configuration item's name”
- “you change only the fields the work requires”
- “Re-pointing, re-assigning or annotating an incident leaves it in its current open state.”

<details><summary>calls</summary>

- `P1-02` **find_incident_by_number**
- `P2-01` **find_configuration_items**
- `P2-03` **find_service_by_name**
- `P2-04` **find_group_by_name**
- `P2-05` **update_incident**  ← `incident_id` read at `P1-02`, `configuration_item` read at `P2-01`, `service` read at `P2-03`, `assignment_group` read at `P2-04`

</details>

### 4. Verify the re-point actually landed, then append the dictated RETARGET audit line to the worknotes

*write — itsm*

A multi-field update can report success while silently dropping a field, which would leave the ticket half on the kiosk and half on the node. Re-reading the incident confirms all three new values are present and none of the kiosk, Workforce Timekeeping or Endpoint Kiosk Support values remain; filtering the incident list by the new configuration item is a second, positive check that the change persisted and is queryable — if it came back empty the update would have to be re-issued. Only once that holds is the audit line written, in the exact dictated shape, using the display names as the systems hold them rather than internal identifiers. The append carries the pre-existing seeded worknote forward verbatim, since worknotes are append-only.

**Must follow:**
- action 3 — The audit line records the values the re-point set, so the re-point must have happened and been confirmed before the line asserting it is written.

**Discharges (user request):**
- “drop a line into the ticket's worknotes in exactly this shape so the audit lot can grep for it”
- “using the real names as those systems hold them”

**Grounded in (policy):**
- “When adding a note you preserve all existing note text verbatim and add your new line alongside it.”
- “Records are referenced in human-readable communication by their number or exact name, never by an internal database identifier.”
- “the shape is preserved exactly and only the placeholders are replaced with discovered values”

<details><summary>calls</summary>

- `P2-05D` **find_incident_by_number**  ← `number` read at `P2-05`
- `P2-05E` **list_incidents**  ← `number` read at `P2-05D`, `configuration_item` read at `P2-05D`
- `P3-01` **update_incident**  ← `incident_id` read at `P2-05E`

</details>

### 5. Confirm the mailbox identity being used before sending any operational mail

***discriminating read** — email*

The notification is an operational message sent on the engineer's behalf and must go out exactly once from the acting identity. Establishing which mailbox is in use before composing avoids sending from an unintended account, and pairs with the once-only rule: knowing the sending identity is what makes it meaningful to check that no equivalent message already exists.

**Grounded in (policy):**
- “Notifications are sent exactly once per event.”

<details><summary>calls</summary>

- `P4-01` **get_user_profile**

</details>

### 6. Email the corporate payroll analyst, and only her, that the ticket has been re-pointed and remains open

*write — email, itsm*

Two people share the name Priya Nadkarni. The authoritative separator is the email domain — the corporate payroll analyst holds an address on the primary corporate domain, while the contractor with the near-identical kiosk ticket holds one on the contractor subdomain. Resolving the recipient by that corporate address, rather than by name, is what guarantees the contractor is never written to. The subject is reproduced byte for byte and the body carries the dictated sentence with the incident number exactly as the ITSM system holds it; the text goes in the message snippet with recipient and subject as headers, no attachment part, no draft, and nobody copied.

**Must follow:**
- action 3 — The message states which team the ticket is now with, so the assignment must already be in place for that statement to be true.
- action 5 — The sending identity is established first so the message goes out once, from the intended mailbox.

**Discharges (user request):**
- “Then email Priya - the corporate one - to let her know.”
- “Just her, nobody else needs it.”
- “Ours is the payroll analyst on the corporate side.”

**Grounded in (policy):**
- “corporate staff hold addresses on the primary corporate domain, while contractors and other non-employees hold addresses on a subdomain of it”
- “the message body text is supplied as the message snippet, and the recipient and subject are supplied as message headers”
- “Only the intended recipient is addressed - no additional recipients are copied on operational notifications.”

<details><summary>calls</summary>

- `P1-01` **get_user_using_email**
- `P4-02` **send_message**  ← `payload.headers[0].value` read at `P1-01`

</details>

### 7. Record in the ticket that the analyst was notified, so the correction is auditable from the ticket alone

*write — itsm*

The email lives in another system, so its existence is written back into the originating incident. The worknotes are re-read immediately beforehand so the new line is appended after both the seeded caller note and the RETARGET line without dropping either — building the text from memory risks clobbering an append made in between. The address written is the corporate one that was actually mailed, and the incident number is reproduced byte for byte. The incident is deliberately left open: the claim that the service desk lead agreed it could be closed is hearsay with no approval record behind it, and the underlying overtime fault on the payroll engine node has not been fixed.

**Must follow:**
- action 6 — The line asserts the notification was sent and names the address it went to, so the send must have happened first.
- action 4 — This line is appended after the RETARGET line, so that note must already be on the record when the worknotes are re-read.

**Discharges (user request):**
- “put a second line in the ticket's worknotes reading”
- “so we can prove she was told without digging through mailboxes”

**Grounded in (policy):**
- “the fact of that communication is written back into the originating record so the whole correction is auditable from the originating system alone”
- “Statements made by a requester about what someone else has approved are hearsay, not authorisation.”
- “Administrative corrections such as re-routing, re-classification or ownership changes never by themselves justify resolving or closing a record”

<details><summary>calls</summary>

- `P5-01` **find_incident_by_number**  ← `number` read at `P3-01`
- `P5-02` **update_incident**  ← `incident_id` read at `P5-01`

</details>

## Gate advisories

- A-K04 3 argument values are neither given in a prompt nor read from an earlier response, e.g. P1-01.email='priya.nadkarni@servicenow.com'; P1-02.number='INC-000102'; P2-01.configuration_item_id='CI_PAYENG_02'
