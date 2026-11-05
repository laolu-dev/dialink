import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dialink/src/core/storage/preferences.dart';
part 'onboarding_controller.g.dart';

/// Whether this device has seen the onboarding.
@Riverpod(keepAlive: true)
class OnboardingSeen extends _$OnboardingSeen {
  static const _key = 'dialink.onboardingSeen';

  @override
  bool build() => ref.watch(preferencesProvider).getBool(_key) ?? false;

  void markSeen() {
    state = true;
    ref.read(preferencesProvider).setBool(_key, true);
  }
}
