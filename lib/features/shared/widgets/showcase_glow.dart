import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// A slowly rotating, softly blended sweep of the brand colors used behind the
/// full-screen discovery and hint showcases to make a reveal feel celebratory.
class ShowcaseGlow extends StatefulWidget {
  const ShowcaseGlow({super.key, required this.size, this.opacity = 0.20});

  final double size;
  final double opacity;

  @override
  State<ShowcaseGlow> createState() => _ShowcaseGlowState();
}

class _ShowcaseGlowState extends State<ShowcaseGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 16),
  )..repeat();

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: widget.opacity,
        child: SizedBox.square(
          dimension: widget.size,
          child: RotationTransition(
            turns: _spin,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: <Color>[
                    AppColors.gold,
                    AppColors.orange,
                    AppColors.brick,
                    AppColors.teal,
                    AppColors.gold,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
