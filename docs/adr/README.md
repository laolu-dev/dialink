# Architecture decision records

Short records of lasting technical decisions: what was decided, why, and
what it costs. Add a new numbered file for each decision. To change one,
write a new record that supersedes it instead of editing the old one.

| No. | Decision | Status |
|---|---|---|
| [0001](0001-dev-integration-branch.md) | Keep a `dev` integration branch | Accepted |
| [0002](0002-merge-methods.md) | Squash into `dev`, merge commits into `main` | Accepted |
| [0003](0003-dev-and-prod-flavours.md) | Dev and prod flavours with separate app IDs | Accepted |
| [0004](0004-go-router.md) | Navigate with go_router, driven by the session | Accepted |

Template: Status, Date, Context, Decision, Consequences.
