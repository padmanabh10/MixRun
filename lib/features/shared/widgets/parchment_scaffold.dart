import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Scaffold for the light "reference" screens (Encyclopedia, Hints, Settings).
///
/// Paints the warm parchment radial background, then hands the remaining
/// space to [child].
class ParchmentScaffold extends StatelessWidget {
  const ParchmentScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.2,
            colors: <Color>[AppColors.parchmentTop, AppColors.parchmentBottom],
          ),
        ),
        child: SafeArea(child: child),
      ),
    );
  }
}
