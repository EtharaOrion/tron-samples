# TRUTH — 07b2292d-4b61-59c5-b329-f73c09c00317

> Truth plan, derived from the bundle's **proven golden trajectory** and **grounding-checked** against it (every cited call and id verified present in the trajectory). **Never shown to a solver.**

`7` tool calls → `5` actions · trajectory `11/11` verifiers · grounding **VERIFIED**

## The job

Under the V12 Change Routing Standard 27, resolve the selected edge serial through ITSM, create exactly one change for that configuration item, exhaustively apply the standard's change reference and work note to every in-scope incident across the new/in_progress/on_hold containers, and post exactly one Teams announcement carrying the byte-exact serial returned by ITSM. Traps: use the ITSM-returned serial (not the Drive-copied value) in the Teams message, do not create a second change, do not send a second announcement, do not touch neighbouring-CI or resolved incidents, and do not retrieve an ITSM knowledge article.

## Plan

### 1. Discover all incident ids before acting

*read — itsm*

List incidents to enumerate the actual record ids rather than guessing them, yielding INC_V12_ESC_NEW, INC_V12_ESC_PROGRESS, and INC_V12_ESC_HOLD across the new, in_progress, and on_hold containers. This establishes the exhaustive in-scope set to update later and ensures every container is covered even when returned separately.

**Discharges (user request):**
- “Exhaustively update every in-scope incident in the new, in_progress, and on_hold containers, even when they are returned separately.”

**Grounded in (policy):**
- “Resolve required artifacts, configuration items, service records, containers, and communication destinations through authenticated system reads.”

<details><summary>calls</summary>

- `P1-01` **list_incidents**

</details>

### 2. Resolve the selected serial through ITSM to get the byte-exact value

***discriminating read** — itsm*

Look up the configuration item by serial SRV-EDGE-417 in ITSM to obtain the authoritative, byte-exact serial and CI id, disambiguating it from any visually similar value copied from the Drive standard. This authoritative value is the only one permitted to cross into the change and the Teams announcement.

**Discharges (user request):**
- “Resolve the selected serial through ITSM before taking action.”
- “The serial token in that message must be the byte-exact serial returned by the ITSM configuration-item lookup, not a value copied directly from the Drive file.”

**Grounded in (policy):**
- “Preserve byte-sensitive values exactly when they cross system boundaries. A value obtained from an authoritative lookup must not be normalized, reconstructed, or replaced by a visually similar value from another source.”

<details><summary>calls</summary>

- `P1-02` **find_configuration_item_by_serial_number**

</details>

### 3. Create exactly one change for the resolved configuration item

*write — itsm*

Create a single change request for the ITSM-resolved edge CI with the standard's change fields (assess status, high impact/risk, critical priority, hardware category, CAB required), producing CHG_001. Exactly one change is created so it can be referenced by all in-scope incidents; no second change is opened.

**Must follow:**
- action 2 — The change must target the CI resolved by the ITSM serial lookup, not the Drive-copied value.

**Discharges (user request):**
- “Create exactly one change for the resolved configuration item.”
- “Do not create a second change or send a second announcement.”

**Grounded in (policy):**
- “Base every action on verified system state. Never fabricate record identifiers, configuration data, policy content, destinations, or action results.”

<details><summary>calls</summary>

- `P1-03` **create_change**

</details>

### 4. Post exactly one Teams announcement with the byte-exact ITSM serial

*write — teams*

Send a single channel message to the standard's Teams destination (TEAM_V12_ESC / CHAN_V12_ESC) whose serial token is the byte-exact SRV-EDGE-417 returned by the ITSM configuration-item lookup, not the Drive-file copy. Exactly one announcement is sent, matching the standard's message template.

**Must follow:**
- action 2 — The serial token in the message must be the byte-exact value returned by the ITSM lookup.

**Discharges (user request):**
- “Send exactly one channel message to the standard's Teams destination.”
- “Do not create a second change or send a second announcement.”

**Grounded in (policy):**
- “Preserve byte-sensitive values exactly when they cross system boundaries. A value obtained from an authoritative lookup must not be normalized, reconstructed, or replaced by a visually similar value from another source.”

<details><summary>calls</summary>

- `P1-04` **send_channel_message**

</details>

### 5. Exhaustively apply the change reference and work note to every in-scope incident

*write — itsm*

Update each in-scope incident — INC_V12_ESC_NEW (new), INC_V12_ESC_PROGRESS (in_progress), and INC_V12_ESC_HOLD (on_hold) — with the change reference CHG_001 and the work note 'Escalated under V12 Change Routing Standard 27' as specified by the standard. All three containers are covered exactly once; neighbouring-CI and resolved incidents are left untouched.

**Must follow:**
- action 1 — Uses the enumerated incident ids from the discovery read.
- action 3 — Applies the single created change CHG_001 as the change reference.

**Discharges (user request):**
- “Apply the change reference and work note specified by the standard to each of those incidents.”
- “Do not update any incident on a neighbouring configuration item.”
- “Do not update resolved incidents.”

**Grounded in (policy):**
- “Do not report a create, update, or send as complete until the responsible system confirms it.”

<details><summary>calls</summary>

- `P1-05` **update_incident**  ← `incident_id` read at `P1-01`
- `P1-06` **update_incident**  ← `incident_id` read at `P1-01`
- `P1-07` **update_incident**  ← `incident_id` read at `P1-01`

</details>

