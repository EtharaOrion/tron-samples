# TRUTH — 23ecb63c-0b37-5b20-8ff1-0b297037b89e

> Truth plan, derived from the bundle's **proven golden trajectory** and **grounding-checked** against it (every cited call and id verified present in the trajectory). **Never shown to a solver.**

`5` tool calls → `5` actions · trajectory `7/7` verifiers · grounding **VERIFIED**

## The job

Dana Whitfield (admin) is consolidating Austin sites by retiring 'Meridian Site B - Austin'. The task: move any installed equipment at Site B whose serial number contains '7731' to 'Meridian Site A - Austin' (updating location_id), leave anything already at Site A untouched, and never touch 'Meridian Site C - Austin'. Any remaining in-use equipment at Site B that is NOT being moved must be taken out of active service (retired), and only once Site B holds no active equipment may it be deactivated; Site A stays active. Traps: don't move non-7731 gear, don't touch Site C, don't alter Site A items, and don't deactivate Site B until it is clear of active equipment; location deactivation requires admin.

## Plan

### 1. Resolve the three Austin sites before acting

***discriminating read** — csm*

List locations to obtain the concrete ids for Site A, Site B, and Site C rather than guessing, confirming Site A = 3010 (target, stays active), Site B = 3011 (to retire), and Site C (must not be touched). This disambiguation prevents writing against the wrong site and grounds the later location update.

**Discharges (user request):**
- “retire 'Meridian Site B - Austin'”
- “move ... over to 'Meridian Site A - Austin'”
- “don't touch 'Meridian Site C - Austin' at all”

**Grounded in (policy):**
- “Resolve and confirm the acting user before performing any write.”
- “no id-guessing”

<details><summary>calls</summary>

- `P1-01` **find_locations**

</details>

### 2. Discover installed products and classify by serial and status

***discriminating read** — csm*

Retrieve installed products to identify which are at Site B and inspect each serial number and status, distinguishing the 7731 item (9001, SN-7731-AX) that must move from other in-use gear (9002) that has no 7731. This read is the basis for deciding move vs. retire and confirms nothing at Site A/C is in scope.

**Must follow:**
- action 1 — Site ids from the location read are needed to tell which installed products sit at Site B vs. Site A/C

**Discharges (user request):**
- “any installed equipment at Site B whose serial number contains '7731'”
- “if any in-use gear remains that isn't being moved”

**Grounded in (policy):**
- “no id-guessing”

<details><summary>calls</summary>

- `P1-02` **retrieve_installed_products**

</details>

### 3. Move the 7731 equipment from Site B to Site A

*write — csm*

Update installed product 9001 (SN-7731-AX) to location_id 3010, relocating the only Site B asset whose serial contains 7731 to Meridian Site A - Austin. Only this item qualifies for the move; Site A's existing items and all Site C items are left unchanged.

**Must follow:**
- action 2 — Depends on identifying 9001 as the 7731 item and 3010 as Site A

**Discharges (user request):**
- “move any installed equipment at Site B whose serial number contains '7731' over to 'Meridian Site A - Austin', updating their location to the new site”
- “Leave anything already at Site A alone”

**Grounded in (policy):**
- “agent: read all; write only on installed_product”
- “admin: full read + write on location, installed_product, account, product, user records.”

<details><summary>calls</summary>

- `P1-03` **update_installed_product_details**  ← `installed_product_id` read at `P1-02`; `location_id` read at `P1-01`

</details>

### 4. Retire remaining in-use Site B gear not being moved

*write — csm*

Set installed product 9002 to status 'retired' because it remains in use at Site B, is not a 7731 item, and therefore cannot stay active once Site B is retired. This clears Site B of active equipment without relocating non-qualifying gear.

**Must follow:**
- action 2 — Depends on confirming 9002 is in-use at Site B and lacks 7731, so it must be retired rather than moved

**Discharges (user request):**
- “Site B can't have any active equipment left assigned to it, so if any in-use gear remains that isn't being moved, take it out of active service”

**Grounded in (policy):**
- “admin: full read + write on location, installed_product, account, product, user records.”

<details><summary>calls</summary>

- `P1-04` **update_installed_product_details**  ← `installed_product_id` read at `P1-02`

</details>

### 5. Deactivate Site B once it is clear of active equipment

*write — csm*

With the 7731 asset moved out and the remaining in-use asset retired, Site B (3011) now holds no active equipment, so set its active flag to false to complete the retirement. Site A (3010) is deliberately left active. Deactivating a location requires admin, which Dana holds.

**Must follow:**
- action 3 — Site B must first have its 7731 asset relocated
- action 4 — Remaining in-use gear must be retired so no active equipment is left before deactivation

**Discharges (user request):**
- “Once Site B is clear of active equipment, deactivate it”
- “Site A stays open and active”

**Grounded in (policy):**
- “Only admin may deactivate a location or change a location's active flag.”

<details><summary>calls</summary>

- `P1-05` **update_location**  ← `location_id` read at `P1-01`

</details>

