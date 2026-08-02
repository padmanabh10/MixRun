"""Hand-authored alternate recipes.

Tier 1 - the everyday spine: nature and childhood concepts a child guesses
first. Goal is both more ways in AND a shallower chain, since `plant`, `tree`
and `seed` gate most of the living world.

Tier 2 - the heritage gateways: the 67 foundation items added in the 2026-07-02
expansion each shipped with exactly one recipe, and they sit at depth 11-18.
They gate every themed level, so each gets 2-3 thematically sound alternates
built from shallower ingredients.

Each entry is (a, b, result). Order does not matter; the validator sorts, checks
for collisions against the live catalog and against the rest of this file, and
enforces that ingredients never come from a later Journey level than the result.
"""

# --------------------------------------------------------------------------
# Tier 1a: obvious guesses that currently produce nothing.
# --------------------------------------------------------------------------
OBVIOUS = [
    ('water', 'tree', 'fruit'),        # watering a tree gives fruit
    ('plant', 'plant', 'tree'),        # plants grow into a tree
    ('rain', 'seed', 'plant'),         # the classic: rain + seed sprouts
    ('rain', 'plant', 'tree'),
    ('grass', 'earth', 'field'),
    ('sun', 'earth', 'sunrise'),       # sun over the earth
    ('sun', 'seed', 'plant'),
    ('sun', 'plant', 'flower'),        # NOTE: sun+plant is taken (oxygen) - validator will drop
    ('earth', 'grass', 'field'),
    ('water', 'grass', 'reed'),
    ('fire', 'tree', 'charcoal'),
    ('water', 'flower', 'lotus'),
    ('earth', 'flower', 'garden'),
    ('water', 'sand', 'mud'),
    ('air', 'tree', 'leaf'),
    ('wind', 'tree', 'leaf'),
    ('water', 'leaf', 'tea'),
    ('fire', 'sand', 'glass'),
    ('water', 'bird', 'duck'),
    ('water', 'cow', 'milk'),
]

# --------------------------------------------------------------------------
# Tier 1b: the living world - shallower roots for plant/tree/seed/wood.
# --------------------------------------------------------------------------
NATURE = [
    ('life', 'mud', 'plant'),          # life in mud -> the first plant (depth 7)
    ('life', 'soil', 'plant'),
    ('life', 'plant', 'seed'),
    ('fruit', 'earth', 'seed'),
    ('fruit', 'soil', 'seed'),
    ('flower', 'earth', 'seed'),
    ('tree', 'stone', 'wood'),         # chop it
    ('tree', 'tool', 'wood'),
    ('tree', 'hammer', 'wood'),
    ('tree', 'sun', 'fruit'),
    ('tree', 'rain', 'fruit'),
    ('tree', 'garden', 'orchard'),
    ('tree', 'water', 'sap'),          # NOTE: water+tree used above - validator drops one
    ('plant', 'stone', 'moss'),
    ('plant', 'water', 'reed'),        # NOTE: water+plant taken (algae)
    ('grass', 'water', 'reed'),
    ('grass', 'sun', 'hay'),
    ('grass', 'field', 'hay'),
    ('tree', 'forest', 'wood'),
    ('seed', 'soil', 'plant'),         # NOTE: taken - validator drops
    ('life', 'sea', 'fish'),
    ('life', 'sky', 'bird'),
    ('life', 'air', 'bird'),
    ('life', 'forest', 'animal'),
    ('life', 'tree', 'monkey'),
    ('life', 'earth', 'animal'),       # NOTE: taken (soil)
    ('animal', 'grass', 'cow'),
    ('animal', 'field', 'livestock'),
    ('animal', 'house', 'cat'),
    ('animal', 'village', 'dog'),
    ('bird', 'water', 'duck'),
    ('bird', 'tree', 'nest'),
    ('bird', 'colour', 'parrot'),      # NOTE: no 'colour' element - validator drops
    ('bird', 'rainbow', 'parrot'),
    ('bird', 'forest', 'parrot'),
]

