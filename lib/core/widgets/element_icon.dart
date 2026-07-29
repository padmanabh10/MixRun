import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/element_icons.dart';

class ElementIcon extends StatelessWidget {
  const ElementIcon({
    super.key,
    required this.elementId,
    this.size = 48,
  });

  final String elementId;
  final double size;

  @override
  Widget build(BuildContext context) {
    final String? assetPath = ElementIcons.svgFor(elementId);

    if (assetPath == null) {
      return SizedBox.square(dimension: size);
    }

    return SizedBox.square(
      dimension: size,
      child: SvgPicture.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}