import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// A slim gold-to-orange progress bar filling [value] (0–1) of its track.
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    required this.trackColor,
    this.height = 5,
  });

  final double value;
  final Color trackColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        // Span the full available width; without this the bar shrink-wraps its
        // fill inside a centering Column and collapses to a small pill.
        width: double.infinity,
        height: height,
        color: trackColor,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value.clamp(0.0, 1.0),
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[AppColors.gold, AppColors.orange],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