# --------------------------------------------------------------------------
# Tier 1c: people, settlement and craft - the other early hubs.
# --------------------------------------------------------------------------
PEOPLE = [
    ('human', 'human', 'family'),
    ('human', 'village', 'farmer'),
    ('human', 'field', 'farmer'),
    ('human', 'house', 'family'),
    ('human', 'flower', 'woman'),
    ('human', 'beauty', 'woman'),      # NOTE: no 'beauty' - dropped
    ('human', 'garden', 'gardener'),
    ('human', 'story', 'writer'),
    ('house', 'house', 'village'),
    ('village', 'house', 'city'),
    ('village', 'wall', 'city'),
    ('village', 'road', 'city'),
    ('city', 'city', 'empire'),
    ('stone', 'stone', 'wall'),
    ('wall', 'wall', 'house'),
    ('wood', 'stone', 'tool'),
    ('stone', 'human', 'tool'),
    ('wood', 'human', 'tool'),
    ('fire', 'stone', 'metal'),
    ('fire', 'rock', 'metal'),
    ('fire', 'human', 'campfire'),
    ('fire', 'wood', 'campfire'),      # NOTE: taken - dropped
    ('human', 'music', 'musician'),
    ('human', 'drum', 'musician'),
    ('human', 'paint', 'painter'),
    ('human', 'stone', 'statue'),
    ('stone', 'tool', 'statue'),
    ('human', 'idea', 'story'),
    ('human', 'book', 'story'),
    ('human', 'fire', 'story'),        # NOTE: fire+human used above - dropped
]

# --------------------------------------------------------------------------
# Tier 2a: the built heritage - temple, fort, palace and the empire chain.
# These gate History, Culture, Arts and Heroes, so they need shallow routes.
# --------------------------------------------------------------------------
HERITAGE_BUILT = [
    # temple (was 11, only statue+stone)
    ('stone', 'goddess', 'temple'),
    ('stone', 'dome', 'temple'),
    ('marble', 'statue', 'temple'),
    ('pillar', 'stone', 'temple'),
    ('arch', 'statue', 'temple'),
    # monk / monastery / goddess
    ('human', 'peace', 'monk'),
    ('human', 'philosophy', 'monk'),
    ('monk', 'mountain', 'monastery'),
    ('monk', 'house', 'monastery'),
    ('temple', 'mountain', 'monastery'),
    ('goddess', 'statue', 'temple'),   # NOTE: dup shape - validator dedupes
    ('woman', 'statue', 'goddess'),
    ('woman', 'temple', 'goddess'),    # NOTE: taken - dropped
    # fort / palace / castle (were 15)
    ('wall', 'hill', 'fort'),
    ('wall', 'stone', 'fort'),         # NOTE: stone+wall taken (arch) - dropped
    ('house', 'wall', 'castle'),
    ('city', 'wall', 'fort'),
    ('stone', 'castle', 'fort'),
    ('marble', 'castle', 'palace'),
    ('gold', 'house', 'palace'),
    ('monarch', 'house', 'palace'),
    ('marble', 'house', 'palace'),     # NOTE: dup - dedupe
    # monarch / empire / army / war / law (were 15-18)
    ('human', 'gold', 'monarch'),
    ('human', 'castle', 'monarch'),
    ('human', 'palace', 'monarch'),
    ('warrior', 'gold', 'monarch'),
    ('city', 'city', 'empire'),        # NOTE: dup with PEOPLE - dedupe
    ('monarch', 'land', 'empire'),
    ('monarch', 'continent', 'empire'),
    ('monarch', 'army', 'empire'),
    ('warrior', 'warrior', 'army'),
    ('warrior', 'village', 'army'),
    ('warrior', 'city', 'army'),
    ('human', 'sword', 'warrior'),
    ('human', 'armor', 'warrior'),
    ('human', 'war', 'warrior'),
    ('army', 'sword', 'war'),
    ('army', 'fire', 'war'),
    ('empire', 'empire', 'war'),
    ('book', 'city', 'law'),
    ('book', 'empire', 'law'),
    ('idea', 'monarch', 'law'),
    ('law', 'house', 'prison'),
    ('law', 'fort', 'prison'),
    ('empire', 'cloth', 'flag'),       # NOTE: no 'cloth' - dropped
    ('empire', 'silk', 'flag'),
    ('fabric', 'monarch', 'flag'),
    ('wagon', 'horse', 'chariot'),
    ('wheel', 'warrior', 'chariot'),
    ('wheel', 'horse', 'chariot'),
    ('ruins', 'stone', 'ruins'),       # NOTE: self-result - dropped
    ('wall', 'time', 'ruins'),         # NOTE: no 'time' - dropped
    ('city', 'ruins', 'ruins'),        # NOTE: self-result - dropped
    ('wall', 'sand', 'ruins'),
    ('city', 'sand', 'ruins'),
]

