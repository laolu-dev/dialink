/// The build's flavour: which backend it talks to and which app it installs
/// as (see docs/environments.md).
enum Flavor { dev, prod }

/// Settings for one flavour, from its env file:
/// `--dart-define-from-file=env/<flavour>.json`.
class Env {
  const Env({
    required this.flavor,
    required this.apiBaseUrl,
    required this.googleServerClientId,
    required this.googleIosClientId,
    this.commit = 'local',
  });

  /// Reads the env file the app was built with, and checks it is the one for
  /// [flavor], so a dev build can't run against prod by mistake.
  factory Env.fromDefines(Flavor flavor) {
    const fileFlavor = String.fromEnvironment('FLAVOR');
    const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
    if (fileFlavor != flavor.name || apiBaseUrl.isEmpty) {
      throw StateError(
        'Run the ${flavor.name} build with '
        '--dart-define-from-file=env/${flavor.name}.json '
        '(copy env/${flavor.name}.example.json to start).',
      );
    }
    return Env(
      flavor: flavor,
      apiBaseUrl: apiBaseUrl,
      googleServerClientId: const String.fromEnvironment(
        'GOOGLE_SERVER_CLIENT_ID',
      ),
      googleIosClientId: const String.fromEnvironment('GOOGLE_IOS_CLIENT_ID'),
      commit: const String.fromEnvironment('GIT_SHA', defaultValue: 'local'),
    );
  }

  final Flavor flavor;
  final String apiBaseUrl;
  final String googleServerClientId;
  final String googleIosClientId;

  /// The commit this build was made from. CI passes it with
  /// `--dart-define=GIT_SHA=<sha>`; local builds say `local`.
  final String commit;
}
