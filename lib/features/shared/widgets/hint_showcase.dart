import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'package:mixrun/l10n/gen/app_localizations.dart';
import '../../../domain/game_controller.dart';
import 'showcase_glow.dart';

/// Presents the full-screen "New Hint" showcase for [elementId].
///
/// A hint reveals the target element's *name* but deliberately keeps its
/// artwork hidden (a mystery "?" tile), so actually discovering it on the canvas
/// is still a surprise. Tapping anywhere returns to the previous screen.
Future<void> showHintShowcase(BuildContext context, String elementId) {
  // Push on the root navigator so the showcase covers the whole screen,
  // including the in-game bottom toolbar.
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      opaque: true,
      barrierColor: AppColors.parchmentBottom,
      transitionDuration: const Duration(milliseconds: 360),
      pageBuilder: (_, __, ___) => _HintShowcase(elementId: elementId),
      transitionsBuilder: (_, animation, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
    ),
  );
}

class _HintShowcase extends StatelessWidget {
  const _HintShowcase({required this.elementId});

  final String elementId;

  @override
  Widget build(BuildContext context) {
    final GameController controller = context.read<GameController>();
    final AppLocalizations strings = AppLocalizations.of(context);

    // Scale the tile to the screen, capped so it stays tasteful on tablets and
    // bounded by height so it doesn't crowd out the text in landscape.
    final Size screen = MediaQuery.sizeOf(context);
    final double tileSize = math.min(
      math.min(screen.shortestSide * 0.62, screen.height * 0.45),
      280,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: <Color>[AppColors.parchmentTop, AppColors.parchmentBottom],
            stops: <double>[0, 0.85],
          ),
        ),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              ShowcaseGlow(size: tileSize * 1.7),
              // Center the tile/text, but let it scroll if a short (landscape)
              // viewport can't fit it rather than overflowing.
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const Icon(Icons.lightbulb_rounded,
                                      size: 16, color: AppColors.gold),
                                  const SizedBox(width: 8),
                                  Text(
                                    strings.hint,
                                    style: AppText.display(
                                      size: 14,
                                      weight: FontWeight.w800,
                                      color: AppColors.gold,
                                      letterSpacing: 3,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.lightbulb_rounded,
                                      size: 16, color: AppColors.gold),
                                ],
                              ),
                              SizedBox(height: tileSize * 0.12),
                              _MysteryTile(size: tileSize),
                              SizedBox(height: tileSize * 0.12),
                              Text(
                                controller.elementName(elementId),
                                textAlign: TextAlign.center,
                                style: AppText.display(
                                  size: 34,
                                  weight: FontWeight.w800,
                                  color: AppColors.cocoa,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                strings.figureOutRecipe,
                                textAlign: TextAlign.center,
                                style: AppText.body(
                                  size: 14,
                                  color: AppColors.cocoaSoft,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 28,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.touch_app_rounded,
                        size: 16, color: AppColors.mutedBrown),
                    const SizedBox(width: 7),
                    Text(
                      strings.close,
                      style: AppText.body(
                        size: 13,
                        weight: FontWeight.w600,
                        color: AppColors.mutedBrown,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The large "?" tile standing in for the still-undiscovered element, matching
/// the mystery tiles on the Hints screen.
class _MysteryTile extends StatelessWidget {
  const _MysteryTile({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFEFE2C4),
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.cocoa.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        '?',
        style: AppText.display(
          size: size * 0.45,
          weight: FontWeight.w800,
          color: AppColors.lockedBrown,
        ),
      ),
    );
  }
}
