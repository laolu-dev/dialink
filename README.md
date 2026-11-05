# Dialink

Dialink is a Flutter app for patients to find a doctor and book, reschedule
or cancel visits, on iOS and Android.

## Overview

- Onboarding, then sign-in with email and password or Google
- Home with your next visit, and tabs for Find, Visits and Account
- Find a doctor by name or specialty, pick a free time and book
- Upcoming and past visits, with reschedule and cancel
- Your details, password, and appearance: seven themes (two for
  accessibility), light and dark, with a matching app icon
- Phones, tablets and iPhone Duo (side tabs on wide screens)

## Tech stack

- Flutter + Dart
- Riverpod and Riverpod Generator
- Dio for API/network communication
- flutter_secure_storage for secure local storage
- talker packages for logging and debugging
- toastification for in-app feedback
- go_router for navigation
- Seven themes in light and dark, with Plus Jakarta Sans and Atkinson Hyperlegible

## Project structure

```text
lib/
├── main_dev.dart, main_prod.dart   Entry points, one per flavour
└── src/
    ├── bootstrap.dart   Shared startup
    ├── app/             App widget, env, router, tab shell, themes
    ├── core/            Network, storage, platform services, logging
    ├── data/            Repositories and models per API area
    ├── shared/          Cross-feature controllers, views, widgets
    └── features/        One folder per screen area
test/                    Mirrors lib/src
env/                     Flavour settings (*.example.json committed)
docs/                    Architecture, environments, theming, release
tool/                    Icon generator, store-notes check
whats_new/               Store release notes per version
```

See [docs/architecture.md](docs/architecture.md) for the layers and their rules.

## Getting started

See [CONTRIBUTING.md](CONTRIBUTING.md) for setup, and
[docs/environments.md](docs/environments.md) for the flavours. In short:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
cp env/dev.example.json env/dev.json
flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json
```

## License

This project is currently for local development and learning purposes.
