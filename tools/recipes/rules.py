"""Rule-based alternates for the long tail of single-recipe items.

Two high-precision rules, in order:

1. Cluster substitution - swap one ingredient for a near-synonym from the same
   semantic cluster, keeping the distinguishing ingredient. `dispur = city+tea`
   becomes `village+tea`; `bharatanatyam = dance+tamilnadu` becomes
   `music+tamilnadu`. Meaning is preserved because the swapped ingredient is the
   generic anchor, not the thing that identifies the item.

2. Category anchor - when no cluster fits, pair the distinguishing ingredient
   with a generic anchor for the item's own Journey level (a state pairs with
   land/map, a hero with warrior/monarch, a dance with music).
"""

# Deliberately excluded, after reviewing a first pass:
#   human<->woman   - flips the gender of real people (Tilak, Shivaji, ...)
#   temple<->church - a Christian building is wrong for a named Hindu or
#                     Buddhist site; temple<->monastery is kept, and is right
#                     for cases like Sattriya, which was born in monasteries
#   lion<->tiger<->elephant, mango<->apple, gold<->diamond
#                   - swapping one named species or material for another states
#                     something factually false about a real place or dish
CLUSTERS = [
    ['earth', 'land', 'soil'],
    ['stone', 'rock', 'boulder', 'pebble', 'granite'],
    ['lake', 'pond', 'river', 'stream'],
    ['sea', 'ocean', 'lake'],
    ['hill', 'mountain', 'mountainrange', 'plateau', 'cliff'],
    # No cluster for people. Roles are not interchangeable in either direction:
    # human->farmer made "farmer+telescope->astronomer", and human->warrior made
    # "meat+warrior->butcher" and "library+warrior->librarian". The handful of
    # base items this leaves short are hand-authored in additions.py.
    ['monarch', 'empire'],
    ['warrior', 'army'],
    ['fire', 'heat', 'warmth', 'lava'],
    ['cold', 'ice', 'snow', 'glacier'],
    ['plant', 'grass', 'tree', 'forest', 'garden'],
    ['tree', 'wood', 'bamboo', 'forest'],
    ['fabric', 'silk', 'cotton', 'wool', 'thread'],
    ['metal', 'steel', 'copper', 'bronze'],
    ['wall', 'brick', 'house', 'castle', 'fort', 'palace'],
    ['tower', 'pillar', 'arch', 'dome', 'minaret'],
    ['village', 'city', 'house', 'street'],
    ['temple', 'monastery'],
    ['music', 'drum', 'flute', 'dance', 'festival'],
    ['painting', 'paint', 'canvas'],
    ['rice', 'wheat', 'flour', 'lentil'],
    ['sand', 'dune', 'desert'],
    ['bird', 'eagle', 'crow', 'pigeon', 'owl'],
    # sun<->fire is not a swap either: it made "fire+moon->eclipse" and
    # "diya+fruit->mango". The sun is celestial, a flame is not.
    ['boat', 'sailboat'],
    ['book', 'paper', 'letter', 'story'],
    ['sword', 'blade', 'bow', 'axe'],
    ['dawn', 'twilight', 'sunrise'],
    ['waterfall', 'river', 'valley'],
    ['ruins', 'fossil', 'cave'],
    ['milk', 'butter', 'yogurt'],
    ['sugar', 'jaggery', 'honey'],
    ['island', 'archipelago', 'beach'],
    ['glacier', 'snow', 'valley'],
    ['tool', 'hammer', 'machine'],
    ['idea', 'philosophy', 'science', 'plan'],
    ['war', 'army', 'empire'],
    ['statue', 'pillar', 'marble'],
    ['garden', 'field', 'orchard', 'farm'],
    ['law', 'book', 'idea'],
]

# Words that name what an item *is*, rather than which one it is. When a recipe
# contains one, the cluster swap is tried first so the alternate keeps saying
# "this is a dance" / "this is a fort"  -  otherwise the anchor rule can drop the
# type word and leave "city+statue->odissi", which no longer reads as a dance.
TYPE_WORDS = {
    'dance', 'music', 'festival', 'painting', 'temple', 'monastery', 'fort',
    'palace', 'empire', 'monarch', 'warrior', 'story', 'boat', 'spice',
}

# Generic anchors to pair a distinguishing ingredient with, per Journey level.
#
# Base has none on purpose. Its items are generic concepts, so a generic anchor
# says nothing ("land+ring->saturn", "bee+land->honey"); the leftovers are
# hand-authored in additions.py instead.
ANCHORS = {
    'states':  ['land', 'map', 'city', 'river', 'mountain', 'village'],
    'history': ['empire', 'ruins', 'story', 'monarch', 'stone'],
    'culture': ['spice', 'festival', 'rice', 'village', 'milk'],
    'arts':    ['music', 'dance', 'painting', 'story', 'festival'],
    'heroes':  ['warrior', 'monarch', 'army', 'story', 'empire'],
}


def _cluster_swaps(a, b):
    """Every (a',b) and (a,b') where the swapped id is a cluster-mate."""
    out = []
    for cluster in CLUSTERS:
        if a in cluster:
            for alt in cluster:
                if alt != a:
                    out.append((alt, b))
        if b in cluster:
            for alt in cluster:
                if alt != b:
                    out.append((a, alt))
    return out


def propose(els, recipes, prod, freq, target=2):
    """Candidate additions, best-first, for every item short of `target`."""
    out = []
    for e, rs in prod.items():
        if e not in els or len(rs) >= target:
            continue
        need = target - len(rs)
        candidates = []
        for (a, b) in rs:
            candidates.extend(_cluster_swaps(a, b))
        # Category anchors: keep the distinguishing ingredient (the rarer one),
        # pair it with a generic anchor for this item's level.
        for (a, b) in rs:
            distinct = a if freq.get(a, 0) <= freq.get(b, 0) else b
            for anchor in ANCHORS.get(els[e]['category'], []):
                candidates.append((distinct, anchor))
        seen = set()
        for (x, y) in candidates:
            if need <= 0:
                break
            key = tuple(sorted((x, y)))
            if key in seen:
                continue
            seen.add(key)
            out.append((x, y, e))
            need -= 1
    return out
