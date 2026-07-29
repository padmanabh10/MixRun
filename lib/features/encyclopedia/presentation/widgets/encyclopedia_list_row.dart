import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/element_icon.dart';
import 'package:mixrun/l10n/gen/app_localizations.dart';
import '../../../../data/game_data.dart';
import '../../../../data/models/game_element.dart';

/// A single full-width element row in the Encyclopedia list view.
///
/// Discovered elements show artwork, name and transliteration with an
/// "add to workspace" button; locked ones are masked behind "???".
class EncyclopediaListRow extends StatelessWidget {
  const EncyclopediaListRow({
    super.key,
    required this.elementId,
    required this.name,
    required this.discovered,
    this.depleted = false,
    this.isFinal = false,
    this.onTap,
    this.onAdd,
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
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final GameElement element = GameData.element(elementId);
    final AppLocalizations strings = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: discovered ? Colors.white : AppColors.cocoa.withValues(alpha: 0.03),
        border: discovered
            ? Border.all(color: AppColors.cocoa.withValues(alpha: 0.06))
            : null,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
            child: Row(
              children: <Widget>[
                if (discovered)
                  ElementIcon(elementId: elementId, size: 44)
                else
                  SizedBox.square(
                    dimension: 44,
                    child: Center(
                      child: Text(
                        '?',
                        style: AppText.display(
                          size: 26,
                          weight: FontWeight.w800,
                          color: AppColors.lockedBrown,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        discovered ? name : '???',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.display(
                          size: 16,
                          weight: FontWeight.w700,
                          color: discovered
                              ? AppColors.cocoa
                              : AppColors.lockedBrown,
                        ),
                      ),
                      if (discovered)
                        Text(
                          element.transliteration,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.body(
                            size: 12,
                            color: AppColors.mutedBrown,
                          ),
                        ),
                    ],
                  ),
                ),
                if (depleted)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: _StatusBadge(label: strings.depleted),
                  )
                else if (isFinal)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: _StatusBadge(label: strings.finalLabel, highlight: true),
                  ),
                if (discovered && onAdd != null)
                  IconButton(
                    onPressed: onAdd,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.add_box_outlined,
                      color: AppColors.spiceBrown,
                      size: 26,
                    ),
                  ),
              ],
            ),
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.gold.withValues(alpha: 0.14)
            : AppColors.cocoa.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        label,
        style: AppText.body(
          size: 11,
          weight: FontWeight.w600,
          color: highlight ? AppColors.spiceBrown : AppColors.mutedBrown,
        ),
      ),
    );
  }
}
