import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/config/feature_flags.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'package:mixrun/l10n/gen/app_localizations.dart';
import '../../../domain/encyclopedia_filter.dart';
import '../../../domain/game_controller.dart';
import '../../shared/widgets/light_back_button.dart';
import '../../shared/widgets/parchment_scaffold.dart';

/// A dashboard of headline numbers: how much of the catalog the player has
/// uncovered, broken down by kind.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GameController controller = context.watch<GameController>();
    final AppLocalizations strings = AppLocalizations.of(context);

    // Tapping a stat (except combinations) opens the Encyclopedia filtered to
    // the matching set of elements.
    void open(EncyclopediaFilter filter) {
      controller.setEncyclopediaFilter(filter);
      context.go(AppRoutes.encyclopedia);
    }

    return ParchmentScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(
              children: <Widget>[
                const LightBackButton(),
                const SizedBox(width: 10),
                Text(
                  strings.stats,
                  style: AppText.display(
                    size: 22,
                    weight: FontWeight.w800,
                    color: AppColors.cocoa,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 32),
              children: <Widget>[
                _StatCard(
                  value:
                      '${controller.discoveredUnlockedItemCount} / ${controller.unlockedItemTotal}',
                  label: strings.discoveredItems,
                  highlight: true,
                  onTap: () => open(EncyclopediaFilter.all),
                ),
                _StatCard(
                    value: '${controller.basicCount}',
                    label: strings.basicItems,
                    onTap: () => open(EncyclopediaFilter.basic),
                ),
                _StatCard(
                    value: '${controller.depletedCount}',
                    label: strings.depletedItems,
                    onTap: () => open(EncyclopediaFilter.depleted),
                ),
                _StatCard(
                    value: '${controller.discoveredFinalCount}',
                    label: strings.finalItems,
                    onTap: () => open(EncyclopediaFilter.finalItems),
                ),
                _StatCard(
                  value:
                      '${controller.discoveredUnlockedComboCount} / ${controller.unlockedComboTotal}',
                  label: strings.combosFound,
                ),
                // Hidden while hints are disabled (see [FeatureFlags]); the
                // card and its Hints screen return when the flag is flipped.
                if (FeatureFlags.hintsEnabled)
                  _StatCard(
                    value: '${controller.activeHintCount}',
                    label: strings.activeHintsTitle,
                    onTap: () => context.go(AppRoutes.hints),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    this.highlight = false,
    this.onTap,
  });

  final String value;
  final String label;
  final bool highlight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: highlight
              ? AppColors.gold.withValues(alpha: 0.3)
              : AppColors.cocoa.withValues(alpha: 0.07),
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 26),
            child: Column(
              children: <Widget>[
                Text(
                  value,
                  style: AppText.display(
                    size: 38,
                    weight: FontWeight.w800,
                    color: highlight ? AppColors.orange : AppColors.cocoa,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: AppText.body(size: 14, color: AppColors.mutedBrown),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
