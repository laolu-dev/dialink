import 'package:talker_flutter/talker_flutter.dart';

/// The app's log, shared by Dio, Riverpod and the app's own messages.
final Talker talker = TalkerFlutter.init(
  settings: TalkerSettings(
    colors: {
      TalkerKey.httpResponse: AnsiPen()..green(),
      TalkerKey.route: AnsiPen()..cyan(),
      TalkerKey.error: AnsiPen()..red(),
      TalkerKey.debug: AnsiPen()..yellow(),
      TalkerKey.info: AnsiPen()..rgb(r: 100 / 255, g: 181 / 255, b: 246 / 255),
      TalkerKey.riverpodAdd: AnsiPen()
        ..rgb(r: 76 / 255, g: 175 / 255, b: 80 / 255),
      TalkerKey.riverpodUpdate: AnsiPen()
        ..rgb(r: 33 / 255, g: 150 / 255, b: 243 / 255),
      TalkerKey.riverpodFail: AnsiPen()
        ..rgb(r: 244 / 255, g: 67 / 255, b: 54 / 255),
      TalkerKey.riverpodDispose: AnsiPen()
        ..rgb(r: 255 / 255, g: 152 / 255, b: 0 / 255),
    },
  ),
);

extension ObjectOrNull on Object? {
  void printLog({Object? msg, LogLevel? level}) {
    switch (level) {
      case LogLevel.info:
        talker.info(msg);
      case LogLevel.error:
        talker.error(msg);
      case LogLevel.critical:
        talker.critical(msg);
      default:
        talker.debug(msg);
    }
  }
}
