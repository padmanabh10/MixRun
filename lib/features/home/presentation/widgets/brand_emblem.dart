import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/element_icon.dart';

/// The rotating mandala emblem with a gently floating diya at its center.
class BrandEmblem extends StatefulWidget {
  const BrandEmblem({super.key});

  @override
  State<BrandEmblem> createState() => _BrandEmblemState();
}

class _BrandEmblemState extends State<BrandEmblem>
    with TickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 30),
  )..repeat();

  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4500),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _spin.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 208,
      height: 208,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Opacity(
            opacity: 0.16,
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
                child: SizedBox.expand(),
              ),
            ),
          ),
          _ring(inset: 18, color: AppColors.gold.withValues(alpha: 0.5)),
          _ring(inset: 38, color: AppColors.cream.withValues(alpha: 0.14), width: 2),
          Padding(
            padding: const EdgeInsets.all(54),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  center: Alignment(0, -0.24),
                  colors: <Color>[AppColors.nightTop, AppColors.nightMid],
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.cocoa.withValues(alpha: 0.12),
                    blurRadius: 22,
                    spreadRadius: -6,
                  ),
                ],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _float,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, -7 * _float.value),
              child: child,
            ),
            child: const ElementIcon(elementId: 'diya', size: 96),
          ),
        ],
      ),
    );
  }

  Widget _ring({required double inset, required Color color, double width = 1.5}) {
    return Padding(
      padding: EdgeInsets.all(inset),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: width),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}