# --------------------------------------------------------------------------
# Tier 2b: music, dance and festival - the whole Arts level hangs off these.
# --------------------------------------------------------------------------
HERITAGE_ARTS = [
    ('sound', 'human', 'music'),
    ('sound', 'idea', 'music'),
    ('drum', 'human', 'music'),        # NOTE: dup with PEOPLE musician - dedupe
    ('flute', 'sound', 'music'),
    ('music', 'city', 'festival'),     # NOTE: taken - dropped
    ('music', 'village', 'festival'),
    ('music', 'temple', 'festival'),
    ('diya', 'village', 'festival'),
    ('diya', 'city', 'festival'),
    ('dance', 'city', 'festival'),
    ('music', 'motion', 'dance'),
    ('music', 'human', 'dance'),       # NOTE: human+music used for musician - dropped
    ('music', 'woman', 'dance'),
    ('festival', 'motion', 'dance'),
    ('drum', 'motion', 'dance'),
    ('music', 'wire', 'harp'),         # NOTE: taken - dropped
    ('sound', 'wire', 'harp'),
    ('wood', 'wire', 'harp'),
    ('story', 'human', 'story'),       # NOTE: self - dropped
    ('idea', 'book', 'story'),
    ('campfire', 'idea', 'story'),
    ('statue', 'stone', 'statue'),     # NOTE: self - dropped
    ('marble', 'hammer', 'statue'),
    ('marble', 'tool', 'statue'),
    ('clay', 'hammer', 'statue'),
]

# --------------------------------------------------------------------------
# Tier 2c: materials, spice and produce - the Culture level's raw stock.
# --------------------------------------------------------------------------
HERITAGE_STOCK = [
    ('plant', 'heat', 'spice'),        # NOTE: taken - dropped
    ('plant', 'fire', 'spice'),
    ('seed', 'heat', 'spice'),         # NOTE: taken (coffee) - dropped
    ('leaf', 'fire', 'spice'),
    ('flower', 'heat', 'spice'),
    ('field', 'water', 'rice'),        # NOTE: taken - dropped
    ('grass', 'field', 'rice'),        # NOTE: dup with hay - dedupe
    ('seed', 'field', 'rice'),         # NOTE: taken (lentil) - dropped
    ('grass', 'water', 'rice'),        # NOTE: dup - dedupe
    ('granite', 'sun', 'marble'),
    ('stone', 'water', 'marble'),
    ('stone', 'polish', 'marble'),     # NOTE: no 'polish' - dropped
    ('thread', 'moth', 'silk'),        # NOTE: taken - dropped
    ('fabric', 'moth', 'silk'),
    ('thread', 'gold', 'silk'),
    ('grass', 'wood', 'bamboo'),       # NOTE: dup shape with tree - check
    ('grass', 'forest', 'bamboo'),
    ('reed', 'wood', 'bamboo'),
    ('flower', 'water', 'lotus'),      # NOTE: dup with OBVIOUS - dedupe
    ('flower', 'pond', 'lotus'),
    ('flower', 'lake', 'lotus'),
    ('fire', 'clay', 'diya'),
    ('fire', 'oil', 'diya'),
    ('pottery', 'oil', 'diya'),
    ('animal', 'forest', 'tiger'),     # NOTE: taken (deer) - dropped
    ('lion', 'forest', 'tiger'),       # NOTE: taken - dropped
    ('cat', 'forest', 'tiger'),
    ('cat', 'jungle', 'tiger'),        # NOTE: no 'jungle' - dropped
    ('animal', 'mountain', 'yak'),
    ('cow', 'mountain', 'yak'),
    ('animal', 'boulder', 'rhino'),    # NOTE: taken (elephant) - dropped
    ('animal', 'swamp', 'rhino'),
    ('animal', 'grass', 'deer'),       # NOTE: dup with cow - dedupe
    ('deer', 'forest', 'deer'),        # NOTE: self - dropped
    ('animal', 'tree', 'monkey'),      # NOTE: dup with life+tree - fine, different pair
    ('animal', 'snow', 'snowleopard'),
    ('cat', 'snow', 'snowleopard'),
    ('animal', 'sky', 'bird'),         # NOTE: dup - dedupe
    ('fruit', 'tree', 'mango'),
    ('fruit', 'forest', 'mango'),      # NOTE: taken (jackfruit) - dropped
    ('fruit', 'heat', 'mango'),
    ('fruit', 'sugar', 'jaggery'),     # NOTE: taken? check
    ('sugar', 'heat', 'jaggery'),
    ('milk', 'fire', 'ghee'),
    ('butter', 'heat', 'ghee'),
    ('seed', 'fire', 'coffee'),
    ('seed', 'sun', 'coffee'),
    ('leaf', 'water', 'tea'),          # NOTE: dup with OBVIOUS - dedupe
    ('leaf', 'heat', 'tea'),
]

