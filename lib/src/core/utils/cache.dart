import 'dart:async';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

extension RefCache on Ref {
  /// Keeps the value for [duration] after the last screen stops using it, so
  /// going back and forth does not fetch it again.
  void cacheFor(Duration duration) {
    final link = keepAlive();
    Timer? timer;
    onCancel(() => timer = Timer(duration, link.close));
    onResume(() => timer?.cancel());
    onDispose(() => timer?.cancel());
  }

  /// Cancelled when the provider is disposed, e.g. once a search is
  /// superseded by the next keystroke, so stale requests stop downloading.
  CancelToken cancelToken() {
    final token = CancelToken();
    onDispose(token.cancel);
    return token;
  }
}
