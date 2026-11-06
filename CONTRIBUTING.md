# Contributing

## Setup

1. Install Flutter 3.47.5 (the version CI uses), Xcode and Android Studio.
2. `flutter pub get`
3. `dart run build_runner build --delete-conflicting-outputs`
4. `cp env/dev.example.json env/dev.json`
5. Run the dev flavour (see [docs/environments.md](docs/environments.md)).

## Branches and commits

The rules come from the maintainer's version control guide (mobile rules).
This repo keeps a `dev` integration branch by choice, so work flows
`feat/…` → `dev` → `main`:

- `main` is what ships. It only changes through a release pull request from
  `dev`, or a hotfix from `release/<major>.<minor>`.
- `dev` is the integration branch. Every change lands here first.
- Branch from `dev`: `feat/…`, `fix/…`, `refactor/…`, `chore/…`, `docs/…`, and
  open the pull request back into `dev`. CI must pass before it can merge.
  While there's one maintainer, review your own PR (read the diff on GitHub)
  before merging. Once there's a second contributor, require their approval.
  GitHub deletes the branch once it's merged.
- Title every pull request as a [Conventional Commit](https://www.conventionalcommits.org),
  e.g. `feat(booking): filter doctors by specialty`. Commits on your branch can
  be rough: the title is what lands on `dev`.

### Merging

| Into | Method | Why |
|---|---|---|
| `dev` | Squash | One Conventional Commit per pull request, titled from the PR |
| `release/*` | Squash | Each hotfix lands as one commit |
| `main` | Merge commit | `main` and `dev` keep the same commits, so they never drift apart |

GitHub rulesets enforce this. `main`, `dev` and `release/*` take changes
only through pull requests with passing checks, and block force-pushes and
deletion. A check blocks pull requests into `main` that don't come from `dev`
or `release/*`. Tags matching `v*` can't be moved or deleted.

### Hotfixes during store review

1. Fix it on `dev` first, through a normal pull request.
2. Cut `release/<major>.<minor>` from `main` if it doesn't exist yet.
3. Cherry-pick the fix onto a branch from `release/<major>.<minor>`, and
   open a pull request into it.
4. Open a pull request from `release/<major>.<minor>` into `main`, and tag
   the next release candidate.

## Code

- Follow the layers in [docs/architecture.md](docs/architecture.md); the
  architecture test enforces them.
- Format with `dart format`, and keep `flutter analyze` clean.
- Tests go under `test/`, mirroring `lib/src/`. Add tests for new controllers,
  repositories and flows.
- UI must work in every theme, in light and dark, with large text and on
  narrow and wide screens (`test/app/layout_stress_test.dart`).

## Versioning

See [docs/release.md](docs/release.md).
