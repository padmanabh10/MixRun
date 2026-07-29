import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'package:mixrun/l10n/gen/app_localizations.dart';
import '../../../data/game_data.dart';
import '../../../data/game_levels.dart';
import '../../../data/models/game_element.dart';
import '../../../data/models/game_level.dart';
import '../../../domain/encyclopedia_filter.dart';
import '../../../domain/game_controller.dart';
import '../../shared/widgets/light_back_button.dart';
import '../../shared/widgets/parchment_scaffold.dart';
import '../../shared/widgets/search_field.dart';
import 'widgets/encyclopedia_card.dart';
import 'widgets/encyclopedia_list_row.dart';

/// How the encyclopedia list is ordered, independent of the active filter.
enum SortMode { alphabetical, recentlyDiscovered }

/// The encyclopedia: browse every discovered element by category, as a
/// scrollable list or a grid.
class EncyclopediaScreen extends StatefulWidget {
  const EncyclopediaScreen({super.key});

  @override
  State<EncyclopediaScreen> createState() => _EncyclopediaScreenState();
}

class _EncyclopediaScreenState extends State<EncyclopediaScreen> {
  String _search = '';
  bool _listView = true;
  SortMode _sort = SortMode.alphabetical;

  @override
  Widget build(BuildContext context) {
    final GameController controller = context.watch<GameController>();
    final AppLocalizations strings = AppLocalizations.of(context);
    final EncyclopediaFilter filter = _effectiveFilter(controller);
    final List<String> visible = _visibleIds(controller, filter);

    return ParchmentScaffold(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 8, 8),
            child: Row(
              children: <Widget>[
                const LightBackButton(),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        strings.encyclopedia,
                        style: AppText.display(
                          size: 22,
                          weight: FontWeight.w800,
                          color: AppColors.cocoa,
                          height: 1,
                        ),
                      ),
                      Text(
                        '${controller.discoveredCount} / ${controller.total} '
                        '${strings.discovered}',
                        style: AppText.body(size: 12, color: AppColors.mutedBrown),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _listView = !_listView),
                  icon: Icon(
                    _listView
                        ? Icons.grid_view_rounded
                        : Icons.view_list_rounded,
                    color: AppColors.spiceBrown,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SearchField(
              hint: strings.searchElements,
              onChanged: (String value) => setState(() => _search = value),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: <Widget>[
                // Generic criteria (All/Basic/Depleted/Final) are always shown;
                // the per-level ones appear only once the Journey unlocks.
                _CategoryDropdown(
                  strings: strings,
                  selected: filter,
                  showLevels: controller.isJourneyUnlocked,
                  onSelected: controller.setEncyclopediaFilter,
                ),
                const Spacer(),
                _SortDropdown(
                  strings: strings,
                  selected: _sort,
                  onSelected: (SortMode mode) => setState(() => _sort = mode),
                ),
              ],
            ),
          ),
          Expanded(
            child: _listView
                ? _ListBody(
                    ids: visible,
                    controller: controller,
                    onOpen: _openDetail,
                    onAdd: _addToWorkspace,
                  )
                : _GridBody(
                    ids: visible,
                    controller: controller,
                    onOpen: _openDetail,
                  ),
          ),
        ],
      ),
    );
  }

  void _openDetail(String id) => context.push('${AppRoutes.element}/$id');

  void _addToWorkspace(String id) {
    context.read<GameController>().addToCanvas(id, 90, 130);
    context.go(AppRoutes.game);
  }

  /// The active filter, guarding against a stale level filter (e.g. set from the
  /// Journey, then progress reset): while the Journey is locked the per-level
  /// criteria aren't offered, so any [LevelFilter] falls back to showing all.
  EncyclopediaFilter _effectiveFilter(GameController controller) {
    final EncyclopediaFilter filter = controller.encyclopediaFilter;
    if (!controller.isJourneyUnlocked && filter is LevelFilter) {
      return EncyclopediaFilter.all;
    }
    return filter;
  }

  List<String> _visibleIds(GameController controller, EncyclopediaFilter filter) {
    final String query = _search.trim().toLowerCase();
    final List<String> ids = GameData.elementOrder.where((String id) {
      // The Encyclopedia only lists discovered elements; undiscovered ones are
      // not surfaced at all.
      if (!controller.isDiscovered(id)) return false;
      if (!_matchesFilter(id, filter, controller)) return false;
      if (query.isEmpty) return true;
      final GameElement e = GameData.element(id);
      return controller.elementName(id).toLowerCase().contains(query) ||
          e.nameEn.toLowerCase().contains(query) ||
          e.transliteration.toLowerCase().contains(query);
    }).toList();
    _applySort(ids, controller);
    return ids;
  }

  void _applySort(List<String> ids, GameController controller) {
    switch (_sort) {
      case SortMode.alphabetical:
        ids.sort((String a, String b) => controller
            .elementName(a)
            .toLowerCase()
            .compareTo(controller.elementName(b).toLowerCase()));
      case SortMode.recentlyDiscovered:
        // The discovered list is in discovery order, so a higher index means a
        // more recent find. Sort descending to put newest first.
        final List<String> order = controller.discovered;
        final Map<String, int> rank = <String, int>{
          for (int i = 0; i < order.length; i++) order[i]: i,
        };
        ids.sort((String a, String b) =>
            (rank[b] ?? -1).compareTo(rank[a] ?? -1));
    }
  }

  bool _matchesFilter(
    String id,
    EncyclopediaFilter filter,
    GameController controller,
  ) {
    return switch (filter) {
      AllFilter() => true,
      BasicFilter() => GameData.isBasic(id),
      LevelFilter(:final String levelId) =>
        controller.elementInLevel(levelId, id),
      DepletedFilter() => controller.isDepleted(id),
      FinalFilter() => controller.isFinal(id),
    };
  }
}

