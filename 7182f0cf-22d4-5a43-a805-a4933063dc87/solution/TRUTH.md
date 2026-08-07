# TRUTH — 7182f0cf-22d4-5a43-a805-a4933063dc87

> Truth plan, derived from the bundle's **proven golden trajectory** and **grounding-checked** against it (every cited call and id verified present in the trajectory). **Never shown to a solver.**

`6` tool calls → `5` actions · trajectory `31/31` verifiers · grounding **VERIFIED**

## The job

Maya Rodriguez in People Ops is converting contractor Daniel Foster (corporate email daniel.foster@globex.com) to full-time end-to-end. The trap is a second Daniel Foster contractor in Sales on a different address, so identity must be pinned by corporate email before any write. The flow: resolve the correct Daniel (person 610) by email, look up the 'employee conversion' service (id 100), flip his HR profile to full-time while staying active, open a brand-new workforce-administration case opened_for Daniel with Maya (501) as owner, send a welcome email from Maya's own mailbox to Daniel's corporate address, stamp the case's own number onto it, and resolve/close with a short summary. No existing inquiry may be reused or edited, no ids fabricated.

## Plan

### 1. Resolve the correct Daniel Foster by corporate email

***discriminating read** — hr*

Look up the HR user by the exact corporate email daniel.foster@globex.com to land on person 610 and avoid the look-alike Daniel Foster contractor in Sales on a different address. This disambiguation must precede every write so all downstream actions target the intended record. No id is assumed; it is discovered from this read.

**Discharges (user request):**
- “Pull up the correct Daniel by his corporate email”
- “there's another Daniel Foster contractor in Sales on a different address who I do NOT want touched”

**Grounded in (policy):**
- “You execute worker-lifecycle changes strictly according to confirmed identity, verified record relationships, valid enums, and referential integrity”
- “never fabricate identifiers”

<details><summary>calls</summary>

- `P1-01` **get_user_using_email**

</details>

### 2. Discover the 'employee conversion' service id

*read — hr*

Resolve the HR service named 'employee conversion' to its id 100 so the new case can be filed under the correct service. This is a lookup, not an assumption, keeping referential integrity for the case creation step.

**Discharges (user request):**
- “filed under our "employee conversion" service”

**Grounded in (policy):**
- “valid enums, and referential integrity”

<details><summary>calls</summary>

- `P1-02` **get_hr_service_by_name**

</details>

### 3. Convert Daniel's HR profile to full-time, keeping him active

*write — hr*

Update HR profile 610 (number HRP0000610, user 610) to type full-time while leaving him active, per the conversion request. This uses the person id confirmed from the email lookup to ensure the right Daniel is changed.

**Must follow:**
- action 1 — Needs the confirmed person 610 from the email disambiguation so the correct record is updated.

**Discharges (user request):**
- “Update his HR record to full-time employee, keeping him active”

**Grounded in (policy):**
- “You execute worker-lifecycle changes (onboarding, conversion, transfers, offboarding) strictly according to confirmed identity”

<details><summary>calls</summary>

- `P1-03` **update_hr_profile**  ← `hr_profile_id` read at `P1-01`; `user_id` read at `P1-01`

</details>

### 4. Open the brand-new conversion case, stamp its number, then resolve and close it

*write — hr*

Create a fresh case titled exactly 'Contractor to FTE conversion for Daniel Foster' as a Workforce Administration matter, status work_in_progress, under service 100, opened_for Daniel Foster, with opened_by resolving to acting user 501 (Maya) as owner — no existing inquiry reused. Once it returns case 2 / number HRC0004002, update that same case to write its own number back onto it and set status closed_complete with a short full-sentence worknote summarizing the conversion. The close depends on the number produced by the create call, so it is done as a paired write on the same record.

**Must follow:**
- action 1 — opened_for must be the confirmed Daniel Foster (610), not the Sales look-alike.
- action 2 — The case must be filed under the discovered service id 100.
- action 3 — The case documents the profile conversion just completed.

**Discharges (user request):**
- “Open a brand-new conversion case (don't reuse or edit any existing inquiry) titled exactly `Contractor to FTE conversion for Daniel Foster`, moderate priority, in progress, filed under our "employee conversion" service, as a workforce administration matter, opened for Daniel, and assign me as owner”
- “Once the case has its number, jot that number down on the case itself”
- “Then resolve and close the case with a short full-sentence summary of what was done”

**Grounded in (policy):**
- “never assume data, never fabricate identifiers”
- “primary`/`me` resolve to it”

<details><summary>calls</summary>

- `P1-04` **create_new_hr_case**
- `P1-05` **update_hr_case**

</details>

### 5. Send the welcome email from Maya's mailbox to Daniel's corporate address

*write — email*

From Maya's own self-service mailbox (userId 'me' = maya.rodriguez@globex.com), send Daniel a welcome note to daniel.foster@globex.com with subject exactly 'Welcome to Globex Daniel Foster' and a warm couple of sentences. The payload includes a non-empty filename to satisfy the message validator, and the To address is the corporate email confirmed earlier.

**Must follow:**
- action 1 — The recipient must be the confirmed Daniel's corporate email, not the Sales namesake.

**Discharges (user request):**
- “From my mailbox, send Daniel a welcome note to his corporate email with subject exactly `Welcome to Globex Daniel Foster` and a warm couple of sentences welcoming him to the full-time team”

**Grounded in (policy):**
- “In the Email system Maya owns exactly ONE self-service mailbox: `maya.rodriguez@globex.com`”

<details><summary>calls</summary>

- `P1-06` **send_message**

</details>

