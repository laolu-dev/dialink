# Dialink

Dialink is a Flutter mobile app designed for booking healthcare appointments. The app includes a landing screen, account creation and login, a user dashboard, and an appointment booking flow for patients and healthcare records.

## Overview

The current codebase implements a structured appointment-management experience with:

- a welcome/landing screen
- sign-up and login screens
- user profile and appointment dashboard
- appointment creation with patient details and medical history
- appointment confirmation or deletion
- custom theming, fonts, and route navigation
- state management using Riverpod

## Tech stack

- Flutter + Dart
- Riverpod and Riverpod Generator
- Dio for API/network communication
- flutter_secure_storage for secure local storage
- talker packages for logging and debugging
- toastification for in-app feedback
- Material 3 design system with custom Poppins and Cooper BT fonts

## Project structure

```text
lib/
├── main.dart
├── src/
│   ├── config/
│   │   ├── router/
│   │   └── theme/
│   ├── core/
│   ├── features/
│   │   ├── authentication/
│   │   ├── book-appointment/
│   │   └── landing/
│   └── widgets/
├── test/
├── android/
├── ios/
├── assets/
├── fonts/
├── pubspec.yaml
└── README.md
```

## Getting started

### Prerequisites

- Flutter SDK 3.6 or newer
- Android Studio / Xcode for device emulation
- A connected device or emulator

### Install dependencies

```bash
flutter pub get
```

### Run the app

```bash
flutter run
```

### iOS-specific note

If the CocoaPods dependencies are not yet installed for the iOS app:

```bash
cd ios
pod install
cd ..
flutter run
```

## App flow

1. Launch the landing screen.
2. Create an account or sign in.
3. View your appointment list on the home dashboard.
4. Book a new appointment with patient, hospital, diagnosis, and medical history details.
5. Accept or delete appointments from the dashboard.

## Notes

This project is structured as a custom Flutter app with a clear feature-first architecture. The authentication and appointment flows are implemented in the app logic and routed through the centralized router configuration.

## License

This project is currently for local development and learning purposes.
