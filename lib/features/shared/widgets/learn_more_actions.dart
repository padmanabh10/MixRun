import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/external_links.dart';
import 'package:mixrun/l10n/gen/app_localizations.dart';
import '../../../data/link_overrides_repository.dart';
import '../../../data/models/game_element.dart';
import '../../../domain/game_controller.dart';

/// A YouTube search for [element] by its English name — the fallback used when
/// no video has been curated for it.
String videoSearchUrl(GameElement element) {
  final String query = Uri.encodeQueryComponent(element.nameEn);
  return 'https://www.youtube.com/results?search_query=$query';
}

/// The pair of side-by-side "learn more" actions for an element,  **Read More**
/// (opens the article) and **Watch a Video** (opens a video search). Shared by
/// the element detail screen and the new-discovery showcase so both stay in step.
///
/// Both links resolve through [GameController], so a URL corrected in Firestore
/// wins over the one baked into the catalog (see [LinkOverridesRepository]).
class LearnMoreActions extends StatelessWidget {
  const LearnMoreActions({super.key, required this.element});

  final GameElement element;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final GameController controller = context.watch<GameController>();
    final String video = controller.videoUrlFor(element.id);
    return Row(
      children: <Widget>[
        Expanded(
          child: _LinkButton(
            icon: Icons.menu_book_rounded,
            label: strings.readMore,
            onTap: () => openArticle(controller.articleUrlFor(element.id)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _LinkButton(
            icon: Icons.play_circle_outline_rounded,
            label: strings.watchVideo,
            onTap: () => openArticle(
              video.isNotEmpty ? video : videoSearchUrl(element),
            ),
          ),
        ),
      ],
    );
  }
}

/// A soft tonal pill with an icon and label,  one "learn more" action.
class _LinkButton extends StatelessWidget {
  const _LinkButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.teal.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 18, color: AppColors.teal),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.display(
                    size: 14,
                    weight: FontWeight.w700,
                    color: AppColors.teal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
