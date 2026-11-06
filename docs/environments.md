# Environments

The app has two flavours. Each installs as its own app, so both fit on one
phone.

| Flavour | Bundle / application ID | Name | Icon | Backend |
|---|---|---|---|---|
| `dev` | `com.dialink.app.dev` | Dialink Dev | Theme icons with a DEV badge | Dialink dev API |
| `prod` | `com.dialink.app` | Dialink | Theme icons | Production API |

## Env files

Settings live in `env/<flavour>.json`, passed with `--dart-define-from-file`.
Copy the example to start; the real files are gitignored.

```bash
cp env/dev.example.json env/dev.json
```

| Key | Meaning |
|---|---|
| `FLAVOR` | Must match the flavour; the app refuses to start otherwise |
| `API_BASE_URL` | Backend address, without `/api/v1` |
| `GOOGLE_SERVER_CLIENT_ID` | Google OAuth **Web** client ID (also in the backend's `GOOGLE_CLIENT_IDS`) |
| `GOOGLE_IOS_CLIENT_ID` | Google OAuth **iOS** client ID for this flavour's bundle ID |

Nothing in these files is secret (they ship inside the app), but they differ
per environment, so they're kept out of git.

## Running

```bash
flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json
flutter run --flavor prod -t lib/main_prod.dart --dart-define-from-file=env/prod.json
```

VS Code has these as launch configurations. A flavour is required; there is
no plain `flutter run`.

## Running on a physical device

List what's connected, then pass the device ID with `-d`:

```bash
flutter devices
flutter run -d <device-id> --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json
```

Dev and prod have different IDs, so both can be installed on one phone.
Add `--release` to try a flavour at release speed (the step before a store
build, see [release.md](release.md)).

### iPhone (iOS 15.0 or later)

1. Connect the iPhone by cable and tap **Trust** on the phone.
2. Turn on **Settings > Privacy & Security > Developer Mode**, and let the
   phone restart.
3. Signing is automatic, using the team already set in the Xcode project.
   On a different Apple account, open `ios/Runner.xcworkspace`, select the
   **Runner** target, and choose your team under **Signing & Capabilities**
   for each `-dev` and `-prod` configuration. Don't commit that change.
4. Run the command above. If iOS blocks the app on first launch, trust the
   developer under **Settings > General > VPN & Device Management**.

### Android phone

1. Turn on **Developer options** (tap **Build number** in **About phone**
   seven times), then **USB debugging**.
2. Connect by cable and accept the debugging prompt on the phone.
3. Run the command above. Debug builds are signed with the local debug key.

### Backend address

A phone can't reach `localhost` on your computer. The example env files use
hosted backends, which work from any device. If you point `API_BASE_URL` at
a backend running on your machine, use the machine's LAN address and keep
both on the same network.

## Where the flavours are defined

- **Android**: `productFlavors` in `android/app/build.gradle`; dev icons in
  `android/app/src/dev/res`.
- **iOS**: `ios/Flutter/dev.xcconfig` and `prod.xcconfig` (bundle ID, display
  name, icon sets), used by the `Debug-<flavour>`, `Release-<flavour>` and
  `Profile-<flavour>` configurations and the `dev` and `prod` schemes.
- **Dart**: `lib/main_<flavour>.dart` → `bootstrap()` → `Env.fromDefines`.

## Google sign-in setup

Google sign-in stays off (the button says it isn't set up) until:

1. Google Cloud has a Web client, an iOS client per bundle ID, and an Android
   client per application ID with the signing key's SHA-1.
2. The client IDs are in `env/<flavour>.json`.
3. iOS knows its callback: add `GOOGLE_REVERSED_CLIENT_ID` to
   `ios/Flutter/<flavour>.xcconfig` and a URL type for it in
   `ios/Runner/Info.plist`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleURLSchemes</key>
       <array><string>$(GOOGLE_REVERSED_CLIENT_ID)</string></array>
     </dict>
   </array>
   ```
4. The backend's `GOOGLE_CLIENT_IDS` lists the Web and iOS client IDs.
