import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The home screen icon. See tool/generate_app_icon.py for the icon sets.
///
/// iOS shows an alert each time the icon changes; Android swaps it once the
/// app is in the background.
abstract final class AppIcon {
  static const _channel = MethodChannel('dialink/app_icon');

  /// Sets the alternate icon by its iOS asset or Android activity-alias
  /// name. Null restores the primary icon.
  static Future<void> set(String? name) async {
    if (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    try {
      await _channel.invokeMethod<bool>('setIcon', name);
    } on PlatformException catch (e) {
      debugPrint('App icon not changed: ${e.message}');
    } on MissingPluginException {
      // Not available on this platform.
    }
  }
}
