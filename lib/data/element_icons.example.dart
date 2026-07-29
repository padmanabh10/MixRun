/// Inline SVG artwork for every element, keyed by element id.
///
/// Each icon is a self-contained `<svg viewBox="0 0 48 48">` string
/// rendered with `flutter_svg`. The art is part of the design and is
/// intentionally kept verbatim.
abstract final class ElementIcons {
  static const Map<String, String> svgById = <String, String>{
    'earth': 'assets/items/earth.svg',
    'water': 'assets/items/water.svg',
    'fire': 'assets/items/fire.svg',
    'air': 'assets/items/air.svg',
    
  };

  static String? svgFor(String id) => svgById[id];
}
