import 'element_category.dart';

/// A single stop on the player's Journey,  a themed grouping of elements shown
/// as one small icon node on the winding path (see `JourneyScreen`).
///
/// Levels mirror [ElementCategory]: every element carries the stage it unlocks
/// at, and each stage becomes one stop on the path. The model stays general so
/// a level could later be defined some other way without touching the path UI.
class GameLevel {
  const GameLevel({
    required this.id,
    required this.titleEn,
    required this.iconElementId,
    required this.elementIds,
    this.category,
  });

  /// Stable identifier (the category name) used for deep links.
  final String id;

  /// English display name, used as a fallback when no localized title exists.
  final String titleEn;

  /// Element id whose SVG artwork stands in as the level's small icon.
  final String iconElementId;

  /// The element ids that belong to this level, in catalog order.
  final List<String> elementIds;

  /// The category this level represents, when it maps to one. Used to resolve a
  /// localized title and to filter the Encyclopedia on tap.
  final ElementCategory? category;
}
