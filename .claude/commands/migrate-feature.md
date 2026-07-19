---
description: Port a Laravel api/ endpoint into the RDB Flutter app — reads the Laravel vertical slice, proposes a migration plan for approval, then implements the equivalent Flutter vertical slice across all Clean-Architecture layers (routed through the single AuthBloc).
argument-hint: <laravel-route-uri>   e.g. mobile/wallet/balance
allowed-tools: Read, Grep, Glob, Write, Edit, Bash, EnterPlanMode, ExitPlanMode
---

# /migrate-feature

You are a Laravel and Flutter developer. You are tasked with porting a single
Laravel **`api/`** endpoint into the RDB Flutter app. You will read the Laravel
vertical slice, propose a migration plan for approval, then implement the
equivalent Flutter vertical slice across all Clean-Architecture layers.

Port a single Laravel **`api/`** endpoint (`mobile/*`, `web/*`, `customer/*`, or a
shared resource group) from `C:\clearance-marketplace-admin` into this Flutter app
(`rdb`) as a Clean-Architecture vertical slice — routed through the **single
`AuthBloc`**.

**Authoritative reference — apply it, do not reinvent:**
`.claude/docs/laravel-to-flutter-migration.md` (the playbook). This command is the
process; the playbook is the knowledge.

This is the **lightweight standalone flow** — it does NOT use the `/start-ticket`
state machine. See the governance flag in Step 4 / playbook §E.

## ⚠️ Core principle — preserve the scenario, clean up only the Dart code

**Changing the endpoint's behavior/scenario during a port is dangerous and is NOT
allowed.** The Flutter port must be a **behavior-for-behavior mirror** of the
Laravel vertical slice — same inputs, same queries/filters, same business rules,
same response shape and field values, same edge cases, same auth/session scoping.
Do **not** "improve", add, drop, rename, reorder, or reinterpret any field,
condition, default, or side effect, and do **not** pass a different argument than
the Laravel source (e.g. `storage_asset($path, false)` must stay `withBaseUrl=false`,
not `true`) — even when the current behavior looks wrong. If something seems like a
bug or a worthwhile behavior change, **STOP and ask** — never decide it yourself.

**What you MAY improve is the Dart *implementation quality only*** — cleaner code
that produces the same observable result: better naming, reusing existing
models/usecases/datasources/API clients and constants, fewer allocations, clearer
control flow, a single canonical model/usecase instead of duplicated ones. Cleaner
code, identical behavior.

When in doubt, faithfulness to the Laravel scenario wins over elegance. Call out any
unavoidable platform difference (e.g. datetime formatting) in the Step 6 report.

**Translated strings** — every Laravel `translate("…")` / `__("…")` must go through
`"<same id>".tr()` (easy_localization; never a raw literal), and the id must be
seeded with authentic translations into **all** `assets/languages/*.json` bundles.
Full rules → **playbook §B (Localization)**.

## Input

- `$ARGUMENTS` — the Laravel route URI (e.g. `mobile/wallet/balance`) or a
  `Controller@method` reference. If missing, ask once, then proceed.

## Step 1 — Read the Laravel vertical slice (read-only)

Follow playbook **§A** to locate and read, in order:
1. **Route** — the file under `routes/api/v1/` matching the URI prefix; capture
   method, URI, controller alias, middleware (`auth:api`?), prefix groups.
2. **Controller** — `app/Http/Controllers/api/v1/...` (mind the three aliased
   `ProductController`s). Read the target method.
3. **Validation** — any type-hinted `*Request` (`app/Http/Requests/...`).
4. **Models** — `app/Domain/.../Model/` → `app/Model/` → `app/Models/`.
5. **Resource** — `app/Resources/v1/...` `toArray()` = the exact response field list.
6. **Business logic** — `app/CPU/*Manager.php` / `app/Services/*` the method calls.

Do not modify anything in the Laravel project — it is a read-only source of truth.
Do not read the commented codes I don't want them.
Do not read any codes that are not in the vertical slice of the endpoint.
Ask me if there is any ambiguity in the vertical slice (e.g. multiple controllers
with the same name, or multiple methods with the same name in a controller) or if
you need clarification on any part of the vertical slice.

## Step 2 — Summarize the scenario

State concisely: HTTP method + URI, auth requirement, inputs (path/query/body +
validation rules), the queries/business logic, the response shape (field list),
and how localization/currency apply. Confirm which RDB **feature** it maps to
(new vs. existing datasource/repository/usecase) and that it will route through the
**single AuthBloc** (a new event/state/handler — never a new Bloc/Cubit).

## Step 2.5 — Ambiguous-contract gate (STOP and ask)

Before planning, resolve the endpoint's exact response contract. The Laravel
**Resource `toArray()`** is the authoritative field list; the model DTO's
`fromJson` must mirror it **exactly** (same keys, same nullability, same types).

**If the endpoint's contract/model is ambiguous — a field's type/nullability is
unclear, a Resource conditionally includes fields, or the response shape cannot be
determined from the slice — STOP and ask me. Do NOT invent response fields, guess
types, or infer the shape from unrelated Eloquent usage.** Wait for me to confirm
the authoritative field list before you write the model and proceed to the plan.
List each ambiguous field by name when you ask.

## Step 2.6 — Reuse existing Flutter code (avoid duplicates)

With the contract confirmed, **before planning any new Dart code**, search the RDB
app for code that already covers what this endpoint needs — the same model, the
same datasource call, the same usecase, or the same API-client helper:

- **Models** — `lib/**/data/models/*_model.dart`: reuse an existing `*_model.dart`
  (or a small generalization) rather than adding a near-identical DTO.
