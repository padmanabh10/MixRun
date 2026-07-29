import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// A circular gauge that fills [value] (0–1) of its ring in gold and shows the
/// rounded percentage in its hub.
class ProgressRing extends StatelessWidget {
  const ProgressRing({super.key, required this.value, this.diameter = 42});

  final double value;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    final int percent = (value.clamp(0.0, 1.0) * 100).round();
    return SizedBox.square(
      dimension: diameter,
      child: CustomPaint(
        painter: _RingPainter(value.clamp(0.0, 1.0)),
        child: Center(
          child: Container(
            width: diameter - 10,
            height: diameter - 10,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.ringTrackFill,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$percent%',
              style: AppText.display(
                size: 12,
                weight: FontWeight.w700,
                color: AppColors.gold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = size.width / 2 - 2.5;
    final Paint track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = AppColors.cream.withValues(alpha: 0.16);
    canvas.drawCircle(center, radius, track);

    final Paint fill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = AppColors.gold;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * value,
      false,
      fill,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.value != value;
}
