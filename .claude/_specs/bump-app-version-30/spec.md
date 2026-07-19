---
ticket: bump-app-version-30
stage: spec
mode: high_risk
status: complete
owner: developer
updated: 2026-07-14
links:
  clickup:
  github:
---

# Spec — bump-app-version-30

> Define *what* must be true when done. **No implementation details, no file
> names, no code.**

## Feature Name

Application version bump to 30

## Business Goal

The app reports an application-version number to the backend on every API
request and on push-notification (FCM) registration. This value must advance to
`30` so the backend and analytics attribute activity, telemetry, and
compatibility decisions to the correct client version for the next release.

## User Story

> As a release engineer, I want the app's reported application version raised to
> `30`, so that the next build is identified as version 30 by the backend and
> push-registration services.

## Functional Requirements

- FR-1: The application's reported application version equals `30`.
- FR-2: The value `30` is reported to the backend on outbound API requests
  (in the application-version reporting carried on requests).
- FR-3: The value `30` is reported on push-notification (FCM) registration.
- FR-4: The application-version value is defined in a single place, so all
  reporting points reflect the same number (no divergence between reporting
  sites).

## Non-Functional Requirements

- NFR-1: No behavioural change beyond the reported number — no control flow,
  feature gating, or user-visible behaviour depends on or is altered by the
  value.
- NFR-2: The change is fully and trivially reversible (restore the prior value)
  with no data or state migration.
- NFR-3: Static analysis remains clean after the change.

## Constraints

- C-1: This ticket changes **only** the reported application-version value. It
  does **not** change the package/marketing version or the platform build
  identifiers (e.g. the Android version code), which are governed separately.
- C-2: The value is an integer; the target is exactly `30`.

## Edge Cases

- EC-1: The prior value differs from what governance records assumed
  (records cite a starting value of `25`; the current value is `20`). The
  outcome is unaffected — the target is `30` regardless of the starting value —
  but the discrepancy should be reconciled in the governance record.
- EC-2: A reporting site could read the value independently and drift from the
  single definition. All reporting sites must reflect `30` (covered by FR-4).

## Open Questions

- OQ-1: Will the ticket proceed to implementation under the current mode, or be
  re-classified before the review gate? (The reported-version definition lives
  in a high-risk-classified location; the review/implement gates enforce the
  mode requirement. This is a workflow-mode question, not a spec question, and
  does not change *what* must be true when done.)
- OQ-2: Should the governance record's starting-value baseline be corrected from
  `25` to `20`?

## Acceptance Criteria Mapping

> Give each criterion a stable ID (AC-1, AC-2, …); `verify.md` references these.

| ID   | Acceptance criterion | Maps to requirement |
|------|----------------------|---------------------|
| AC-1 | The reported application version equals `30`. | FR-1 |
| AC-2 | Outbound API requests report application version `30`. | FR-2 |
| AC-3 | Push-notification (FCM) registration reports application version `30`. | FR-3 |
| AC-4 | The application-version value has a single source, and all reporting points reflect `30` (no divergent value). | FR-4 |
| AC-5 | No behaviour other than the reported number changes; static analysis is clean. | NFR-1, NFR-3 |
| AC-6 | Only the reported application-version value changes — package/marketing version and platform build identifiers are untouched. | C-1 |

## Out of Scope

- Changing the package/marketing version in the package manifest (`version`).
- Changing platform build identifiers (Android `versionCode`/`versionName`,
  iOS build number).
- Relocating or refactoring where the application-version value is defined.
- Any change to authentication, session, wallet, KYC, or money-movement
  behaviour.