class _ListBody extends StatelessWidget {
  const _ListBody({
    required this.ids,
    required this.controller,
    required this.onOpen,
    required this.onAdd,
  });

  final List<String> ids;
  final GameController controller;
  final ValueChanged<String> onOpen;
  final ValueChanged<String> onAdd;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
      itemCount: ids.length,
      itemBuilder: (context, index) {
        final String id = ids[index];
        final bool discovered = controller.isDiscovered(id);
        final bool depleted = controller.isDepleted(id);
        final bool isFinal = controller.isFinal(id);
        return EncyclopediaListRow(
          elementId: id,
          name: controller.elementName(id),
          discovered: discovered,
          depleted: depleted,
          isFinal: isFinal,
          onTap: discovered ? () => onOpen(id) : null,
          // Depleted and final items can't be added to the workspace.
          onAdd: discovered && !depleted && !isFinal ? () => onAdd(id) : null,
        );
      },
    );
  }
}

class _GridBody extends StatelessWidget {
  const _GridBody({
    required this.ids,
    required this.controller,
    required this.onOpen,
  });

  final List<String> ids;
  final GameController controller;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 11,
        mainAxisSpacing: 11,
        childAspectRatio: 0.86,
      ),
      itemCount: ids.length,
      itemBuilder: (context, index) {
        final String id = ids[index];
        final bool discovered = controller.isDiscovered(id);
        return EncyclopediaCard(
          elementId: id,
          name: controller.elementName(id),
          discovered: discovered,
          depleted: controller.isDepleted(id),
          isFinal: controller.isFinal(id),
          onTap: discovered ? () => onOpen(id) : null,
        );
      },
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({
    required this.strings,
    required this.selected,
    required this.showLevels,
    required this.onSelected,
  });

  final AppLocalizations strings;
  final EncyclopediaFilter selected;

  /// Whether the per-level criteria are offered. They appear only once the
  /// Journey unlocks; the generic All/Basic/Depleted/Final are always shown.
  final bool showLevels;
  final ValueChanged<EncyclopediaFilter> onSelected;

  String _label() => switch (selected) {
        AllFilter() => strings.all,
        BasicFilter() => strings.basicItems,
        LevelFilter(:final String levelId) => _levelTitle(levelId),
        DepletedFilter() => strings.depleted,
        FinalFilter() => strings.finalLabel,
      };

  String _levelTitle(String levelId) {
    for (final GameLevel level in GameLevels.all) {
      if (level.id == levelId) return level.titleEn;
    }
    return strings.all;
  }

  @override
  Widget build(BuildContext context) {
    final String label = _label();
    // PopupMenuButton treats a null selection as a dismissal and never fires
    // onSelected for it, so every choice must carry a real value. We key the
    // menu by int and map it back to a filter on selection.
    return PopupMenuButton<EncyclopediaFilter>(
      initialValue: selected,
      onSelected: onSelected,
      offset: const Offset(0, 40),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (context) => <PopupMenuEntry<EncyclopediaFilter>>[
        PopupMenuItem<EncyclopediaFilter>(
          value: EncyclopediaFilter.all,
          child: Text(strings.all, style: AppText.body(size: 14)),
        ),
        PopupMenuItem<EncyclopediaFilter>(
          value: EncyclopediaFilter.basic,
          child: Text(strings.basicItems, style: AppText.body(size: 14)),
        ),
        if (showLevels)
          for (final GameLevel level in GameLevels.all)
            PopupMenuItem<EncyclopediaFilter>(
              value: LevelFilter(level.id),
              child: Text(level.titleEn, style: AppText.body(size: 14)),
            ),
        const PopupMenuDivider(),
        PopupMenuItem<EncyclopediaFilter>(
          value: EncyclopediaFilter.depleted,
          child: Text(strings.depleted, style: AppText.body(size: 14)),
        ),
        PopupMenuItem<EncyclopediaFilter>(
          value: EncyclopediaFilter.finalItems,
          child: Text(strings.finalLabel, style: AppText.body(size: 14)),
        ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: AppText.display(
              size: 16,
              weight: FontWeight.w700,
              color: AppColors.spiceBrown,
            ),
          ),
          const Icon(Icons.expand_more_rounded,
              size: 20, color: AppColors.spiceBrown),
        ],
      ),
    );
  }
}

/// Lets the player order the list alphabetically or by most recent discovery.
/// Applies across every category/filter.
class _SortDropdown extends StatelessWidget {
  const _SortDropdown({
    required this.strings,
    required this.selected,
    required this.onSelected,
  });

  final AppLocalizations strings;
  final SortMode selected;
  final ValueChanged<SortMode> onSelected;

  String _label(SortMode mode) => switch (mode) {
        SortMode.alphabetical => strings.alphabetical,
        SortMode.recentlyDiscovered => strings.recentlyDiscovered,
      };

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SortMode>(
      initialValue: selected,
      onSelected: onSelected,
      offset: const Offset(0, 40),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (context) => <PopupMenuEntry<SortMode>>[
        for (final SortMode mode in SortMode.values)
          PopupMenuItem<SortMode>(
            value: mode,
            child: Text(_label(mode), style: AppText.body(size: 14)),
          ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.sort_rounded, size: 18, color: AppColors.spiceBrown),
          const SizedBox(width: 4),
          Text(
            _label(selected),
            style: AppText.display(
              size: 14,
              weight: FontWeight.w700,
              color: AppColors.spiceBrown,
            ),
          ),
          const Icon(Icons.expand_more_rounded,
              size: 18, color: AppColors.spiceBrown),
        ],
      ),
    );
  }
}
