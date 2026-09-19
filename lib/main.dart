import 'package:dialink/src/core/core.dart';
import 'package:dialink/src/dialink.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ProviderScope(
      observers: [
        TalkerRiverpodObserver(
          talker: AppConstants.instance.talker,
          settings: TalkerRiverpodLoggerSettings(printProviderDisposed: true),
        ),
      ],
      child: Dialink(),
    ),
  );
}
