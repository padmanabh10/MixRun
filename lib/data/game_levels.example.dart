import 'game_data.dart';
import 'models/game_level.dart';

/// DUMMY placeholder Journey levels,  pairs with `game_data.example.dart`.
///
/// The real level groupings live in `game_levels.dart`, kept out of version
/// control (see `.gitignore`). This template exposes the same six stops (Base
/// Level + five themed levels with the same ids) so the app compiles and runs,
/// each pointing at the example catalog's placeholder elements.
///
/// Copy this file to `game_levels.dart` (alongside `game_data.example.dart` →
/// `game_data.dart`) to build from a fresh clone.
abstract final class GameLevels {
  /// The Base Level: everything not pinned to a themed level.
  static final GameLevel baseLevel = GameLevel(
    id: 'base',
    titleEn: 'Base Level',
    iconElementId: 'water',
    elementIds: _baseIds,
  );

  static final GameLevel states = GameLevel(
    id: 'states',
    titleEn: 'States & UTs',
    iconElementId: 'village',
    elementIds: _states,
  );

  static final GameLevel history = GameLevel(
    id: 'history',
    titleEn: 'History & Sites',
    iconElementId: 'chronicle',
    elementIds: _history,
  );

  static final GameLevel culture = GameLevel(
    id: 'culture',
    titleEn: 'Culture & Cuisine',
    iconElementId: 'feast',
    elementIds: _culture,
  );

  static final GameLevel arts = GameLevel(
    id: 'arts',
    titleEn: 'Dance & Local Art',
    iconElementId: 'mural',
    elementIds: _arts,
  );

  static final GameLevel heroes = GameLevel(
    id: 'heroes',
    titleEn: 'Heroes & Kings',
    iconElementId: 'hero',
    elementIds: _heroes,
  );

  /// Every stop on the Journey, in order.
  static final List<GameLevel> all = <GameLevel>[
    baseLevel,
    states,
    history,
    culture,
    arts,
    heroes,
  ];

  /// Ids claimed by the five themed levels, carved out of the Base Level.
  static final Set<String> _themedIds = <String>{
    ..._states,
    ..._history,
    ..._culture,
    ..._arts,
    ..._heroes,
  };

  /// Everything not pinned to a themed level, in canonical catalog order.
  static final List<String> _baseIds = <String>[
    for (final String id in GameData.elementOrder)
      if (!_themedIds.contains(id)) id,
  ];

  static const List<String> _states = <String>['village'];
  static const List<String> _history = <String>['chronicle'];
  static const List<String> _culture = <String>['feast'];
  static const List<String> _arts = <String>['mural'];
  static const List<String> _heroes = <String>['hero'];
}