# --------------------------------------------------------------------------
# Tier 4: the stragglers.
#
# Base items the rule engine cannot help, because their one recipe is already
# the only obvious phrasing (star+star, oxygen+oxygen, telescope+telescope) and
# there is no cluster-mate to swap in. Plus the four states items whose only
# recipe needs a History ingredient, which a States player has not unlocked yet.
# Several candidates are listed per item; the validator keeps the first that is
# free and drops the rest.
# --------------------------------------------------------------------------
LEFTOVERS = [
    ('night', 'star', 'constellation'), ('sky', 'star', 'constellation'),
    ('sun', 'horizon', 'dawn'), ('darkness', 'sun', 'dawn'),
    ('moon', 'darkness', 'eclipse'), ('moon', 'day', 'eclipse'),
    ('darkness', 'sky', 'night'), ('darkness', 'day', 'night'),
    ('oxygen', 'atmosphere', 'ozone'), ('oxygen', 'sky', 'ozone'),
    ('planet', 'ice', 'saturn'), ('jupiter', 'ring', 'saturn'),
    ('energy', 'sky', 'star'), ('energy', 'galaxy', 'star'),
    ('darkness', 'horizon', 'twilight'), ('night', 'horizon', 'twilight'),
    ('charcoal', 'pressure', 'diamond'), ('coal', 'mineral', 'diamond'),
    ('sheep', 'scissors', 'wool'), ('sheep', 'thread', 'wool'),
    ('sheep', 'fabric', 'wool'), ('sheep', 'sheep', 'wool'),
    ('flower', 'gold', 'sunflower'), ('flower', 'day', 'sunflower'),
    ('moth', 'flower', 'butterfly'), ('moth', 'rainbow', 'butterfly'),
    ('bee', 'sugar', 'honey'), ('beehive', 'sugar', 'honey'),
    ('fruit', 'palm', 'banana'), ('monkey', 'fruittree', 'banana'),
    ('idea', 'telescope', 'science'), ('idea', 'machine', 'science'),
    ('pipe', 'bucket', 'waterpipe'), ('pipe', 'house', 'waterpipe'),
    ('duck', 'nest', 'duckling'), ('duck', 'duck', 'duckling'),
    ('glass', 'sun', 'prism'), ('diamond', 'sun', 'prism'),
    ('water', 'land', 'puddle'), ('rain', 'road', 'puddle'),
    ('puddle', 'rain', 'rivulet'), ('puddle', 'puddle', 'rivulet'),
    ('flower', 'swamp', 'lotus'), ('garden', 'mud', 'lotus'),
    ('flower', 'forest', 'orchid'), ('rose', 'rainforest', 'orchid'),
    ('vine', 'spice', 'pepper'), ('seed', 'chili', 'pepper'),
    ('ginger', 'gold', 'turmeric'), ('spice', 'sun', 'turmeric'),
    ('flower', 'perfume', 'saffron'), ('rose', 'spice', 'saffron'),
    ('spice', 'perfume', 'cardamom'), ('seed', 'garden', 'cardamom'),
    ('vegetable', 'farm', 'onion'), ('vegetable', 'orchard', 'onion'),
    # NB: no vegetable+land here - that pair is the rule engine's only route to
    # potato, and hand-authored entries are placed first.
    ('vegetable', 'plant', 'onion'),
    ('vegetable', 'mud', 'potato'), ('vegetable', 'clay', 'potato'),
    ('fruit', 'orchard', 'mango'), ('fruit', 'warmth', 'mango'),
    ('tree', 'spice', 'tamarind'), ('fruittree', 'spice', 'tamarind'),
    ('andhrapradesh', 'city', 'amaravati'), ('andhrapradesh', 'river', 'amaravati'),
    ('uttarakhand', 'river', 'haridwar'), ('uttarakhand', 'temple', 'haridwar'),
    ('kolkata', 'marble', 'victoriamemorial'), ('kolkata', 'palace', 'victoriamemorial'),
    ('beach', 'wall', 'daman'), ('beach', 'street', 'daman'),
    ('sea', 'street', 'daman'), ('island', 'fort', 'daman'),

    # Trades and callings, which have no interchangeable cluster-mate: each is
    # its tool or its subject plus the person, not a different profession.
    ('human', 'rose', 'love'), ('rose', 'woman', 'love'),
    ('book', 'library', 'librarian'), ('idea', 'library', 'librarian'),
    ('knife', 'meat', 'butcher'), ('blade', 'meat', 'butcher'),
    ('star', 'telescope', 'astronomer'), ('science', 'telescope', 'astronomer'),
    ('temple', 'philosophy', 'monk'), ('monastery', 'human', 'monk'),
    ('motion', 'village', 'sport'), ('motion', 'city', 'sport'),
    ('monk', 'philosophy', 'enlightenment'), ('peace', 'philosophy', 'enlightenment'),
    # An elephant is not made from a pebble.
    ('animal', 'mountainrange', 'elephant'), ('animal', 'hill', 'elephant'),
]

