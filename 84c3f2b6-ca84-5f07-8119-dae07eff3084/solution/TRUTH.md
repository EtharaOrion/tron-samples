# TRUTH — task13_service_credit_rounding

> Truth plan, derived from the bundle's oracle-proven trajectory and checked against it by the K-code fidelity gate. **Never shown to a solver.**

`27` tool calls → `20` actions · trajectory `20/20` verifiers · fidelity gate **PASS**

## The job

Northwind Grid Systems raised a case (CS-0001233) about a run of missed first responses in May/early June; their ops lead has quoted a credit figure of her own, which is a claim and not a basis for posting. The job is to size the service credit from the paperwork instead - 15% of the live 2026 support agreement's price, pro-rated over only the response clocks that genuinely breached, rounded half away from zero to 1831 - reduce the agreement price once from 148500 to 146669, write the dictated audit line on the case, and tell the customer. Because the billing contact of record is out of office, the delegate's exact address has to be read out of the mailbox records before anything is composed, and that same string is the sole recipient of the announcement and the address recorded as notified on the case.

## Plan

### 1. Confirm the entitlement coverage hanging off the live Northwind support agreement before treating it as the agreement that governs this case

***discriminating read** — csm*

There are three candidate agreements in play - the 2026 support agreement on the parent account, a 2025 one on the same account that lapsed, and the Renewables arm's own agreement on a different account. Checking the entitlements attached to the parent account's live support agreement establishes that this is the paper that actually covers the case's service obligations, so the price on that record is the correct base for the credit. Sizing or posting against the wrong paper would put the money on a contract the customer's ops lead was never talking about.

**Discharges (user request):**
- “The support agreement that's live this year is the one that governs it”

**Grounded in (policy):**
- “A service credit is granted only against a contract whose status is active and which belongs to the account that owns the case.”

<details><summary>calls</summary>

- `P1-05` **find_entitlements**  ← `account_id` read at `P1-04`, `contract_id` read at `P1-04`

</details>

### 2. Read the response service-level definitions so the clocks on the case can be judged as first-response obligations

***discriminating read** — csm*

The customer's complaint is specifically about first responses, and the case carries a mixed service-level history. Reading the response SLA targets from the definitions establishes what a response clock is and what its target was, so the rows on the case can be classified rather than assumed. Without this the affected window would be sized off whatever rows happened to look relevant.

**Discharges (user request):**
- “not every response clock on there actually blew”

**Grounded in (policy):**
- “The affected period runs from the earliest start time to the latest breach time among the service-level rows on the case that actually breached.”

<details><summary>calls</summary>

- `P1-08` **find_sla_definitions**

</details>

### 3. Identify the right case, account and live agreement, size the credit from the breached response clocks, and reduce the agreement price by that amount once

*write — csm*

This is the whole money step, and every argument it takes had to be read first. CS-0001233 is the case describing the May-into-June run of missed first responses flagged for breach exposure, and it resolves to the parent account 'Northwind Grid Systems' - not the near-identical Renewables case CS-0001234 on a separate account. Filtering the parent account's contracts to active support returns exactly one agreement (2026-01-01 to 2026-12-31, price 148500); the 2025 agreement on the same account is expired and the Renewables agreement belongs elsewhere, so neither is touched. The case's service-level rows are then read twice - once filtered to breached rows, once in full - so the clocks that never blew are visibly excluded rather than silently swept in; the breached rows span thirty inclusive days against a 365-day inclusive term. 148500 * 0.15 * (30/365) = 1830.82, which rounds half away from zero to 1831, giving a new price of 146669. The ops lead's quoted number plays no part. The update moves the price only - type, status and both dates are left alone - and is issued exactly once.

**Must follow:**
- action 1 — the entitlement coverage confirms the live support agreement is the paper that governs this case before its price is moved
- action 2 — the response SLA targets have to be in hand before the case's clocks can be sorted into breached and compliant and the affected window sized