- **Datasources** — `lib/**/data/data_sources/*_remote_datasource.dart`: prefer
  adding a method to an existing `@injectable` datasource over a parallel one.
- **Repositories / usecases** — `lib/**/domain/repositories/*.dart`,
  `lib/**/domain/use_cases/*_usecase.dart`: reuse an existing method/usecase when
  it fits.
- **API clients / routes** — `lib/core/api/methods/**` and the
  `lib/common/constant/configuration/*_url_routes.dart` constants: reuse the
  existing `Get/Post/Patch/Put/DeleteClient` helpers and add the endpoint constant
  to the right `*_url_routes.dart`.

Only write **new** code when nothing existing covers the shape, and say so in the
plan (name what you searched and why it doesn't fit). This keeps one canonical
model/usecase per scenario and avoids duplicated logic drifting apart.

## Step 3 — Propose the migration plan (enter plan mode)

Produce the plan using playbook **§C** (file-by-file, dependency order) and **§B**
(envelope + localization + auth mappings). The plan must name, in dependency order:
1. **Model** — `data/models/<entity>_model.dart` (hand-written `fromJson` mirroring
   the Laravel Resource `toArray()` field list EXACTLY; `json_serializable` only if
   the feature already uses it).
2. **Endpoint constant** — `common/constant/configuration/<area>_url_routes.dart`.
3. **Datasource** — `data/data_sources/<feature>_remote_datasource.dart`
   (`@injectable`; `Get/Post/Patch/Put/DeleteClient` with `RequestConfig` +
   `ResponseValue` + `ServerName`).
4. **Repository interface** — `domain/repositories/<feature>_repository.dart`
   (add method → `Future<Either<Failure, T>>`).
5. **Repository impl** — `data/repositories/<feature>_repository_impl.dart`
   (implement; map exceptions → `Failure`).
6. **UseCase** — `domain/use_cases/<action>_usecase.dart` (`@injectable`,
   `UseCase<T, Params>`, `NoParams` if the endpoint takes no input).
7. **AuthBloc wiring** — `presentation/manager/auth_event.dart` +
   `auth_state.dart` + `auth_bloc.dart` (add the event/state/handler — route
   through the **SINGLE AuthBloc**; **NO new Bloc/Cubit**).
8. **UI** — `presentation/pages|widgets` (consume via `BlocBuilder`/`BlocListener`).
9. Whether `dart run build_runner build --delete-conflicting-outputs` regeneration
   is required (new `@injectable` / `json_serializable` / DI).
10. Localization keys to seed into every `assets/languages/*.json` bundle.
- the exact list of files to create/edit.

Show the plan and **wait for approval** (`ExitPlanMode`). Do not write Dart source
before approval.

## Step 4 — Implement (after approval)

Apply changes in playbook §C dependency order:
1. Model → endpoint constant → datasource (`@injectable`) → repository interface →
   repository impl (exceptions → `Failure`) → usecase (`@injectable`) → AuthBloc
   event/state/handler → UI.
2. **Route everything through the single `AuthBloc`** — add a new event, state, and
   handler; **never** add a parallel Bloc/Cubit (that is an architecture violation
   and is high_risk).
3. Run **`dart run build_runner build --delete-conflicting-outputs`** to regenerate
   DI + json (`*.g.dart`, `*.config.dart`, `di_container.config.dart`) — **never
   hand-edit generated files.**
4. Preserve conventions (playbook §D): `Either<Failure, T>` returns,
   `@injectable` registration, session/auth scoping, and a `// Mirrors PHP ...`
   doc-comment for parity.
5. **Stick to the scenario (see Core principle above):** implement the same
   behavior the Laravel slice has — cleaner Dart code is welcome, changed behavior
   is not. Match every field, condition, default, argument, and edge case exactly;
   if the source looks wrong, STOP and ask instead of "fixing" it in the port.

**Governance flag (playbook §E):** if the endpoint touches **money/wallet/KYC** or
**authentication/session/passcode** — or would introduce a new Bloc/Cubit — call it
out explicitly and recommend the heavier `high_risk` review before proceeding — do
not silently port it under the lightweight flow.

## Step 5 — Verify

- Run **`flutter analyze`** then **`flutter test`**.
- If codegen changed, run **`dart run build_runner build --delete-conflicting-outputs`**
  and confirm generated code is in sync (`git diff --exit-code`) — never hand-edit
  `*.g.dart` / `*.config.dart`.
- Fix any failures before reporting done.
- Update CLAUDE.md's "Modules (Backbones)" list with the new feature/module.
- Review the code between the Laravel and Flutter implementations for parity, and
  note any differences in behavior or edge cases. If there are any, document them in
  the report.
- Confirm every Laravel `translate(...)` / `__(...)` string maps to a `"…".tr()`
  key seeded into all `assets/languages/*.json` bundles.

## Step 6 — Report

List every file created/edited, the feature/usecase and the AuthBloc event/state
added, and a concrete smoke-test (example request with required `lang`/`country`
context and, for protected routes, the authenticated session/token) showing the UI
consuming the new slice via `BlocBuilder`/`BlocListener`.

## Reference slice (Flutter)

The `getUserProfile` slice is the canonical shape to mirror:
`auth_remote_datasource.dart` → `auth_repository.dart` / `auth_repository_impl.dart`
→ `get_user_profile_usecase.dart` → **AuthBloc** (event → handler → state) → UI.
Follow the same layering, naming, and `Either<Failure, T>` flow for the ported
endpoint.
