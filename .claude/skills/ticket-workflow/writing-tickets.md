# Writing tickets — RDB Backlog Ticket writer

Produce a backlog ticket that fully complies with the **RDB Backlog Ticket Standard**.

> **The format is defined once, canonically, in
> [`references/Backlog Ticket Standard.md`](references/Backlog%20Ticket%20Standard.md)** —
> required metadata, the status workflow, the exact 3-section body template
> (User Story → Acceptance Criteria → Test Cases), the "Common Mistakes to Avoid"
> rules, and the Ticket Quality Checklist. **Follow it verbatim; do not restate it
> here.** This file only adds the RDB context and the operational how-to.

## Project context (RDB)

Ramaaz Digital Bank (RDB) is a **Flutter mobile banking app** (Clean Architecture:
Page/Widget → AuthBloc → UseCase → Repository interface → RepositoryImpl →
RemoteDatasource → GetClient/PostClient/… → dio). Keep this in mind when writing criteria:

- **Session & Security Safety is real and mandatory** — a user can only ever access
  their own account and session; tokens, passcodes, and biometric/face state are never
  leaked or cross-used; every money/KYC action is authorized and scoped to the
  authenticated user. Because RDB is a bank, the `Session & Security Safety` section is
  **never optional**.
- **UI is primary** — RDB is a mobile app whose screens consume the wallet/KYC backend.
  Keep "UI & API Consistency": UI and API enforce identical rules, and auth failures
  (401/403) are handled and surfaced clearly in the UI. State every screen's expected
  behavior rather than inventing it.
- **New APIs/features route through the SINGLE `AuthBloc`** — no parallel blocs/cubits.
  Adding a new Bloc/Cubit is an architecture violation and is high_risk.
- **Backbone** is the module the ticket belongs to. Use a real RDB module, e.g.:
  `Authentication`, `Onboarding/Registration`, `Passcode`, `Biometric/Face`, `Wallet`,
  `KYC`, `Transfers/Payments`, `Security`, `Notifications (FCM)`, `Profile`,
  `Localization`. If a new module is implied, name it clearly.
- **Actors** in RDB map to: `Normal User`, `System Admin`, `System`
  (e.g. an FCM push handler or scheduled job acting with no human actor).

## How to use

0. **First read the project summary / `CLAUDE.md`** so the ticket reflects the real modules,
   conventions, and constraints.
1. Take the feature the user describes (e.g. "add a wallet balance overview screen").
2. Fill in **every required metadata field** (per the Standard). If a value is genuinely
   unknowable (Assignee, exact Sprint, Time Estimate), put a sensible placeholder/estimate
   and flag it with `⚠️` — a blank required field fails the standard.
3. Write the body with **exactly the 3 sections, in order** (per the Standard's template):
   User Story → Acceptance Criteria → Test Cases.
4. End with the **Ticket Quality Checklist** (from the Standard), ticking each box `[x]`
   only when the ticket genuinely satisfies it.
5. Output the whole ticket in one markdown block the user can paste straight into ClickUp.
6. **Always save the ticket to a markdown file** (see below) — every run ends by writing it.

## Always save to a markdown file

Every invocation MUST finish by writing the full ticket to a markdown file — do not stop at
showing it in chat. Rules:

- **Location:** `.claude/tickets/` at the repo root. Create the directory if it does not exist.
- **Filename:** a kebab-case slug derived from the ticket Title, e.g.
  `add-wallet-balance-overview.md`. If a file with that name already exists and is a
  *different* ticket, append a short disambiguator rather than overwriting.
- **Contents:** the exact same markdown you output in chat — metadata table, the 3 body
  sections, and the Ticket Quality Checklist — nothing trimmed.
- **Multiple tickets in one run** (e.g. an epic split into children): write one file per
  ticket, and name them so the relationship is clear (e.g. `epic-<slug>.md` plus
  `<slug>-01-foundation.md`).
- After writing, tell the user the file path so they can open or paste it.
