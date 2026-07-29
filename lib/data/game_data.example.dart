import 'models/element_category.dart';
import 'models/game_element.dart';

/// DUMMY placeholder catalog,  a tiny, self-contained example graph.
///
/// The real Indian-heritage catalog lives in `game_data.dart`, which is kept
/// out of version control (see `.gitignore`) because it is the game's curated
/// content. This template ships a handful of generic elements with the exact
/// same public API so the project compiles and runs without the real data.
///
/// To build from a fresh clone, copy this file over the real name:
///
/// ```sh
/// cp lib/data/game_data.example.dart lib/data/game_data.dart
/// cp lib/data/game_levels.example.dart lib/data/game_levels.dart
/// ```
///
/// then drop in the real catalog locally. The two example files form one
/// consistent, fully reachable graph on their own.
abstract final class GameData {
  /// Element ids a player starts with before discovering anything.
  static const List<String> starterIds = <String>[
    'earth',
    'water',
    'fire',
    'air',
  ];

  /// The classical "basic" building blocks,  the four starters plus the raw
  /// forces derived straight from them. They are what the Stats "Basic items"
  /// card and the Encyclopedia's basic filter list.
  static const List<String> basicIds = <String>[
    'earth',
    'water',
    'fire',
    'air',
  ];

  /// Whether [id] is one of the classical [basicIds].
  static bool isBasic(String id) => basicIds.contains(id);

  static const Map<String, GameElement> elements = <String, GameElement>{
    'earth': GameElement(
      id: 'earth',
      nameEn: "Earth",
      transliteration: '',
      category: ElementCategory.base,
      descriptionEn: "Earth,  one of the classical building blocks of everything you create.",
      url: "https://example.com/earth",
    ),
    'water': GameElement(
      id: 'water',
      nameEn: "Water",
      transliteration: '',
      category: ElementCategory.base,
      descriptionEn: "Water,  one of the classical building blocks of everything you create.",
      url: "https://example.com/water",
    ),
    'fire': GameElement(
      id: 'fire',
      nameEn: "Fire",
      transliteration: '',
      category: ElementCategory.base,
      descriptionEn: "Fire,  one of the classical building blocks of everything you create.",
      url: "https://example.com/fire",
    ),
    'air': GameElement(
      id: 'air',
      nameEn: "Air",
      transliteration: '',
      category: ElementCategory.base,
      descriptionEn: "Air,  one of the classical building blocks of everything you create.",
      url: "https://example.com/air",
    ),
    'steam': GameElement(
      id: 'steam',
      nameEn: "Steam",
      transliteration: '',
      category: ElementCategory.base,
      descriptionEn: "Steam,  a natural feature of the world around you.",
      url: "https://example.com/steam",
    ),
    'mud': GameElement(
      id: 'mud',
      nameEn: "Mud",
      transliteration: '',
      category: ElementCategory.base,
      descriptionEn: "Mud,  a natural feature of the world around you.",
      url: "https://example.com/mud",
    ),
    'dust': GameElement(
      id: 'dust',
      nameEn: "Dust",
      transliteration: '',
      category: ElementCategory.base,
      descriptionEn: "Dust,  a natural feature of the world around you.",
      url: "https://example.com/dust",
    ),
    'lava': GameElement(
      id: 'lava',
      nameEn: "Lava",
      transliteration: '',
      category: ElementCategory.base,
      descriptionEn: "Lava,  a natural feature of the world around you.",
      url: "https://example.com/lava",
    ),
    'rain': GameElement(
      id: 'rain',
      nameEn: "Rain",
      transliteration: '',
      category: ElementCategory.base,
      descriptionEn: "Rain,  a natural feature of the world around you.",
      url: "https://example.com/rain",
    ),
    'plant': GameElement(
      id: 'plant',
      nameEn: "Plant",
      transliteration: '',
      category: ElementCategory.base,
      descriptionEn: "Plant,  living green that grows and spreads.",
      url: "https://example.com/plant",
    ),
    'stone': GameElement(
      id: 'stone',
      nameEn: "Stone",
      transliteration: '',
      category: ElementCategory.base,
      descriptionEn: "Stone,  a natural feature of the world around you.",
      url: "https://example.com/stone",
    ),
    'village': GameElement(
      id: 'village',
      nameEn: "Village",
      transliteration: '',
      category: ElementCategory.states,
      descriptionEn: "Village,  a built structure that shelters and endures.",
      url: "https://example.com/village",
    ),
    'chronicle': GameElement(
      id: 'chronicle',
      nameEn: "Chronicle",
      transliteration: '',
      category: ElementCategory.history,
      descriptionEn: "Chronicle,  a natural feature of the world around you.",
      url: "https://example.com/chronicle",
    ),
    'feast': GameElement(
      id: 'feast',
      nameEn: "Feast",
      transliteration: '',
      category: ElementCategory.culture,
      descriptionEn: "Feast,  a celebration of colour, sound, and community.",
      url: "https://example.com/feast",
    ),
    'mural': GameElement(
      id: 'mural',
      nameEn: "Mural",
      transliteration: '',
      category: ElementCategory.arts,
      descriptionEn: "Mural,  a crafted thing, shaped by hand and tool.",
      url: "https://example.com/mural",
    ),
    'hero': GameElement(
      id: 'hero',
      nameEn: "Hero",
      transliteration: '',
      category: ElementCategory.heroes,
      descriptionEn: "Hero,  a living creature of the world.",
      url: "https://example.com/hero",
    ),
  };

