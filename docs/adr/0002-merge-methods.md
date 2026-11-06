# 0002. Squash into `dev`, merge commits into `main`

- Status: Accepted
- Date: 2026-11-06

## Context

The version control guide uses squash merges, with the pull request title
as the commit (PR-5). With a `dev` branch (0001), squashing the release pull
request from `dev` into `main` would give `main` commits that `dev` doesn't
have, so the two branches would drift apart after every release.

## Decision

| Into | Method |
|---|---|
| `dev` | Squash, with the PR title and description as the commit |
| `release/*` | Squash |
| `main` | Merge commit |

GitHub rulesets enforce the method per branch. `dev` and `release/*` also
require linear history.

## Consequences

- Each pull request is one Conventional Commit on `dev`, so the PR title
  must be a valid Conventional Commit. CI checks it (`tool/pr_title.sh`).
- `main` gets one merge commit per release, and is not linear.
- Branch commits can be rough, because only the title reaches `dev`.
