# ADR 009: Edit the composition-root `applicationVersion` global to bump the reported app version

- **Status:** accepted
- **Date:** 2026-07-14
- **Ticket:** bump-app-version-30
- **Deciders:** helal (reviewer), ali (second approver / workflow_owner)

## Context

The app reports an application-version value to the backend on API request headers
and on FCM registration. That value is the Dart global `int applicationVersion`,
defined once in `lib/main.dart` and read across the API and authentication layers.
The ticket `bump-app-version-30` requires advancing this value from `25` to `30`.

`lib/main.dart` matches the `composition_root` glob in
`project-config.yaml > high_risk_paths`. By GU-2 / MO-3, any edit to a high-risk
path requires `mode: high_risk`, which mandates two approvals, this ADR, and a
rollback rehearsal at verification — even though the change itself is a single
integer-literal edit with no behavioural logic change. An ADR is therefore
required to record why a high-risk-path edit is being made and that its risk is
understood and accepted.

## Decision

Bump the reported app version by editing the single `applicationVersion` global
definition in `lib/main.dart` from `25` to `30`. No new abstraction, indirection,
or config extraction is introduced — the value continues to live at its existing
definition site. The high-risk classification is honoured procedurally (two
approvals, this ADR, rollback rehearsal), not by changing the mechanism.

## Consequences

- Positive: minimal, single-line, immediately reversible change; all reporting
  points (API headers, FCM payload) pick up `30` from the one definition.
- Positive: the high-risk workflow leaves an auditable record (this ADR + review
  approvals) for a composition-root edit.
- Negative: a one-line version bump carries the full high-risk overhead because the
  value is classified by file path rather than behaviour. Accepted as correct per
  the current rules; no exception is sought.
- Rollback is trivial: restore `30 → 25` (single line), no data/state migration.

## Alternatives considered

- **Relocate `applicationVersion` out of `lib/main.dart`** (e.g. into a config
  constant outside high-risk paths) to avoid the composition-root classification —
  not chosen: that is a larger refactor with wider blast radius than the bump it
  aims to simplify, and out of scope for this ticket.
- **Run as `standard` mode** — rejected: `lib/main.dart` is a declared high-risk
  path; downgrading the mode would violate GU-2/MO-3.
