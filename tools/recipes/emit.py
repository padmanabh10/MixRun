"""Splice the merged recipe map back into lib/data/game_data.dart."""
import re
from parse import SRC, load, depths, producers
import build  # runs the pipeline and exposes hand / added_rule

els, order, recipes = load()
merged = dict(recipes)
merged.update(build.hand)
merged.update(build.added_rule)
print(f"merging {len(recipes)} + {len(merged) - len(recipes)} = {len(merged)}")

text = open(SRC, encoding='utf-8').read()

HEADER = """  /// Combination rules keyed by the two ingredient ids sorted and joined with
  /// `+`. Use [recipeFor] rather than indexing directly so ordering is handled.
  ///
  /// Most items have several recipes on purpose. A single path per item made
  /// the game unfair for the children it is for: an item whose one pair you
  /// never guessed was simply unreachable, and the themed levels sat behind
  /// chains up to nineteen combinations long. Every non-starter element now has
  /// at least two ways in.
  static const Map<String, String> _recipes = <String, String>{
"""

start = text.index('  /// Combination rules keyed by')
end = text.index('\n  };', start) + len('\n  };')
body = "".join(f"    '{a}+{b}': '{v}',\n" for (a, b), v in sorted(merged.items()))
text = text[:start] + HEADER + body + '  };' + text[end:]

open(SRC, 'w', encoding='utf-8', newline='\n').write(text)
print("written")

# Re-parse from disk to prove the file says what we think it says.
els2, order2, recipes2 = load()
depth2, reach2 = depths(els2, recipes2)
prod2 = producers(recipes2)
singles = [e for e in order2 if len(prod2[e]) < 2 and e not in ('earth', 'water', 'fire', 'air')]
print(f"re-parsed: elements={len(els2)} recipes={len(recipes2)} "
      f"reachable={len(reach2)} maxdepth={max(depth2.values())} "
      f"under-2-recipes={len(singles)}")
