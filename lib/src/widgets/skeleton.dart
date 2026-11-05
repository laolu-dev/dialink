import 'package:flutter/material.dart';

import 'package:dialink/src/core/core.dart';
import 'package:dialink/src/widgets/surface.dart';

/// Sweeps a soft highlight across [child]'s shapes while content loads.
///
/// Paint the shapes in any opaque colour; the shimmer replaces it. Still
/// when animations are turned off (Easy read, or Reduce Motion).
///
/// Placeholders use faint colours; give [base] and [highlight] to shimmer
/// text that must stay readable.
class Shimmer extends StatefulWidget {
  const Shimmer({
    super.key,
    required this.child,
    this.base,
    this.highlight,
    this.label = "Loading",
  });

  final Widget child;
  final Color? base;
  final Color? highlight;

  /// What screen readers hear instead of the shapes.
  final String label;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final base = widget.base ?? p.muted.withValues(alpha: .16);
    final highlight = widget.highlight ?? p.muted.withValues(alpha: .05);

    return Semantics(
      label: widget.label,
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _controller,
          child: widget.child,
          builder: (context, child) => ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [base, highlight, base],
              stops: const [.35, .5, .65],
              transform: _Slide(_controller.value),
            ).createShader(bounds),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Moves the gradient from off the left edge to off the right.
class _Slide extends GradientTransform {
  const _Slide(this.progress);

  final double progress;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * (progress * 2 - 1), 0, 0);
}

/// A placeholder shape, for use inside a [Shimmer].
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.width, this.height = 14, this.radius = 8});

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

/// A card-shaped placeholder: a round avatar beside two lines of text.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.avatar = true, this.lines = 2});

  final bool avatar;
  final int lines;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(14),
      child: Shimmer(
        child: Row(
          spacing: 12,
          children: [
            if (avatar) const SkeletonBox(width: 44, height: 44, radius: 22),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  const FractionallySizedBox(
                    widthFactor: .55,
                    child: SkeletonBox(height: 16),
                  ),
                  for (var i = 1; i < lines; i++)
                    FractionallySizedBox(
                      widthFactor: i.isOdd ? .8 : .4,
                      child: const SkeletonBox(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A list of [SkeletonCard]s, the shape of a list that is still loading.
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.count = 6,
    this.avatar = true,
    this.lines = 2,
  });

  final int count;
  final bool avatar;
  final int lines;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: count,
      separatorBuilder: (context, index) => 10.0.verticalSpacing,
      itemBuilder: (context, index) =>
          SkeletonCard(avatar: avatar, lines: lines),
    );
  }
}
