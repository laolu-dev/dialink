import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';

import 'package:dialink/src/app/app.dart';
import 'package:dialink/src/app/env/env.dart';
import 'package:dialink/src/core/logging/logger.dart';
import 'package:dialink/src/core/network/api_client.dart';
import 'package:dialink/src/core/network/api_exception.dart';
import 'package:dialink/src/core/services/google_auth/google_auth.dart';
import 'package:dialink/src/core/storage/preferences.dart';
import 'package:dialink/src/core/utils/time.dart';

/// Shared startup for every flavour: reads its settings, loads what the
/// first frame needs, and starts the app.
Future<void> bootstrap(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  final env = Env.fromDefines(flavor);

  // Errors Flutter and the platform catch, in the same log as the rest.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    talker.handle(details.exception, details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    talker.handle(error, stack);
    return true;
  };

  GoogleAuth.instance.configure(
    serverClientId: env.googleServerClientId,
    iosClientId: env.googleIosClientId,
  );
  final preferences = await SharedPreferences.getInstance();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // After the first frame, so the splash shows without waiting on it.
  WidgetsBinding.instance.addPostFrameCallback((_) => AppTime.init());

  runApp(
    ProviderScope(
      retry: ClientException.retryPolicy,
      overrides: [
        preferencesProvider.overrideWithValue(preferences),
        apiBaseUrlProvider.overrideWithValue(env.apiBaseUrl),
      ],
      observers: [
        TalkerRiverpodObserver(
          talker: talker,
          settings: TalkerRiverpodLoggerSettings(printProviderDisposed: true),
        ),
      ],
      child: const Dialink(),
    ),
  );
}
