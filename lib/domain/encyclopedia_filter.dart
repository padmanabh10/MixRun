/// What the Encyclopedia list is currently narrowed down to.
///
/// Either one of the special sets ([AllFilter], [BasicFilter], [DepletedFilter],
/// [FinalFilter]) or the elements of a single Journey level via [LevelFilter].
sealed class EncyclopediaFilter {
  const EncyclopediaFilter();

  static const EncyclopediaFilter all = AllFilter();
  static const EncyclopediaFilter basic = BasicFilter();
  static const EncyclopediaFilter depleted = DepletedFilter();
  static const EncyclopediaFilter finalItems = FinalFilter();
}

/// Every discovered element.
class AllFilter extends EncyclopediaFilter {
  const AllFilter();
}

/// The classical building blocks,  the "Element" category (earth, water, …).
class BasicFilter extends EncyclopediaFilter {
  const BasicFilter();
}

/// Discovered elements belonging to a single Journey level, keyed by its id
/// (see `GameLevels`). Used by the Journey map and the Encyclopedia's level
/// filter to scope the list to one stop's items.
class LevelFilter extends EncyclopediaFilter {
  const LevelFilter(this.levelId);

  final String levelId;

  @override
  bool operator ==(Object other) =>
      other is LevelFilter && other.levelId == levelId;

  @override
  int get hashCode => levelId.hashCode;
}

/// Discovered elements that can no longer make anything new.
class DepletedFilter extends EncyclopediaFilter {
  const DepletedFilter();
}

/// Discovered elements that are never used as an ingredient.
class FinalFilter extends EncyclopediaFilter {
  const FinalFilter();
}
