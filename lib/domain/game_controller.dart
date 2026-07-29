import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../data/content_localizations.dart';
import '../data/game_data.dart';
import '../data/game_levels.dart';
import '../data/link_overrides_repository.dart';
import '../data/models/element_category.dart';
import '../data/models/game_element.dart';
import '../data/models/game_level.dart';
import '../data/progress_repository.dart';
import 'canvas_item.dart';
import 'combine_outcome.dart';
import 'encyclopedia_filter.dart';

/// The single source of truth for MixRun's app state.
///
/// Owns the player's discovered elements, audio preferences, the active hint
/// and the items currently on the play canvas. The view layer reads from it and
/// calls its command methods; it persists durable progress through a
/// [ProgressRepository].
class GameController extends ChangeNotifier {
  GameController(this._repository) {
    final SavedProgress saved = _repository.load();
    _locale = Locale(saved.localeCode);
    _discovered = List<String>.of(saved.discovered);
    _activeHints = saved.activeHints
        .where((String id) =>
            GameData.elements.containsKey(id) && !_discovered.contains(id))
        .toList();
    _usedRecipes = saved.usedRecipes.toSet();
    _adsWatched = saved.adsWatched;
    _hintDayKey = saved.hintDayKey;
    _hintsUsedToday = saved.hintsUsedToday;
    _introSeen = _repository.introSeen;
  }

  final ProgressRepository _repository;
  final math.Random _random = math.Random();

  /// Items within this squared pixel distance are treated as touching.
  static const double _combineDistanceSquared = 56 * 56;

  late Locale _locale;
  late List<String> _discovered;
  bool _soundOn = true;
  bool _musicOn = true;
  late bool _introSeen;
  final List<CanvasItem> _canvasItems = <CanvasItem>[];
  int _uidCounter = 0;

  /// The most a player can have outstanding at once. Reaching this blocks any
  /// new hints until some are resolved by discovery.
  static const int maxActiveHints = 10;

  /// How many fresh hints a player may unlock per calendar day.
  static const int dailyHintLimit = 3;

  /// Elements the player has been hinted to discover but hasn't found yet.
  /// Each stays here until discovered (see [combineNear]); reaching
  /// [maxActiveHints] blocks new hints.
  List<String> _activeHints = <String>[];

  /// Recipe keys the player has already performed (see [GameData.recipeKey]).
  /// Drives the difference between re-mixing the *same* pair (a hint) and
  /// reaching an already-discovered item through a *new* recipe (which briefly
  /// produces it on the canvas). Populated as recipes are first combined.
  late Set<String> _usedRecipes;

  /// Day (as a YYYYMMDD key) the daily hint counter currently refers to, and
  /// how many hints have been unlocked on that day so far.
  int _hintDayKey = 0;
  int _hintsUsedToday = 0;

  /// Total rewarded ads the player has watched to completion (lifetime).
  int _adsWatched = 0;

  /// Invoked after durable progress (discovered ids / locale) is saved locally.
  /// The account layer hooks this to mirror changes to the cloud.
  VoidCallback? onDurableChange;

  /// The filter the Encyclopedia is currently showing. Lives here so other
  /// screens (e.g. Stats) can deep-link into a filtered Encyclopedia.
  EncyclopediaFilter _encyclopediaFilter = EncyclopediaFilter.all;

  /// Snapshot of the canvas captured on the last [clearCanvas], so the player
  /// can revert. Invalidated as soon as a new element lands on the canvas.
  List<CanvasItem>? _clearedCanvasBackup;

  Locale get locale => _locale;
  bool get soundOn => _soundOn;
  bool get musicOn => _musicOn;

  /// Whether the first-run walkthrough has already been shown. The canvas
  /// checks this once on first build to decide whether to open the intro.
  bool get introSeen => _introSeen;

  /// Records that the walkthrough has been seen, so it never auto-opens again.
  void markIntroSeen() {
    if (_introSeen) return;
    _introSeen = true;
    _repository.setIntroSeen(true);
    notifyListeners();
  }