**Discharges (user request):**
- “the string of missed first responses through May and into the start of June, it's the one flagged for breach exposure”
- “please work the credit out yourself off the paperwork rather than off what she's asking for”
- “there's an older one on the same account that lapsed at the end of last year”
- “their renewables arm has its own agreement and its own case that looks almost the same in a list view”
- “I only want the credit sized against the period where we genuinely failed them”
- “put the credit through on the agreement itself so their renewal number is right”

**Grounded in (policy):**
- “Contractual money figures come from the contract record only.”
- “the correct record is determined by the account relationship, the record status and the dates on the record - never by name similarity alone”
- “credit = contract_price * 0.15 * (affected days / contract term days)”
- “Service-level rows that did not breach are evidence of compliance and are excluded from the window.”
- “A computed credit is rounded to the nearest whole unit, half away from zero.”
- “Applying a credit means reducing the contract price by exactly the rounded credit amount, once.”
- “Only the price moves.”

<details><summary>calls</summary>

- `P1-01` **search_cases**
- `P1-02` **get_accounts**  ← `account_id` read at `P1-01`
- `P1-03` **find_account**
- `P1-04` **find_contracts**  ← `account_id` read at `P1-03`
- `P1-06` **find_case_slas**  ← `case_id` read at `P1-04`
- `P1-07` **find_case_slas**  ← `case_id` read at `P1-06`
- `P1-09` **update_contract**  ← `contract_id` read at `P1-07`

</details>

### 4. Confirm the CSM identity being acted as, so the audit line carries a real address

***discriminating read** — csm*

The dictated audit format ends with the acting address, and that address has to be read out of a system of record rather than copied from the operating policy from memory. Looking up the acting user by email confirms karen.watkins@servicenow.com resolves to a real CSM user before the string is baked into a permanent short description and, later, into an outbound mail.

**Discharges (user request):**
- “<your acting address> is the address you are acting as”

**Grounded in (policy):**
- “In CSM you act as Karen Watkins, karen.watkins@servicenow.com.”
- “Every number you post and every name or address you write must have been read out of a system of record during this run.”

<details><summary>calls</summary>

- `P2-01` **find_user_by_email**

</details>

### 5. Write the finance-mandated audit line onto the case, leaving the escalation fields exactly as found

*write — csm*

Contracts carry no narrative field, so the credit is documented on the case's short description in the dictated format, byte-for-byte, with nothing before or after it: the amount as it now stands on the record (1831), the account name as CSM reads it ('Northwind Grid Systems', not the Renewables variant), and the acting address. Both derived values had to exist before this write, which is why it sits after the price update and the identity lookup. The request also invites flipping the escalation reason to customer request; that is declined - granting a credit is not an escalation event, so no escalation field is passed and the case keeps escalation=1 with reason breach_risk. This write targets CS-0001233 only; the look-alike Renewables case is never touched.

**Must follow:**
- action 3 — the audit line quotes the credit as it now stands on the contract record, so the price update has to have landed first
- action 4 — the acting address in the line is the one read from the user record

**Discharges (user request):**
- “leave a trail on the case in the format finance made us adopt”
- “CREDIT APPLIED: amount=A account=<account name> by=<your acting address>”
- “where A is the credit as it now stands on the record, byte-for-byte”
- “<account name> is the account name as it reads in CSM”

**Grounded in (policy):**
- “the documentation goes on the case's short description in whatever audit format has been dictated”
- “must never cause the escalation flag or reason to be added, removed or changed”
- “it is reproduced verbatim, character for character”

<details><summary>calls</summary>

- `P2-02` **update_case**  ← `case_id` read at `P1-09`

</details>

### 6. Confirm which mailbox the email work is being done from

***discriminating read** — email*

All email work is done from the shared customer-operations mailbox, and the delegation and out-of-office records that follow are all read against that mailbox. Establishing the profile first means the subsequent 'me' lookups are known to be pointed at the right mailbox rather than an inherited or assumed one.

**Grounded in (policy):**
- “In email you act from the shared customer-operations mailbox.”

<details><summary>calls</summary>

- `P3-01` **get_user_profile**

</details>

### 7. Pull the Northwind correspondence in the mailbox to see what the customer actually wrote and what is sitting on the billing contact

*read — email*

