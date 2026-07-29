import 'package:flutter/material.dart';
import 'package:mixrun/l10n/gen/app_localizations.dart';

import '../../../core/config/feature_flags.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/game_data.dart';
import '../../../data/game_levels.dart';
import '../../../domain/game_controller.dart';
import '../../shared/widgets/light_back_button.dart';
import '../../shared/widgets/parchment_scaffold.dart';

/// Frequently asked questions about how MixRun is played.
///
/// Reached from Settings › Help. Answers that quote a number (catalog size,
/// unlock threshold, hint allowances) read it from the source of truth rather
/// than hardcoding it, so the page cannot drift from the game's actual rules.
class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);

    return ParchmentScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(child: _header(context, strings)),
          for (final _FaqSection section in _sections(strings)) ...<Widget>[
            SliverToBoxAdapter(child: _sectionTitle(section.title)),
            SliverList.separated(
              itemCount: section.entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (BuildContext context, int i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: _FaqTile(entry: section.entries[i]),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, AppLocalizations strings) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              LightBackButton(onTap: () => Navigator.of(context).pop()),
              const SizedBox(width: 10),
              Text(
                strings.faq,
                style: AppText.display(
                  size: 22,
                  weight: FontWeight.w800,
                  color: AppColors.cocoa,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 48),
            child: SizedBox(height: 2),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 48, top: 2),
            child: Text(
              strings.faqSubtitle,
              style: AppText.body(size: 13, color: AppColors.mutedBrown),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 10),
      child: Text(
        title.toUpperCase(),
        style: AppText.display(
          size: 14,
          weight: FontWeight.w700,
          color: AppColors.mutedBrown,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  List<_FaqSection> _sections(AppLocalizations strings) {
    return <_FaqSection>[
      _FaqSection(
        title: strings.faqSectionBasics,
        entries: <_FaqEntry>[
          _FaqEntry(strings.faqWhatIsQ, strings.faqWhatIsA),
          _FaqEntry(strings.faqStartQ, strings.faqStartA),
          _FaqEntry(
            strings.faqHowManyQ,
            strings.faqHowManyA(GameData.total, GameLevels.all.length),
          ),
        ],
      ),
      _FaqSection(
        title: strings.faqSectionPlaying,
        entries: <_FaqEntry>[
          _FaqEntry(strings.faqHowCombineQ, strings.faqHowCombineA),
          _FaqEntry(strings.faqPairQ, strings.faqPairA),
          _FaqEntry(strings.faqCantMakeQ, strings.faqCantMakeA),
          _FaqEntry(strings.faqBasicQ, strings.faqBasicA),
          _FaqEntry(strings.faqDepletedQ, strings.faqDepletedA),
          _FaqEntry(strings.faqFinalQ, strings.faqFinalA),
        ],
      ),
      _FaqSection(
        title: strings.faqSectionJourney,
        entries: <_FaqEntry>[
          _FaqEntry(strings.faqJourneyQ, strings.faqJourneyA),
          _FaqEntry(
            strings.faqUnlockQ,
            strings.faqUnlockA(
              (GameController.levelUnlockFraction * 100).round(),
            ),
          ),
          // Hints are gated behind a feature flag; don't document a screen the
          // player can't use yet.
          if (FeatureFlags.hintsEnabled)
            _FaqEntry(
              strings.faqHintsQ,
              strings.faqHintsA(
                GameController.dailyHintLimit,
                GameController.maxActiveHints,
              ),
            ),
        ],
      ),
      _FaqSection(
        title: strings.faqSectionProgress,
        entries: <_FaqEntry>[
          _FaqEntry(strings.faqSaveQ, strings.faqSaveA),
          _FaqEntry(strings.faqResetQ, strings.faqResetA),
          _FaqEntry(strings.faqLearnMoreQ, strings.faqLearnMoreA),
          _FaqEntry(strings.faqOfflineQ, strings.faqOfflineA),
          if (!FeatureFlags.languageSelectionEnabled)
            _FaqEntry(strings.faqLanguageQ, strings.faqLanguageA),
        ],
      ),
    ];
  }
}

class _FaqSection {
  const _FaqSection({required this.title, required this.entries});

  final String title;
  final List<_FaqEntry> entries;
}

class _FaqEntry {
  const _FaqEntry(this.question, this.answer);

  final String question;
  final String answer;
}

/// A question card that expands to reveal its answer.
class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.entry});

  final _FaqEntry entry;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _open = !_open),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: _open
                ? AppColors.gold.withValues(alpha: 0.35)
                : AppColors.cocoa.withValues(alpha: 0.07),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    widget.entry.question,
                    style: AppText.display(
                      size: 15,
                      weight: FontWeight.w700,
                      color: _open ? AppColors.spiceBrown : AppColors.cocoa,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    Icons.expand_more_rounded,
                    size: 22,
                    color: _open ? AppColors.spiceBrown : AppColors.mutedBrown,
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 10, right: 8),
                child: Text(
                  widget.entry.answer,
                  style: AppText.body(
                    size: 13,
                    color: AppColors.cocoaSoft,
                    height: 1.55,
                  ),
                ),
              ),
              crossFadeState: _open
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 180),
              sizeCurve: Curves.easeOut,
            ),
          ],
        ),
      ),
    );
  }
}
