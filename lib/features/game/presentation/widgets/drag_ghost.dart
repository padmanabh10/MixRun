import 'package:flutter/material.dart';

import '../../../../core/widgets/element_icon.dart';

/// The icon that follows the pointer while dragging,  just the bare artwork,
/// no frame or background, matching how items look resting on the canvas.
class DragGhost extends StatelessWidget {
  const DragGhost({
    super.key,
    required this.elementId,
    required this.size,
  });

  final String elementId;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.9,
      child: ElementIcon(elementId: elementId, size: size),
    );
  }
}
