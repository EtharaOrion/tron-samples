# TRUTH — 288c1470-ec9b-5720-9c5d-b698c27b9a23

> Truth plan, derived from the bundle's **proven golden trajectory** and **grounding-checked** against it (every cited call and id verified present in the trajectory). **Never shown to a solver.**

`7` tool calls → `5` actions · trajectory `15/15` verifiers · grounding **VERIFIED**

## The job

An emergency change must be raised for the SAP production Oracle database CI identified by serial SRV-ORC-9981. The task resolves that CI to its record id, creates exactly one change with a verbatim short description and specific status/impact/risk/priority/category with CAB approval required against that CI, then links precisely the incidents the ITSM emergency change incident mapping standard puts in scope (INC_001, INC_069, INC_901) while honoring its exceptions. The key trap is INC-000904: although it describes a similar fault and is open, it is recorded against a different CI, so the standard excludes it and it must be neither linked nor modified.

## Plan

### 1. Discover candidate incidents before any linkage

***discriminating read** — itsm*

List all incidents to obtain concrete incident record ids so no id is guessed and each in-scope candidate can be evaluated against the mapping standard. This establishes the working set (INC_001, INC_069, INC_901 among others) and separates them from look-alikes like INC-000904. Reading first prevents acting on assumed data.

**Discharges (user request):**
- “Link the incidents that the current emergency change incident mapping standard requires”

**Grounded in (policy):**
- “Do not generate or fabricate record IDs, record numbers, or field values”
- “You must always act on confirmed system state”

<details><summary>calls</summary>

- `P1-01` **list_incidents**

</details>

### 2. Resolve the configuration item by its serial number

*read — itsm*

Look up the CI by serial number SRV-ORC-9981 to obtain its record id (CI_001) so the change can be recorded against a confirmed CI rather than an assumed one. This is Step 1 and is a prerequisite for correctly creating and scoping the change. Resolving by the given identifier follows the lookup-not-invent rule.

**Discharges (user request):**
- “Look the configuration item up by that serial number so you have its record id”

**Grounded in (policy):**
- “When identifiers such as numbers or IDs are missing, look them up in the owning system by the identifier you were given”

<details><summary>calls</summary>

- `P1-02` **find_configuration_item_by_serial_number**

</details>

### 3. Retrieve the binding emergency change incident mapping standard

*read — itsm*

Fetch the ITSM knowledge article defining the emergency change incident mapping so linkage follows the documented condition and its overriding exceptions rather than intuition. This standard determines which incidents are in the set and which are excluded (e.g., a different-CI open incident like INC-000904). Reading it before writing ensures the linkage is applied exactly.

**Discharges (user request):**
- “The standard is in the ITSM knowledge base; retrieve it and apply it exactly”
- “It defines which incidents are in the set by condition, and it carries exceptions that override the general rule”

**Grounded in (policy):**
- “Do not provide knowledge, procedures, or record data that cannot be retrieved from the authenticated system”

<details><summary>calls</summary>

- `P1-03` **retrieve_knowledge_articles**

</details>

### 4. Create the single emergency change against the resolved CI

*write — itsm*

Create exactly one change with the verbatim short description 'Emergency Oracle failover patch for SAP production database' and status assess, impact high, risk high, priority critical, category software, CAB approval required, recorded against CI_001. This is Step 2 and yields CHG_026, the target for all subsequent linkage. It depends on the CI resolution to bind the change to a confirmed configuration item.

**Must follow:**
- action 2 — The change must be recorded against the CI record id (CI_001) resolved from the serial number

**Discharges (user request):**
- “Create exactly one change with short description exactly `Emergency Oracle failover patch for SAP production database`, status `assess`, impact `high`, risk `high`, priority `critical`, category `software`, CAB approval required, recorded against the configuration item from step 1”

**Grounded in (policy):**
- “You are strictly prohibited from assuming data values, acting outside the requested scope”
- “act on confirmed system state”

<details><summary>calls</summary>

- `P1-04` **create_change**

</details>

### 5. Link exactly the in-scope incidents onto the change

*write — itsm*

Map INC_001 (in_progress database incident), INC_069 (on_hold), and INC_901 (new) onto CHG_026 because the retrieved standard's condition places them in the set. INC-000904 is deliberately not linked and not modified since it is recorded against a different CI, matching the standard's overriding exception. Linkage depends on both the created change and the standard so only the required incidents are attached and none excluded.

**Must follow:**
- action 1 — Provides the concrete incident ids to link
- action 3 — Defines which incidents the condition includes and which exceptions exclude
- action 4 — Supplies the target change id CHG_026 for the mappings

**Discharges (user request):**
- “Link every incident the standard puts in the set and no incident it excludes”
- “Do not link it and do not modify it”

**Grounded in (policy):**
- “Compliance Level: Strict, especially regarding change scope and incident linkage”
- “altering records nobody asked you to alter”

<details><summary>calls</summary>

- `P1-05` **map_change_request**  ← `change_id` read at `P1-04`; `incident_id` read at `P1-01`
- `P1-06` **map_change_request**  ← `change_id` read at `P1-04`; `incident_id` read at `P1-01`
- `P1-07` **map_change_request**  ← `change_id` read at `P1-04`; `incident_id` read at `P1-01`

</details>

