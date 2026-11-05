# Contributing

## Setup

1. Install Flutter 3.47.5 (the version CI uses), Xcode and Android Studio.
2. `flutter pub get`
3. `dart run build_runner build --delete-conflicting-outputs`
4. `cp env/dev.example.json env/dev.json`
5. Run the dev flavour (see [docs/environments.md](docs/environments.md)).

## Branches and commits

- Branch from `main`: `feat/…`, `fix/…`, `refactor/…`, `chore/…`, `docs/…`.
- Write commits in the [Conventional Commits](https://www.conventionalcommits.org)
  style, e.g. `feat(booking): filter doctors by specialty`.
- Open a pull request into `main`. CI must pass and someone must review it.

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
