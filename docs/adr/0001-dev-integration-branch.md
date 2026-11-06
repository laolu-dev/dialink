# 0001. Keep a `dev` integration branch

- Status: Accepted
- Date: 2026-11-05

## Context

The maintainer's version control guide defaults to trunk-based development,
with `main` as the only long-lived branch (BRANCH-1). Its "Choices to
confirm" allow `dev` and `staging` branches when the maintainer chooses them.

## Decision

Work flows `feat/…` → `dev` → `main`:

- Every change lands in `dev` through a pull request. `dev` is the default
  branch.
- `main` only changes through a release pull request from `dev`, or a hotfix
  from `release/<major>.<minor>`. A required check (the branch guard)
  rejects other sources.
- Environments are still build flavours of a commit (see 0003), not
  branches.

## Consequences

- `main` always matches the last release, and `dev` shows what's coming next.
- A release is a pull request from `dev` into `main`, so it needs a merge
  method that keeps the two branches in step (see 0002).
- A hotfix during store review is fixed on `dev` first, then cherry-picked
  onto `release/<major>.<minor>`, which merges into `main`.
- Dependabot targets `dev`, as do new pull requests by default.
