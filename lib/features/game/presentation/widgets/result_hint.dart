import 'package:flutter/material.dart';

import '../../../../core/widgets/element_icon.dart';

/// A translucent copy of a result element that drifts upward and fades out.
///
/// Shown when re-mixing an already-discovered combination: rather than creating
/// the item again, the game gently reminds the player what that pair makes.
class ResultHint extends StatelessWidget {
  const ResultHint({super.key, required this.elementId});

  final String elementId;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1150),
      curve: Curves.easeOut,
      builder: (context, t, child) {
        return Opacity(
          opacity: (0.85 * (1 - t)).clamp(0.0, 1.0),
          child: Transform.translate(offset: Offset(0, -48 * t), child: child),
        );
      },
      child: ElementIcon(elementId: elementId, size: 64),
    );
  }
}
