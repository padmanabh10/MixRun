import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/audio_service.dart';

/// A labeled on/off row with a custom sliding switch, matching the design's
/// pill toggle rather than the default Material switch.
class LabeledToggle extends StatelessWidget {
  const LabeledToggle({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.showDivider = false,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Play before the toggle takes effect so turning *off* sound still
        // gives the click feedback.
        context.read<AudioService>().playEffect(Sfx.toggle);
        onChanged(!value);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                    color: AppColors.cocoa.withValues(alpha: 0.06),
                  ),
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              label,
              style: AppText.body(
                size: 15,
                weight: FontWeight.w600,
                color: AppColors.cocoa,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 27,
              padding: const EdgeInsets.all(3),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              decoration: BoxDecoration(
                color: value ? AppColors.teal : const Color(0xFFD6C8A8),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Container(
                width: 21,
                height: 21,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.cocoa.withValues(alpha: 0.18),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
