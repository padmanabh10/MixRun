/// The Journey stage an element belongs to,  the stop at which it unlocks.
///
/// Stages are listed in unlock order: [base] is available from the start and
/// each themed stage opens once the one before it is complete. The label is
/// used by the Encyclopedia filter and the element detail views, and mirrors
/// the stop titles in `GameLevels`.
enum ElementCategory {
  base('Base Level'),
  states('States & UTs'),
  history('History & Sites'),
  culture('Culture & Cuisine'),
  arts('Dance & Local Art'),
  heroes('Heroes & Kings');

  const ElementCategory(this.label);

  final String label;
}
