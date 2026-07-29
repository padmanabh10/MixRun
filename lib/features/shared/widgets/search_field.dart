import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// A rounded search input with a leading magnifier.
///
/// Defaults to the light (parchment) styling; set [dark] for the in-game
/// library where it sits on a deep purple panel.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.dark = false,
  });

  final String hint;
  final ValueChanged<String> onChanged;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final Color textColor = dark ? AppColors.cream : AppColors.cocoa;
    final Color fill =
        dark ? AppColors.cream.withValues(alpha: 0.08) : Colors.white;
    final Color border = dark
        ? AppColors.cream.withValues(alpha: 0.12)
        : AppColors.cocoa.withValues(alpha: 0.10);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: fill,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.search_rounded,
            size: 18,
            color: textColor.withValues(alpha: dark ? 0.5 : 0.4),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              cursorColor: AppColors.gold,
              style: AppText.body(size: 14, color: textColor),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: InputBorder.none,
                hintText: hint,
                hintStyle: AppText.body(
                  size: 14,
                  color: textColor.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
