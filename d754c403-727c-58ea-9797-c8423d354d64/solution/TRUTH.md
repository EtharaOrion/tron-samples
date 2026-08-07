# TRUTH — d754c403-727c-58ea-9797-c8423d354d64

> Truth plan, derived from the bundle's **proven golden trajectory** and **grounding-checked** against it (every cited call and id verified present in the trajectory). **Never shown to a solver.**

`11` tool calls → `8` actions · trajectory `17/17` verifiers · grounding **VERIFIED**

## The job

Run Priya Nair's (priya.nair@northstar.example, HR id 22) leaver handoff end to end across seven systems as of ref date 2026-07-29, keeping it strictly disjoint from the look-alike leaver Priya Shah. The core trap is routing: the HR offboarding-handoff standard states a general rule plus a work-location exception, and Priya Nair's own work-location type selects which applies, resolving through HR profiles to the handoff owner's HR personal email (dana.cole@northmail.example). Open exactly one HR case and offboard her, mint exactly one ITSM change (CHG0000019) carrying that personal email in its description, confirm the Priya-Nair-named calendar event (not its look-alike) and set its description to 'Handoff confirmed', and send exactly one notification whose Subject copies the minted change number byte for byte. The mail system enforces a strict message shape, so the first send is reshaped (filename at payload level, headers populated) until the To/Subject checks pass.

## Plan

### 1. Resolve Priya Nair and the handoff owner by reading her profile against the retrieved standard

***discriminating read** — hr*

Look up priya.nair@northstar.example to get her user_id (22) and confirm she is the correct leaver, not Priya Shah. Retrieve the published HR offboarding-handoff routing standard and apply its general-rule-vs-work-location-exception logic to her own work-location type, chasing HR profiles until the handoff owner's HR personal email (dana.cole@northmail.example) is fixed. This binding procedure must be read, never assumed.

**Discharges (user request):**
- “Read Priya Nair's HR profile”
- “Retrieve the current HR offboarding-handoff routing standard from the HR knowledge base and apply it”
- “Resolve the handoff owner through the HR profiles until you have that person's personal email”

**Grounded in (policy):**
- “The binding routing procedure for an offboarding handoff is not stated in a request. It lives in the HR knowl”
- “Act only on confirmed system state. Never assume, guess, or fabricate a record id”

<details><summary>calls</summary>

- `P1-01` **get_user_using_email**
- `P1-02` **retrieve_knowledge_articles**

</details>

### 2. Confirm your own operations mailbox

*read — email*

Read the me profile to confirm the operations mailbox (dana.wu@northstar.example) that will originate the notification. This grounds the From address so no mail identifier is fabricated.

**Discharges (user request):**
- “confirm ... your own operations mailbox in mail”

**Grounded in (policy):**
- “Every value you write must come from an authenticated tool response or from this request.”

<details><summary>calls</summary>

- `P1-03` **get_user_profile**

</details>

### 3. Confirm the correct Priya-Nair handoff calendar event, not the look-alike

***discriminating read** — calendar*

Read evt_handoff_priya_nair on cal_leaver_handoffs to verify its summary names Priya Nair before any patch. This disambiguates it from the look-alike event so the wrong record is never touched.

**Discharges (user request):**
- “Confirm the correct handoff calendar event ... the one whose summary names Priya Nair”
- “Do not touch the look-alike event”

**Grounded in (policy):**
- “Reuse retrieved identifiers byte for byte; never reformat, re-case, or abbreviate a value another system produced.”

<details><summary>calls</summary>

- `P1-04` **get_event**

</details>

### 4. Confirm the standing offboarding-tracker incident

*read — itsm*

Read inc_offboarding_tracker and its existing work notes to confirm the standing tracker exists before referencing the minted change against it. This ensures the later change record is attached to a confirmed incident.

**Discharges (user request):**
- “add a work note to the standing offboarding-tracking incident inc_offboarding_tracker”

**Grounded in (policy):**
- “Act only on confirmed system state. Never assume, guess, or fabricate a record id”

