# ADR 008: Delivery is performed manually by the developer; standardized next-step guidance

- **Status:** accepted
- **Date:** 2026-06-17
- **Ticket:** wf-005
- **Deciders:** reviewer (gate), developer/ai_agent (author), workflow_owner (governance)

> **Note:** the automated publishing command and its helper script were
> removed (GitHub automation was dropped). Delivery is now manual — the developer
> commits, pushes, and opens the PR by hand. The decisions below about
> **no commit at implement/verify** and **standardized next-step guidance**
> remain in force; the delivery-boundary decision now reads as *manual delivery*.

## Context

Commit creation used to be spread across the lifecycle (an earlier design had
`/implement` commit and a separate publish step push), which made the delivery
lifecycle harder to reason about and easier to get wrong. Separately, the seven
stage commands each reported "what's next" in ad-hoc prose, so operators —
especially newcomers — could not rely on a consistent, complete statement of the
next legal action, required manual steps, or terminal conditions.

wf-005 asks to (a) consolidate where the git commit is created and (b) make the
next expected action explicit after every command — **without** changing the
canonical state machine, approval gates, or `ticket.md` state ownership.

## Decision

1. **Delivery (commit + push + PR) is performed manually by the developer.**
   `/implement` and `/verify` create no commit. After `/verify` closes the
   ticket, the developer stages the explicit implemented paths plus
   `.claude/_specs/<slug>/`, confirms the staged set, commits with a
   `<type>(<area>): <summary>` message, pushes `ticket/<slug>`, and opens the PR
   on GitHub's web UI (base branch `main`). No command creates the commit and no
   `gh` CLI or helper script is involved; delivery performs no workflow-state
   transition.
2. **`/implement` creates no commit.** It applies the planned changes to the
   working tree on the branch and records `implement.md`; the changes remain
   uncommitted until the developer commits at delivery (IM-9). No SHAs are
   recorded at implement.
3. **`/verify` creates no commit.** Validation stays read-only; the absence of a
   commit is expected and is not treated as missing evidence (VF-10, VF-3).
4. **The delivery commit/PR includes the full set:** implementation changes +
   `implement.md` + `verify.md` + the `ticket.md` closure update. On a ticket
   branch the working-tree changes are exactly the ticket's own work, so staging
   is naturally confined (GU-3).
5. **Standardized next-step guidance.** Every stage command emits, on
   completion, a next-step block with five fields: current workflow state; next
   legal command; required manual actions; optional actions; terminal-state
   condition when applicable. Blocked outcomes state the unblock condition;
   terminal outcomes state that no further workflow action is required. The
   contract lives in `command-architecture.md §6`; validation is NS-1..NS-4.
6. **Governance is unchanged in meaning** (AC-9..AC-11): the lifecycle states,
   allowed transitions, approval counts, and `ticket.md` state ownership are
   untouched. Manual delivery is orthogonal to the state machine and performs no
   transition. Next-step guidance is presentation-only and never changes state.

## Consequences

- **Positive:** git history is written at one obvious, developer-controlled
  point; `/implement` and `/verify` become pure working-tree/validation steps;
  PRs contain the complete, verified, closed unit of work; operators get
  consistent, complete next-step guidance. Fully framework- and
  environment-agnostic — no CI/CD, MCP, or GitHub-state readback introduced.
- **Negative / cost:** between `/implement` and manual delivery the work lives
  uncommitted on the branch, so an operator who abandons a ticket without
  delivering leaves no commit (acceptable — nothing was delivered). Manual
  staging must be confined to the ticket's work; the developer stages explicit
  paths and confirms the staged set before committing.

## Alternatives considered

- **Keep `/implement` commits, defer only the push** — rejected: the AC requires
  commit creation to *no longer happen* at implement/verify, and a single
  developer-owned delivery point is simpler than "commit here, push there".
- **A shared snippet file imported by each command** — rejected: commands are
  standalone markdown; a documented contract (§6) that each command fills is
  simpler and avoids a new include mechanism.
- **Reclassify wf-005 as `high_risk`** — not required: no high-risk path
  runtime is touched and every change is reversible text; the reviewer may
  still escalate at the gate. This ADR is recorded even though `standard` does
  not mandate one, satisfying AC-11's "governance recorded, not silently changed".

## Out of scope

Reading/syncing GitHub state into the workflow, merge/auto-merge,
reviewer/label/milestone management, branch deletion, and any change to a
high-risk path. Also out of scope: changes to lifecycle states, allowed
transitions, approval counts, or `ticket.md` ownership.