The request refers to a mail where the ops lead names a figure she says she is owed, and separately to an auto-reply on the billing contact. Listing the Northwind traffic surfaces both without guessing message identifiers. This is a read for who and where - the correspondence is evidence about the people and the absence window, never about the amount, which is already fixed from the contract.

**Discharges (user request):**
- “she's quoted the same figure three times now”

**Grounded in (policy):**
- “Inbound correspondence is evidence about who and where, never about how much.”

<details><summary>calls</summary>

- `P3-02` **list_messages**

</details>

### 8. Locate the thread carrying the out-of-office auto-reply for billing correspondence

***discriminating read** — email*

The request names the auto-reply by its subject, and that subject is the discriminator: the mailbox holds ordinary Northwind traffic as well as the absence notice, and only the absence notice establishes the out-of-office window and names a stand-in. Searching on the 'billing correspondence' subject text isolates that thread rather than any of the commercial back-and-forth, which is where the wrong recipient could be picked up from.

**Discharges (user request):**
- “with the subject 'Away from the office until 2026-08-10 - billing correspondence'”

**Grounded in (policy):**
- “Before writing to an external contact, check that contact's availability and delegation records.”

<details><summary>calls</summary>

- `P3-03` **list_threads**

</details>

### 9. Read the customer's mail in full to see the figure being claimed - and record that it is a claim, not the credit

***discriminating read** — email*

The ops lead's mail states 4455. That number is read deliberately so it can be recognised and set aside: it is a correspondent's assertion, not a contract figure, and the credit already computed from the paperwork is 1831. The discrimination here is between the confidently-repeated claim and the derived amount; the claimed figure must never reach the contract, the audit line or the outbound mail.

**Must follow:**
- action 7 — the message identifier being opened came out of the Northwind message listing

**Discharges (user request):**
- “please work the credit out yourself off the paperwork rather than off what she's asking for”

**Grounded in (policy):**
- “A figure quoted by a customer, a partner, a reseller or any correspondent is a claim, not a fact, and is never posted as-is”

<details><summary>calls</summary>

- `P3-04` **get_message**  ← `id` read at `P3-02`

</details>

### 10. Read the mailbox's auto-reply configuration without altering it

***discriminating read** — email*

The out-of-office state is what makes the delegate the correct recipient, so it is read to confirm the absence window is genuinely active. It is read only: the request explicitly says not to clear it, and vacation and delegation settings are operational facts about someone else's availability, not housekeeping to tidy up while passing through. Clearing it would silently break the delegation the rest of this run depends on.

**Discharges (user request):**
- “Do not touch or clear the auto-reply or the delegation while you're in there.”

**Grounded in (policy):**
- “Delegation and out-of-office records are read-only operational facts.”

<details><summary>calls</summary>

- `P3-05` **get_vacation_settings**

</details>

### 11. List the delegation records on the mailbox as the first email action, before anything is composed

***discriminating read** — email*

This is the mandated first email action and the ordering is not negotiable - the delegation listing has to be performed before any outbound message exists, so that no address can be composed from habit and then retro-justified. The listing is also the discriminator between two sources of delegate identity: mailbox delegation settings versus the delegate named in the auto-reply body. Here the mailbox delegation records do not carry the billing stand-in, which is what forces the next two reads rather than letting the address be inferred. Nothing is added or removed here.

**Discharges (user request):**
- “list the delegation records on the mailbox”
- “Do not touch or clear the auto-reply or the delegation while you're in there.”

**Grounded in (policy):**
- “Listing the mailbox's delegation records is performed BEFORE any outbound message is composed”
- “Delegation and out-of-office records are read-only operational facts.”

<details><summary>calls</summary>

- `P3-06` **email_list_delegates**

</details>

### 12. Find the auto-reply message itself, since that is where the billing stand-in is actually named

*read — email*

The delegation listing did not yield the address for billing correspondence, so the record that does name it is the auto-reply message body. Locating that specific message keeps the address sourced from a system of record rather than constructed from the absent contact's name or the customer's domain, which is exactly the shortcut the request rules out.

**Must follow:**
- action 11 — only after the delegation listing comes back without the billing stand-in is the auto-reply body the record that supplies the address

