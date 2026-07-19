# `.claude/commands/`

Home for the ticket-workflow slash commands. Each command operates on a ticket
workspace under `.claude/_specs/<ticket>/`, reads/writes state in `ticket.md`, and
produces its stage artifact from [`.claude/_specs/_templates/`](../_specs/_templates).

The seven lifecycle stages plus the additive commands:

| Command | Stage / role |
|---|---|
| [`write-ticket`](./write-ticket.md) | pre-workflow — author the ticket to `.claude/tickets/<slug>.md` (no state) |
| [`start-ticket`](./start-ticket.md) | intake — create the workspace |
| [`research`](./research.md) | research — read-only discovery |
| [`spec`](./spec.md) | spec — requirements + acceptance criteria |
| [`plan`](./plan.md) | plan — approach, files, validation, rollback |
| [`review`](./review.md) | review gate — reviewer approves/rejects |
| [`implement`](./implement.md) | implement — apply the approved plan (no commit) |
| [`verify`](./verify.md) | verify gate — validate + close |
| [`migrate-feature`](./migrate-feature.md) | Laravel→Flutter port, driven inside the gates |

**Delivery is manual (not a command).** After `/verify` closes the ticket, the
developer delivers to GitHub by hand: `git add` the implemented files +
`.claude/_specs/<slug>/`, `git commit`, `git push -u origin ticket/<slug>`, then
open the PR on GitHub's web UI (base branch `main`) and paste its URL into
`ticket.md > links.github`. This performs no workflow-state transition.

Canonical rules/config: [`../rules/*.md`](../rules), [`../project-config.yaml`](../project-config.yaml).
Operating procedure: the `ticket-workflow` skill ([`../skills/ticket-workflow/`](../skills/ticket-workflow)).
