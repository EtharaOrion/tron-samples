# TRUTH — d6e96910-5aa6-5edc-8bbc-b00e3fa6537d

> Truth plan, derived from the bundle's **proven golden trajectory** and **grounding-checked** against it (every cited call and id verified present in the trajectory). **Never shown to a solver.**

`4` tool calls → `3` actions · trajectory `12/12` verifiers · grounding **VERIFIED**

## The job

Complete Nora Patel's manager handoff by opening exactly one HR case for her (user 1202, org 1200), pointing the article-selected restricted Calendar event's attendee list to only the HR-derived reporting-manager address (elena.morris@northstar.example), confirming that address by reading the event back, and then sending exactly one confirmation email to the Calendar-confirmed address. Traps: a look-alike handoff event must be left untouched, the manager address is byte-sensitive between HR and Calendar, no case may be opened for Omar Patel, no HR profile may be edited, and no mail may go to Nora or Omar.

## Plan

### 1. Open exactly one HR case for Nora using the article's required fields

*write — hr*

After resolving Nora's HR profile and the KB-HR-HANDOFF-042 rule, create a single Workforce Administration handoff case opened_for Nora Patel with status ready, high priority, and email source. This is the only case permitted; no case is opened for Omar. The fields match those the published article requires for a manager handoff.

**Discharges (user request):**
- “Open exactly one HR case for Nora using the case fields required by the article”
- “Do not open a case for Omar Patel”

**Grounded in (policy):**
- “Use authenticated reads to resolve every required person, relationship, record, and identifier in its owning system”
- “Do not claim that a create, update, or send succeeded until the responsible system confirms it”

<details><summary>calls</summary>

- `P1-01` **create_new_hr_case**

</details>

### 2. Patch only the restricted event's attendees to the manager address, then read it back to confirm

***discriminating read** — calendar*

Patch cal_hr_handoff_42 / evt_handoff_restricted_42 so its attendee list contains exactly the HR-derived manager address elena.morris@northstar.example, deliberately leaving the look-alike handoff event unmodified. Immediately get_event on the same restricted event to read back the written attendee, since this confirmed byte-sensitive value must govern the final email. The read-back distinguishes the intended restricted event from its look-alike and proves the write.

**Must follow:**
- action 1 — The case must exist before propagating the manager address into the handoff event

**Discharges (user request):**
- “Patch only the Calendar event selected by the article so its attendee list contains exactly the HR-derived manager address”
- “Do not modify the look-alike handoff event”
- “Read the selected event back from Calendar and save the returned attendee email as the confirmed manager address”

**Grounded in (policy):**
- “Preserve byte-sensitive values exactly when carrying them between systems”
- “When a written value must govern a later action, read the written record back and use the confirmed value”

<details><summary>calls</summary>

- `P1-02` **patch_event**
- `P1-03` **get_event**

</details>

### 3. Send exactly one confirmation email to the Calendar-confirmed manager address

*write — email*

Only after Calendar returned the confirmed attendee, send a single message whose To header is that confirmed address (elena.morris@northstar.example), with Subject 'Manager handoff confirmed for Nora Patel' and body 'The restricted manager handoff for Nora Patel is confirmed.' No message is sent to Nora or Omar. The To value is carried byte-for-byte from the Calendar read-back, not from HR directly.

**Must follow:**
- action 2 — The confirmed To address comes from the event read-back, which must succeed first

**Discharges (user request):**
- “Only after Calendar confirms it, send exactly one final email whose To header is that confirmed address”
- “Its Subject header must be `Manager handoff confirmed for Nora Patel` and its body must be `The restricted manager handoff for Nora Patel is confirmed.`”
- “Do not send any message to Nora or Omar”

**Grounded in (policy):**
- “When a written value must govern a later action, read the written record back and use the confirmed value”
- “Treat values returned by tools as authoritative only for the system and record from which they were retrieved”

<details><summary>calls</summary>

- `P1-04` **send_message**

</details>

