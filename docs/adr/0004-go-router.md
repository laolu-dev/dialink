# 0004. Navigate with go_router, driven by the session

- Status: Accepted
- Date: 2026-11-05

## Context

Screens were pushed by hand, so sign-in state, onboarding and deep links
each needed their own navigation logic.

## Decision

- go_router, created by the `appRouterProvider` Riverpod provider. Every
  location is a constant in `Routes` (`lib/src/app/router/routes.dart`).
- One `redirect` decides where the user may be, from the session and
  whether onboarding was seen:
  - the splash while the session restores;
  - home once signed in;
  - onboarding on first launch;
  - sign-in otherwise.
- The router listens to those providers and re-runs the redirect when they
  change.
- The four tabs are a `StatefulShellRoute.indexedStack`, so each tab keeps
  its own stack. Screens that cover the tabs use the root navigator.

## Consequences

- Signing in or out, or the server ending the session, moves the user
  without any screen navigating itself.
- Locations are URLs, which makes deep links possible later.
- Route arguments that aren't in the URL travel as `extra`, for example
  `DoctorTimesArgs`. Screens need a fallback when `extra` is missing, such as
  `DoctorTimesLoader`, which loads the doctor by ID.
- Redirect behaviour is covered by `test/app/router/app_router_test.dart`.
