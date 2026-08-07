# TRUTH — fec331bf-9326-57ae-bbc1-2e478b5fed0c

> Truth plan, derived from the bundle's **proven golden trajectory** and **grounding-checked** against it (every cited call and id verified present in the trajectory). **Never shown to a solver.**

`10` tool calls → `5` actions · trajectory `9/9` verifiers · grounding **VERIFIED**

## The job

Route a regulated-device maintenance change for Northstar Systems (reference date 2026-07-29) against the correct in-scope grid configuration item, CI_GRID_4471, keyed off serial GRD-NX-4471. The proven solve enumerates that CI's in-scope incidents (status new/in_progress/on_hold), resolves the serial in the customer-service system to installed-product id 5502147, opens exactly one routing change (assess/medium/low/moderate) carrying that CSM id byte for byte in its short description while satisfying the ITSM system's strict change shape (the rejected category field), annotates each in-scope incident with the exact work note, and maps the change to that in-scope set. The traps are: a look-alike neighbouring CI whose incidents must NOT be touched, copying the CSM identifier (not the serial) verbatim, restricting annotation to only the three in-scope statuses, and opening one and only one change.

## Plan

### 1. List in-scope incidents on CI_GRID_4471

*read — itsm*

Read every incident on configuration item CI_GRID_4471 so the in-scope set (status new, in_progress, on_hold) can be identified before any writes. This establishes the working set of incident ids (INC_GRID_N1, INC_GRID_P1, INC_GRID_H1) and deliberately scopes to this CI, excluding the resembling neighbouring CI. Reading first ensures every later annotation and mapping is grounded in confirmed system state.

**Discharges (user request):**
- “The in-scope incident set is every incident on that configuration item whose status is `new`, `in_progress`, or `on_hold`”

**Grounded in (policy):**
- “Act only on confirmed system state. Never assume, guess, or fabricate a record id”

<details><summary>calls</summary>

- `P1-01` **list_incidents**

</details>

### 2. Resolve serial GRD-NX-4471 to CSM installed-product identifier

***discriminating read** — csm*

Query the customer-service system by serial GRD-NX-4471 to obtain its installed-product identifier, 5502147, under the CSM scheme. This value is distinct from the serial and is the identifier the routing change must carry, so it must be resolved from the owning system and reused byte for byte. Resolving here disambiguates the CSM installed-product id from the serial and from the ITSM configuration item.

**Discharges (user request):**
- “Resolve that serial in the customer-service system to its installed-product identifier ... it is the value the routing change must carry”

**Grounded in (policy):**
- “When an identifier is missing, look it up in the system that owns it and reuse the exact value that system returns. Reuse retrieved identifiers byte for byte”

<details><summary>calls</summary>

- `P1-02` **find_installed_product_by_serial**

</details>

### 3. Open the single routing change on CI_GRID_4471

*write — itsm*

Create exactly one change on CI_GRID_4471 with short description `Change routing for installed asset 5502147`, embedding the CSM id from the prior step verbatim, at status assess, impact medium, risk low, priority moderate. The ITSM system enforces a strict change shape, so the category field named by its rejection is supplied. This yields change CHG_001, the single routing change for this cycle.

**Must follow:**
- action 2 — The short description must copy the CSM installed-product id 5502147 resolved from the customer-service system

**Discharges (user request):**
- “Open exactly one routing change in the service-management system on that configuration item ... Raise the change at status `assess`, impact `medium`, risk `low`, priority `moderate` ... supply whatever field its rejection names”

**Grounded in (policy):**
- “Reuse retrieved identifiers byte for byte; never reformat, re-case, or abbreviate a value another system produced”

<details><summary>calls</summary>

- `P1-03` **create_change**

</details>

### 4. Annotate each in-scope incident with the exact work note

*write — itsm*

Add the work note exactly `Linked to the grid routing change` to each of the three in-scope incidents on CI_GRID_4471 (INC_GRID_N1, INC_GRID_P1, INC_GRID_H1), one per status new/in_progress/on_hold. No incident on the neighbouring look-alike CI is touched. The note text is written verbatim with no reformatting.

**Must follow:**
- action 1 — Uses the in-scope incident ids enumerated from CI_GRID_4471

**Discharges (user request):**
- “Add the work note exactly `Linked to the grid routing change` to every incident in that in-scope set, and to no incident on any other configuration item”

**Grounded in (policy):**
- “Act only on confirmed system state. Never assume, guess, or fabricate a record id, an identifier, a serial, or any field value”

<details><summary>calls</summary>

- `P1-04` **update_incident**  ← `incident_id` read at `P1-01`
- `P1-05` **update_incident**  ← `incident_id` read at `P1-01`
- `P1-06` **update_incident**  ← `incident_id` read at `P1-01`

</details>

### 5. Confirm the in-scope set and map the change to it

*write — itsm*

Re-list CI_GRID_4471's incidents to reconfirm the exact in-scope ids, then map change CHG_001 to each of INC_GRID_N1, INC_GRID_P1, and INC_GRID_H1. Confirming immediately before mapping guards against mapping a stale or wrong id and keeps the association restricted to the in-scope set on this CI only. The neighbouring CI's incidents are excluded from the mapping.

**Must follow:**
- action 3 — Requires the created change id CHG_001 to map against
- action 1 — Maps only the in-scope incident ids from CI_GRID_4471

**Discharges (user request):**
- “Then map that change to the in-scope incident set”

**Grounded in (policy):**
- “Compliance Level: Strict, especially regarding routing, exhaustive scope, and record precision”

<details><summary>calls</summary>

- `P1-07` **list_incidents**
- `P1-08` **map_change_request**  ← `change_id` read at `P1-03`; `incident_id` read at `P1-01`
- `P1-09` **map_change_request**  ← `change_id` read at `P1-03`; `incident_id` read at `P1-01`
- `P1-10` **map_change_request**  ← `change_id` read at `P1-03`; `incident_id` read at `P1-01`

</details>

