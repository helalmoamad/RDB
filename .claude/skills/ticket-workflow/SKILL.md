---
name: ticket-workflow
description: Operating procedure for taking one unit of work from idea → ClickUp ticket → Engineering-Workflow-v1 stages (start-ticket/research/spec/plan/review/implement/verify) → GitHub PR in the Ramaaz Digital Bank (RDB) Flutter mobile banking app. Use when the user asks to write/create a backlog ticket, task, or user story (RDB Backlog Ticket Standard — see writing-tickets.md), run the ticket workflow, drive the stages, push a ticket to ClickUp, pick standard vs high_risk mode or Track A vs Track B (Laravel→Flutter migration), open the PR, or asks about this environment's gotchas (never hand-edit generated *.g.dart/*.config.dart — regenerate with build_runner; single AuthBloc, no parallel blocs; ClickUp REST vs MCP; branch base = main).
---

# Ticket Workflow Guide — rdb

A practical guide to taking one unit of work from **idea → ClickUp ticket →
Engineering-Workflow-v1 stages → GitHub PR** in the Ramaaz Digital Bank (RDB)
Flutter mobile banking app (Clean Architecture, BLoC, dio, get_it+injectable, dartz).

- **This file** = the single operating procedure (how-to-use + this environment's gotchas).
- **Canonical rules** (never overridden by this guide) =
  `.claude/project-config.yaml`, `.claude/rules/workflow-rules.md`,
  `.claude/rules/validation-model.md`.

> **Run it step-by-step.** Pause and ask for approval before each stage. On
> approval → proceed to the next step; on denial → the operator gives a comment,
> which you incorporate before re-presenting. Never chain stages without an
> approval in between — this applies especially to the review gates and to
> outward-facing actions (ClickUp task creation, git commit/push, opening a PR).

---

## 1. Pick the track

| The task is… | Track | Driver |
|---|---|---|
| New/changed Flutter behavior, no Laravel source | **A — Standard** | the seven stages |
| Porting a Laravel `api/` endpoint to Flutter 1:1 | **B — Migration** | `/migrate-feature` inside the gates |

**High-risk trigger.** If the change touches a high-risk path — auth/session/passcode/
token & secure storage, wallet/KYC balances or money moved, the api/network layer,
the composition root, config/secrets, or generated code — **or** introduces a NEW
Bloc/Cubit instead of routing through the single `AuthBloc` → the ticket **must** be
`mode: high_risk` (2 approvals + ADR + rollback rehearsal). Most Track-B migrations
are high_risk.

---

## 2. The happy path (copy-paste)

```text
# 1. Create the ticket  (write it per writing-tickets.md → .claude/tickets/<slug>.md)
#    follow the RDB Backlog Ticket Standard (see "Writing tickets" below / writing-tickets.md)
#    push it to ClickUp via REST (see §5) → note the returned <task_id>

# 2. Bootstrap the workspace
/start-ticket <slug> "<Title>" mode=standard clickup_id=<task_id>
#    open .claude/_specs/<slug>/intake.md → set Readiness Status = READY

# 3. Author stages
/research <slug>          # read-only discovery → research.md
/spec <slug>              # AC-1..AC-n (no file names / no code) → spec.md
/plan <slug>              # approach, files, validation, rollback → plan.md

# 4. Review gate  (a human is the reviewer — NOT the AI author)
/review <slug> APPROVED "<rationale>"

# 5. Branch, then implement
git pull --no-edit origin main
git checkout -b ticket/<slug>
/implement <slug>         # edits only the planned files, leaves them uncommitted

# 6. Verify → closes the ticket
/verify <slug>            # flutter analyze; maps every AC → PASS closes it

# 7. Deliver to GitHub (manual — see §6)
git add <the ticket's files> && git diff --cached --name-status   # CONFIRM the set
git commit -m "feat(<area>): <summary>"
git push -u origin ticket/<slug>
#    open the compare URL, set base = main, paste PR body → record the PR URL
```

---

## 2b. Writing tickets (step 1 detail)

The ticket written in step 1 must follow the **RDB Backlog Ticket Standard**. Full
instructions — required metadata, the 3 body sections (User Story / Acceptance Criteria /
Test Cases), hard rules, and the quality checklist — are defined canonically in
[Backlog Ticket Standard.md](references/Backlog%20Ticket%20Standard.md);
[`writing-tickets.md`](writing-tickets.md) adds the RDB context and the how-to.
Every run saves the ticket to `.claude/tickets/<slug>.md`.

---

## 3. What each command does

State is owned by one file: `.claude/_specs/<slug>/ticket.md > state`.
Every command reads it, does its work, writes its artifact, and advances it.

`draft → ready-for-research → research-complete → spec-complete → plan-complete → approved → implementation-in-progress → implemented → verified → closed`

| Command | Produces | State after |
|---|---|---|
| `/start-ticket` | `ticket.md` + `intake.md` | `draft` |
| `/research` | `research.md` (read-only discovery) | `ready-for-research` |
| `/spec` | `spec.md` (requirements + `AC-n`) | `research-complete` |
| `/plan` | `plan.md` (approach, files, validation, rollback) | `spec-complete` |
| `/review APPROVED` | `review.md` | `approved` (REJECTED → `closed`) |
| `/implement` | branch + code edits (no commit) + `implement.md` | `implemented` |
| `/verify` | `verify.md`; PASS closes | `closed` (FAIL → blocked) |

After `/verify` closes the ticket, **delivery to GitHub is manual** (git by hand +
open the PR in the browser — see §6). It is not a command, not a gate, and changes
no workflow state.

---

## 4. Track B — Laravel→Flutter migrations

Keep the same governance (ticket + gates + PR), but let `/migrate-feature` supply
the engineering content. Authoritative knowledge:
[`.claude/docs/laravel-to-flutter-migration.md`](../../docs/laravel-to-flutter-migration.md).

```text
/migrate-feature <laravel-route-uri>     e.g. mobile/product/details/{slug}
```

Maps onto the stages: **research** = read the Laravel vertical slice (route →
controller → request → model → resource → CPU/service) — **STOP and ask** if the
endpoint's contract/model is ambiguous or anything is unclear (do not invent
response fields); **plan** = file-by-file in dependency order (model → url-route
constant → datasource → repository interface → repository impl → usecase → AuthBloc
event/state/handler → pages/widgets → build_runner); **implement** = build the
vertical slice up the layers, then **`dart run build_runner build --delete-conflicting-outputs`**
to regenerate DI + json (never hand-edit `*.g.dart` / `*.config.dart`); **verify** =
`flutter analyze` + `flutter test`, then update the "Modules" list in `CLAUDE.md`.

