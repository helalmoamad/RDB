# Architecture Decision Records (ADRs)

Append-only log of significant or hard-to-reverse decisions. Use
[`ADR-0000-template.md`](./ADR-0000-template.md) as the starting point and number
ADRs sequentially (`ADR-0001-...md`, `ADR-0002-...md`).

Rules:

- One decision per ADR; reference the originating ticket.
- ADRs are immutable once `accepted` — to change a decision, add a new ADR that
  supersedes the old one (mark the old one `superseded by ADR-<n>`).
- A ticket references its ADRs in the relevant stage artifact.

## Index

| ADR | Title | Status | Ticket |
|-----|-------|--------|--------|
| 001 | _(reserved — not yet written)_ | — | — |
| 002 | _(reserved — not yet written)_ | — | — |
| 003 | [Ticket state ownership](./ADR-003-ticket-state-ownership.md) | accepted | workflow-phase-5.95 |
| 005 | [ClickUp intake](./ADR-005-clickup-intake.md) | accepted | wf-pilot-002 |
| 006 | [Validation profiles](./ADR-006-validation-profiles.md) | accepted | wf-pilot-003 |
| 007 | _(withdrawn — GitHub PR publish automation dropped; delivery is manual)_ | withdrawn | wf-004 |
| 008 | [Manual delivery + next-step guidance](./ADR-008-delivery-commit-boundary.md) | accepted | wf-005 |

> Note: ADR-003 was assigned by the phase that created it; 001–002 are reserved
> for earlier decisions not yet retro-documented. ADR-007 was withdrawn when the
> automated GitHub publishing was removed; ADR-008 now describes manual delivery.
