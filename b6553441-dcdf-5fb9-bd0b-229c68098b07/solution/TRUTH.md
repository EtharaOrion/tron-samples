# TRUTH — b6553441-dcdf-5fb9-bd0b-229c68098b07

> Truth plan, derived from the bundle's **proven golden trajectory** and **grounding-checked** against it (every cited call and id verified present in the trajectory). **Never shown to a solver.**

`7` tool calls → `5` actions · trajectory `16/16` verifiers · grounding **VERIFIED**

## The job

Stand up TechCorp HR's contractor-to-permanent conversion service end to end for Robert Taylor (robert.taylor@techcorp.com): register a `Contractor Conversion Approval` criteria routed per the HR knowledge-base routing standard, create the `Contractor Conversion Review` HR service binding the topic detail, template and that criteria, and open exactly one HR case at the standard-required priority. The trap is that routing group and case priority are not given but are determined by combining Robert's HR profile with the published routing standard (which resolves to group 6 / critical), that ids (user 8, topic detail 11, template 6, criteria 4) must be resolved from the system rather than assumed, and that Maria Garcia is explicitly out of scope so no case, criteria, or profile change may touch her.

## Plan

### 1. Establish Robert's profile and the routing standard before deciding routing

***discriminating read** — hr*

Look up Robert Taylor's user record by email to get his user_id (8) and read his HR profile attributes, then retrieve the published HR knowledge articles carrying the approval routing standard. The standard turns on what the profile says, so both must be read together to derive the correct user group (Level 2 Support, group 6) and case priority (critical). This disambiguates routing that is not stated in the request and must not be assumed.

**Discharges (user request):**
- “routed to the user group that the current HR approval routing standard requires for this employee”
- “Read Robert Taylor's HR profile before you decide the routing”
- “at the priority the routing standard requires for this employee”

**Grounded in (policy):**
- “You must always act on confirmed system state”
- “When identifiers such as names, numbers, or IDs are missing, look them up in the owning system”

<details><summary>calls</summary>

- `P1-01` **get_user_using_email**
- `P1-02` **retrieve_knowledge_articles**

</details>

### 2. Resolve the topic detail and service template ids for the service

*read — hr*

Fetch the `Contractor Conversion Review` topic detail (id 11) and the `Contractor Conversion Template` service template (id 6) by name so the service can bind confirmed record ids. These lookups prevent fabricating ids and confirm the bindings exist before the write.

**Discharges (user request):**
- “binding the `Contractor Conversion Review` topic detail, the `Contractor Conversion Template` service template”

**Grounded in (policy):**
- “Do not generate or fabricate record IDs, record numbers, or field values”
- “look them up in the owning system, verify that you are reusing correct values”

<details><summary>calls</summary>

- `P1-03` **get_topic_details**
- `P1-04` **get_service_templates**

</details>

### 3. Register the approval criteria routed to the required group

*write — hr*

Register the approval criteria named exactly `Contractor Conversion Approval`, type `approval`, active, with user_group 6 (Level 2 Support) as the routing standard requires for Robert's profile. This becomes criteria id 4 following the seed criteria 1-3 and is the criteria the service and case will reference.

**Must follow:**
- action 1 — The routing group (6) comes from combining Robert's profile with the routing standard

**Discharges (user request):**
- “Register an approval criteria named exactly `Contractor Conversion Approval`, of type `approval`, active”
- “routed to the user group that the current HR approval routing standard requires for this employee”

**Grounded in (policy):**
- “deliver HR service configuration securely and accurately”
- “You must always act on confirmed system state”

<details><summary>calls</summary>

- `P1-05` **register_hr_criteria**

</details>

### 4. Create the HR service binding topic, template and criteria

*write — hr*

Create the HR service named exactly `Contractor Conversion Review`, active, fulfillment type `workflow`, binding topic detail 11, service template 6, and the `Contractor Conversion Approval` criteria registered in the prior step. This wires the review-carrying service to its approval routing.

**Must follow:**
- action 2 — Needs the resolved topic detail (11) and template (6) ids
- action 3 — Must bind the criteria registered in step 1 (id 4)

**Discharges (user request):**
- “Create an HR service named exactly `Contractor Conversion Review`, active, with fulfillment type `workflow`”
- “binding the `Contractor Conversion Review` topic detail, the `Contractor Conversion Template` service template, and the approval criteria you registered in step 1”

**Grounded in (policy):**
- “deliver HR service configuration securely and accurately”

<details><summary>calls</summary>

- `P1-06` **create_new_hr_service**

</details>

### 5. Open exactly one HR case for Robert at the required priority

*write — hr*

Open a single HR case opened_for Robert Taylor with short description exactly `Contractor conversion review for Robert Taylor`, COE type `Workforce Administration`, status `ready`, priority `critical` per the routing standard, linked to the step-2 HR service and the step-1 approval criteria (id 4). Exactly one case is opened for Robert and none for Maria Garcia, keeping the action within requested scope.

**Must follow:**
- action 1 — Priority (critical) is derived from Robert's profile plus the routing standard, and opened_for resolves to user 8
- action 3 — Case must link the registered approval criteria (id 4)
- action 4 — Case must link the HR service created in the prior step

**Discharges (user request):**
- “Open exactly one HR case for Robert Taylor with short description exactly `Contractor conversion review for Robert Taylor`, Center of Excellence type `Workforce Administration`, status `ready`, linked to the HR service from step 2 and to the approval criteria from step 1, at the priority the routing standard requires”
- “Do not open a case for her”

**Grounded in (policy):**
- “strictly prohibited from assuming data values, acting outside the requested scope, or performing actions that alter records nobody asked you to alter”

<details><summary>calls</summary>

- `P1-07` **create_new_hr_case**

</details>

