---
ticket: <ticket-id>
stage: review
mode: standard          # standard | high_risk  (fast deferred, not in v1)
status: not_started     # not_started | in_progress | blocked | complete
owner: em
updated: <YYYY-MM-DD>
links:
  clickup:
  github:
---

# Review — <ticket>

> EM review gate. The EM evaluates the spec and plan before any implementation.

## Review Scope

<what was reviewed: spec, plan, and any context>

## Plan Summary

<the proposed approach, in the reviewer's words>

## Risks

- <risks identified during review>

## Assumptions

- <assumptions the plan relies on>

## Open Questions

- <questions the EM needs answered>

## Decision

`APPROVED` | `CHANGES_REQUESTED` | `REJECTED`

- Rationale:

## Approvals

> `standard` requires 1 approver (EM). `high_risk` requires 2.

- Approver 1 (EM):
- Approver 2 (high_risk only):

## ADR reference

> Required for `high_risk`; otherwise "none".

- ADR: <e.g. ADR-0001, or none>

## Required Follow-up Actions

- <actions needed before implementation may begin, or "none">
