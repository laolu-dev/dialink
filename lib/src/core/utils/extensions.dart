import 'package:dialink/src/config/config.dart';
import 'package:dialink/src/core/core.dart';
import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';

extension ObjectOrNull on Object? {
  void printLog({Object? msg, LogLevel? level}) {
    switch (level) {
      case LogLevel.info:
        AppConstants.instance.talker.info(msg);
        break;

      case LogLevel.error:
        AppConstants.instance.talker.error(msg);
        break;

      case LogLevel.critical:
        AppConstants.instance.talker.critical(msg);
        break;

      default:
        AppConstants.instance.talker.debug(msg);
    }
  }
}

extension BuildContextExtension on BuildContext {
  Size get deviceSize => MediaQuery.sizeOf(this);

  TextTheme get textTheme => Theme.of(this).textTheme;

  NavigatorState get router => AppRouter.instance.routerKey.currentState!;
}

extension SizedBoxExtension on double {
  SizedBox get verticalSpacing => SizedBox(height: this);

  SizedBox get horizontalSpacing => SizedBox(width: this);
}
