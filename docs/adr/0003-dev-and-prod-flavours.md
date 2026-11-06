# 0003. Dev and prod flavours with separate app IDs

- Status: Accepted
- Date: 2026-11-05

## Context

Testing against the dev backend shouldn't replace the production app on the
same phone, and nothing environment-specific should depend on a branch
(BRANCH-2, BRANCH-3).

## Decision

- Two flavours, `dev` and `prod`, with their own entry points
  (`lib/main_dev.dart`, `lib/main_prod.dart`).
- Bundle and application IDs are `com.dialink.app.dev` and
  `com.dialink.app`.
- On Android these are product flavours. On iOS they are `dev` and `prod`
  schemes with per-flavour build configurations and xcconfig files.
- The dev build is called "Dialink Dev" and its icons carry a DEV badge.
- Settings come from `env/<flavour>.json` through
  `--dart-define-from-file`. Only the `*.example.json` files are committed,
  and the app checks that the file matches the flavour.

## Consequences

- Both apps can be installed side by side.
- A plain `flutter run` no longer works: every run and build names a
  flavour and its env file (see `docs/environments.md`).
- The ID change from `com.tmdc.dialink.dialink` means earlier installs
  don't update in place.
- Google sign-in needs OAuth clients registered for both IDs.
