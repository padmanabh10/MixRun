"""Validate proposed additions against the catalog's invariants."""
import collections
from parse import load, depths, producers, STARTERS

LEVEL_ORDER = ['base', 'states', 'history', 'culture', 'arts', 'heroes']


def validate(proposed, els, recipes, verbose=True):
    """Returns (accepted, rejected) where rejected is [(a,b,r,reason)]."""
    rank = {c: i for i, c in enumerate(LEVEL_ORDER)}
    accepted = {}
    rejected = []
    for a, b, r in proposed:
        key = tuple(sorted((a, b)))
        if a not in els:
            rejected.append((a, b, r, f"no element '{a}'")); continue
        if b not in els:
            rejected.append((a, b, r, f"no element '{b}'")); continue
        if r not in els:
            rejected.append((a, b, r, f"no element '{r}'")); continue
        if r in (a, b):
            rejected.append((a, b, r, "result is its own ingredient")); continue
        if r in STARTERS:
            rejected.append((a, b, r, "result is a starter")); continue
        if key in recipes:
            rejected.append((a, b, r, f"pair taken -> {recipes[key]}")); continue
        if key in accepted:
            rejected.append((a, b, r, f"duplicate of proposed -> {accepted[key]}")); continue
        ra, rb, rr = rank[els[a]['category']], rank[els[b]['category']], rank[els[r]['category']]
        if max(ra, rb) > rr:
            rejected.append((a, b, r, "ingredient from a later Journey level")); continue
        accepted[key] = r
    if verbose:
        print(f"  accepted {len(accepted)}, rejected {len(rejected)}")
    return accepted, rejected


def report(els, order, recipes, extra):
    """Full before/after comparison."""
    merged = dict(recipes)
    merged.update(extra)
    for label, rc in (("BEFORE", recipes), ("AFTER ", merged)):
        depth, reach = depths(els, rc)
        prod = producers(rc)
        singles = [e for e in order if len(prod[e]) == 1]
        zero = [e for e in order if len(prod[e]) == 0 and e not in STARTERS]
        maxd = max(depth.get(e, 0) for e in els)
        avgd = sum(depth.get(e, 0) for e in els) / len(els)
        print(f"{label}: recipes={len(rc)} reachable={len(reach)}/{len(els)} "
              f"maxdepth={maxd} avgdepth={avgd:.1f} single-recipe={len(singles)} "
              f"no-recipe={len(zero)}")
    return merged


if __name__ == '__main__':
    from additions import ALL_HAND
    els, order, recipes = load()
    print("Hand-authored:")
    acc, rej = validate(ALL_HAND, els, recipes)
    print()
    print("=== rejected (reason) ===")
    for a, b, r, why in rej:
        print(f"  {a}+{b} -> {r}   [{why}]")
    print()
    merged = report(els, order, recipes, acc)
    print()
    depth, _ = depths(els, merged)
    prod = producers(merged)
    print("=== gateway depths after hand-authored tier ===")
    for e in ['plant', 'tree', 'seed', 'grass', 'wood', 'fruit', 'temple',
              'monk', 'fort', 'palace', 'monarch', 'empire', 'army', 'war',
              'law', 'flag', 'music', 'festival', 'dance', 'statue', 'story',
              'spice', 'rice', 'silk', 'marble', 'chariot', 'warrior']:
        print(f"  {e:12} depth={depth.get(e):>2} recipes={len(prod[e])}")