**Route through the SINGLE `AuthBloc`** — add the event/state/handler there; adding a
new Bloc/Cubit is an architecture violation and is high_risk.

**Golden rule:** preserve the scenario, clean up only the Dart implementation
quality — no added/dropped/renamed/reordered fields, no changed defaults or
arguments. If the source looks wrong, ask; don't "fix" it in the port. Reuse existing
models/usecases/clients rather than duplicating. Every `translate("x")` / `__("x")` →
`"x".tr()` (easy_localization) with authentic strings seeded into **all**
`assets/languages/*.json` bundles.

---

## 5. Push a ticket to ClickUp (REST, not MCP)

The ClickUp **MCP** server is license-locked for writes here, so use the REST API
with the token in the gitignored `.env`:

```powershell
$tok = ((Get-Content "d:\Ramaaz_Digital_Bank\rdb\.env" | Where-Object { $_ -match '^CLICKUP_API_TOKEN=' } | Select-Object -First 1) -replace '^CLICKUP_API_TOKEN=','' -replace '"','').Trim()
$raw = Get-Content "d:\Ramaaz_Digital_Bank\rdb\.claude\tickets\<slug>.md" -Raw -Encoding utf8
# Description starts at the User Story - drop the H1 title heading + Metadata table
# (Title is the task `name`; metadata belongs in ClickUp fields, not the body).
$body = $raw.Substring($raw.IndexOf("## User Story"))
# Dodge ClickUp's misleading 413 on non-ASCII glyphs:
$body = $body -replace [char]0x26A0,'(!)' -replace [char]0xFE0F,'' -replace [char]0x2014,'-' -replace [char]0x2192,'->'
$body = -join ($body.ToCharArray() | Where-Object { [int]$_ -lt 128 })
# Default: assign <ASSIGNEE_ID> + tag "<TAG>" (space tag must exist).
$payload = @{ name = "<Ticket Title>"; description = $body; assignees = @(<ASSIGNEE_ID>); tags = @("<TAG>") } | ConvertTo-Json -Depth 5
$resp = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/list/<LIST_ID>/task" -Method Post -Headers @{ Authorization = $tok } -ContentType "application/json" -Body $payload
"$($resp.id)  $($resp.url)"
```

