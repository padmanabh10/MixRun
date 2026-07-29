import 'package:flutter/material.dart';
import 'package:mixrun/l10n/gen/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../core/config/feature_flags.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/element_icon.dart';
import '../../../data/game_data.dart';
import '../../../domain/game_controller.dart';
import '../../shared/widgets/parchment_scaffold.dart';
import 'widgets/drag_demo.dart';

/// The first-run walkthrough: what the game is, how the core gesture works,
/// and what each section of the app is for.
///
/// Shown automatically the first time a player reaches the canvas (see
/// `GameView`), and replayable from Settings › Help. Dismissing it by any
/// route,  Skip, finishing, or the back gesture,  marks it as seen.
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pages = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _finish() {
    context.read<GameController>().markIntroSeen();
    Navigator.of(context).pop();
  }

  void _next(int pageCount) {
    if (_index >= pageCount - 1) {
      _finish();
      return;
    }
    _pages.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final List<Widget> pages = _buildPages(strings);

    return PopScope(
      // Backing out still counts as having seen it, so it won't reappear.
      canPop: false,
      onPopInvokedWithResult: (bool didPop, _) {
        if (!didPop) _finish();
      },
      child: ParchmentScaffold(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 6, 14, 0),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    strings.introSkip,
                    style: AppText.display(
                      size: 14,
                      weight: FontWeight.w700,
                      color: AppColors.mutedBrown,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: (int i) => setState(() => _index = i),
                children: pages,
              ),
            ),
            _Dots(count: pages.length, active: _index),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
              child: _PrimaryButton(
                label: _index == pages.length - 1
                    ? strings.introStart
                    : strings.introNext,
                onTap: () => _next(pages.length),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPages(AppLocalizations strings) {
    final GameController controller = context.read<GameController>();

    return <Widget>[
      _Page(
        title: strings.introWelcomeTitle,
        body: strings.introWelcomeBody(GameData.total),
        art: const _StarterArt(),
      ),
      _Page(
        title: strings.introCombineTitle,
        body: strings.introCombineBody,
        footnote: strings.introCombineHint,
        art: _combineDemo(controller),
      ),
      _Page(
        title: strings.introLibraryTitle,
        body: strings.introLibraryBody,
        footnote: strings.introLibraryClear,
        art: const _LibraryArt(),
      ),
      _Page(
        title: strings.introSectionsTitle,
        body: strings.introSectionsBody,
        art: _SectionsArt(strings: strings),
      ),
      _Page(
        title: strings.introReadyTitle,
        body: strings.introReadyBody,
        art: const _ReadyArt(),
      ),
    ];
  }

  /// The drag demo, built from a real starter recipe so the walkthrough always
  /// shows something the player can actually make on their first turn.
  Widget _combineDemo(GameController controller) {
    const String source = 'earth';
    const String target = 'water';
    final String? result = GameData.recipeFor(source, target);
    if (result == null) {
      // No such recipe in this catalog (e.g. the placeholder template): fall
      // back to the gesture without a result rather than showing nothing.
      return const _StarterArt();
    }
    return DragDemo(
      sourceId: source,
      targetId: target,
      resultId: result,
      sourceLabel: controller.elementName(source),
      targetLabel: controller.elementName(target),
      resultLabel: controller.elementName(result),
    );
  }
}

/// One walkthrough page: artwork on top, then a title, body and optional note.
class _Page extends StatelessWidget {
  const _Page({
    required this.title,
    required this.body,
    required this.art,
    this.footnote,
  });

  final String title;
  final String body;
  final Widget art;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 8),
          art,
          const SizedBox(height: 26),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppText.display(
              size: 24,
              weight: FontWeight.w800,
              color: AppColors.cocoa,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            textAlign: TextAlign.center,
            style: AppText.body(
              size: 14.5,
              color: AppColors.cocoaSoft,
              height: 1.55,
            ),
          ),
          if (footnote != null) ...<Widget>[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                footnote!,
                textAlign: TextAlign.center,
                style: AppText.body(
                  size: 12.5,
                  color: AppColors.spiceBrown,
                  height: 1.45,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// The four starting elements, shown as a row of tiles.
class _StarterArt extends StatelessWidget {
  const _StarterArt();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: Center(
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: <Widget>[
            for (final String id in GameData.starterIds)
              _MiniTile(elementId: id),
          ],
        ),
      ),
    );
  }
}

class _MiniTile extends StatelessWidget {
  const _MiniTile({required this.elementId});

  final String elementId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
      height: 74,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cocoa.withValues(alpha: 0.08)),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: AppColors.cardShadow, blurRadius: 10,
              offset: Offset(0, 4)),
        ],
      ),
      child: ElementIcon(elementId: elementId, size: 44),
    );
  }
}

/// A stylised canvas + library rail, to orient the player before they land on
/// the real thing.
class _LibraryArt extends StatelessWidget {
  const _LibraryArt();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(18),
                border:
                    Border.all(color: AppColors.cocoa.withValues(alpha: 0.07)),
              ),
              child: Center(
                child: Text(
                  'canvas',
                  style: AppText.body(size: 12, color: AppColors.fadedBrown),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.libraryPanel,
                borderRadius: BorderRadius.circular(18),
                border:
                    Border.all(color: AppColors.cocoa.withValues(alpha: 0.07)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  for (final String id in GameData.starterIds.take(4))
                    ElementIcon(elementId: id, size: 26),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon-and-caption rows explaining each toolbar destination.
class _SectionsArt extends StatelessWidget {
  const _SectionsArt({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final List<(IconData, String, String)> rows = <(IconData, String, String)>[
      (Icons.menu_book_rounded, strings.encyclopedia,
          strings.introEncyclopediaBody),
      (Icons.route_rounded, strings.journey, strings.introJourneyBody),
      (Icons.bar_chart_rounded, strings.stats, strings.introStatsBody),
      (Icons.tune_rounded, strings.settings, strings.introSettingsBody),
      if (FeatureFlags.hintsEnabled)
        (Icons.lightbulb_rounded, strings.hint, strings.introHintBody),
    ];

    return Column(
      children: <Widget>[
        for (final (IconData icon, String title, String body) in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: AppColors.spiceBrown),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: AppText.display(
                          size: 14.5,
                          weight: FontWeight.w700,
                          color: AppColors.cocoa,
                        ),
                      ),
                      Text(
                        body,
                        style: AppText.body(
                          size: 12.5,
                          color: AppColors.mutedBrown,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ReadyArt extends StatelessWidget {
  const _ReadyArt();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: Center(
        child: Container(
          width: 116,
          height: 116,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.gold.withValues(alpha: 0.12),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
          ),
          child: const Icon(Icons.auto_awesome_rounded,
              size: 52, color: AppColors.gold),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (int i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == active ? 20 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: i == active
                  ? AppColors.gold
                  : AppColors.cocoa.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(16),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          label,
          style: AppText.display(
            size: 16,
            weight: FontWeight.w700,
            color: AppColors.onGold,
          ),
        ),
      ),
    );
  }
}
