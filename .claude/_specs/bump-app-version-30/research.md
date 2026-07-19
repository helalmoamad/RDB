---
ticket: bump-app-version-30
stage: research
mode: high_risk
status: complete
owner: ai_agent
updated: 2026-07-14
links:
  clickup:
  github:
---

# Research — bump-app-version-30

> Read-only phase. **No implementation is allowed in this command.**

## Goal

Bump the reported application version from `20` to `30`. This is the single Dart
global `int applicationVersion`, defined at `lib/main.dart:32` and read across
the API and authentication layers for outbound reporting (request headers and
the FCM registration payload).

## Relevant directories

- `lib/` — hosts the definition site (`lib/main.dart`) and every read site.
- `lib/core/api/` — `base_api.dart` embeds `applicationVersion` in an outbound
  request header string.
- `lib/features/authentication/` — multiple read sites (OTP verify, biometric
  auth, FCM send use case) interpolate `applicationVersion` into reported
  strings/payloads. Note: this directory is a declared high-risk path
  (`auth_and_session`), but no file here is *edited* by this ticket — they only
  read the global.

## Relevant config files

- `.claude/project-config.yaml` — declares `lib/main.dart` under
  `high_risk_paths.composition_root`; defines modes, `validation_checks`
  (`flutter-analyze`, `build-runner-clean`) and `validation_profiles`
  (`flutter-standard`, `codegen-change`).
- `pubspec.yaml` — carries the *package* version (`version: 1.0.0+21`). This is
  **separate** from `applicationVersion`; the ticket does **not** change it.
- `android/app/build.gradle.kts` — Android `versionCode`/`versionName` derive
  from Flutter's version (pubspec), also **unrelated** to `applicationVersion`.
- `.claude/docs/adr/ADR-009-app-version-bump-composition-root-edit.md` — the
  accepted ADR governing this exact edit. (Records the decision to edit the
  global in place; cites a stale starting value of `25` — actual is `20`.)

## Possibly affected services

- **Backend API** — receives the application-version value in request header
  strings via `lib/core/api/base_api.dart`. After the bump it will observe `30`.
- **FCM registration** — `send_fcm_usecase.dart` sends `"appVersion":
  applicationVersion.toString()`; the registered device record will report `30`.
- **Analytics/telemetry strings** — OTP verify and biometric auth log lines
  interpolate the value (display/logging only; no behavioural branch on it).

No control-flow depends on the numeric value (grep found no comparisons/branches
on `applicationVersion`); all sites stringify it for reporting.

## Test / validation commands available

(Discovered from `project-config.yaml`; **not run** during research.)

- `flutter analyze` — static analysis / lints across the package
  (`validation_checks.flutter-analyze`, `pass_when: exit-zero`). Basis of the
  `flutter-standard` profile.
- `dart run build_runner build --delete-conflicting-outputs && git diff --exit-code`
  — `validation_checks.build-runner-clean`. **Not applicable** here: this ticket
  touches no `@injectable`/`json_serializable`/model/DI source, so no
  regeneration is required.
- `flutter test` — package test runner (available generally; no test currently
  asserts `applicationVersion`).

## Risks and unknowns

- **Mode misclassification (blocking downstream).** `lib/main.dart` is a
  high-risk `composition_root` path, so editing it requires `mode: high_risk`
  (GU-2 / MO-3 / IM-5) and an ADR (ADR-009 already exists). The ticket is
  currently `mode: standard` per owner decision — planning stages will proceed,
  but `/review` (MO-3) and `/implement` (GU-2/IM-5) will **hard-block** until the
  mode is high_risk. Likelihood: certain if unaddressed; impact: cannot pass the
  review gate or implement.
- **Stale ADR baseline.** ADR-009 states the bump is `25 → 30`; the working tree
  is `20`. Low functional impact (target `30` unchanged), but the ADR baseline
  should be reconciled to `20` to keep the audit record accurate.
- **Working tree already dirty.** `lib/main.dart` shows as modified (`M`) in git
  status before any workflow edit — the pre-existing change should be understood
  before `/implement` so the bump isn't conflated with unrelated edits.
- **Blast radius (low, but real by classification).** The value feeds every API
  request header and FCM registration; a wrong literal would misreport the
  version app-wide. The edit itself is a single integer literal.

## Open questions

- Will the mode be switched to `high_risk` before `/review`/`/implement`, or is
  the intent to stop the ticket at planning? (Required to reach implementation.)
- Should ADR-009's baseline be corrected from `25` to `20` (append/supersede,
  since ADRs are append-only)?
- What is the pre-existing uncommitted change in `lib/main.dart`, and is it in
  scope for this ticket or unrelated?

## Notes

- No code was changed during research.
- No auth/session or wallet/KYC high-risk paths were modified during research.
