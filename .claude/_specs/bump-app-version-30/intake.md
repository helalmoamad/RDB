---
ticket: bump-app-version-30
stage: intake
mode: high_risk
status: complete
owner: developer
updated: 2026-07-14
links:
  clickup:
  github:
---

# Intake — bump-app-version-30

> First stage. Qualify the request only. **No technical planning allowed.**

## Ticket Reference

bump-app-version-30 (no ClickUp task / GitHub issue linked)

## Ticket Summary

Bump the application's `applicationVersion` to 30. This is the Dart global
`int applicationVersion` defined once in `lib/main.dart` and reported to the
backend on API request headers and FCM registration. Current value is `20`;
target is `30` (real bump `20 → 30`).

## Ticket Metadata

- id / slug: bump-app-version-30
- title: Bump applicationVersion to 30
- owner: developer
- created: 2026-07-14
- links:

## User Story

> As a release engineer, I want the app's `applicationVersion` bumped to 30, so that the next build ships under the correct version number.

## Acceptance Criteria Presence Check

- Present? (no)
- Notes: To be defined at /spec. Expectation: the `applicationVersion` global in `lib/main.dart` equals `30`.

## Test Cases Presence Check

- Present? (no)
- Notes: To be defined at /spec.

## Missing Information

- None blocking. Resolved: the version-defining source is the Dart global
  `int applicationVersion` at `lib/main.dart:32` (current value `20`); "30" is
  that reported application-version integer, not a pubspec/Gradle build code or
  semantic version name.
- Note for later stages (not blocking intake): `lib/main.dart` is a declared
  high-risk `composition_root` path (`project-config.yaml`), and ADR-009 governs
  this ticket. The mode is currently `standard` per the owner's decision; the
  review/implement gates (MO-3 / GU-2 / IM-5) will require `high_risk` to edit
  this file. ADR-009 also cites a stale starting value (`25`); the actual working
  tree is `20`.

## Readiness Status

`READY`

- Justification: The request is qualified and unambiguous — bump the
  `applicationVersion` global in `lib/main.dart` from `20` to `30`. No blocking
  information remains for research to proceed.
