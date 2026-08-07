# TRUTH — f5793303-72a0-5c7d-932d-79a203c5369c

> Truth plan, derived from the bundle's **proven golden trajectory** and **grounding-checked** against it (every cited call and id verified present in the trajectory). **Never shown to a solver.**

`5` tool calls → `4` actions · trajectory `9/9` verifiers · grounding **VERIFIED**

## The job

Execute Northstar's regulated-device entitlement remediation for cycle reference date 2026-07-29: retrieve the Entitlement Remediation Standard, compose its general eligibility rule with its exception to identify the in-scope device serial and the eligible account (Aurora Transit, id 1300) versus the look-alike, resolve that serial to configuration item CI_GRID_4471 (canonical asset name 'Grid Gateway 4471'), set only that CI to maintenance while leaving neighbour CI_GRID_9000 untouched, then in CSM file exactly one strictly-shaped remediation case for the eligible account and advance its pending case to in_progress/high. Traps: two near-identical accounts where only the one holding an active enterprise entitlement is eligible, a neighbouring CI that must not be touched, a byte-for-byte asset name that must be copied into the short description, and a strict case shape that names any missing required field.

## Plan

### 1. Resolve the in-scope configuration item and isolate its untouchable neighbour

***discriminating read** — itsm*

List configuration items in the service-management system to resolve the in-scope device serial to its canonical CI rather than guessing an id, surfacing CI_GRID_4471 as the in-scope grid gateway and its canonical asset name 'Grid Gateway 4471'. This read also distinguishes the target CI from the neighbouring CI_GRID_9000 that must remain untouched. Doing the lookup first guarantees every downstream write reuses the exact id and name the ITSM system owns.

**Discharges (user request):**
- “Resolve that serial to its configuration item in the service-management system and take the configuration item's canonical asset name”
- “leave any neighbouring configuration item untouched”

**Grounded in (policy):**
- “When an identifier is missing, look it up in the system that owns it and reuse the exact value that system returns”
- “Never assume, guess, or fabricate a record id, an identifier, a serial, an asset name, or any field value”

<details><summary>calls</summary>

- `P1-01` **find_configuration_items**

</details>

### 2. Discriminate the eligible account from the look-alike by active enterprise entitlement

***discriminating read** — csm*

Query CSM entitlements to determine which of the candidate versus look-alike account actually holds an active enterprise entitlement for the in-scope device, resolving eligibility to account/contact 1300 (Aurora Transit). This discriminating read is required because the two accounts are near-identical and only the one with active enterprise coverage is in scope. The look-alike lacks active coverage and is therefore excluded from all writes.

**Must follow:**
- action 1 — the entitlement must be matched against the in-scope device/CI resolved in ITSM

**Discharges (user request):**
- “The eligible account is the one holding an active enterprise entitlement for the in-scope device”
- “examine both the candidate account and the look-alike account”

**Grounded in (policy):**
- “Act only on confirmed system state”
- “Never assume, guess, or fabricate a record id, an identifier, a serial, an asset name, or any field value”

<details><summary>calls</summary>

- `P1-02` **find_entitlements**

</details>

### 3. Mark only the in-scope CI to maintenance

*write — itsm*

Update configuration item CI_GRID_4471 to status 'maintenance', using the exact id returned by the ITSM listing. Only this CI is changed; the neighbouring CI_GRID_9000 is deliberately left untouched. This write depends on the earlier ITSM read that confirmed the id and canonical asset name.

**Must follow:**
- action 1 — uses the exact CI id CI_GRID_4471 resolved from the ITSM read and preserves the untouched neighbour

**Discharges (user request):**
- “Mark that configuration item's status `maintenance`, and leave any neighbouring configuration item untouched”

**Grounded in (policy):**
- “reuse the exact value that system returns”
- “Reuse retrieved identifiers and names byte for byte”

<details><summary>calls</summary>

- `P1-03` **update_configuration_item**  ← `configuration_item_id` read at `P1-01`

</details>

### 4. File the single remediation case and advance the pending case for the eligible account only

*write — csm*

For eligible account/contact 1300 only, create exactly one remediation case at channel 'web', priority 'high', state 'new', with short description 'Entitlement remediation for asset Grid Gateway 4471' copying the CI canonical asset name byte for byte, supplying whatever required field the strict case shape names (contact_id). Then advance the account's existing pending remediation case (id 1300) to state 'in_progress', priority 'high'. No case is created or modified for the look-alike account.

**Must follow:**
- action 2 — acts only on the eligible account 1300 confirmed via active enterprise entitlement
- action 3 — reuses the CI canonical asset name 'Grid Gateway 4471' resolved and confirmed in ITSM

**Discharges (user request):**
- “File exactly one remediation case. Its short description must be exactly `Entitlement remediation for asset <ASSET_NAME>`”
- “Open it at channel `web`, priority `high`, state `new`”
- “supply whatever field its rejection names”
- “Advance the eligible account's existing pending remediation case to state `in_progress`, priority `high`”
- “Do not file a case for it, do not change its existing case, and do not alter its records”

**Grounded in (policy):**
- “Reuse retrieved identifiers and names byte for byte; never reformat, re-case, or abbreviate a value another system produced”
- “Strict, especially regarding eligibility, record scope, and precision”

<details><summary>calls</summary>

- `P1-04` **create_new_case**  ← `account_id` read at `P1-02`; `contact_id` read at `P1-02`
- `P1-05` **update_case**  ← `case_id` read at `P1-02`

</details>

