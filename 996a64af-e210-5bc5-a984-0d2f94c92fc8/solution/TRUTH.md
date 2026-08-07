# TRUTH — 996a64af-e210-5bc5-a984-0d2f94c92fc8

> Truth plan, derived from the bundle's **proven golden trajectory** and **grounding-checked** against it (every cited call and id verified present in the trajectory). **Never shown to a solver.**

`5` tool calls → `4` actions · trajectory `12/12` verifiers · grounding **VERIFIED**

## The job

Handle the V12 entitlement exception for Aurora Transit by qualifying only the entitled CSM case and only the matching ITSM configuration item, then dropping exactly one Drive evidence file whose name is the byte-exact serial the ITSM lookup returns. The traps are: acting on the look-alike non-entitled account or neighbouring CI, naming the Drive file from the CSM-side serial instead of the ITSM-returned serial, creating extra evidence files, altering entitlements, or pulling an ITSM knowledge article. Every id (entitlement 1300, case CS-V12-09007/1300, serial ENT-AX-9007, CI_V12_ENT_9007, Drive folder DRV_V12_ENT) must come from authenticated reads, never guessed.

## Plan

### 1. Discover the entitlement and qualify only the entitled Aurora Transit case

*write — csm*

Read find_entitlements to surface the qualifying entitlement id (1300) rather than guessing which entitlement applies, then update only that entitled case (CS-V12-09007 / case 1300) to in_progress/high with escalation for the V12 exception. This binds the write to a confirmed entitlement so the look-alike non-entitled account's case is never touched. The entitlement discovery must precede the update so the write targets the correct case.

**Discharges (user request):**
- “Resolve the named account, its qualifying entitlement, the entitled installed product, and the matching active or pending case”
- “Update only the entitled CSM case”
- “Preserve the look-alike case for the non-entitled account”

**Grounded in (policy):**
- “Retrieve every required account, entitlement, installed product, case, configuration item, and evidence destination through authenticated reads in the owning system”
- “Do not create or alter entitlements”

<details><summary>calls</summary>

- `P1-01` **find_entitlements**
- `P1-02` **update_case**  ← `case_id` read at `P1-01`

</details>

### 2. Resolve the CSM installed-product serial through ITSM to fix asset identity

***discriminating read** — itsm*

Look up the installed-product serial ENT-AX-9007 in ITSM to obtain the authoritative configuration item (CI_V12_ENT_9007) and the byte-exact serial the ITSM system returns. This read disambiguates the entitled CI from the neighbouring installed product and establishes the identifier that must later name the Drive file, rather than copying the CSM-side value. It must run before any CI update or evidence creation so both downstream steps use the ITSM-returned identity.

**Must follow:**
- action 1 — The entitled case must be qualified first so the serial being resolved belongs to the entitled installed product, not the look-alike account

**Discharges (user request):**
- “Save the installed-product serial returned by CSM and resolve it through ITSM”
- “the entitled installed product”
- “Its entire file name must be the byte-exact serial returned by the ITSM configuration-item lookup, not the value copied directly from CSM”

**Grounded in (policy):**
- “Preserve byte-sensitive values exactly when transferring them between systems. Do not normalize or reconstruct an identifier that an authoritative lookup returned”

<details><summary>calls</summary>

- `P1-03` **find_configuration_item_by_serial_number**

</details>

### 3. Update only the matching ITSM configuration item

*write — itsm*

Set CI_V12_ENT_9007, the CI returned by the serial lookup, to maintenance. Only this matching configuration item is touched so the neighbouring ITSM CI is preserved. This write depends on the prior ITSM resolution to guarantee the correct target.

**Must follow:**
- action 2 — The CI id CI_V12_ENT_9007 only exists as a verified target after the ITSM serial lookup

**Discharges (user request):**
- “only the matching ITSM configuration item”
- “Preserve the neighbouring installed product and ITSM configuration item”

**Grounded in (policy):**
- “Do not claim that an update or creation succeeded until the responsible system confirms it”

<details><summary>calls</summary>

- `P1-04` **update_configuration_item**  ← `configuration_item_id` read at `P1-03`

</details>

### 4. Create exactly one Drive evidence file named the ITSM-returned serial

*write — drive*

Create a single text/plain evidence file in folder DRV_V12_ENT whose name is the byte-exact ITSM-returned serial ENT-AX-9007, with the exception-evidence description. Exactly one file is created and it uses the ITSM lookup value, not the CSM copy, avoiding the naming trap. Pre-existing Drive permissions on the folder are left untouched since only a create is performed.

**Must follow:**
- action 2 — The file name must be the byte-exact serial returned by the ITSM configuration-item lookup, established in the ITSM read

**Discharges (user request):**
- “Create exactly one Drive evidence file”
- “Its entire file name must be the byte-exact serial returned by the ITSM configuration-item lookup”
- “every pre-existing Drive permission”

**Grounded in (policy):**
- “Preserve byte-sensitive values exactly when transferring them between systems. Do not normalize or reconstruct an identifier that an authoritative lookup returned”

<details><summary>calls</summary>

- `P1-05` **create_file**

</details>

