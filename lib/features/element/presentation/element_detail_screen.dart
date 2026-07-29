import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/element_icon.dart';
import 'package:mixrun/l10n/gen/app_localizations.dart';
import '../../../data/game_data.dart';
import '../../../data/models/game_element.dart';
import '../../../domain/game_controller.dart';
import '../../shared/widgets/category_chip.dart';
import '../../shared/widgets/gold_button.dart';
import '../../shared/widgets/icon_tile.dart';
import '../../shared/widgets/learn_more_actions.dart';
import '../../shared/widgets/light_back_button.dart';

/// Full-screen element detail: artwork, lore, the recipe it came from, the
/// categories it belongs to and a "makes" grid of everything it can create.
class ElementDetailScreen extends StatelessWidget {
  const ElementDetailScreen({super.key, required this.elementId});

  final String elementId;

  @override
  Widget build(BuildContext context) {
    final GameController controller = context.watch<GameController>();
    final AppLocalizations strings = AppLocalizations.of(context);
    final GameElement element = GameData.element(elementId);
    final bool discovered = controller.isDiscovered(elementId);
    final bool depleted = controller.isDepleted(elementId);
    final bool isFinal = controller.isFinal(elementId);

    final List<String> results = controller.resultsUsing(elementId);
    final List<String> discoveredResults =
        results.where(controller.isDiscovered).toList();
    final int undiscovered = results.length - discoveredResults.length;

    // "combinations" = the recipes that produce this item. Show only the ones
    // the player can make (both ingredients discovered); the rest are counted
    // as still-undiscovered below.
    final List<(String a, String b)> producing =
        controller.recipesProducing(elementId);
    final List<(String a, String b)> knownCombos = producing
        .where((r) =>
            controller.isDiscovered(r.$1) && controller.isDiscovered(r.$2))
        .toList();
    final int undiscoveredCombos = producing.length - knownCombos.length;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.2,
            colors: <Color>[AppColors.parchmentTop, AppColors.parchmentBottom],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 16, 0),
                    child: LightBackButton(
                      onTap: () => context.canPop()
                          ? context.pop()
                          : context.go(AppRoutes.game),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                _Hero(
                  elementId: elementId,
                  element: element,
                  name: controller.elementName(elementId),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Text(
                    controller.elementDescription(elementId),
                    textAlign: TextAlign.center,
                    style: AppText.body(
                      size: 15,
                      color: AppColors.cocoaSoft,
                      height: 1.55,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _StatusLine(discovered: discovered, strings: strings),
                const SizedBox(height: 26),
                _Section(
                  title: strings.categories,
                  child: _Categories(
                    element: element,
                    categoryLabel: controller.categoryLabel(element.category),
                    depleted: depleted,
                    isFinal: isFinal,
                    strings: strings,
                  ),
                ),
                if (producing.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 26),
                  _Section(
                    title: strings.combinations,
                    child: _Combinations(
                      known: knownCombos,
                      undiscovered: undiscoveredCombos,
                      strings: strings,
                    ),
                  ),
                ],
                if (discoveredResults.isNotEmpty || undiscovered > 0) ...<Widget>[
                  const SizedBox(height: 26),
                  _Section(
                    title: strings.makes,
                    child: _MakesGrid(
                      results: discoveredResults,
                      undiscovered: undiscovered,
                      strings: strings,
                    ),
                  ),
                ],
                // Depleted and final items can't be added to the workspace.
                if (discovered && !depleted && !isFinal) ...<Widget>[
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: GoldButton(
                      label: strings.addToWorkspace,
                      fontSize: 16,
                      leading: const Icon(
                        Icons.add_circle_outline_rounded,
                        color: AppColors.onGold,
                        size: 22,
                      ),
                      onPressed: () {
                        controller.addToCanvas(elementId, 90, 130);
                        context.go(AppRoutes.game);
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: LearnMoreActions(element: element),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.elementId,
    required this.element,
    required this.name,
  });

  final String elementId;
  final GameElement element;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 150,
          height: 150,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: <Color>[
                AppColors.gold.withValues(alpha: 0.18),
                AppColors.gold.withValues(alpha: 0.0),
              ],
            ),
          ),
          child: ElementIcon(elementId: elementId, size: 96),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: AppText.display(
            size: 30,
            weight: FontWeight.w800,
            color: AppColors.cocoa,
          ),
        ),
        Text(
          '${element.transliteration} · ${element.nameEn}',
          style: AppText.body(size: 13, color: AppColors.mutedBrown),
        ),
      ],
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.discovered, required this.strings});

  final bool discovered;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final Color color = discovered ? AppColors.spiceBrown : AppColors.lockedBrown;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          discovered ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(
          discovered ? strings.discoveredStatus : strings.notDiscovered,
          style: AppText.body(size: 13, weight: FontWeight.w600, color: color),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          title,
          style: AppText.display(
            size: 22,
            weight: FontWeight.w800,
            color: AppColors.spiceBrown,
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: child,
        ),
      ],
    );
  }
}

