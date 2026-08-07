# TRUTH — dbb1a73e-e2c5-55fb-84d3-1d6179c0f5c9

> Truth plan, derived from the bundle's **proven golden trajectory** and **grounding-checked** against it (every cited call and id verified present in the trajectory). **Never shown to a solver.**

`2` tool calls → `2` actions · trajectory `5/5` verifiers · grounding **VERIFIED**

## The job

The user wants to check whether POP is enabled on their own mailbox and, if it's off, enable it for ALL mail (not just messages arriving from now on) while setting downloaded messages to be archived so they leave the inbox — then confirm the resulting settings, and touch nothing else. The trap is honoring verified-records-only (read POP settings before writing), correctly mapping 'ALL mail' to accessWindow=allMail and 'archive out of inbox' to disposition=archive, and scoping every call to the acting user via the literal token 'me' without altering unrelated settings.

## Plan

### 1. Read current POP settings before changing anything

*read — email*

Fetch the acting user's current POP configuration via userId 'me' to determine whether POP is currently on or off. This satisfies verified-records-only by establishing the baseline before any write, and confirms the exact fields (accessWindow, disposition) that the follow-on update must set. It also provides the values needed to confirm the change back to the user afterward.

**Discharges (user request):**
- “is POP even on right now?”
- “don't touch anything else”

**Grounded in (policy):**
- “Verified-records-only: never modify a setting you have not first read in the same session”
- “pass `me` unless the acting user has an administrator grant”

<details><summary>calls</summary>

- `P1-01` **get_pop_settings**

</details>

### 2. Enable POP for all mail and archive downloaded messages

*write — email*

Update the acting user's POP settings with accessWindow='allMail' so POP applies to ALL existing mail rather than only new messages, and disposition='archive' so downloaded copies are archived out of the inbox. This reuses the surface read in the prior step and writes only the two requested fields, leaving everything else untouched, then the resulting values are confirmed back to the user.

**Must follow:**
- action 1 — Must read the POP surface first (verified-records-only) and reuse observed values before writing.

**Discharges (user request):**
- “if it's off, turn it on for ALL mail (not just new stuff)”
- “set downloaded messages to get archived so they don't stay in my inbox”
- “confirm the new settings back to me”
- “don't touch anything else”

**Grounded in (policy):**
- “Inspect and modify per-account mail delivery, protocol-access... settings on behalf of the authenticated acting user only”
- “End User (self-service) | Modify own settings | ✅”

<details><summary>calls</summary>

- `P1-02` **update_pop_settings**

</details>

