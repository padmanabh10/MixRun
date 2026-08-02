"""Shared parser for lib/data/game_data.dart."""
import re, collections, os

# Repo root is two levels up from tools/recipes/, so the scripts run from
# anywhere: `python tools/recipes/build.py`.
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SRC = os.path.join(ROOT, 'lib', 'data', 'game_data.dart')
STARTERS = ['earth', 'water', 'fire', 'air']


def load():
    text = open(SRC, encoding='utf-8').read()

    # Elements: id + name + category
    elements = {}
    order = []
    for m in re.finditer(
            r"^    '([a-z0-9]+)': GameElement\(\s*\n"
            r"\s*id: '\1',\s*\n"
            r"\s*nameEn: \"(.*?)\",\s*\n"
            r"\s*transliteration: '(.*?)',\s*\n"
            r"\s*category: ElementCategory\.(\w+),",
            text, re.M):
        eid, name, translit, cat = m.groups()
        elements[eid] = {'name': name, 'category': cat}
        order.append(eid)

    # Recipes: 'a+b': 'result',
    body = text.split('static const Map<String, String> _recipes')[1]
    recipes = {}
    for m in re.finditer(r"^    '([a-z0-9]+)\+([a-z0-9]+)': '([a-z0-9]+)',", body, re.M):
        a, b, r = m.groups()
        recipes[(a, b)] = r
    return elements, order, recipes


def depths(elements, recipes):
    """BFS tier: min rounds of simultaneous crafting from the starters."""
    have = set(STARTERS)
    depth = {s: 0 for s in STARTERS}
    tier = 0
    while True:
        tier += 1
        new = set()
        for (a, b), r in recipes.items():
            if r not in have and a in have and b in have:
                new.add(r)
        if not new:
            break
        for r in new:
            depth[r] = tier
        have |= new
    return depth, have


def producers(recipes):
    p = collections.defaultdict(list)
    for (a, b), r in recipes.items():
        p[r].append((a, b))
    return p


if __name__ == '__main__':
    els, order, recipes = load()
    depth, reach = depths(els, recipes)
    prod = producers(recipes)
    print(f"elements={len(els)} recipes={len(recipes)} reachable={len(reach)}")
    print(f"unreachable={sorted(set(els) - reach)[:20]}")
    counts = collections.Counter(len(prod[e]) for e in els)
    print("recipes-per-item:", dict(sorted(counts.items())))
    maxd = max(depth.values())
    print("max depth:", maxd)
    dd = collections.Counter(depth.values())
    print("depth histogram:", dict(sorted(dd.items())))
    print()
    print("Sample early items:")
    for e in ['tree', 'sky', 'plant', 'rain', 'cloud', 'stone', 'sea', 'sand',
              'grass', 'flower', 'wood', 'seed', 'mud', 'dust', 'steam', 'life']:
        if e in els:
            print(f"  {e:10} depth={depth.get(e,'-'):>3} recipes={len(prod[e])} -> {prod[e][:4]}")