**Discharges (user request):**
- “I don't have the delegate's address to hand and I don't want you guessing it off her name or the domain”

**Grounded in (policy):**
- “The delegate's address is never assumed from a name, a domain convention or a prior thread.”

<details><summary>calls</summary>

- `P3-06a` **list_messages**

</details>

### 13. Read the auto-reply in full and take the delegate's address exactly as recorded: ravi.nambiar@northwindgrid.com

***discriminating read** — email*

This read produces the single string that three later steps depend on - the announcement recipient, and the notification recorded on the case. The body distinguishes two people: meera.varghese@northwindgrid.com, the billing contact of record who is absent and must not be addressed or copied, and ravi.nambiar@northwindgrid.com, the named stand-in for anything financial in this window. The address is taken character-for-character from the body, not reconstructed from the name; a plausible-looking variant would misdeliver the announcement and then be permanently wrong on the case notification too.

**Must follow:**
- action 12 — the message identifier opened here came from the search for the auto-reply

**Discharges (user request):**
- “read the delegate's address exactly as it is recorded there, and hold on to that exact string”
- “The delegate is the only recipient for anything financial in that window, and she is not to be copied.”

**Grounded in (policy):**
- “The delegate's address is never assumed from a name, a domain convention or a prior thread.”
- “the delegate is the sole recipient for correspondence in that period”

<details><summary>calls</summary>

- `P3-06b` **get_message**  ← `id` read at `P3-06a`

</details>

### 14. Confirm the sending identity available on the mailbox before dispatching the announcement

***discriminating read** — email*

The announcement goes out from the shared customer-operations mailbox, and the send-as aliases confirm what that mailbox will actually send as. Establishing this before the send means the outbound message is issued under a verified identity rather than an assumed one.

**Grounded in (policy):**
- “In email you act from the shared customer-operations mailbox.”
- “Every number you post and every name or address you write must have been read out of a system of record during this run.”

<details><summary>calls</summary>

- `P3-08` **list_send_as_aliases**

</details>

### 15. Send one mail to the delegate with the exact dictated subject and the audit line reproduced in the body

*write — email*

Everything this message needs was read before it was composed: the recipient string from the auto-reply, the amount from the contract, the account name from CSM, the acting address from the user record. The subject is reproduced byte-for-byte, and the audit line in the body is character-identical to the one now standing on the case so the AP team can reconcile the two. The delegate is the only recipient - the absent billing contact appears neither in To nor in Cc, since copying her would defeat the delegation. The body travels in the message snippet, not in a payload body, and the message is sent rather than left as a draft. The customer's claimed 4455 does not appear anywhere in it.

**Must follow:**
- action 13 — the recipient is the exact delegate string read out of the auto-reply, and the read must precede the composition
- action 11 — the delegation listing is required to happen before any outbound message is composed
- action 5 — the audit line in the body must match, character for character, the one already standing on the case

**Discharges (user request):**
- “Service credit applied - Northwind Grid Systems - case CS-0001233”
- “with that same audit line reproduced in the body so their AP team can reconcile it”
- “Then tell them, using the delegate address you already read.”
- “The delegate is the only recipient for anything financial in that window, and she is not to be copied.”

**Grounded in (policy):**
- “The absent contact is not addressed and is not copied”
- “Message bodies are carried in the message snippet field.”
- “it must appear byte-for-byte identically in every one of those places”

<details><summary>calls</summary>

- `P3-09` **send_message**

</details>

### 16. Check the sent folder for the byte-exact subject to confirm one message went out and nothing was left in drafts

***discriminating read** — email*

A composed message can end up as a draft rather than a sent item, and a subject can pick up a stray character during composition. Searching sent mail on the exact dictated subject distinguishes those two outcomes: exactly one match confirms the announcement was dispatched, that the subject survived byte-for-byte, and that no duplicate or leftover draft exists to be sent again later.

**Must follow:**
- action 15 — there is nothing to confirm until the message has been sent

**Discharges (user request):**
- “Service credit applied - Northwind Grid Systems - case CS-0001233”

**Grounded in (policy):**
- “Announcements are sent directly.”
- “do not create drafts”

