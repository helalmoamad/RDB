# `.claude/_specs/`

Ticket workspaces for the staged **Engineering Workflow v1**. Every change moves
through a fixed sequence of lifecycle stages, each producing one Markdown
artifact under `.claude/_specs/<ticket>/`.

## Layout

```
.claude/_specs/
  _templates/          # canonical stage-artifact templates (do not delete)
  <ticket-slug>/       # one workspace per ticket, created by /start-ticket
    ticket.md          # the single source of truth for workflow state (ADR-003)
    intake.md
    research.md
    spec.md
    plan.md
    review.md
    implement.md
    verify.md
```

Each stage produces its artifact from [`_templates/`](_templates). A ticket's
workflow **state lives in exactly one place** — `<ticket>/ticket.md > state`;
never infer state from which artifacts exist.

## Stages & commands

`intake → research → spec → plan → review → implement → verify`

Driven by the slash commands in [`../commands/`](../commands), plus a manual
delivery step (git by hand).

## Canonical sources

This README is an overview. The authoritative definitions live in:

- [`../../CLAUDE.md`](../../CLAUDE.md) — architecture & conventions
- [`../project-config.yaml`](../project-config.yaml) — state machine, modes, validation
- [`../rules/workflow-rules.md`](../rules/workflow-rules.md) — stages, gates, guardrails
- [`../rules/validation-model.md`](../rules/validation-model.md) — validation rules
- [`../docs/command-architecture.md`](../docs/command-architecture.md) — command contracts
- [`../docs/WORKFLOW_V1_RUNBOOK.md`](../docs/WORKFLOW_V1_RUNBOOK.md) — operational runbook

Where this README and a canonical source ever disagree, the canonical source wins.
