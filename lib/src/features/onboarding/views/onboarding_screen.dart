import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:dialink/src/app/theme/app_palette.dart';
import 'package:dialink/src/core/utils/extensions.dart';
import 'package:dialink/src/features/onboarding/controllers/onboarding_controller.dart';
import 'package:dialink/src/features/onboarding/widgets/onboarding_illustrations.dart';
import 'package:dialink/src/shared/widgets/app_scaffold.dart';
import 'package:dialink/src/shared/widgets/buttons.dart';

/// Three pages on what the app does, shown once before the first sign-in.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _pages = [
    (
      title: "Find the right doctor",
      body: "Search by name or specialty and see who's taking visits.",
    ),
    (
      title: "Book in a few taps",
      body:
          "Pick a time that suits you. Times show in your doctor's time zone.",
    ),
    (
      title: "Stay on top of your visits",
      body:
          "See when a visit is confirmed, and reschedule or cancel when plans change.",
    ),
  ];

  final PageController _controller = PageController();
  int _page = 0;

  bool get _isLast => _page == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_isLast) {
      ref.read(onboardingSeenProvider.notifier).markSeen();
      return;
    }
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpToPage(_page + 1);
    } else {
      _controller.nextPage(
        duration: Durations.medium2,
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final illustrations = OnboardingIllustrations.all(p);

    return AppScaffold(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 4, 12, 0),
              child: Visibility(
                visible: !_isLast,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: TextButton(
                  onPressed: () =>
                      ref.read(onboardingSeenProvider.notifier).markSeen(),
                  style: TextButton.styleFrom(foregroundColor: p.muted),
                  child: const Text("Skip"),
                ),
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (page) => setState(() => _page = page),
              itemBuilder: (context, index) {
                final page = _pages[index];
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      16.0.verticalSpacing,
                      ExcludeSemantics(
                        child: AspectRatio(
                          aspectRatio: 200 / 170,
                          child: SvgPicture.string(illustrations[index]),
                        ),
                      ),
                      32.0.verticalSpacing,
                      Semantics(
                        header: true,
                        child: Text(
                          page.title,
                          style: context.textTheme.headlineMedium,
                        ),
                      ),
                      10.0.verticalSpacing,
                      Text(
                        page.body,
                        style: context.textTheme.bodyLarge!.copyWith(
                          color: p.muted,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Semantics(
            label: "Page ${_page + 1} of ${_pages.length}",
            child: ExcludeSemantics(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 6,
                children: [
                  for (var i = 0; i < _pages.length; i++)
                    AnimatedContainer(
                      duration: Durations.short4,
                      width: i == _page ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _page
                            ? p.primary
                            : p.muted.withValues(alpha: .35),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                ],
              ),
            ),
          ),
          20.0.verticalSpacing,
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: PrimaryButton(
              label: _isLast ? "Get started" : "Next",
              onPressed: _next,
            ),
          ),
        ],
      ),
    );
  }
}