class _Categories extends StatelessWidget {
  const _Categories({
    required this.element,
    required this.categoryLabel,
    required this.depleted,
    required this.isFinal,
    required this.strings,
  });

  final GameElement element;
  final String categoryLabel;
  final bool depleted;
  final bool isFinal;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final bool isBasic = GameData.starterIds.contains(element.id);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 8,
      children: <Widget>[
        if (isBasic) const CategoryChip(label: 'basic'),
        CategoryChip(label: categoryLabel),
        if (isFinal)
          CategoryChip(label: strings.finalLabel)
        else if (depleted)
          CategoryChip(label: strings.depleted),
      ],
    );
  }
}

class _MakesGrid extends StatelessWidget {
  const _MakesGrid({
    required this.results,
    required this.undiscovered,
    required this.strings,
  });

  final List<String> results;
  final int undiscovered;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 18,
          runSpacing: 18,
          children: <Widget>[
            for (final String id in results) _MakeItem(elementId: id),
          ],
        ),
        if (undiscovered > 0) ...<Widget>[
          if (results.isNotEmpty) const SizedBox(height: 18),
          Text(
            strings.andMoreUndiscovered(undiscovered),
            style: AppText.body(size: 13, color: AppColors.lockedBrown),
          ),
        ],
      ],
    );
  }
}

class _MakeItem extends StatelessWidget {
  const _MakeItem({required this.elementId});

  final String elementId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 86,
      child: GestureDetector(
        onTap: () => context.push('${AppRoutes.element}/$elementId'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconTile(elementId: elementId, size: 60, radius: 18),
            const SizedBox(height: 6),
            Text(
              context.read<GameController>().elementName(elementId),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: AppText.display(
                size: 12,
                weight: FontWeight.w600,
                color: AppColors.cocoa,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Combinations extends StatelessWidget {
  const _Combinations({
    required this.known,
    required this.undiscovered,
    required this.strings,
  });

  final List<(String a, String b)> known;
  final int undiscovered;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (final (String a, String b) recipe in known)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _ComboRow(a: recipe.$1, b: recipe.$2),
          ),
        if (undiscovered > 0)
          Text(
            strings.undiscoveredCombosLine(
                undiscovered, known.isNotEmpty ? 'true' : 'false'),
            textAlign: TextAlign.center,
            style: AppText.body(size: 13, color: AppColors.lockedBrown),
          ),
      ],
    );
  }
}

class _ComboRow extends StatelessWidget {
  const _ComboRow({required this.a, required this.b});

  final String a;
  final String b;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: _ComboIngredient(elementId: a)),
        SizedBox(
          height: 54,
          child: Center(
            child: Text(
              '+',
              style: AppText.display(
                size: 22,
                weight: FontWeight.w800,
                color: AppColors.spiceBrown,
              ),
            ),
          ),
        ),
        Expanded(child: _ComboIngredient(elementId: b)),
      ],
    );
  }
}

class _ComboIngredient extends StatelessWidget {
  const _ComboIngredient({required this.elementId});

  final String elementId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('${AppRoutes.element}/$elementId'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ElementIcon(elementId: elementId, size: 54),
          const SizedBox(height: 6),
          Text(
            context.read<GameController>().elementName(elementId),
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: AppText.display(
              size: 13,
              weight: FontWeight.w600,
              color: AppColors.cocoa,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

