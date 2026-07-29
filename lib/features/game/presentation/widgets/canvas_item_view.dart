import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/widgets/element_icon.dart';

/// The visual for one element resting on the canvas: just the bare icon, with
/// no frame or background. Plays a brief shake when a combination is rejected,
/// and a circle-collapse fade when [vanishing] is set (used for the temporary
/// result of re-reaching an already-discovered item via a new recipe).
class CanvasItemView extends StatefulWidget {
  const CanvasItemView({
    super.key,
    required this.elementId,
    required this.shaking,
    this.vanishing = false,
    this.onVanished,
  });

  /// Footprint used by the canvas to center the item on its coordinates.
  static const Size footprint = Size(48, 48);

  final String elementId;
  final bool shaking;

  /// When true the item collapses inward and fades, then reports [onVanished].
  final bool vanishing;

  /// Called once the collapse animation finishes, so the owner can drop the
  /// item from the canvas.
  final VoidCallback? onVanished;

  @override
  State<CanvasItemView> createState() => _CanvasItemViewState();
}

class _CanvasItemViewState extends State<CanvasItemView>
    with TickerProviderStateMixin {
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 430),
  );

  late final AnimationController _vanish = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
  )..addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) widget.onVanished?.call();
    });

  @override
  void initState() {
    super.initState();
    if (widget.vanishing) _vanish.forward(from: 0);
  }

  @override
  void didUpdateWidget(CanvasItemView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shaking && !oldWidget.shaking) {
      _shake.forward(from: 0);
    }
    if (widget.vanishing && !oldWidget.vanishing) {
      _vanish.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    _vanish.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _vanish,
      builder: (context, child) {
        if (_vanish.value == 0) return child!;
        return ClipPath(
          clipper: _CircleCollapseClipper(_vanish.value),
          child: Opacity(
            opacity: (1 - _vanish.value * 0.85).clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _shake,
        builder: (context, child) {
          final double dx = math.sin(_shake.value * math.pi * 3) *
              8 *
              (1 - _shake.value);
          return Transform.translate(offset: Offset(dx, 0), child: child);
        },
        child: ElementIcon(elementId: widget.elementId, size: 48),
      ),
    );
  }
}

/// Clips its child to a circle that shrinks from fully covering the icon down to
/// nothing as [t] runs 0 → 1, giving a "swallowed by a closing circle" wipe.
class _CircleCollapseClipper extends CustomClipper<Path> {
  const _CircleCollapseClipper(this.t);

  /// Collapse progress: 0 = full circle (icon fully visible), 1 = zero radius.
  final double t;

  @override
  Path getClip(Size size) {
    final Offset center = size.center(Offset.zero);
    // Start slightly larger than the icon so nothing is clipped at t == 0.
    final double maxRadius = size.longestSide / 2 * 1.05;
    final double radius = maxRadius * (1 - t);
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(_CircleCollapseClipper oldClipper) => oldClipper.t != t;
}