  /// Combination rules keyed by the two ingredient ids sorted and joined with
  /// `+`. Use [recipeFor] rather than indexing directly so ordering is handled.
  static const Map<String, String> _recipes = <String, String>{
    'air+earth': 'dust',
    'air+water': 'rain',
    'earth+fire': 'lava',
    'earth+rain': 'plant',
    'earth+water': 'mud',
    'fire+stone': 'hero',
    'fire+water': 'steam',
    'lava+water': 'stone',
    'mud+plant': 'village',
    'plant+stone': 'chronicle',
    'plant+water': 'feast',
    'stone+water': 'mural',
  };

  /// The canonical ordering of every element id.
  static List<String> get elementOrder => elements.keys.toList();

  /// Total number of discoverable elements.
  static int get total => elements.length;

  static GameElement element(String id) => elements[id]!;

  /// The element produced by combining [a] and [b], or null if no recipe
  /// matches. Ingredient order does not matter.
  static String? recipeFor(String a, String b) {
    return _recipes[recipeKey(a, b)];
  }

  /// The canonical, order-independent key identifying the recipe made from
  /// ingredients [a] and [b]. Used both to look recipes up and to record which
  /// specific combinations the player has already performed.
  static String recipeKey(String a, String b) {
    final List<String> pair = <String>[a, b]..sort();
    return '${pair[0]}+${pair[1]}';
  }

  /// The two ingredient ids that produce [resultId], or null if none.
  static (String, String)? ingredientsFor(String resultId) {
    for (final MapEntry<String, String> entry in _recipes.entries) {
      if (entry.value == resultId) {
        final List<String> parts = entry.key.split('+');
        return (parts[0], parts[1]);
      }
    }
    return null;
  }

  /// All recipe entries as ingredient/result records, in declaration order.
  static Iterable<(String a, String b, String result)> get allRecipes sync* {
    for (final MapEntry<String, String> entry in _recipes.entries) {
      final List<String> parts = entry.key.split('+');
      yield (parts[0], parts[1], entry.value);
    }
  }

  /// Distinct result ids that can be produced using [id] as an ingredient,
  /// in recipe declaration order. Powers the "Makes" grid on element details.
  static List<String> resultsUsing(String id) {
    final List<String> out = <String>[];
    for (final MapEntry<String, String> entry in _recipes.entries) {
      final List<String> parts = entry.key.split('+');
      if ((parts[0] == id || parts[1] == id) && !out.contains(entry.value)) {
        out.add(entry.value);
      }
    }
    return out;
  }

  /// Every ingredient pair that produces [id], in recipe declaration order.
  /// An item can have more than one recipe; basic elements have none.
  static List<(String a, String b)> recipesProducing(String id) {
    final List<(String, String)> out = <(String, String)>[];
    for (final MapEntry<String, String> entry in _recipes.entries) {
      if (entry.value == id) {
        final List<String> parts = entry.key.split('+');
        out.add((parts[0], parts[1]));
      }
    }
    return out;
  }

  /// Every id that appears as an ingredient in at least one recipe.
  static final Set<String> _ingredientIds = <String>{
    for (final String key in _recipes.keys) ...key.split('+'),
  };

  /// Total number of combination recipes in the catalog.
  static int get recipeCount => _recipes.length;

  /// Whether [id] is used as an ingredient in at least one recipe.
  static bool isIngredient(String id) => _ingredientIds.contains(id);

  /// Whether [id] is a "final" element: never used as an ingredient, so it sits
  /// at the end of a chain and cannot make anything further.
  static bool isFinalItem(String id) => !_ingredientIds.contains(id);

  /// "Final" elements: those never used as an ingredient (the end of a chain).
  static int get finalItemCount =>
      elements.keys.where(isFinalItem).length;
}
