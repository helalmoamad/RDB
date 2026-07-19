---
ticket: bump-app-version-30
stage: verify
mode: high_risk
status: complete
owner: reviewer
updated: 2026-07-14
links:
  clickup:
  github:
---

# Verify — bump-app-version-30

> Final validation and impact review before the ticket is closed.

## Checks performed

> Reference acceptance-criteria IDs from `spec.md` (AC-1, AC-2, …).
> If `plan.md` named a validation profile, record each executed check resolved
> from `project-config.yaml` (profile → check → command), incl. exit code and a
> bounded output summary.

- Validation profile: `flutter-standard` → check `flutter-analyze` → command
  `flutter analyze` (`pass_when: exit-zero`). Depth `all-ac`; mode `high_risk`
  adds a rollback rehearsal (MO-6). Executed locally, read-only (VP-2/VP-3).

| AC ID | Check / test case | Command (resolved) | Exit | Output summary | Result |
|-------|-------------------|--------------------|------|----------------|--------|
| AC-1 | `applicationVersion` global equals `30` | `git show` / inspect `lib/main.dart:32` | — | `int applicationVersion = 30;` | PASS |
| AC-2 | API request-header reporting uses the global | inspect `lib/core/api/base_api.dart:33` (`application version: $applicationVersion`) | — | reads the single global → reports `30` | PASS |
| AC-3 | FCM registration reports the global | inspect `lib/features/authentication/domain/use_cases/send_fcm_usecase.dart:38` (`"appVersion": applicationVersion.toString()`) | — | reads the single global → reports `30` | PASS |
| AC-4 | Single source; all reporting points reflect `30` | `grep -rn applicationVersion lib/` | — | exactly one definition (`main.dart:32`); all other hits are reads. `home_page.dart:85 applicationVersion: "1.0.0"` is a distinct named widget arg, not this global | PASS |
| AC-5 | No behaviour change; static analysis clean | `flutter analyze` | 0 | `No issues found! (ran in 18.6s)` | PASS |
| AC-6 | Only the reported value changes | `git diff --stat` | — | `1 file changed, 1 insertion(+), 1 deletion(-)` — only `lib/main.dart:32`; `pubspec.yaml` version & Android/iOS build IDs untouched | PASS |

## Commands run

- `flutter analyze` (profile `flutter-standard` → `flutter-analyze`, pass_when exit-zero)
  ```
  Analyzing rdb...
  No issues found! (ran in 18.6s)
  EXIT_CODE=0        → PASS (AC-5)
  ```
- `git diff -- lib/main.dart` / `git diff --stat`
  ```
  -int applicationVersion = 25;
  +int applicationVersion = 30;
  1 file changed, 1 insertion(+), 1 deletion(-)   → confined to line 32 (AC-6)
  ```
- **Rollback rehearsal (high_risk, MO-6):**
  ```
  before:  int applicationVersion = 30;   (diff: 1 file, 1 line)
  rollback: git checkout -- lib/main.dart
  after rollback:  int applicationVersion = 25;   (git status: clean — no residue)
  re-apply: set 30
  after re-apply:  int applicationVersion = 30;   (diff back to 1 line 25->30)
  → rollback reverts cleanly to the committed baseline and re-applies with no
    residual change; net working-tree state unchanged (VP-2).  → PASS
  ```
- Post-validation working-tree check (VP-2): `git status --short` → only
  `M lib/main.dart` (the delivered change) and untracked `.claude/`; validation
  introduced no implementation-file change (VF-7).

## Security & money impact review

- Did this ticket change any auth/session/passcode or wallet/KYC/money high-risk
  path? **Yes — high-risk path touched (composition_root).** The change edits
  `lib/main.dart`, a declared `composition_root` high-risk path.
- If yes: which files, and was the change intended and reviewed? **`lib/main.dart`
  only.** The edit was intended and **approved at the review gate** under
  `mode: high_risk` with **ADR-009** (reviewer: helal). It did **not** alter
  authentication/session/passcode or wallet/KYC/money integrity, and introduced
  **no** new Bloc/Cubit (nothing routes around the single AuthBloc). It only
  raises the reported application-version integer read by the API-header and FCM
  reporting sites. (TR-3 / VF-9 statement satisfied.)

## Sign-off

- Outcome: **verified** (all AC-1..AC-6 PASS + rollback rehearsal PASS)
- Final ticket state: `closed`   # reviewer transitions verified → closed
- Approver(s): helal (reviewer). ADR-009 (co-decider ali) governs the high_risk change.
- Commit: none created at verify (VF-10 / ADR-008 — committing is done **manually
  by the developer** at delivery)
- Notes: Delivered change is a single uncommitted line on branch
  `ticket/bump-app-version-30` (`applicationVersion 25 → 30`). The pre-existing
  unrelated `25 → 20` working-tree edit remains stashed at `stash@{0}`. ADR-009's
  stale `25` baseline matched the actual committed baseline; the earlier
  `20 → 30` framing came from that stashed edit (recorded as a deviation in
  `implement.md`).
