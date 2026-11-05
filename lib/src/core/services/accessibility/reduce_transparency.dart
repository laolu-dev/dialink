import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'reduce_transparency.g.dart';

/// Whether iOS asks apps to reduce transparency. Glass is drawn solid then.
///
/// Flutter doesn't expose the setting, so the app asks iOS at launch and
/// each time it comes back to the foreground.
@Riverpod(keepAlive: true)
class ReduceTransparency extends _$ReduceTransparency {
  static const _channel = MethodChannel('dialink/accessibility');

  @override
  bool build() {
    if (defaultTargetPlatform != TargetPlatform.iOS) return false;

    final listener = AppLifecycleListener(onResume: _read);
    ref.onDispose(listener.dispose);
    _read();
    return false;
  }

  Future<void> _read() async {
    try {
      final reduce = await _channel.invokeMethod<bool>('reduceTransparency');
      if (ref.mounted) state = reduce ?? false;
    } on PlatformException {
      // Keep the current value.
    } on MissingPluginException {
      // Keep the current value.
    }
  }
}
