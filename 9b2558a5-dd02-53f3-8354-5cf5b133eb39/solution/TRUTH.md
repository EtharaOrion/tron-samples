# TRUTH — 9b2558a5-dd02-53f3-8354-5cf5b133eb39

> Truth plan, derived from the bundle's **proven golden trajectory** and **grounding-checked** against it (every cited call and id verified present in the trajectory). **Never shown to a solver.**

`2` tool calls → `2` actions · trajectory `11/11` verifiers · grounding **VERIFIED**

## The job

Priya, the current Folder Owner, is going on leave and must hand off the exact folder 'Q3 Planning - Analytics Team' in the Northwind Analytics Shared drive to Marcus Oyelaran (marcus.oyelaran@northwind-analytics.example.com), who already holds reader access. Traps: there are archived and prior-quarter copies of the same-named folder that must NOT be touched, a similarly-named employee who is NOT the intended Marcus, and a strict ordering requirement — Marcus must become owner FIRST so the folder is never ownerless, then Priya's personal access is removed. All other shares (Analytics Team group, company-wide domain) and Marcus's access on other folders must remain untouched.

## Plan

### 1. Promote Marcus's existing reader permission to owner via ownership transfer

*write — drive*

On the resolved target folder (fileId 1FoLdErNwA_Q3_Planning_TeamFolder_ID), upgrade Marcus's already-present reader grant (permissionId perm_marcus_reader_qa_folder_002) to role 'owner' with transferOwnership=true and supportsAllDrives=true. This is done FIRST so the folder always has an owner and is never even briefly ownerless. Acting under the Folder Owner token authorizes the transfer, and reusing Marcus's verified reader permission id ensures it lands on the correct Marcus, not the look-alike employee.

**Discharges (user request):**
- “Transfer ownership to Marcus Oyelaran”
- “He already has read access on it”
- “Make Marcus the owner first”
- “I don't want it to be ownerless even briefly”

**Grounded in (policy):**
- “Folder Owner ... Transfer ownership Y”
- “The acting user for this session is the current Folder Owner of the target artifact”

<details><summary>calls</summary>

- `P1-01` **update_permission**

</details>

### 2. Remove Priya's now-redundant owner permission after transfer

*write — drive*

After ownership is confirmed on Marcus, delete Priya's prior owner permission (permissionId perm_priya_owner_qa_folder_001) from the same folder with supportsAllDrives=true. This strips Priya's personal access as requested while leaving the Analytics Team group share and company-wide domain access intact, since only her specific permission id is deleted. Ordering after P1-01 guarantees the folder was never ownerless.

**Must follow:**
- action 1 — Priya's owner access may only be removed once Marcus is confirmed owner, or the folder would be ownerless.

**Discharges (user request):**
- “then remove my personal access from the folder”
- “Leave every other share on the folder as-is”
- “don't change Marcus's access on any other folder”

**Grounded in (policy):**
- “Folder Owner ... Delete perm Y”
- “Never guess an identifier. Every id used in a write MUST have been returned by a prior read call”

<details><summary>calls</summary>

- `P1-02` **delete_permission**

</details>

