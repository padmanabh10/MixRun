"""Build the full set of additions: hand-authored tiers, then rule-based tail."""
import collections, sys
from parse import load, depths, producers, STARTERS
from validate import validate, report, LEVEL_ORDER
from rules import _cluster_swaps, ANCHORS, TYPE_WORDS
from additions import ALL_HAND

TARGET = 2

els, order, recipes = load()
rank = {c: i for i, c in enumerate(LEVEL_ORDER)}
freq = collections.Counter()
for (a, b) in recipes:
    freq[a] += 1
    freq[b] += 1


def ok(a, b, r, live):
    """Same invariants as validate(), for the greedy loop."""
    if a not in els or b not in els or r not in els:
        return False
    if r in (a, b) or r in STARTERS:
        return False
    if tuple(sorted((a, b))) in live:
        return False
    if max(rank[els[a]['category']], rank[els[b]['category']]) > rank[els[r]['category']]:
        return False
    return True


# --- tier 1+2: hand-authored -------------------------------------------------
hand, rejected = validate(ALL_HAND, els, recipes, verbose=False)
live = dict(recipes)
live.update(hand)
print(f"hand-authored accepted: {len(hand)}")

# --- tier 3: rule-based, greedy ---------------------------------------------
prod = producers(live)
added_rule = {}
unfixed = []
for e in order:
    if e in STARTERS:
        continue
    need = TARGET - len(prod[e])
    if need <= 0:
        continue
    swaps, anchors = [], []
    for (a, b) in prod[e]:
        swaps.extend(_cluster_swaps(a, b))
        # Keep whichever ingredient identifies the item (the rarer one) and
        # pair it with a generic anchor for its level.
        distinct = a if freq.get(a, 0) <= freq.get(b, 0) else b
        for anchor in ANCHORS.get(els[e]['category'], []):
            anchors.append((distinct, anchor))
    # Proper nouns (states, heroes, dishes, dances) take the generic anchor
    # first: "Kolkata from a delta and a village" can't be factually wrong,
    # whereas a cluster swap on a named thing can be. Generic base concepts
    # take the cluster swap first, since it preserves their meaning best.
    has_type = any(x in TYPE_WORDS for r in prod[e] for x in r)
    cands = (swaps + anchors) if (els[e]['category'] == 'base' or has_type) \
        else (anchors + swaps)
    seen = set()
    for (x, y) in cands:
        if need <= 0:
            break
        key = tuple(sorted((x, y)))
        if key in seen:
            continue
        seen.add(key)
        if ok(x, y, e, live):
            live[key] = e
            added_rule[key] = e
            need -= 1
    if need > 0:
        unfixed.append((e, need, len(prod[e])))

print(f"rule-based accepted: {len(added_rule)}")
print(f"still short of {TARGET}: {len(unfixed)}")
print("  " + ", ".join(f"{e}(has {h})" for e, n, h in unfixed[:60]))

extra = dict(hand)
extra.update(added_rule)
print()
report(els, order, recipes, extra)

if '--dump' in sys.argv:
    print()
    print("=== every rule-generated recipe, grouped by Journey level ===")
    by_cat = collections.defaultdict(list)
    for (a, b), r in added_rule.items():
        by_cat[els[r]['category']].append(f"{a}+{b}->{r}")
    for cat in LEVEL_ORDER:
        rows = sorted(by_cat[cat])
        print(f"\n--- {cat} ({len(rows)}) ---")
        for i in range(0, len(rows), 3):
            print("   " + "".join(f"{x:<42}" for x in rows[i:i + 3]))
