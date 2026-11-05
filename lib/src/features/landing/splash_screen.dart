import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import 'package:dialink/src/config/config.dart';
import 'package:dialink/src/core/core.dart';
import 'package:dialink/src/widgets/skeleton.dart';
import 'package:dialink/src/widgets/surface.dart';

/// Shown while a saved session is restored, in the patient's theme.
///
/// It continues the native launch screen: the icon is the same size and in
/// the same place, so the hand-over is seamless. The native screen can't know
/// the saved theme, so it uses the platform's default one (see
/// tool/generate_app_icon.py).
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key, this.error, this.onRetry});

  /// The session couldn't be restored, e.g. no connection.
  final Object? error;
  final VoidCallback? onRetry;

  /// Matches the launch image size on iOS and Android.
  static const iconSize = 120.0;

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  /// The first request can wait 20–30 s for the server to start, so say what
  /// is happening if it isn't quick.
  bool _slow = false;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(
      const Duration(milliseconds: 1500),
      () => setState(() => _slow = true),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final theme = ref.watch(themeSettingsControllerProvider).theme;
    final fade = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : Durations.medium2;

    return AppBackground(
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  SplashScreen.iconSize * .22,
                ),
                child: Image.asset(
                  theme.iconAsset,
                  width: SplashScreen.iconSize,
                  height: SplashScreen.iconSize,
                  semanticLabel: "Dialink",
                ),
              ),
            ),
            // Below the icon without moving it off centre.
            Align(
              alignment: const Alignment(0, .28),
              child: Text("Dialink", style: context.textTheme.headlineMedium),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: AnimatedOpacity(
                    opacity: widget.error != null || _slow ? 1 : 0,
                    duration: fade,
                    child: widget.error != null
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 8,
                            children: [
                              Icon(Iconsax.wifi_square, color: p.muted),
                              Text(
                                widget.error.toString(),
                                textAlign: TextAlign.center,
                                style: context.textTheme.bodyMedium!.copyWith(
                                  color: p.muted,
                                ),
                              ),
                              OutlinedButton(
                                onPressed: widget.onRetry,
                                child: const Text("Try again"),
                              ),
                            ],
                          )
                        : Shimmer(
                            base: p.muted,
                            highlight: p.primary,
                            label: "Signing you in…",
                            child: Text(
                              "Signing you in…",
                              textAlign: TextAlign.center,
                              style: context.textTheme.bodyLarge!.weight(
                                FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
