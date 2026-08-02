# Recipe generator

Adds alternate recipes to `lib/data/game_data.dart` so no element is reachable
by only one lucky pair. Run from the repo root:

```sh
python tools/recipes/build.py          # dry run: report only, writes nothing
python tools/recipes/build.py --dump   # also print every generated recipe
python tools/recipes/emit.py           # apply: rewrite the _recipes map
```

`emit.py` rewrites the whole map sorted by key and re-parses the file afterwards
to prove it says what the report claimed. `flutter test test/catalog_test.dart`
checks the same invariants from Dart, and is the thing CI would catch a bad
regeneration with.

## Why

The curated catalog shipped 483 of its 793 elements with exactly one recipe, and
at depth 15+ that was *every* element. Miss the one pair and the item was
unreachable, which is the wrong game for the children MixRun is for. The themed
Journey levels were worst: `dance` fed 20 items from depth 16 behind a single
thread, so Arts and Heroes were effectively unreachable.

## How it works

Four passes, each validated against the live catalog before anything is kept.

1. **`additions.py`** — hand-authored recipes, in five tiers: obvious guesses
   that used to produce nothing (`water+tree`, `rain+seed`), shallower roots for
   the living world, the heritage gateways that unlock the themed levels,
   stragglers with no cluster-mate, and corrections where a generated recipe
   said something false.
2. **`rules.py`** — two generation rules for the long tail. *Cluster
   substitution* swaps an ingredient for a near-synonym, keeping the one that
   identifies the item (`city+tea` → `village+tea`). *Category anchors* pair the
   identifying ingredient with a stock ingredient for the item's Journey level.
3. **`build.py`** — runs hand-authored first, then greedily fills the rest to
   two recipes each, re-validating as the set grows.
4. **`validate.py`** — the invariants. A candidate is dropped unless both
   ingredients and the result are real elements, the pair is not already taken,
   the result is not one of its own ingredients, and no ingredient comes from a
   *later* Journey level than the result (which would be an alternate the player
   cannot use yet).

## Editing it

Add to the hand-authored lists in `additions.py` first — they are applied before
the rules, so they win any contested pair. Author two or three candidates per
item and let the validator drop the ones already taken; that is cheaper than
looking each pair up by hand.

Be wary of widening the clusters in `rules.py`. The comments there record the
swaps that were tried and reverted, all of which stated something false about a
real person, place or craft: `human`↔`woman` flipped the gender of historical
figures, `human`↔`farmer` made "farmer+telescope→astronomer", `temple`↔`church`
put a Christian building in Hindu sites, and `sun`↔`fire` produced
"fire+moon→eclipse".

## Result

| | before | after |
|---|---|---|
| recipes | 1,860 | 2,465 |
| elements with one recipe | 483 | 0 |
| deepest element | 19 | 15 |
| mean depth | 10.8 | 8.7 |

793 elements, all still reachable from the four starters.