<details><summary>calls</summary>

- `P1-05` **list_incidents**

</details>

### 5. Open exactly one HR case and offboard Priya Nair

*write — hr*

Create exactly one HR case for Priya Nair with short_description 'Offboarding handoff for Priya Nair', coe_type 'Workforce Administration', status 'ready', opened_for the resolved user. Then offboard her HR profile using id 22 confirmed in the first action, keeping Priya Shah entirely untouched.

**Must follow:**
- action 1 — Needs Priya Nair's confirmed user_id 22 so the case and offboarding target the right leaver, not Priya Shah

**Discharges (user request):**
- “Open exactly one HR offboarding case for Priya Nair, short description exactly `Offboarding handoff for Priya Nair`, Center of Excellence type `Workforce Administration`, status `ready`. Then offboard Priya Nair's HR profile.”

**Grounded in (policy):**
- “Compliance Level: Strict, especially regarding routing, record scope, and irreversible notifications.”

<details><summary>calls</summary>

- `P1-06` **create_new_hr_case**
- `P1-07` **offboard_hr_profile**  ← `hr_profile_id` read at `P1-01`

</details>

### 6. Raise exactly one offboarding-handoff change carrying the owner's personal email

*write — itsm*

Create exactly one change with short_description 'Offboarding handoff for Priya Nair', status assess, impact medium, risk low, priority moderate, embedding the resolved handoff-owner HR personal email (dana.cole@northmail.example) in the description. The system mints and returns CHG0000019, which downstream steps must reuse verbatim.

**Must follow:**
- action 1 — The change description must carry the exact handoff-owner personal email resolved from HR

**Discharges (user request):**
- “raise exactly one offboarding-handoff change ... Record the handoff owner you resolved in step 1 by putting their HR personal email into the change description. Raise the change at status `assess`, impact `medium`, risk `low`, priority `moderate`.”

**Grounded in (policy):**
- “The system will mint and return the change number.”
- “Reuse retrieved identifiers byte for byte; never reformat, re-case, or abbreviate a value another system produced.”

<details><summary>calls</summary>

- `P1-08` **create_change**

</details>

### 7. Patch the confirmed handoff event to 'Handoff confirmed'

*write — calendar*

Set the description of evt_handoff_priya_nair on cal_leaver_handoffs to exactly 'Handoff confirmed', operating only on the event already confirmed to name Priya Nair. The look-alike event is deliberately left unchanged.

**Must follow:**
- action 3 — Only patch the event verified in the discriminating read to name Priya Nair

**Discharges (user request):**
- “patch its description to read exactly `Handoff confirmed`. Do not touch the look-alike event.”

**Grounded in (policy):**
- “Act only on confirmed system state. Never assume, guess, or fabricate a record id”

<details><summary>calls</summary>

- `P1-09` **patch_event**

</details>

### 8. Send exactly one notification, reshaping to satisfy the mail validator

*write — email*

Send exactly one message from the operations mailbox to the owner's personal email dana.cole@northmail.example with Subject 'Offboarding handoff for Priya Nair under change CHG0000019' copying the minted number byte for byte. The strict mail shape rejects the first attempt, so the payload is corrected by placing filename at payload level and populating message_headers so the To/Subject checks pass on the successful send.

**Must follow:**
- action 1 — Recipient must be the resolved handoff-owner HR personal email
- action 6 — Subject must embed the exact change number CHG0000019 minted by ITSM

**Discharges (user request):**
- “Send exactly one offboarding-handoff notification email to the handoff owner's personal email. Its `Subject` header must read exactly `Offboarding handoff for Priya Nair under change <NUMBER>` ... copied byte for byte. The mail system enforces a strict message shape; supply whatever field its rejection names.”

**Grounded in (policy):**
- “especially regarding ... irreversible notifications.”
- “If a step cannot be completed compliantly, state the precise reason, complete every other compliant step”

<details><summary>calls</summary>

- `P1-10` **send_message**
- `P1-11` **send_message**

</details>

