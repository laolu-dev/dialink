# Releasing

Releases follow the maintainer's version control guide (mobile rules,
"Releases and versioning"). Until there are Google Play Console and Apple
Developer Program accounts, Android builds are distributed through GitHub
Releases and iOS isn't distributed.

## Versioning

- `version` in `pubspec.yaml` is the single source of the user-facing version
  (REL-1). Bump the `x.y.z` part in a pull request for each release: patch
  for fixes, minor for features, major for breaking changes. Leave the
  `+build` part alone.
- CI sets the build number with `tool/build_number.sh`: the number of
  commits in the build's history (REL-2). Android `versionCode` and iOS
  `CFBundleVersion` both use it, and it rises as `main` moves forward.
- Every build records its commit (`GIT_SHA`) and logs it at startup (REL-4).
- Each version needs:
  - store notes in `whats_new/<x.y.z>.txt`, at most 500 characters (CI
    runs `tool/whats_new.sh`);
  - a `CHANGELOG.md` section. `tool/changelog.sh <x.y.z>` drafts one from the
    commits since the last release (REL-6).

## One-time setup

Do these once, before the first tag.

### 1. Create the upload keystore

Every Android update must be signed with this key, including a later move to
Google Play. Losing it means users have to uninstall and reinstall.

```bash
keytool -genkeypair -v -keystore ~/dialink-upload.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000
```

Store the file and both passwords in your password manager, and keep an
encrypted backup outside Git (SEC-2). Never commit them (SEC-1).

### 2. Add the signing secrets to GitHub

```bash
base64 -i ~/dialink-upload.jks | gh secret set ANDROID_KEYSTORE_BASE64
gh secret set ANDROID_KEYSTORE_PASSWORD
gh secret set ANDROID_KEY_ALIAS --body upload
gh secret set ANDROID_KEY_PASSWORD
```

`gh secret set` without `--body` prompts for the value, so passwords don't
end up in your shell history.

### 3. Add the prod settings

The release workflow writes `env/prod.json` from a repository variable.
These values aren't secret (they ship inside the app).

```bash
gh variable set ENV_PROD_JSON < env/prod.json
```

### 4. Register the key with Google sign-in

Google sign-in on Android needs an OAuth client for `com.dialink.app` with
this key's SHA-1 (see [environments.md](environments.md#google-sign-in-setup)):

```bash
keytool -list -v -keystore ~/dialink-upload.jks -alias upload | grep SHA1
```

To sign a release build locally as well, copy `android/key.properties.example`
to `android/key.properties` and point it at the keystore.

## Release steps

1. **Prepare.** In a pull request into `dev`, bump `version` in
   `pubspec.yaml`, add `whats_new/<x.y.z>.txt`, and add the `CHANGELOG.md`
   section. Merge it once checks pass.
2. **Test.** Run the prod flavour in release mode on a real iPhone and
   Android phone. Check sign-in, booking, rescheduling and cancelling against
   the production API, and an icon change.
3. **Release PR.** Open a pull request from `dev` into `main`, titled
   `chore(release): <x.y.z>`, and merge it with a merge commit (the only
   method `main` allows).
4. **Release candidate.** Tag the merge commit on `main` and push the tag:

   ```bash
   git switch main && git pull
   git tag v<x.y.z>-rc.1 && git push origin v<x.y.z>-rc.1
   ```

   The release workflow checks the tag, builds the signed prod APK, and
   publishes it as a GitHub pre-release.
5. **Testers.** Share the pre-release link. Testers download the APK and
   allow their browser or file manager to install unknown apps once. Later
   builds install over it, because they're signed with the same key.
6. **If it fails.** Fix it on `dev` first. Then either repeat steps 3 and 4
   with the next `rc` number, or, if `dev` has moved on with work that isn't
   ready, use a hotfix branch (see [CONTRIBUTING.md](../CONTRIBUTING.md#hotfixes-during-store-review)).
   Tags can't be moved or deleted, so never re-tag: use `rc.2`, `rc.3` and so
   on.
7. **Release.** Tag the same commit as the approved candidate:

   ```bash
   git tag v<x.y.z> <rc-tag> && git push origin v<x.y.z>
   ```

   The workflow publishes it as the latest GitHub release.

## iOS

There's no Apple Developer Program account, so iOS builds can't be signed for
other people's devices. The release workflow only checks that the prod
flavour builds for the simulator. To run it on your own iPhone, see
[environments.md](environments.md#running-on-a-physical-device). With a free
Apple ID, the app stops launching after 7 days until it's reinstalled.

## Once there are store accounts

TODO when the accounts exist:

- **Google Play:**
  - Enrol in Play App Signing using this upload key (SEC-3).
  - Build an app bundle (`flutter build appbundle`).
  - Upload debug symbols (REL-5).
  - Release with a staged rollout (REL-7).
- **App Store:**
  - Set the team and profiles for `com.dialink.app`.
  - Build with `flutter build ipa`.
  - Test through TestFlight, then use a phased release (REL-7).
- **Both:**
  - Add store upload jobs to the release workflow, with credentials
    restricted to it (CI-10).
  - Add a remote minimum-version check before an update ever needs forcing
    (REL-11).
