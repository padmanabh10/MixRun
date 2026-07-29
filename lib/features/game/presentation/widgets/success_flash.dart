import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A one-shot ring-and-glow burst played where a combination succeeds.
class SuccessFlash extends StatelessWidget {
  const SuccessFlash({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOut,
      builder: (context, t, _) {
        return Opacity(
          opacity: (1 - t).clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.3 + t * 2.1,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold, width: 3),
                gradient: RadialGradient(
                  colors: <Color>[
                    AppColors.goldLight.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
