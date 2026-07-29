import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/audio_service.dart';

/// The app's primary call-to-action: a glowing gold gradient button.
class GoldButton extends StatelessWidget {
  const GoldButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.fontSize = 21,
    this.padding = const EdgeInsets.all(17),
    this.borderRadius = 20,
    this.leading,
    this.solid = false,
  });

  final String label;
  final VoidCallback onPressed;
  final double fontSize;
  final EdgeInsets padding;
  final double borderRadius;
  final Widget? leading;

  /// When `true`, the button renders as a flat solid color with no gradient or
  /// drop shadow.
  final bool solid;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: solid ? AppColors.gold : null,
        gradient: solid
            ? null
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[AppColors.goldLight, AppColors.goldDeep],
              ),
        boxShadow: solid
            ? null
            : <BoxShadow>[
                BoxShadow(
                  color: AppColors.goldDeep.withValues(alpha: 0.4),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () {
            context.read<AudioService>().playEffect(Sfx.button);
            onPressed();
          },
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (leading != null) ...<Widget>[
                  leading!,
                  const SizedBox(width: 10),
                ],
                Text(
                  label,
                  style: AppText.display(
                    size: fontSize,
                    color: AppColors.onGold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
