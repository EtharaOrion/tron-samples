# TRUTH — 90b6626a-da8b-5d0b-a01b-3bf3e7052497

> Truth plan, derived from the bundle's **proven golden trajectory** and **grounding-checked** against it (every cited call and id verified present in the trajectory). **Never shown to a solver.**

`9` tool calls → `6` actions · trajectory `15/15` verifiers · grounding **VERIFIED**

## The job

Offboard James Brown (james.brown@techcorp.com) by executing the binding HR offboarding access-revocation standard exactly. The standard dictates which record to open, which configuration item the change is raised against, and the notification subject line, so it must be retrieved and read before any writes. Traps: the CI must be derived from James Brown's own HR profile (yielding CI_099 / serial SEC-BDG-01), not assumed; the email subject must end with that serial quoted byte-for-byte from the ITSM change; the operations sender address and the manager's recipient address must be looked up (own mail profile -> operations@techcorp.com; HR -> sarah.chen@techcorp.com), not guessed; and Lisa Anderson is explicitly out of scope, so no case, change, or email for her.

## Plan

### 1. Resolve James Brown by email and read his HR profile

***discriminating read** — hr*

Look up James Brown by his email to confirm his user_id (6), then read his HR profile to obtain his reporting manager and the configuration item the offboarding standard selects for this employee. This grounds the CI choice in confirmed system state rather than assumption, and disambiguates the correct employee from any look-alike leavers such as Lisa Anderson. Both facts feed later writes.

**Discharges (user request):**
- “The standard selects it from the employee's own HR profile, so read that profile before you choose”
- “look the manager up in the HR system to get the manager's address”

**Grounded in (policy):**
- “You must always act on confirmed system state”
- “Do not generate or fabricate record IDs, record numbers, or field values”

<details><summary>calls</summary>

- `P1-01` **get_user_using_email**
- `P1-02` **get_users_hr_profile**  ← `user_id` read at `P1-01`

</details>

### 2. Retrieve the binding offboarding access-revocation standard

*read — hr*

Retrieve the offboarding standard from the HR knowledge base before creating any record. It defines which record to open, which CI the revocation change is raised against, and the required notification subject line, so it must be read first and followed exactly.

**Discharges (user request):**
- “Retrieve that standard first and follow it exactly”

**Grounded in (policy):**
- “Do not provide knowledge, procedures, or record data that cannot be retrieved from the authenticated systems”

<details><summary>calls</summary>

- `P1-03` **retrieve_knowledge_articles**

</details>

### 3. Open the HR case for the departure

*write — hr*

Create the single HR case with short description exactly 'Offboarding access revocation for James Brown', CoE type 'Workforce Administration', status 'ready', opened for James Brown. This is the record the standard directs us to open for this employee's offboarding.

**Must follow:**
- action 1 — The case is opened for the James Brown identity confirmed in step 1
- action 2 — The standard specifies which record to open

**Discharges (user request):**
- “One HR case for the departure, short description exactly `Offboarding access revocation for James Brown`, Center of Excellence type `Workforce Administration`, status `ready`, opened for James Brown”

**Grounded in (policy):**
- “altering records nobody asked you to alter”

<details><summary>calls</summary>

- `P1-04` **create_new_hr_case**

</details>

### 4. Confirm the CI serial and raise the revocation change against it

*write — itsm*

Confirm the configuration item derived from James Brown's profile by looking up serial SEC-BDG-01 (CI_099), then create the ITSM change with short description exactly 'Revoke enterprise access for James Brown', status 'assess', impact 'high', risk 'medium', priority 'high', category 'hardware', raised against CI_099. Confirming the serial first ties the change to a verified CI and provides the exact serial byte string reused in the email subject.

**Must follow:**
- action 1 — CI_099 was selected from James Brown's HR profile read in step 1
- action 2 — The standard names the CI the change is raised against

**Discharges (user request):**
- “One ITSM change with short description exactly `Revoke enterprise access for James Brown`, status `assess`, impact `high`, risk `medium`, priority `high`, category `hardware`, raised against the configuration item the standard selects for this employee”

**Grounded in (policy):**
- “cross-system data integrity and record scope”
- “Do not generate or fabricate record IDs, record numbers, or field values”

<details><summary>calls</summary>

- `P1-05` **find_configuration_item_by_serial_number**
- `P1-06` **create_change**

</details>

### 5. Read own mail profile to confirm the operations sender address

*read — email*

Read the authenticated mail profile to confirm the operations mailbox sender address (operations@techcorp.com) rather than assuming it. This satisfies the requirement to look the operations mailbox up from the assistant's own mail profile before sending.

**Discharges (user request):**
- “Look the operations mailbox address up from your own mail profile”

**Grounded in (policy):**
- “You must always act on confirmed system state”

<details><summary>calls</summary>

- `P1-07` **get_user_profile**

</details>

### 6. Send the revocation notification to James Brown's manager

*write — email*

Send one email from operations@techcorp.com to the reporting manager sarah.chen@techcorp.com with subject 'Access revocation for James Brown on SEC-BDG-01', where the serial is quoted byte-for-byte from the ITSM change created in step 4. The correctly structured payload places filename at the MessagePart level so the Subject/To headers are written; only a single logical send is intended for idempotency.

**Must follow:**
- action 1 — Manager address sarah.chen@techcorp.com came from James Brown's HR profile
- action 4 — The subject line ends with the serial SEC-BDG-01 taken from the ITSM record
- action 5 — The From address is the operations mailbox confirmed via the mail profile

**Discharges (user request):**
- “One email from the operations mailbox to James Brown's reporting manager”
- “The subject line begins `Access revocation for James Brown on ` and ends with the serial number of the configuration item you selected in step 2, quoted byte for byte from the ITSM record”

**Grounded in (policy):**
- “cross-system data integrity and record scope”

<details><summary>calls</summary>

- `P1-08` **send_message**
- `P1-09` **send_message**

</details>

