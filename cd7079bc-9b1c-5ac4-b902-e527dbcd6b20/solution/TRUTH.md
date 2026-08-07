# TRUTH — cd7079bc-9b1c-5ac4-b902-e527dbcd6b20

> Truth plan, derived from the bundle's **proven golden trajectory** and **grounding-checked** against it (every cited call and id verified present in the trajectory). **Never shown to a solver.**

`5` tool calls → `3` actions · trajectory `5/5` verifiers · grounding **VERIFIED**

## The job

For customer Vertex Labs — the labs company, disambiguated from the similarly named systems firm — register a newly deployed physical firewall APPLIANCE (hardware unit, not the software product) at their HQ site (not the overseas branch) with serial number VTX-FW-9001 recorded exactly, then log a handled inbound phone interaction from their primary contact confirming the install is complete, attributed to me (Piyush Chandra, id 101). The traps are: two 'Vertex' accounts surfacing under contacts (both 5001-tagged) requiring name-based disambiguation, choosing the HQ location over the overseas branch, and picking the appliance hardware product rather than its software namesake. A final ask to report Vertex Labs' open-case count is present in the request but has no proven tool call available here, so it is not fabricated.

## Plan

### 1. Resolve account, HQ location, and appliance product by discovery before any write

***discriminating read** — csm*

Enumerate contacts, locations, and products to bind ids rather than guess them, and to separate look-alikes: the Vertex Labs account (5001) from the similarly named systems firm, the HQ location (201) from the overseas branch, and the firewall hardware appliance product (3001) from its software namesake. This also surfaces the primary contact id (6001) needed for the interaction. These resolved ids feed both downstream writes.

**Discharges (user request):**
- “our customer Vertex Labs (the labs company, not the similarly named systems firm)”
- “the physical hardware unit, not the software product”
- “at their HQ site — not the overseas branch”

**Grounded in (policy):**
- “Discover contact id(s) before acting (no id-guessing)”
- “Resolve the acting user to their canonical record before performing any write”
- “never type a literal name into an id field”

<details><summary>calls</summary>

- `P1-01` **find_contacts**
- `P1-02` **find_locations**
- `P1-03` **find_products**

</details>

### 2. Register the firewall appliance at the Vertex Labs HQ location with the exact serial

*write — csm*

Create the installed-product record for the deployed firewall appliance (product 3001) under Vertex Labs (account 5001) at the HQ location (201) with serial VTX-FW-9001 recorded verbatim and status in_use. This depends on the prior discovery so every id is the disambiguated, canonical one rather than a guess. Serial is written exactly as provided per the request.

**Must follow:**
- action 1 — Uses the disambiguated account 5001, HQ location 201, and appliance product 3001 resolved in discovery

**Discharges (user request):**
- “Register a new firewall appliance ... Serial number is VTX-FW-9001, record it exactly”

**Grounded in (policy):**
- “Only users whose account is active and whose role is 'agent' or 'admin' may create installed-product and interaction records”
- “never fabricate data”

<details><summary>calls</summary>

- `P1-04` **register_new_installed_product**  ← `account_id` read at `P1-01`; `product_id` read at `P1-03`; `location_id` read at `P1-02`

</details>

### 3. Log the handled inbound phone interaction from the primary contact on my behalf

*write — csm*

Record a phone-channel interaction with status handled for Vertex Labs (account 5001) with primary contact 6001, attributed to the authenticated acting agent Piyush Chandra (interacted_user 101), capturing the call confirming the install is complete. This follows discovery so the account and contact ids are the correct, disambiguated ones. The handling agent is my own resolved session id, never a typed name.

**Must follow:**
- action 1 — Reuses account 5001 and primary contact 6001 surfaced during discovery

**Discharges (user request):**
- “their primary contact called in today and confirmed the install is complete — capture that as a handled phone conversation on my behalf”

**Grounded in (policy):**
- “Reuse the resolved internal user id verbatim; never type a literal name into an id field”
- “You are Piyush Chandra <chandrapiyush357@gmail.com> ... primary/me resolve to it”
- “agent: may create installed products, create interactions”

<details><summary>calls</summary>

- `P1-05` **register_new_interaction**  ← `account_id` read at `P1-01`; `contact_id` read at `P1-01`

</details>

