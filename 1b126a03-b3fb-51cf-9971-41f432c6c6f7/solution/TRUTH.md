# TRUTH — 1b126a03-b3fb-51cf-9971-41f432c6c6f7

> Truth plan, derived from the bundle's **proven golden trajectory** and **grounding-checked** against it (every cited call and id verified present in the trajectory). **Never shown to a solver.**

`4` tool calls → `3` actions · trajectory `5/5` verifiers · grounding **VERIFIED**

## The job

We renegotiated with customer Stellar Systems (stellarsystems.com), which must not be confused with the separate Stellar Solutions account. The task is to positively identify Stellar Systems' ACTIVE support agreement (leaving the lapsed warranty untouched), amend it by pushing its end date out exactly one year and setting total contract value to $60,000; update the PRIMARY contact's cell to +1-555-0199 (not the secondary contact); and finally verify — read-only — that the support coverage tied to the amended agreement is still active. Traps: the look-alike account name, the wrong (warranty) contract, and the wrong (secondary) contact.

## Plan

### 1. Resolve Stellar Systems' primary contact and active support contract before writing

***discriminating read** — csm*

List contacts and contracts to positively identify the correct records rather than guessing ids. This disambiguates Stellar Systems (stellarsystems.com) from the look-alike Stellar Solutions account, distinguishes the primary contact (Dana Okoro, 1101) from the secondary contact, and separates the active support agreement (301) from the lapsed warranty agreement that must be left alone. These lookups establish the exact ids used by the subsequent writes.

**Discharges (user request):**
- “Find their active support agreement”
- “They also have a lapsed warranty agreement on file; leave that one alone”
- “update the primary contact's phone (not the secondary contact)”

**Grounded in (policy):**
- “Reader: may call any list_* / get_* lookup tool”
- “act only on records you have positively identified”

<details><summary>calls</summary>

- `P1-01` **find_contacts**
- `P1-02` **find_contracts**

</details>

### 2. Amend the active support contract's end date and value

*write — csm*

Update contract 301 — the active support agreement, not the lapsed warranty — pushing its end_date to 2027-12-31 (exactly one year from the current 2026-12-31 end) and setting contract_price to $60,000. This is permitted because Stellar Systems is a customer-type account. The lapsed warranty contract is deliberately left unmodified.

**Must follow:**
- action 1 — Needs the confirmed active-support contract id 301, not the warranty, to avoid amending the wrong record

**Discharges (user request):**
- “push the end date out by exactly one year and set the total contract value to $60,000”

**Grounded in (policy):**
- “Account Steward: may update contracts and contacts/portal-user attributes for accounts of account_type 'customer'”

<details><summary>calls</summary>

- `P1-03` **update_contract**  ← `contract_id` read at `P1-02`

</details>

### 3. Update the primary contact's cell phone

*write — csm*

Set the phone of primary contact Dana Okoro (user 1101) to +1-555-0199, leaving the secondary contact untouched. This is authorized for a customer-type account. Using the id resolved earlier prevents editing the wrong contact.

**Must follow:**
- action 1 — Needs the confirmed primary-contact id 1101 to avoid updating the secondary contact

**Discharges (user request):**
- “update the primary contact's phone to +1-555-0199 (not the secondary contact)”

**Grounded in (policy):**
- “Account Steward: may update contracts and contacts/portal-user attributes for accounts of account_type 'customer'”

<details><summary>calls</summary>

- `P1-04` **update_user_details**  ← `user_id` read at `P1-01`

</details>