  /// Switches the display language and persists the choice.
  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    _persist();
    notifyListeners();
  }

  /// Localized display name of element [id] for the current locale.
  String elementName(String id) => ContentL10n.name(id, _locale.languageCode);

  /// Localized description of element [id] for the current locale.
  String elementDescription(String id) =>
      ContentL10n.description(id, _locale.languageCode);

  /// Server-published replacements for broken "learn more" links, keyed by
  /// element id. Empty until [applyLinkOverrides] supplies any.
  Map<String, LinkOverride> _linkOverrides = const <String, LinkOverride>{};

  /// Installs link corrections fetched from Firestore (see
  /// [LinkOverridesRepository]). Safe to call repeatedly; only notifies when
  /// something actually changed.
  void applyLinkOverrides(Map<String, LinkOverride> overrides) {
    if (identical(_linkOverrides, overrides)) return;
    _linkOverrides = overrides;
    notifyListeners();
  }

  /// The article to open for element [id] — the published correction when there
  /// is one, otherwise the link baked into the catalog.
  String articleUrlFor(String id) =>
      _linkOverrides[id]?.url ?? GameData.element(id).url;

  /// The curated video for element [id], or an empty string when none has been
  /// chosen. Callers fall back to a search (see `videoUrlFor`).
  String videoUrlFor(String id) =>
      _linkOverrides[id]?.videoUrl ?? GameData.element(id).videoUrl;

  /// Localized label of [category] for the current locale.
  String categoryLabel(ElementCategory category) =>
      ContentL10n.category(category, _locale.languageCode);

  List<String> get discovered => List<String>.unmodifiable(_discovered);
  bool isDiscovered(String id) => _discovered.contains(id);
  int get discoveredCount => _discovered.length;
  int get total => GameData.total;
  double get progress => total == 0 ? 0 : _discovered.length / total;

  List<CanvasItem> get canvasItems => List<CanvasItem>.unmodifiable(_canvasItems);
  bool get isCanvasEmpty => _canvasItems.isEmpty;

  EncyclopediaFilter get encyclopediaFilter => _encyclopediaFilter;

  /// Sets the Encyclopedia filter and notifies listeners if it changed.
  void setEncyclopediaFilter(EncyclopediaFilter filter) {
    if (_encyclopediaFilter == filter) return;
    _encyclopediaFilter = filter;
    notifyListeners();
  }

  /// Whether a cleared canvas can still be restored (nothing new added since).
  bool get canRevertClear => _clearedCanvasBackup != null;

  /// The element id of the canvas item with [uid], or null if it is gone.
  String? elementIdOf(int uid) =>
      _canvasItems.where((CanvasItem it) => it.uid == uid).firstOrNull?.elementId;

  /// Discovered element ids sorted alphabetically by localized name, optionally
  /// filtered by [query] against the localized name, English name or its
  /// transliteration.
  List<String> libraryIds(String query) {
    // Depleted and final items can no longer make anything new, so they are
    // hidden from the canvas rail to keep it focused on still-useful elements.
    final List<String> ids = _discovered
        .where((String id) => !isDepleted(id) && !isFinal(id))
        .toList()
      ..sort((String a, String b) =>
          elementName(a).toLowerCase().compareTo(elementName(b).toLowerCase()));
    final String trimmed = query.trim();
    if (trimmed.isEmpty) return ids;
    final String lower = trimmed.toLowerCase();
    return ids.where((String id) {
      final GameElement e = GameData.element(id);
      return elementName(id).toLowerCase().contains(lower) ||
          e.nameEn.toLowerCase().contains(lower) ||
          e.transliteration.toLowerCase().contains(lower);
    }).toList();
  }

  void toggleSound() {
    _soundOn = !_soundOn;
    notifyListeners();
  }

  void toggleMusic() {
    _musicOn = !_musicOn;
    notifyListeners();
  }

  /// Returns the canvas to empty and progress to the starter elements.
  void resetProgress() {
    _canvasItems.clear();
    _clearedCanvasBackup = null;
    _activeHints = <String>[];
    _usedRecipes = <String>{};
    _discovered = List<String>.of(GameData.starterIds);
    _persist();
    notifyListeners();
  }

  /// Spawns [elementId] at ([x], [y]) and returns its new uid.
  int addToCanvas(String elementId, double x, double y) {
    // A fresh element on the canvas retires the "revert clear" option.
    _clearedCanvasBackup = null;
    final int uid = ++_uidCounter;
    _canvasItems.add(
      CanvasItem(uid: uid, elementId: elementId, x: x, y: y),
    );
    notifyListeners();
    return uid;
  }

  /// Commits a dragged item's final position.
  void updatePosition(int uid, double x, double y) {
    final int i = _canvasItems.indexWhere((CanvasItem it) => it.uid == uid);
    if (i < 0) return;
    _canvasItems[i] = _canvasItems[i].copyWith(x: x, y: y);
    notifyListeners();
  }

  /// Moves an item to the end of the list so it paints above the others.
  void bringToFront(int uid) {
    final int i = _canvasItems.indexWhere((CanvasItem it) => it.uid == uid);
    if (i < 0) return;
    final CanvasItem item = _canvasItems.removeAt(i);
    _canvasItems.add(item);
    notifyListeners();
  }

  /// Removes a single item from the canvas (e.g. dragged back onto the rail).
  void removeFromCanvas(int uid) {
    final int before = _canvasItems.length;
    _canvasItems.removeWhere((CanvasItem it) => it.uid == uid);
    if (_canvasItems.length != before) notifyListeners();
  }

  void clearCanvas() {
    if (_canvasItems.isEmpty) return;
    _clearedCanvasBackup = List<CanvasItem>.of(_canvasItems);
    _canvasItems.clear();
    notifyListeners();
  }

  /// Restores the canvas to its state just before the last [clearCanvas].
  void revertClear() {
    final List<CanvasItem>? backup = _clearedCanvasBackup;
    if (backup == null) return;
    _canvasItems
      ..clear()
      ..addAll(backup);
    _clearedCanvasBackup = null;
    notifyListeners();
  }

  /// Attempts to combine the item [uid] with its nearest neighbor.
  ///
  /// On a recipe match the two ingredients are replaced by the result; a new
  /// element is recorded as discovered the first time it appears.
  CombineOutcome combineNear(int uid) {
    final CanvasItem? source =
        _canvasItems.where((CanvasItem it) => it.uid == uid).firstOrNull;
    if (source == null) return const CombineNone();

    CanvasItem? target;
    double best = _combineDistanceSquared;
    for (final CanvasItem other in _canvasItems) {
      if (other.uid == uid) continue;
      final double dx = other.x - source.x;
      final double dy = other.y - source.y;
      final double distance = dx * dx + dy * dy;
      if (distance < best) {
        best = distance;
        target = other;
      }
    }
    if (target == null) return const CombineNone();

    final String? resultId =
        GameData.recipeFor(source.elementId, target.elementId);
    if (resultId == null) {
      return CombineRejected(uid, target.uid);
    }

    // Discovery is gated by Journey unlocks: a brand-new result whose level is
    // still locked can't be made yet. Already-discovered items re-combine
    // freely, since their level was unlocked when they were first found.
    if (!_discovered.contains(resultId) && !isElementUnlocked(resultId)) {
      return CombineRejected(uid, target.uid);
    }

    final double x = target.x;
    final double y = target.y;

    final String recipeKey =
        GameData.recipeKey(source.elementId, target.elementId);
    final bool firstUseOfRecipe = !_usedRecipes.contains(recipeKey);

    // The result was already discovered, so this is never a new find.
    if (_discovered.contains(resultId)) {
      if (!firstUseOfRecipe) {
        // The very same pair re-mixed: don't re-create it or consume the
        // ingredients,  just float a translucent hint of the result.
        return CombineHinted(resultId: resultId, x: x, y: y);
      }
      // A *different* recipe reaching an already-discovered item: no showcase,
      // but reward the new path by briefly placing the result on the canvas.
      // The ingredients stay; the view fades the produced item out after a few
      // seconds with a circle-collapse animation.
      _usedRecipes.add(recipeKey);
      final int replayUid = ++_uidCounter;
      _canvasItems.add(
        CanvasItem(uid: replayUid, elementId: resultId, x: x, y: y),
      );
      _persist();
      notifyListeners();
      return CombineReplayed(resultId: resultId, x: x, y: y, uid: replayUid);
    }

    // A brand-new discovery merges the ingredients into the result.
    _usedRecipes.add(recipeKey);
    _canvasItems
        .removeWhere((CanvasItem it) => it.uid == uid || it.uid == target!.uid);
    _canvasItems.add(
      CanvasItem(uid: ++_uidCounter, elementId: resultId, x: x, y: y),
    );
    _discovered.add(resultId);
    // Discovering a hinted item resolves that hint and frees up a slot.
    _activeHints.remove(resultId);
    // The new discovery may have spent some elements (or be a dead-end itself):
    // clear those off the canvas so only still-useful items remain.
    _pruneSpentCanvasItems();
    _persist();
    notifyListeners();
    return CombineMerged(
      resultId: resultId,
      x: x,
      y: y,
      isNewDiscovery: true,
    );
  }

  /// Removes canvas items that can no longer lead to a new discovery: depleted
  /// items (every result already found) and final items (never an ingredient).
  void _pruneSpentCanvasItems() {
    _canvasItems.removeWhere(
      (CanvasItem it) => isDepleted(it.elementId) || isFinal(it.elementId),
    );
  }

  /// Distinct result ids that combining [id] can yield, in catalog order.
  List<String> resultsUsing(String id) => GameData.resultsUsing(id);

  /// Ingredient pairs that produce [id] (the recipes that make this item).
  List<(String a, String b)> recipesProducing(String id) =>
      GameData.recipesProducing(id);

  /// How many combinations that use [id] still lead to an undiscovered result.
  int undiscoveredCombosUsing(String id) =>
      GameData.resultsUsing(id).where((String r) => !isDiscovered(r)).length;

  /// Whether [id] is "depleted": a discovered element that is used as an
  /// ingredient in at least one recipe, yet every result it can make has
  /// already been found,  so it can no longer lead to a new discovery.
  bool isDepleted(String id) =>
      isDiscovered(id) &&
      GameData.resultsUsing(id).isNotEmpty &&
      undiscoveredCombosUsing(id) == 0;

  /// Number of discovered elements that are now depleted.
  int get depletedCount => _discovered.where(isDepleted).length;

  /// Whether [id] is a discovered "final" element: never used as an ingredient,
  /// so it cannot make anything further. Shown distinctly from depleted items.
  bool isFinal(String id) => isDiscovered(id) && GameData.isFinalItem(id);

  /// Number of discovered "basic" elements,  those in the classical
  /// [GameData.basicIds] set that the Stats "Basic items" card filters to,
  /// so the figure matches the list that card opens.
  int get basicCount => _discovered.where(GameData.isBasic).length;

  /// Number of "final" elements (never used as an ingredient) in the catalog.
  int get finalCount => GameData.finalItemCount;

  /// Number of "final" elements the player has actually discovered.
  int get discoveredFinalCount => _discovered.where(isFinal).length;

  /// Number of Journey stages elements are grouped into.
  int get categoryCount => ElementCategory.values.length;

  /// Recipes whose result the player has already discovered.
  int get discoveredComboCount =>
      GameData.allRecipes.where((r) => _discovered.contains(r.$3)).length;

  /// Total number of combination recipes.
  int get totalCombos => GameData.recipeCount;

  /// Fraction of a level that must be discovered before the next one unlocks.
  /// Shared with the Journey map so both agree on what counts as unlocked.
  static const double levelUnlockFraction = 0.7;

  /// The Journey levels currently unlocked: the Base Level, then each themed
  /// level whose predecessor is at least [levelUnlockFraction] discovered.
  /// Stops at the first still-locked level (later ones are locked too).
  List<GameLevel> get unlockedLevels {
    final List<GameLevel> out = <GameLevel>[];
    bool unlocked = true; // The Base Level always opens the journey.
    for (final GameLevel level in GameLevels.all) {
      if (!unlocked) break;
      out.add(level);
      final int total = level.elementIds.length;
      final int found = level.elementIds.where(isDiscovered).length;
      unlocked = total > 0 && found >= (total * levelUnlockFraction).ceil();
    }
    return out;
  }

  /// Distinct element ids belonging to a currently-unlocked level.
  Set<String> get unlockedElementIds => <String>{
        for (final GameLevel level in unlockedLevels) ...level.elementIds,
      };

  /// Whether [id]'s Journey level is unlocked, so the element may be discovered.
  /// Base-level elements are always unlocked; a themed item requires its level
  /// (and thus every level before it reaching [levelUnlockFraction]).
  bool isElementUnlocked(String id) => unlockedElementIds.contains(id);

  /// Whether the level identified by [levelId] is currently unlocked.
  bool isLevelUnlocked(String levelId) =>
      unlockedLevels.any((GameLevel level) => level.id == levelId);

  /// Whether the Journey is available yet: it stays hidden until the first
  /// themed level (States & UTs) unlocks, so it only appears once the player has
  /// discovered enough of the Base Level to have somewhere to travel.
  bool get isJourneyUnlocked => isLevelUnlocked(GameLevels.states.id);

  /// Element ids grouped by the id of the level they belong to, memoized so the
  /// Encyclopedia's level filter is a constant-time membership test.
  late final Map<String, Set<String>> _levelIdSets = <String, Set<String>>{
    for (final GameLevel level in GameLevels.all)
      level.id: level.elementIds.toSet(),
  };

  /// Whether element [id] belongs to the level identified by [levelId].
  bool elementInLevel(String levelId, String id) =>
      _levelIdSets[levelId]?.contains(id) ?? false;

  /// Stats "discovered items" denominator: items in unlocked levels only.
  int get unlockedItemTotal => unlockedElementIds.length;

  /// Stats "discovered items" numerator: discovered items in unlocked levels.
  int get discoveredUnlockedItemCount {
    final Set<String> ids = unlockedElementIds;
    return _discovered.where(ids.contains).length;
  }

  /// Stats "combinations" denominator: recipes whose result sits in an unlocked
  /// level (the combinations reachable within unlocked content).
  int get unlockedComboTotal {
    final Set<String> ids = unlockedElementIds;
    return GameData.allRecipes.where((r) => ids.contains(r.$3)).length;
  }

  /// Stats "combinations" numerator: unlocked combinations already discovered.
  int get discoveredUnlockedComboCount {
    final Set<String> ids = unlockedElementIds;
    return GameData.allRecipes
        .where((r) => ids.contains(r.$3) && _discovered.contains(r.$3))
        .length;
  }

  /// Fraction (0..1) of unlocked-level items discovered,  the value for progress
  /// bars, scoped to unlocked content to match the Stats "discovered items"
  /// figure rather than the full catalog.
  double get unlockedProgress {
    final Set<String> ids = unlockedElementIds;
    if (ids.isEmpty) return 0;
    return _discovered.where(ids.contains).length / ids.length;
  }

  /// Elements the player has active hints for, oldest first.
  List<String> get activeHints => List<String>.unmodifiable(_activeHints);

  /// How many hints the player currently has outstanding.
  int get activeHintCount => _activeHints.length;

  /// Lifetime count of rewarded ads watched to completion.
  int get adsWatched => _adsWatched;

  /// Day (YYYYMMDD) the daily hint counter refers to (for cloud sync).
  int get hintDayKey => _hintDayKey;

  /// Hints unlocked during [hintDayKey] (for cloud sync).
  int get hintsUsedToday => _hintsUsedToday;

  /// The current day's key (YYYYMMDD) in local time.
  int get _currentDayKey {
    final DateTime now = DateTime.now();
    return now.year * 10000 + now.month * 100 + now.day;
  }

  /// Fresh hints the player may still unlock today (resets at local midnight).
  int get hintsRemainingToday {
    final int used = _hintDayKey == _currentDayKey ? _hintsUsedToday : 0;
    return (dailyHintLimit - used).clamp(0, dailyHintLimit);
  }

  /// Whether [requestHint] would succeed right now: under the daily cap, under
  /// [maxActiveHints], and with at least one element left to hint at.
  bool get canRequestHint =>
      hintsRemainingToday > 0 &&
      _activeHints.length < maxActiveHints &&
      hintCandidates.isNotEmpty;

  /// Distinct undiscovered elements the player could make right now,  both
  /// ingredients of at least one of their recipes are already discovered,  and
  /// that aren't already an active hint.
  List<String> get hintCandidates {
    final List<String> out = <String>[];
    for (final (String a, String b, String result) in GameData.allRecipes) {
      if (_discovered.contains(result) || out.contains(result)) continue;
      if (_activeHints.contains(result)) continue;
      if (_discovered.contains(a) && _discovered.contains(b)) out.add(result);
    }
    return out;
  }

  /// Records that the player finished watching a rewarded ad.
  void recordAdWatched() {
    _adsWatched++;
    _persist();
    notifyListeners();
  }

  /// Adds a random makeable, undiscovered element to the active hints and
  /// returns it, or null when blocked (daily cap reached, [maxActiveHints]
  /// reached, or nothing left to hint). A hint stays active until discovered.
  String? requestHint() {
    _rolloverDailyHints();
    if (_hintsUsedToday >= dailyHintLimit) return null;
    if (_activeHints.length >= maxActiveHints) return null;
    final List<String> candidates = hintCandidates;
    if (candidates.isEmpty) return null;

    final String pick = candidates[_random.nextInt(candidates.length)];
    _activeHints.add(pick);
    _hintsUsedToday++;
    _persist();
    notifyListeners();
    return pick;
  }

  /// Rolls the daily hint counter over to today if it refers to a past day.
  void _rolloverDailyHints() {
    final int today = _currentDayKey;
    if (_hintDayKey != today) {
      _hintDayKey = today;
      _hintsUsedToday = 0;
    }
  }

  /// Replaces the discovered set (e.g. with progress merged from the cloud),
  /// dropping ids no longer in the catalog and never falling below the starters.
  void adoptProgress(List<String> discovered) {
    final List<String> valid =
        discovered.where(GameData.elements.containsKey).toList();
    _discovered = valid.isEmpty ? List<String>.of(GameData.starterIds) : valid;
    _pruneResolvedHints();
    _persist();
    notifyListeners();
  }

  /// Merges cloud-stored state into local state on sign-in, keeping the most
  /// progress: the union of discoveries and active hints, the higher ad count,
  /// and today's larger hint-usage tally.
  void mergeCloud({
    required List<String> discovered,
    required List<String> activeHints,
    required int adsWatched,
    int? hintDayKey,
    int? hintsUsedToday,
  }) {
    final Set<String> mergedDiscovered = <String>{..._discovered, ...discovered}
      ..removeWhere((String id) => !GameData.elements.containsKey(id));
    _discovered = mergedDiscovered.isEmpty
        ? List<String>.of(GameData.starterIds)
        : mergedDiscovered.toList();

    final List<String> mergedHints = <String>[
      for (final String id in <String>{..._activeHints, ...activeHints})
        if (GameData.elements.containsKey(id) && !_discovered.contains(id)) id,
    ];
    _activeHints = mergedHints.take(maxActiveHints).toList();

    _adsWatched = math.max(_adsWatched, adsWatched);

    if (hintDayKey != null && hintsUsedToday != null) {
      _rolloverDailyHints();
      if (hintDayKey == _currentDayKey) {
        _hintsUsedToday = math.max(_hintsUsedToday, hintsUsedToday);
      }
    }

    _persist();
    notifyListeners();
  }

  /// Drops any active hints whose element is now discovered.
  void _pruneResolvedHints() {
    _activeHints.removeWhere(_discovered.contains);
  }

  void _persist() {
    // Fire and forget; persistence failures must not block gameplay.
    _repository.save(
      localeCode: _locale.languageCode,
      discovered: _discovered,
      activeHints: _activeHints,
      usedRecipes: _usedRecipes.toList(),
      adsWatched: _adsWatched,
      hintDayKey: _hintDayKey,
      hintsUsedToday: _hintsUsedToday,
    );
    onDurableChange?.call();
  }
}