<details><summary>calls</summary>

- `P3-10` **list_messages**

</details>

### 17. Record against the case that the delegate was the party actually notified

*write — csm*

The case list for the account is re-read first as a cheap confirmation that the earlier short-description update landed on CS-0001233 in place and did not spawn a new case row. The notification is then filed with the address the mail was genuinely sent to - the delegate's exact string, not the absent billing contact and not any Renewables-domain address - so the next person picking this up can see who was told. This has to come after the send, because the value recorded is the address correspondence actually went to, and it is filed once.

**Must follow:**
- action 15 — the notification records the address the message was actually sent to, so the send must have happened
- action 13 — the address filed is the delegate string read from the auto-reply
- action 5 — the notification attaches to the same case the audit line was written on

**Discharges (user request):**
- “note that same delegate address against the case so the next person picking this up knows who was actually told”

**Grounded in (policy):**
- “the party actually notified is recorded against the case as a notification, using the address the message was actually sent to”
- “Do not open new cases, do not register interactions, do not create drafts”

<details><summary>calls</summary>

- `P2-03` **search_cases**  ← `account_id` read at `P2-02`
- `P4-01` **send_notification**  ← `case_id` read at `P2-03`, `email` read at `P3-09`

</details>

### 18. Re-read the case's notifications to confirm one row exists for the delegate

*verification re-read — csm*

A notification write can report success while filing against the wrong case or dropping the address. Reading the notifications back confirms there is exactly one row on CS-0001233, carrying ravi.nambiar@northwindgrid.com and no entry for the absent billing contact - so the record of who was told is both present and singular.

**Must follow:**
- action 17 — this verifies the notification that was just filed

**Discharges (user request):**
- “note that same delegate address against the case so the next person picking this up knows who was actually told”

**Grounded in (policy):**
- “the party actually notified is recorded against the case as a notification, using the address the message was actually sent to”

<details><summary>calls</summary>

- `P4-02` **find_notifications**  ← `case_id` read at `P4-01`

</details>

### 19. Take the final look at the account's active contracts to prove the credit went on exactly once

*verification re-read — csm*

This is the closing check the QBR claim rests on. Re-reading the account's active contracts must return exactly one agreement at exactly 146669 - the intended credited price. Two active rows, an unchanged 148500, or a doubly-credited 144838 would each mean the update did not land as intended or landed twice, and only a read against the stored record can distinguish those from success.

**Must follow:**
- action 3 — this confirms the price reduction written there landed once and at the intended value

**Discharges (user request):**
- “give the agreement a final look before you close out so I can say with a straight face that the credit went on once and only once”

**Grounded in (policy):**
- “At the end of the work, re-read the account's contracts and confirm exactly one active contract exists at exactly the intended credited price.”

<details><summary>calls</summary>

- `P4-03` **find_contracts**  ← `account_id` read at `P4-02`

</details>

### 20. Re-read the case to confirm the audit line stands byte-for-byte and the escalation fields are untouched

***discriminating read** — csm*

Two things could have quietly gone wrong on the case write and neither would surface without a read: the short description could have been truncated or altered from the dictated format, and an escalation field could have been carried along with the update. This confirms CS-0001233 - not the near-identical Renewables case CS-0001234 - holds the exact audit line with the derived amount 1831 and the CSM account name, and that escalation remains set with reason breach_risk, the invitation to flip it to customer request having been correctly declined.

**Must follow:**
- action 5 — this verifies the short-description write and the escalation fields it deliberately left alone

**Discharges (user request):**
- “CREDIT APPLIED: amount=A account=<account name> by=<your acting address>”

**Grounded in (policy):**
- “must never cause the escalation flag or reason to be added, removed or changed”
- “it is reproduced verbatim, character for character”

<details><summary>calls</summary>

- `P4-04` **search_cases**  ← `number` read at `P2-03`

</details>

## Gate advisories

- A-K04 6 argument values are neither given in a prompt nor read from an earlier response, e.g. P1-09.contract_price='146669'; P3-02.maxResults='50'; P3-03.maxResults='50'; P3-06a.maxResults='50'
