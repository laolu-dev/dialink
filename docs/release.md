# Releasing

## Versioning

`version` in `pubspec.yaml` is `<semver>+<build>`, e.g. `1.2.0+14`:

- Bump the **semver** for each store release: patch for fixes, minor for new
  features, major for breaking changes.
- Bump the **build** number for every upload to the stores; it must always
  go up.

Each version needs store notes in `whats_new/<semver>.txt` (Google Play
allows 500 characters). CI runs `tool/whats_new.sh` to check.

## Before a release

1. Everything for the release is merged into `dev`, and all checks pass there.
2. Run the prod flavour in release mode on a real iPhone and Android phone.
3. Check sign-in, booking, rescheduling and cancelling against the
   production API, and an icon change.
4. Update `whats_new/<version>.txt`.
5. Open a pull request from `dev` into `main`, titled `chore(release): <version>`,
   and merge it with a merge commit (the only method `main` allows). Build the
   store releases from `main`.
6. Tag the merge commit on `main` with `v<version>` (e.g. `git tag v1.0.0 && git push origin v1.0.0`).

## Android

```bash
flutter build appbundle --flavor prod -t lib/main_prod.dart --dart-define-from-file=env/prod.json
```

Release signing isn't set up yet: `android/app/build.gradle` still signs
release builds with the debug key. Before the first upload, create an upload
key, keep it out of git, and add a release `signingConfig` reading it from
`android/key.properties` or CI secrets.

## iOS

```bash
flutter build ipa --flavor prod -t lib/main_prod.dart --dart-define-from-file=env/prod.json
```

Signing uses the `prod` scheme's Release-prod configuration. Set the team and
provisioning profiles for `com.dialink.app` in Xcode (or in CI) before the
first upload.
