---
ticket: bump-app-version-30
stage: review
mode: high_risk
status: complete
owner: reviewer
updated: 2026-07-14
links:
  clickup:
  github:
---

# Review — bump-app-version-30

> Review gate. The reviewer evaluates the spec and plan before any implementation.

## Review Scope

Reviewed `spec.md` (AC-1..AC-6) and the revised `plan.md` (rev 2, high_risk) for
the application-version bump `20 → 30`, against the mode/guardrail rules in
`project-config.yaml` and `validation-model.md`. This is the re-review after the
prior CHANGES_REQUESTED decision and the ticket's re-classification to
`mode: high_risk`.

## Plan Summary

Change the single global `int applicationVersion` at its one definition site in
`lib/main.dart` from `20` to `30`; no read site is edited. Delivered under
`mode: high_risk` (ADR-009). Validate with the `flutter-standard` profile
(analyze) plus a rollback rehearsal (all-ac + rollback, MO-6). Rollback is a
one-line revert. The plan is sound and traceable to AC-1..AC-6.

## Risks

- **High-risk composition-root edit (accepted).** The change edits
  `lib/main.dart` (composition_root). This is now handled correctly under
  `mode: high_risk` with ADR-009 and a rollback rehearsal — the guardrail
  (MO-3/GU-2) is honoured procedurally, not bypassed.
- **Stale ADR baseline (minor, tracked).** ADR-009 cites a `25` starting value;
  the working tree is `20`. Reconciliation is a governance follow-up on the ADR
  (append/supersede), out of scope for this code change.
- **Pre-existing working-tree edit.** `lib/main.dart` was already modified before
  the workflow; `/implement` must ensure only the version literal changes and no
  unrelated edit is folded in (IM-4).

## Assumptions

- The target value is exactly `30`; only the reported application-version integer
  changes (not pubspec/marketing version or platform build IDs).
- No control flow depends on the value (confirmed in research — reporting only).

## Open Questions

- None blocking. ADR-009 baseline reconciliation remains a governance follow-up.

## Decision

`APPROVED`

- Rationale: The revised plan is correct, minimal, and fully traceable to the
  acceptance criteria (PL-1..PL-5, RV-3). The high-risk `composition_root` edit
  is now delivered under `mode: high_risk` with the mandatory ADR (ADR-009) and a
  rollback rehearsal at verification (MO-6), satisfying MO-3/GU-2/RV-5/RV-6.
  Separation of duties holds: the reviewer is not the plan author (RA-3). Approved
  for implementation.

## Approvals

> `standard` requires 1 approver. `high_risk` requires 1 distinct reviewer
> (canonical: project-config.yaml > modes.high_risk.approvals = 1; RV-5). Must
> not be the plan author; high_risk never self-reviews.

- Approver 1 (reviewer): helal
- Approver 2 (high_risk only): ali (ADR-009 co-decider; supporting, not required by RV-5)

## ADR reference

> Required for `high_risk` APPROVED; otherwise "none".

- ADR: ADR-009 (composition-root `applicationVersion` bump)

## Required Follow-up Actions

- none (approved). At `/implement`: confine changes to the single version literal
  in `lib/main.dart` (IM-4) and ensure the pre-existing working-tree edit is not
  conflated with the bump. At `/verify`: execute the rollback rehearsal (MO-6)
  and record it in `verify.md`.
