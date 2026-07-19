---
ticket: bump-app-version-30
stage: plan
mode: high_risk
status: complete
owner: developer
updated: 2026-07-14
links:
  clickup:
  github:
---

# Plan — bump-app-version-30

> Decide the approach before changing code. Plan only — no implementation here.

> **Revision (rev 2).** Rewritten after `review.md` Decision = CHANGES_REQUESTED.
> Addresses every Required Follow-up Action from the review (see
> "Review follow-ups addressed" below). The ticket has been re-classified
> `mode: high_risk`.

## Approach

Change the single integer literal at the one definition site of the reported
application-version global from `20` to `30`. The value is defined once
(`int applicationVersion` in `lib/main.dart`) and read everywhere else, so a
one-line edit at that site satisfies every reporting point (API headers, FCM
registration) with no divergence. This is the approach recorded in ADR-009. The
rejected alternative — relocating the global out of the composition root to avoid
the high-risk classification — is a larger refactor and out of scope. Because
`lib/main.dart` is a high-risk `composition_root` path, the change is delivered
under `mode: high_risk` (ADR-009, distinct reviewer, rollback rehearsal at
verify), honouring MO-3/GU-2.

## Review follow-ups addressed

- **FU-1 (re-classify to high_risk):** done — this plan and all artifacts are now
  `mode: high_risk`; `ticket.md` records the reclassification.
- **FU-2 (distinct reviewer):** the high_risk `/review` must be run by a reviewer
  who is not the plan author (RA-3; high_risk never self-reviews). Recorded here
  as a gating requirement for the next `/review`.
- **FU-3 (ADR-009 + baseline):** ADR-009 is this ticket's governing ADR and will
  be the `/review` ADR reference (RV-6). Its baseline is stale (`25`); the real
  bump is `20 → 30`. Baseline reconciliation is a governance follow-up on the ADR
  (append/supersede) and is out of scope for this code change.
- **FU-4 (verification depth):** validation now includes a rollback rehearsal
  (all-ac + rollback, MO-6) — see Validation strategy and Rollback.

## Steps

1. Edit the application-version global definition, changing the literal `20` to
   `30`.
2. Confirm no other definition of the value exists (single source), so all read
   sites — API request headers and FCM registration — pick up `30` without
   further edits.
3. Run static analysis to confirm the package is clean.
4. Rehearse rollback (revert `30 → 20`, confirm clean, re-apply `30`) as required
   for high_risk verification.

## Files to change

- `lib/main.dart` — change the single global `int applicationVersion = 20;` to
  `int applicationVersion = 30;` (line 32). This is the **only** file changed.
  No read site is edited. (High-risk `composition_root` path — delivered under
  `mode: high_risk` per ADR-009.)

## Validation strategy

- Validation profile: `flutter-standard`   # analyze; depth all-ac
- Prove each acceptance criterion:
  - AC-1/AC-4: inspect that the single global definition equals `30` and confirm
    (via search) there is no second/divergent definition of the value.
  - AC-2/AC-3: confirm the API-header reporting and FCM-registration payload read
    the same global (they already interpolate it; no code change needed), so both
    report `30`.
  - AC-5: `flutter analyze` is clean; confirm no control flow branches on the
    value (search shows only string interpolation), so behaviour is unchanged.
  - AC-6: confirm `pubspec.yaml` `version` and Android/iOS build identifiers are
    unchanged in the diff.
- **Rollback rehearsal (high_risk, MO-6):** at `/verify`, rehearse reverting the
  literal `30 → 20`, confirm the tree returns to the pre-change state, then
  re-apply `30`. Record the rehearsal outcome in `verify.md`.

## Rollback

- Revert the single literal `30 → 20` (one line, `lib/main.dart`). No data or
  state migration is involved; the change is immediately and fully reversible,
  restoring the exact prior reported value at every reporting site. The rollback
  is rehearsed at verification (see Validation strategy).

## Out of scope

- Editing any read site of the value (API layer, auth widgets, FCM use case).
- Changing `pubspec.yaml` `version` or Android/iOS build identifiers.
- Relocating or refactoring the global out of the composition root.
- Reconciling ADR-009's stale `25` baseline in the ADR text (governance
  follow-up on the ADR, not a code change in this ticket).