# --------------------------------------------------------------------------
# Tier 5: where the generic level anchor says the wrong thing.
#
# The anchor rule pairs an item with a stock ingredient for its Journey level,
# which reads well for the things that level is mostly about (a state and its
# landmark, a dish and its spice, a king and his empire) and badly for the rest.
# Geography filed under History became "cloud+empire->himalayas"; crafts filed
# under Arts became "gold+music->zardozi"; instruments and observances filed
# under Culture became "harp+spice->sitar" and "philosophy+spice->yoga".
# These are authored from what the thing actually is.
# --------------------------------------------------------------------------
CORRECTIONS = [
    # History: landforms and rivers, which owe nothing to an empire.
    ('camel', 'sand', 'thardesert'), ('camel', 'dune', 'thardesert'),
    ('cloud', 'mountain', 'himalayas'), ('snow', 'mountainrange', 'himalayas'),
    ('rainforest', 'mountain', 'westernghats'), ('rainforest', 'hill', 'westernghats'),
    ('plateau', 'stone', 'deccanplateau'), ('plateau', 'hill', 'deccanplateau'),
    ('mountainrange', 'desert', 'aravallirange'), ('hill', 'desert', 'aravallirange'),
    ('coral', 'sea', 'coralreef'), ('coral', 'island', 'coralreef'),
    ('river', 'goddess', 'ganga'), ('river', 'glacier', 'ganga'),
    ('fire', 'story', 'vedicage'), ('story', 'philosophy', 'vedicage'),

    # Culture: instruments are wood, skin and string - not spice.
    ('drum', 'leather', 'mridangam'), ('drum', 'clay', 'mridangam'),
    ('leather', 'wood', 'tabla'), ('drum', 'drum', 'tabla'),
    ('flute', 'wood', 'shehnai'), ('flute', 'festival', 'shehnai'),
    ('harp', 'music', 'sitar'), ('harp', 'festival', 'sitar'),
    ('sitar', 'music', 'veena'), ('sitar', 'temple', 'veena'),

    # Culture: observances, ornaments and crafts.
    ('philosophy', 'motion', 'yoga'), ('philosophy', 'peace', 'yoga'),
    ('peace', 'village', 'namaste'), ('peace', 'family', 'namaste'),
    ('seed', 'temple', 'rudraksha'), ('seed', 'monk', 'rudraksha'),
    ('shell', 'temple', 'conch'), ('shell', 'sound', 'conch'),
    ('powder', 'woman', 'bindi'), ('kumkum', 'woman', 'bindi'),
    ('ring', 'glass', 'bangles'), ('ring', 'woman', 'bangles'),
    ('bell', 'ring', 'anklet'), ('bell', 'woman', 'anklet'),
    ('cotton', 'wheel', 'charkha'), ('thread', 'wheel', 'charkha'),

    # Arts: crafts, which are clay, metal and thread rather than music.
    ('clay', 'pottery', 'terracotta'), ('clay', 'heat', 'terracotta'),
    ('bronze', 'clay', 'dhokra'), ('metal', 'wax', 'dhokra'),
    ('gold', 'needle', 'zardozi'), ('silk', 'gold', 'zardozi'),
    ('gold', 'paint', 'meenakari'), ('metal', 'paint', 'meenakari'),
    ('clay', 'paint', 'bluepottery'), ('pottery', 'rainbow', 'bluepottery'),

    # Heroes: Tilak revived the Ganesh festival; he was not a dancer.
    ('festival', 'writer', 'balgangadhartilak'),
    ('festival', 'independence', 'balgangadhartilak'),
]

ALL_HAND = (OBVIOUS + NATURE + PEOPLE + HERITAGE_BUILT + HERITAGE_ARTS
            + HERITAGE_STOCK + LEFTOVERS + CORRECTIONS)
