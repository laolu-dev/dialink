import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';

import 'package:dialink/src/app/app.dart';
import 'package:dialink/src/core/logging/logger.dart';
import 'package:dialink/src/core/network/api_exception.dart';
import 'package:dialink/src/core/storage/preferences.dart';
import 'package:dialink/src/core/utils/time.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      overrides: [preferencesProvider.overrideWithValue(preferences)],
      observers: [
        TalkerRiverpodObserver(
          talker: talker,
          settings: TalkerRiverpodLoggerSettings(printProviderDisposed: true),
        ),
      ],
      child: Dialink(),
    ),
  );
}
