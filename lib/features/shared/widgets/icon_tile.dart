import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/element_icon.dart';

/// The recurring cream rounded-square that frames an element's icon.
///
/// Used on the canvas, in the library, and inside the detail and discovery
/// surfaces so every element icon shares one tactile treatment.
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.elementId,
    this.size = 58,
    this.radius = 18,
    this.padding = 8,
    this.gradientTop = AppColors.tileTop,
    this.gradientBottom = AppColors.tileBottom,
    this.shadow = true,
  });

  final String elementId;
  final double size;
  final double radius;
  final double padding;
  final Color gradientTop;
  final Color gradientBottom;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[gradientTop, gradientBottom],
        ),
        boxShadow: shadow
            ? <BoxShadow>[
                BoxShadow(
                  color: AppColors.cocoa.withValues(alpha: 0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: ElementIcon(elementId: elementId, size: size - padding * 2),
    );
  }
}
