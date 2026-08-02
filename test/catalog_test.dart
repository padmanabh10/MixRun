import 'package:flutter_test/flutter_test.dart';

import 'package:mixrun/data/game_data.dart';

/// Structural guarantees for the element graph.
///
/// `game_data.dart` is generated, so these are the properties a regeneration
/// must not quietly break: the graph stays closed, stays winnable from the four
/// starters, and stays fair - no item reachable by only one lucky pair.
void main() {
  final Set<String> ids = GameData.elements.keys.toSet();

  test('every recipe is made of real elements and makes a real one', () {
    for (final (String a, String b, String result) in GameData.allRecipes) {
      expect(ids, contains(a), reason: 'unknown ingredient "$a"');
      expect(ids, contains(b), reason: 'unknown ingredient "$b"');
      expect(ids, contains(result), reason: 'unknown result "$result"');
    }
  });

  test('no recipe produces one of its own ingredients', () {
    // Three inherited from the original curated set are deliberate jokes or
    // no-ops and are left alone; nothing new may join them, since a generated
    // "a+b makes a" is a bug rather than a gag.
    const Set<String> legacy = <String>{
      'coal+fire',
      'explosion+petroleum',
      'rabbit+rabbit',
    };
    final List<String> offenders = <String>[
      for (final (String a, String b, String result) in GameData.allRecipes)
        if ((result == a || result == b) &&
            !legacy.contains(GameData.recipeKey(a, b)))
          '$a+$b->$result',
    ];
    expect(offenders, isEmpty);
  });

  test('every element except the starters has at least two recipes', () {
    // One recipe per item is what made the game unfair: miss the single pair
    // and the item is simply unreachable. See the note on GameData._recipes.
    final List<String> thin = <String>[
      for (final String id in ids)
        if (!GameData.starterIds.contains(id) &&
            GameData.recipesProducing(id).length < 2)
          id,
    ];
    expect(thin, isEmpty, reason: 'single-path items: ${thin.join(", ")}');
  });

  test('every element is reachable from the four starters', () {
    final Set<String> have = GameData.starterIds.toSet();
    bool grew = true;
    while (grew) {
      grew = false;
      for (final (String a, String b, String result) in GameData.allRecipes) {
        if (have.contains(a) && have.contains(b) && have.add(result)) {
          grew = true;
        }
      }
    }
    expect(ids.difference(have), isEmpty);
  });

  test('nothing sits deeper than 15 combinations from the starters', () {
    // Depth is the number of rounds of simultaneous crafting needed. The
    // themed levels used to bottom out at 19, behind single-recipe chains.
    final Set<String> have = GameData.starterIds.toSet();
    int rounds = 0;
    while (have.length < ids.length) {
      final Set<String> next = <String>{
        for (final (String a, String b, String result) in GameData.allRecipes)
          if (!have.contains(result) && have.contains(a) && have.contains(b))
            result,
      };
      if (next.isEmpty) break;
      have.addAll(next);
      rounds++;
    }
    expect(rounds, lessThanOrEqualTo(15));
  });
}
