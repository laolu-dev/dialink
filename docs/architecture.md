# Architecture

Dialink is a Flutter app using Riverpod (with code generation) for state and
dependency injection, Dio for the API, and go_router for navigation.

## Layout

```
lib/
├── main_dev.dart, main_prod.dart   Entry points: bootstrap(Flavor.x)
└── src/
    ├── bootstrap.dart   Startup shared by the flavours
    ├── app/             The app widget, env, router, tab shell and themes
    ├── core/            Network, storage, platform channels, logging, utils
    ├── data/            One folder per API area: repository, models, data providers
    ├── shared/          Cross-feature controllers, views, widgets and UI utils
    └── features/        One folder per screen area: controllers/ views/ widgets/
```

| Folder | What goes there |
|---|---|
| `app/env` | `Flavor` and `Env`, read from `env/<flavour>.json` |
| `app/router` | `Routes` (every location), route arguments, the `GoRouter` and its redirects |
| `app/shell` | The tab bar / side rail around the four tabs |
| `app/theme` | Palettes, the seven themes, `buildTheme`, the saved theme settings |
| `core/network` | Dio client, auth interceptor, endpoints, `ClientException`, `Result`, `PageResponse` |
| `core/storage` | Token store (secure storage), shared preferences, provider caching |
| `core/services` | Google sign-in, the app icon and accessibility method channels |
| `data/<area>` | `auth`, `users`, `doctors`, `appointments`: repository + `models/` |
| `shared/controllers` | State several features need: the session, appointments |
| `shared/widgets` | Buttons, surfaces, fields, skeletons, cards, dialogs |
| `features/<area>` | `authentication`, `onboarding`, `home`, `booking`, `visits`, `account`, `appearance` |

## Layer rules

Imports flow one way. `test/architecture/import_rules_test.dart` fails the
build when a file breaks them.

| A file in | May import |
|---|---|
| `core/` | `core/` |
| `data/` | `core/`, `data/` |
| `shared/` | `core/`, `data/`, `shared/`, `app/theme/`, `app/router/routes.dart` |
| `features/<x>/` | `core/`, `data/`, `shared/`, `app/theme/`, `app/router/routes.dart`, and `features/<x>/` itself |
| `app/` | anything |

So a feature never imports another feature. When two features need the same
thing, it moves down: state to `shared/controllers`, a widget to
`shared/widgets`, data to `data/`. Features reach each other's screens by
route (`context.push(Routes.x)`), not by import.

There are no barrel files: each file imports exactly what it uses.

## Data flow

1. A **repository** in `data/` calls the API and returns
   `Result<T, ClientException>` (via `guard`), never throwing.
2. **Providers** expose it: data providers next to the repository (e.g.
   `searchProvidersProvider`, cached with `ref.cacheFor`), and controllers in
   `shared/controllers` or a feature's `controllers/` for state and actions.
3. **Views** watch providers. An action returns its `Result` to the screen
   that started it, which shows the feedback (toast, navigation).

## Navigation

`app/router/app_router.dart` builds the `GoRouter`. Its redirect follows the
session and the onboarding flag: restoring shows `/splash`, a first launch
`/welcome`, signed out `/sign-in`, signed in `/home`. The four tabs are a
`StatefulShellRoute`, so each keeps its state. Screens over the tabs use the
root navigator.

## Adding a feature

1. Create `lib/src/features/<name>/` with `views/`, and `controllers/` and
   `widgets/` if needed.
2. New API calls go in the matching `data/<area>/` repository (or a new area).
3. Add its location to `Routes` and a `GoRoute` in `app_router.dart`.
4. Add tests under `test/features/<name>/`, mirroring `lib/`.
5. Run `dart run build_runner build` after adding `@riverpod` or
   `@JsonSerializable` code.
