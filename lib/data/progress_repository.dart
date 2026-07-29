import 'package:shared_preferences/shared_preferences.dart';

import 'game_data.dart';

/// A snapshot of the player's persisted state.
class SavedProgress {
  const SavedProgress({
    required this.localeCode,
    required this.discovered,
    this.activeHints = const <String>[],
    this.usedRecipes = const <String>[],
    this.adsWatched = 0,
    this.hintDayKey = 0,
    this.hintsUsedToday = 0,
  });

  final String localeCode;
  final List<String> discovered;

  /// Elements with an outstanding hint, not yet discovered.
  final List<String> activeHints;

  /// Recipe keys (see `GameData.recipeKey`) the player has already performed.
  /// Lets re-mixing the *same* pair show a hint while a *different* recipe for
  /// an already-discovered item still briefly produces it on the canvas.
  final List<String> usedRecipes;

  /// Lifetime count of rewarded ads watched to completion.
  final int adsWatched;

  /// Day (YYYYMMDD) the daily hint counter refers to, and how many were used.
  final int hintDayKey;
  final int hintsUsedToday;
}

/// Persists the player's language choice and discovered elements.
///
/// Backed by [SharedPreferences]. Only durable progress is stored; transient
/// game state such as canvas items is intentionally not saved.
class ProgressRepository {
  ProgressRepository(this._prefs);

  final SharedPreferences _prefs;

  static const String _localeKey = 'mixrun.locale';
  static const String _discoveredKey = 'mixrun.discovered';
  static const String _activeHintsKey = 'mixrun.activeHints';
  static const String _usedRecipesKey = 'mixrun.usedRecipes';
  static const String _adsWatchedKey = 'mixrun.adsWatched';
  static const String _hintDayKey = 'mixrun.hintDayKey';
  static const String _hintsUsedTodayKey = 'mixrun.hintsUsedToday';
  static const String _introSeenKey = 'mixrun.introSeen';

  /// Whether the first-run walkthrough has already been shown on this device.
  ///
  /// Deliberately outside [SavedProgress] and the cloud sync: it describes this
  /// install, not the player's progress, and survives [resetProgress] so
  /// starting a new game doesn't replay the intro. Settings › Help can replay it
  /// on demand.
  bool get introSeen => _prefs.getBool(_introSeenKey) ?? false;

  Future<bool> setIntroSeen(bool value) => _prefs.setBool(_introSeenKey, value);

  /// Opens the platform store. Call once during app startup.
  static Future<ProgressRepository> create() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return ProgressRepository(prefs);
  }

  SavedProgress load() {
    final List<String> stored =
        _prefs.getStringList(_discoveredKey) ?? <String>[];
    // Guard against ids removed from the catalog between versions.
    final List<String> discovered =
        stored.where(GameData.elements.containsKey).toList();
    final List<String> activeHints =
        (_prefs.getStringList(_activeHintsKey) ?? <String>[])
            .where(GameData.elements.containsKey)
            .toList();
    return SavedProgress(
      localeCode: _prefs.getString(_localeKey) ?? 'en',
      discovered: discovered.isEmpty ? GameData.starterIds : discovered,
      activeHints: activeHints,
      usedRecipes: _prefs.getStringList(_usedRecipesKey) ?? <String>[],
      adsWatched: _prefs.getInt(_adsWatchedKey) ?? 0,
      hintDayKey: _prefs.getInt(_hintDayKey) ?? 0,
      hintsUsedToday: _prefs.getInt(_hintsUsedTodayKey) ?? 0,
    );
  }

  Future<void> save({
    required String localeCode,
    required List<String> discovered,
    List<String> activeHints = const <String>[],
    List<String> usedRecipes = const <String>[],
    int adsWatched = 0,
    int hintDayKey = 0,
    int hintsUsedToday = 0,
  }) {
    // Start every write up front (each updates the in-memory cache
    // synchronously) so a fire-and-forget save still reflects immediately, then
    // await the platform flushes together.
    return Future.wait<bool>(<Future<bool>>[
      _prefs.setString(_localeKey, localeCode),
      _prefs.setStringList(_discoveredKey, discovered),
      _prefs.setStringList(_activeHintsKey, activeHints),
      _prefs.setStringList(_usedRecipesKey, usedRecipes),
      _prefs.setInt(_adsWatchedKey, adsWatched),
      _prefs.setInt(_hintDayKey, hintDayKey),
      _prefs.setInt(_hintsUsedTodayKey, hintsUsedToday),
    ]);
  }
}
