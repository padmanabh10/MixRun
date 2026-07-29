import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'package:mixrun/l10n/gen/app_localizations.dart';
import '../../../data/audio_service.dart';
import '../../../data/game_data.dart';
import '../../../domain/game_controller.dart';
import 'icon_tile.dart';
import 'learn_more_actions.dart';
import 'showcase_glow.dart';

/// Presents the full-screen "New Discovery" showcase for [elementIds].
///
/// Each newly discovered element is shown one at a time with large artwork and a
/// short description. Tapping anywhere advances to the next element, or returns
/// to the canvas once the last one has been seen. Pass a single id for the usual
/// one-at-a-time discovery; a list supports showing a batch in sequence.
Future<void> showDiscoveryShowcase(
  BuildContext context,
  List<String> elementIds,
) {
  if (elementIds.isEmpty) return Future<void>.value();
  // Push on the root navigator so the showcase covers the whole screen,
  // including the in-game bottom toolbar.
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      opaque: true,
      barrierColor: AppColors.parchmentBottom,
      transitionDuration: const Duration(milliseconds: 360),
      pageBuilder: (_, __, ___) => _DiscoveryShowcase(elementIds: elementIds),
      transitionsBuilder: (_, animation, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
    ),
  );
}

class _DiscoveryShowcase extends StatefulWidget {
  const _DiscoveryShowcase({required this.elementIds});

  final List<String> elementIds;

  @override
  State<_DiscoveryShowcase> createState() => _DiscoveryShowcaseState();
}

class _DiscoveryShowcaseState extends State<_DiscoveryShowcase> {
  int _index = 0;

  /// Advances to the next discovered element, or returns to the canvas once the
  /// last one has been shown.
  void _next() {
    if (_index + 1 < widget.elementIds.length) {
      setState(() => _index++);
      context.read<AudioService>().playEffect(Sfx.discovery);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final GameController controller = context.read<GameController>();
    final AppLocalizations strings = AppLocalizations.of(context);
    final String id = widget.elementIds[_index];
    final bool hasMore = _index + 1 < widget.elementIds.length;

    // Scale the artwork to the screen, capped so it stays tasteful on tablets
    // and bounded by height so it doesn't crowd out the text in landscape.
    final Size screen = MediaQuery.sizeOf(context);
    final double imageSize = math.min(
      math.min(screen.shortestSide * 0.62, screen.height * 0.45),
      280,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _next,
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
              // A slow celebratory glow behind the artwork.
              ShowcaseGlow(size: imageSize * 1.7),
              // Center the artwork/text, but let it scroll if a short (landscape)
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
                          // Cross-fade between elements when advancing a batch.
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 280),
                            child: Column(
                              key: ValueKey<String>(id),
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    const Icon(Icons.auto_awesome,
                                        size: 15, color: AppColors.orange),
                                    const SizedBox(width: 8),
                                    Text(
                                      strings.newDiscovery,
                                      style: AppText.display(
                                        size: 14,
                                        weight: FontWeight.w800,
                                        color: AppColors.orange,
                                        letterSpacing: 3,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.auto_awesome,
                                        size: 15, color: AppColors.orange),
                                  ],
                                ),
                                SizedBox(height: imageSize * 0.12),
                                IconTile(
                                  elementId: id,
                                  size: imageSize,
                                  radius: imageSize * 0.22,
                                  padding: imageSize * 0.16,
                                  gradientTop: Colors.white,
                                  gradientBottom: AppColors.tileBottom,
                                ),
                                SizedBox(height: imageSize * 0.12),
                                Text(
                                  controller.elementName(id),
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
                                  controller.elementDescription(id),
                                  textAlign: TextAlign.center,
                                  style: AppText.body(
                                    size: 14,
                                    color: AppColors.cocoaSoft,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 22),
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 380),
                                  child: LearnMoreActions(
                                    element: GameData.element(id),
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
              ),
              // The tap-anywhere affordance.
              Positioned(
                bottom: 28,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.touch_app_rounded,
                        size: 16, color: AppColors.mutedBrown),
                    const SizedBox(width: 7),
                    Text(
                      hasMore ? strings.continueLabel : strings.close,
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

