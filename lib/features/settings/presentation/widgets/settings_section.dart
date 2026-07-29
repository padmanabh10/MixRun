import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// An uppercase section heading above a settings card.
class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: AppText.display(
              size: 14,
              weight: FontWeight.w700,
              color: AppColors.mutedBrown,
              letterSpacing: 0.5,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
