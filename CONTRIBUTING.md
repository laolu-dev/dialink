# Contributing

## Setup

1. Install Flutter 3.47.5 (the version CI uses), Xcode and Android Studio.
2. `flutter pub get`
3. `dart run build_runner build --delete-conflicting-outputs`
4. `cp env/dev.example.json env/dev.json`
5. Run the dev flavour (see [docs/environments.md](docs/environments.md)).

## Branches and commits

Work flows `feat/…` → `dev` → `main`:

- `main` is what ships. It only changes through a release pull request from
  `dev`.
- `dev` is the integration branch. Every change lands here first.
- Branch from `dev`: `feat/…`, `fix/…`, `refactor/…`, `chore/…`, `docs/…`, and
  open the pull request back into `dev`. CI must pass and someone must review
  it. Delete the branch once it's merged.
- Write commits in the [Conventional Commits](https://www.conventionalcommits.org)
  style, e.g. `feat(booking): filter doctors by specialty`.
- Merge with a merge commit, not a squash, so the commit history (and its
  `feat`/`fix`/`!` markers) reaches `main` intact.

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
