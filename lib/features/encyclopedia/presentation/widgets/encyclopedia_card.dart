import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/element_icon.dart';
import 'package:mixrun/l10n/gen/app_localizations.dart';
import '../../../../data/game_data.dart';
import '../../../../data/models/game_element.dart';

/// A single element card in the Encyclopedia grid.
///
/// Discovered elements show their icon, name and transliteration; locked ones
/// are masked behind a "???" placeholder and are not tappable.
class EncyclopediaCard extends StatelessWidget {
  const EncyclopediaCard({
    super.key,
    required this.elementId,
    required this.name,
    required this.discovered,
    this.depleted = false,
    this.isFinal = false,
    this.onTap,
  });

  final String elementId;

  /// Localized display name for the current language.
  final String name;
  final bool discovered;

  /// Whether this discovered element can no longer make anything new.
  final bool depleted;

  /// Whether this discovered element is a "final" item (never an ingredient).
  final bool isFinal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final GameElement element = GameData.element(elementId);
    final AppLocalizations strings = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 12, 6, 9),
        decoration: BoxDecoration(
          color: discovered ? Colors.white : AppColors.cocoa.withValues(alpha: 0.04),
          border: discovered
              ? Border.all(color: AppColors.gold.withValues(alpha: 0.3))
              : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (discovered)
              ElementIcon(elementId: elementId, size: 42)
            else
              SizedBox.square(
                dimension: 42,
                child: Center(
                  child: Text(
                    '?',
                    style: AppText.display(
                      size: 26,
                      weight: FontWeight.w800,
                      color: const Color(0xFFCDBB95),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 4),
            Text(
              discovered ? name : '???',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppText.display(
                size: 12,
                weight: FontWeight.w600,
                color: discovered ? AppColors.cocoa : AppColors.lockedBrown,
                height: 1.1,
              ),
            ),
            if (discovered)
              Text(
                element.transliteration,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.body(size: 9, color: AppColors.fadedBrown),
              ),
            if (depleted) ...<Widget>[
              const SizedBox(height: 5),
              _StatusBadge(label: strings.depleted),
            ] else if (isFinal) ...<Widget>[
              const SizedBox(height: 5),
              _StatusBadge(label: strings.finalLabel, highlight: true),
            ],
          ],
        ),
      ),
    );
  }
}

/// A small pill marking an element's status. Depleted items use a muted grey;
/// [highlight] (final items) use a warm saffron tint to stand apart.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, this.highlight = false});

  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.gold.withValues(alpha: 0.14)
            : AppColors.cocoa.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppText.body(
          size: 9,
          weight: FontWeight.w600,
          color: highlight ? AppColors.spiceBrown : AppColors.mutedBrown,
        ),
      ),
    );
  }
}
