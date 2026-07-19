# Workflow Governance — Engineering Workflow v1 (Ramaaz Digital Bank (RDB))

Governance contract for any AI agent (and human) working in this repository under
the engineering workflow. This file is authoritative for **workflow conduct**;
the root `CLAUDE.md` remains authoritative for **codebase architecture and
conventions**. When in doubt, stop and ask the Workflow Owner.

## Mission

This repository hosts **Ramaaz Digital Bank (RDB)** — a Flutter mobile banking
app (Clean Architecture, BLoC, dio, get_it+injectable, dartz). The mission of the
engineering workflow is to make every change **small, reviewed, and verifiable**,
moving through a fixed set of stages with explicit review gates — never
improvising scope or skipping review. Authentication/session safety and the
integrity of wallet/KYC balances and money moved are first-class safety concerns
at every stage.

## Workflow stages

Canonical stages (see `.claude/project-config.yaml` and
`.claude/rules/workflow-rules.md` for full definitions):

1. `intake` — capture and qualify the request.
2. `research` — read-only investigation of the repo and impact.
3. `spec` — define what "done" means (criteria + test cases).
4. `plan` — decide the approach and concrete steps.
5. `review` — a reviewer reviews spec/plan before any code.
6. `implement` — apply the change per the approved plan.
7. `verify` — validate the change and review runtime impact.

Each stage produces an artifact under `.claude/_specs/<ticket>/` from the templates in
`.claude/_specs/_templates/`.

## High-risk triggers (RDB)

The sample workflow keyed `high_risk` to a single narrow runtime concern. In RDB,
`high_risk` mode (2 approvals + mandatory ADR + rollback rehearsal) is required
whenever a change touches any **high-risk path** defined in
`.claude/project-config.yaml > high_risk_paths`:

- **Auth & session** — `lib/features/authentication/**`, `lib/features/security/**`,
  `lib/core/data/repository/prefs_repository_impl.dart`,
  `lib/core/domin/repositories/prefs_repository.dart` (token/passcode/secure-storage,
  biometric/face flows).
- **State management (single AuthBloc)** —
  `lib/features/authentication/presentation/manager/**` (`auth_bloc.dart`,
  `auth_event.dart`, `auth_state.dart`); everything routes through it (wide blast
  radius).
- **Money / wallet / KYC paths** — wallet balance/transfers, login/create-wallet,
  KYC — anything affecting balances shown or money moved
  (`wallet_balance_response_model.dart`, `login_to_wallet_model.dart`,
  `create_wallet_usecase.dart`, kyc routes).
- **API / network, composition & config** — `lib/core/api/**` (dio, client config,
  interceptors, `methods/**`, server detection); `lib/main.dart`, `lib/core/di/**`,
  `lib/base_page.dart`, `lib/service/service_provider.dart`; `.env`, native
  manifests, firebase config, `assets/languages/**`.

**Cross-cutting rule:** any change that alters authentication/session/passcode/token
handling, alters wallet/KYC balances or the amount of money moved, or introduces a
NEW Bloc/Cubit instead of routing through the existing single AuthBloc is
`high_risk` even if its file is not globbed above.

## Hard stop conditions

Stop immediately and request Workflow Owner direction if any of these occur:

- A change would touch a **high-risk path** (see above) outside an explicitly
  approved `implement` stage running in `high_risk` mode.
- The request requires deleting or rewriting existing workflow artifacts.
- Acceptance criteria are missing, ambiguous, or untestable.
- A stage's entry criteria are not met (e.g. implementing before plan approval).
- Scope grows beyond what the approved spec/plan describes.
- A change would let a user access another account/session, leak or cross-use
  tokens/passcodes/biometric state, or perform an unauthorized wallet/KYC action
  (session & security breach).

## Forbidden actions

- Do **not** create workflow commands unless a phase explicitly authorizes it.
- Do **not** implement tickets during research, spec, plan, or review stages.
- Do **not** modify high-risk paths as part of workflow/governance work, or in
  any mode other than an approved `high_risk` implement stage.
- Do **not** hand-edit generated code (`*.g.dart`, `*.config.dart`,
  `lib/core/di/di_container.config.dart`) — change the sources (`@injectable`,
  `json_serializable`, models, DI) and regenerate with
  `dart run build_runner build --delete-conflicting-outputs`.
- Do **not** delete `.claude/_specs/`, `.claude/commands/README.md`, or
  `.claude/project-config.yaml` (the canonical config).
- Do **not** skip stages or self-approve work that requires review. Separation
  of duties (RA-1..RA-3) requires the `reviewer` gate actor to differ from the
  author, **except** for `standard` low-risk tickets when self-review is
  explicitly enabled (`separation_of_duties.allow_self_review.standard: true`).
  `high_risk` never self-reviews.

## Review gate requirements

- The gates `/review` and `/verify` are owned per ticket by a **reviewer** — any
  qualified team member who is **not** the ticket's author. They do **not**
  require an Engineering Manager; the workflow never depends on EM participation
  per ticket.
- The `review` stage is a **mandatory gate**: no `implement` may begin until a
  reviewer accepts the `spec` and `plan`.
- A reviewer signs off again at `verify` before a ticket is considered done.
- Review decisions are recorded as `CHANGES_REQUESTED` / `REJECTED` / `APPROVED`
  against the relevant stage.
- The **Workflow Owner** owns governance (workflow evolution, governance
  decisions, escalations, cross-project issues), not per-ticket sign-off.
  Escalate to the Workflow Owner only when a hard-stop or governance question
  arises.

## Small-change philosophy

- Prefer the smallest change that satisfies the acceptance criteria.
- One ticket = one focused outcome; split anything larger.
- Bias toward read-only investigation first; touch code last and minimally.
- Every change must be reversible and individually verifiable.

## Relationship to other docs

- `CLAUDE.md` (repo root) — codebase architecture, modules, commands, conventions.
- `.claude/project-config.yaml` — canonical state machine, modes, high-risk
  paths, validation checks/profiles.
- `.claude/rules/workflow-rules.md` — stage definitions, gates, guardrails.
- `.claude/rules/validation-model.md` — the validation rule catalogue.
- `.claude/docs/command-architecture.md` — per-command contracts.
