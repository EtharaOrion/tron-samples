# TRUTH — bb9a010e-2bfc-5405-9583-3647b9321540

> Truth plan, derived from the bundle's **proven golden trajectory** and **grounding-checked** against it (every cited call and id verified present in the trajectory). **Never shown to a solver.**

`4` tool calls → `4` actions · trajectory `5/5` verifiers · grounding **VERIFIED**

## The job

Piyush Chandra (chandrapiyush357@gmail.com) wants a new Mentorship Program lifecycle flow built entirely within his org's scope: a brand-new `Career Development` topic category under the Workforce Administration COE, a `Mentorship Enrollment` topic detail hung off that new category, and a new manual (non-lifecycle) HR service `Mentorship Enrollment Request` linked to that detail. The traps are decoys: don't reuse the existing `Career Growth` or `Workforce Development` categories, don't hang the detail off older categories, and don't touch or reuse the pre-existing lifecycle-event `Mentorship Enrollment` service (decoy id 77). First his identity/role must be confirmed as admin or hr_manager, and every write must stay in his organization's scope with exact-string names.

## Plan

### 1. Confirm acting user's role and org scope before any write

*read — hr*

Resolve Piyush Chandra by his user id to confirm he is admin or hr_manager and capture his organization scope. This gates all subsequent catalog authoring since only those two roles may create categories, details, or services. It also fixes the org scope that every created record must inherit.

**Discharges (user request):**
- “first confirm I'm allowed to do this”
- “keep everything in our org's scope”

**Grounded in (policy):**
- “Before any write, resolve the acting user by their email and confirm their role permits the operation. If the acting user is not `admin` or `hr_manager`, refuse the catalog-authoring request.”
- “All records you create MUST be scoped to the acting user's organization.”

<details><summary>calls</summary>

- `P1-01` **get_user**

</details>

### 2. Create the brand-new `Career Development` topic category under Workforce Administration

*write — hr*

Create a new topic category named exactly `Career Development` with COE type Workforce Administration, active. This deliberately avoids reusing the existing `Career Growth` or `Workforce Development` categories. The new category is the anchor for the detail created next.

**Must follow:**
- action 1 — Write is only permitted after the acting user's role and org scope are confirmed.

**Discharges (user request):**
- “Create a brand-new topic category `Career Development` under our Workforce Administration center of excellence — don't reuse the existing `Career Growth` or `Workforce Development` ones”

**Grounded in (policy):**
- “You provision and maintain the HR service catalog — topic categories, topic details, and HR services — for the enterprise.”
- “and exact-string data integrity rules”

<details><summary>calls</summary>

- `P1-02` **add_new_topic_category**

</details>

### 3. Add the `Mentorship Enrollment` topic detail hung off the new category

*write — hr*

Create a topic detail named exactly `Mentorship Enrollment` linked by name to the newly created `Career Development` category, active. This ensures the detail hangs off the new category and not the older `Career Growth` or `Workforce Development` ones. The detail becomes the link target for the HR service.

**Must follow:**
- action 2 — The detail must reference the just-created `Career Development` category, so it cannot precede that category's creation.

**Discharges (user request):**
- “add a topic detail `Mentorship Enrollment` (hung off this new category, not the older ones)”

**Grounded in (policy):**
- “Every identifier consumed by a write MUST originate from a value you actually read back from the system”
- “and exact-string data integrity rules”

<details><summary>calls</summary>

- `P1-03` **add_new_topic_detail**

</details>

### 4. Create the new manual HR service linked to the new detail

*write — hr*

Create HR service `Mentorship Enrollment Request` with fulfillment_type manual (no automation, not a lifecycle event), active, linked to the new `Mentorship Enrollment` detail. This explicitly avoids the decoy id 77 and the older lifecycle-event `Mentorship Enrollment` service, neither of which is touched or reused. It completes the lifecycle flow entirely within the acting user's org scope.

**Must follow:**
- action 3 — The service links to the `Mentorship Enrollment` detail created in the prior step.

**Discharges (user request):**
- “create a new manual HR service `Mentorship Enrollment Request` — no automation, not a lifecycle event — linked to that new `Mentorship Enrollment` detail”
- “There's an older lifecycle-event `Mentorship Enrollment` service already in the system; don't touch or reuse it”

**Grounded in (policy):**
- “you never assume the existence of a record you have not read”
- “You never fabricate identifiers”

<details><summary>calls</summary>

- `P1-04` **create_new_hr_service**

</details>

