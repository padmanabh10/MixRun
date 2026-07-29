import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';

/// The rounded close (X) button used at the top of the in-game section pages.
///
/// Defaults to returning to the canvas (the in-game sections sit inside the
/// shell); pass [onTap] to navigate elsewhere.
class LightBackButton extends StatelessWidget {
  const LightBackButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => context.go(AppRoutes.game),
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.cocoa.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.close_rounded, color: AppColors.cocoa, size: 24),
      ),
    );
  }
}