> **Two ClickUp gotchas (learned the hard way):**
> 1. **Description body starts at `## User Story`.** Do **not** paste the ticket file's
>    H1 title + Metadata table into the description — the Title is the task `name`, and the
>    metadata (Backbone/Actor/Time Estimate/Work Item Type/Risk Level) belongs in ClickUp
>    fields. The `.Substring(IndexOf("## User Story"))` above strips them.
> 2. **Custom fields can't be set on this workspace's plan.** `POST .../task/<id>/field/<id>`
>    returns `{"err":"Custom field usages exceeded for your plan","ECODE":"FIELD_033"}`.
>    Don't waste calls trying — leave that metadata in the canonical ticket file
>    (`.claude/tickets/<slug>.md`) + the workflow's `ticket.md` (which is what the stages
>    actually read `mode` from). Only `name`, `description`, `assignees`, `tags`, and the
>    native task `status` are reliably writable via REST here.

Fill in the real ClickUp ids the user provides — the target list `<LIST_ID>`, the
`<ASSIGNEE_ID>`, and the space `<SPACE_ID>` / `<TAG>`. To (re)discover lists:
```bash
TOK=$(grep -h '^CLICKUP_API_TOKEN=' /d/Ramaaz_Digital_Bank/rdb/.env | head -1 | cut -d= -f2- | tr -d '"'"'"' \r')
curl -s -H "Authorization: $TOK" "https://api.clickup.com/api/v2/space/<SPACE_ID>/folder?archived=false"
```
**Read a task back** (read-only, the `clickup_intake.py` equivalent): `GET
https://api.clickup.com/api/v2/task/<task_id>` → `{name, description, url}`.

---

## 6. Deliver to GitHub (manual)

Delivery is **manual** — no command creates the commit or opens the PR. After
`/verify` closes the ticket, the developer runs git by hand and opens the PR in the
browser. Stage **explicit paths only** (never `git add -A` — it sweeps unrelated
files):

```bash
git add lib/... assets/languages/*.json .claude/_specs/<slug>/
git restore --staged <anything pre-staged that isn't yours>   # check the index first!
git diff --cached --name-status                               # CONFIRM before committing
git commit -m "feat(<area>): <summary>

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
git push -u origin ticket/<slug>
# GitHub prints a compare URL for pull/new/ticket/<slug>
# open it in the browser, set base = main (branch was cut from main), create the PR,
# then paste the PR URL into ticket.md > links.github
```

This step performs no workflow-state transition; the only thing recorded back is the
PR URL in `ticket.md > links.github`.

---

## 7. Rules that bite (this environment)

| Thing | Rule / reality | Do instead |
|---|---|---|
| generated files | never hand-edit `*.g.dart` / `*.config.dart` (incl. `di_container.config.dart`) | regenerate with `dart run build_runner build --delete-conflicting-outputs`; validate with `flutter analyze` + `flutter test` |
| new Bloc/Cubit | adding one instead of routing through `AuthBloc` is an architecture violation | add the event/state/handler to the SINGLE `AuthBloc` (high_risk if auth/session/money) |
| Review gates | self-review is OFF (`allow_self_review.standard: false`) | a human is the reviewer of record, distinct from the AI author |
| `/implement` branch base | GU-4 base is `main` | `git pull origin main` then branch `ticket/<slug>` from a clean `main` |
| ClickUp writes | MCP license-locked | REST API + `.env` token (§5) |
| pre-staged index | rides into commits even after targeted `git add` | `git diff --cached` + `git restore --staged` before every commit |
| high-risk paths | need `mode: high_risk` | 2 approvals + ADR + rollback rehearsal |

---

## 8. Reference map

- Ticket writing standard: `writing-tickets.md` + `references/` (in this skill)
- Ticket state (single source of truth): `.claude/_specs/<slug>/ticket.md > state`
- All stage artifacts: `.claude/_specs/<slug>/`
- Command definitions: `.claude/commands/*.md`
- Templates: `.claude/_specs/_templates/*.md`
- Migration knowledge: `.claude/docs/laravel-to-flutter-migration.md`
- Canonical rules/config: `.claude/rules/*.md`, `.claude/project-config.yaml`
