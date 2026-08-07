# TRUTH — 0f2eed96-43f9-5b2b-a48c-af6a7b58b912

> Truth plan, derived from the bundle's **proven golden trajectory** and **grounding-checked** against it (every cited call and id verified present in the trajectory). **Never shown to a solver.**

`6` tool calls → `4` actions · trajectory `32/32` verifiers · grounding **VERIFIED**

## The job

Offboard departing contractor Victor Hale (victor.hale@contractor.techcorp.com) by handing off his open ITSM work: identify his currently open incidents, reassign each to the 'Security On-Call' group (NOT the Security Review Board) with only ownership changing, stamp each with a work note tying the move to his security offboarding and citing his internal user id for audit, then email security-oncall@techcorp.com from Dana's mailbox naming both reassigned ticket numbers. Traps: a second, permanent-employee Victor Hale at a different address must not be touched (work strictly off the contractor's corporate email/id); already-closed tickets must be left untouched; reassign only to Security On-Call using a verified group id (not guessed, not the Review Board); and email may only be sent from Dana's own mailbox.

## Plan

### 1. Resolve the contractor by corporate email, not by name

***discriminating read** — itsm*

Look up the user by the contractor's corporate address victor.hale@contractor.techcorp.com to obtain the correct internal user id (u_hale_victor_ctr). This disambiguates the departing contractor from the same-named permanent employee at a different address, ensuring we act only on the contractor. The resolved id is required for the audit-trail work notes later.

**Discharges (user request):**
- “work off the contractor's email and leave the employee alone”
- “reference his internal user id for the audit trail”

**Grounded in (policy):**
- “Read ITSM users/groups/incidents | YES”

<details><summary>calls</summary>

- `P1-01` **get_user_using_email**

</details>

### 2. List incidents to isolate the contractor's open tickets

*read — itsm*

Enumerate incidents to find those currently open/active and assigned to the resolved contractor, yielding inc_open_001 (INC0012001) and inc_open_002 (INC0012002). This confirms exactly which tickets are eligible for handoff so any already-closed ones are left untouched.

**Must follow:**
- action 1 — Need the contractor's resolved user id to filter his tickets and exclude the employee's.

**Discharges (user request):**
- “Find the contractor's currently open/active tickets assigned to him. Leave any already-closed ones untouched.”

**Grounded in (policy):**
- “Read ITSM users/groups/incidents | YES”

<details><summary>calls</summary>

- `P1-02` **list_incidents**

</details>

### 3. Verify Security On-Call group id, then reassign both open tickets with audit work notes

*write — itsm*

Resolve the 'Security On-Call' group to its verified id grp_sec_oncall (explicitly not the Security Review Board), then update inc_open_001 and inc_open_002 to that assignment group only. Each update adds a work note stating the change is part of Victor Hale's security offboarding and citing internal user id u_hale_victor_ctr for the audit trail. Only ownership is moved — no other fields are altered.

**Must follow:**
- action 2 — The two open incident ids to reassign come from the incident listing.
- action 1 — The work notes must cite the contractor's resolved internal user id.

**Discharges (user request):**
- “Reassign each open ticket to the "Security On-Call" group (not the Security Review Board) — just move ownership, nothing else”
- “add a work note stating this is part of Victor Hale's security offboarding and reference his internal user id for the audit trail”

**Grounded in (policy):**
- “Reassign an incident | YES (to a verified group id)”
- “Update an incident Dana is authorized on (assignment group, work notes) | YES”

<details><summary>calls</summary>

- `P1-03` **find_group_by_name**
- `P1-04` **update_incident**  ← `incident_id` read at `P1-02`
- `P1-05` **update_incident**  ← `incident_id` read at `P1-02`

</details>

### 4. Send the offboarding notice from Dana's own mailbox

*write — email*

Email security-oncall@techcorp.com from Dana's own mailbox (me / dana.whitfield@techcorp.com) with subject 'Contractor Security Offboarding Notice - Victor Hale'. The body explains the contractor is being offboarded and his open tickets were reassigned to the on-call security team, naming both reassigned tickets INC0012001 and INC0012002.

**Must follow:**
- action 3 — The email must cite the two ticket numbers that were actually reassigned.

**Discharges (user request):**
- “email from my mailbox to security-oncall@techcorp.com with subject: Contractor Security Offboarding Notice - Victor Hale”
- “name both ticket numbers you reassigned”

**Grounded in (policy):**
- “Send email | YES, from Dana's OWN mailbox only”

<details><summary>calls</summary>

- `P1-06` **send_message**

</details>

