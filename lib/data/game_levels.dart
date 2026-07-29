import 'game_data.dart';
import 'models/game_level.dart';

/// The ordered stops of MixRun's Journey path.
///
/// Level 1, **"Base Level"**, holds the whole curated catalog. It is followed
/// by five themed stops drawn from the Indian-heritage expansion,  States &
/// UTs, History & Sites, Culture & Cuisine, Dance & Local Art, and Heroes &
/// Kings,  each of which unlocks once the stop before it is fully discovered.
/// The Journey UI renders however many stops [all] contains.
abstract final class GameLevels {
  /// The Base Level: the original curated catalog plus the generic building
  /// blocks the expansion introduced,  everything that is not pinned to one of
  /// the five themed stops. It is self-contained and reachable on its own, and
  /// completing it unlocks the first themed level.
  static final GameLevel baseLevel = GameLevel(
    id: 'base',
    titleEn: 'Base Level',
    iconElementId: 'water',
    elementIds: _baseIds,
  );

  /// States & UTs,  210 elements from the heritage expansion.
  static final GameLevel states = GameLevel(
    id: 'states',
    titleEn: 'States & UTs',
    iconElementId: 'tajmahal',
    elementIds: _states,
  );

  /// History & Sites,  26 elements from the heritage expansion.
  static final GameLevel history = GameLevel(
    id: 'history',
    titleEn: 'History & Sites',
    iconElementId: 'mauryaempire',
    elementIds: _history,
  );

  /// Culture & Cuisine,  65 elements from the heritage expansion.
  static final GameLevel culture = GameLevel(
    id: 'culture',
    titleEn: 'Culture & Cuisine',
    iconElementId: 'sitar',
    elementIds: _culture,
  );

  /// Dance & Local Art,  15 elements from the heritage expansion.
  static final GameLevel arts = GameLevel(
    id: 'arts',
    titleEn: 'Dance & Local Art',
    iconElementId: 'madhubani',
    elementIds: _arts,
  );

  /// Heroes & Kings,  32 elements from the heritage expansion.
  static final GameLevel heroes = GameLevel(
    id: 'heroes',
    titleEn: 'Heroes & Kings',
    iconElementId: 'mahatmagandhi',
    elementIds: _heroes,
  );

  /// Every stop on the Journey, in order.
  static final List<GameLevel> all = <GameLevel>[
    baseLevel,
    states,
    history,
    culture,
    arts,
    heroes,
  ];

  /// Ids claimed by the five themed levels, used to carve them out of the
  /// Base Level so no element is counted toward two stops.
  static final Set<String> _themedIds = <String>{
    ..._states,
    ..._history,
    ..._culture,
    ..._arts,
    ..._heroes,
  };

  /// Everything not pinned to a themed level, in canonical catalog order.
  static final List<String> _baseIds = <String>[
    for (final String id in GameData.elementOrder)
      if (!_themedIds.contains(id)) id,
  ];

  static const List<String> _states = <String>[
    'andhrapradesh', 'amaravati', 'tirupati', 'arakuvalley', 'gongura',
    'arunachalpradesh', 'itanagar', 'tawangmonastery', 'selapass',
    'mithun', 'assam', 'dispur', 'kaziranga', 'kamakhyatemple', 'mugasilk',
    'bihu', 'bihar', 'patna', 'bodhgaya', 'nalanda', 'littichokha',
    'madhubani', 'chhattisgarh', 'raipur', 'chitrakotefalls',
    'bastardhokra', 'wildbuffalo', 'goa', 'panaji', 'basilicaofbomjesus',
    'dudhsagarfalls', 'vindaloo', 'carnival', 'gujarat', 'gandhinagar',
    'girlion', 'rannofkutch', 'somnath', 'statueofunity', 'dhokla',
    'garba', 'bandhani', 'haryana', 'kurukshetra', 'kabaddi', 'buttermilk',
    'himachalpradesh', 'shimla', 'manali', 'rohtangpass', 'kullushawl',
    'jharkhand', 'ranchi', 'hundrufalls', 'betlaforest', 'chhau',
    'karnataka', 'bengaluru', 'hampi', 'mysorepalace', 'coorgcoffee',
    'channapatnatoy', 'yakshagana', 'kerala', 'thiruvananthapuram',
    'alleppeybackwaters', 'munnar', 'padmanabhaswamytemple', 'snakeboat',
    'appam', 'onam', 'kathakali', 'madhyapradesh', 'bhopal', 'khajuraho',
    'sanchistupa', 'kanhabandhavgarh', 'gondart', 'maharashtra', 'mumbai',
    'gatewayofindia', 'ajantaellora', 'raigadfort', 'vadapav', 'warli',
    'lavani', 'manipur', 'imphal', 'loktaklake', 'kanglafort',
    'sangaideer', 'manipuri', 'meghalaya', 'shillong', 'cherrapunji',
    'livingrootbridge', 'nohkalikaifalls', 'mizoram', 'aizawl', 'cheraw',
    'chapcharkut', 'nagaland', 'kohima', 'hornbillfestival', 'odisha',
    'bhubaneswar', 'jagannathtemple', 'konarksuntemple', 'chilikalake',
    'rathyatra', 'pattachitra', 'odissi', 'punjab', 'amritsar',
    'goldentemple', 'wagahborder', 'sarsondasaag', 'bhangra', 'rajasthan',
    'jaipur', 'amberfort', 'mehrangarhfort', 'hawamahal', 'jaisalmer',
    'dalbaati', 'ghoomar', 'kathputli', 'sikkim', 'gangtok',
    'kanchenjunga', 'rumtekmonastery', 'tamilnadu', 'chennai',
    'meenakshitemple', 'brihadeeswaratemple', 'mahabalipuram', 'pongal',
    'bharatanatyam', 'tanjorepainting', 'telangana', 'hyderabad',
    'charminar', 'golcondafort', 'hyderabadibiryani', 'bidriware',
    'bathukamma', 'tripura', 'agartala', 'ujjayantapalace', 'neermahal',
    'unakoti', 'uttarpradesh', 'lucknow', 'tajmahal', 'varanasi',
    'fatehpursikri', 'awadhikebab', 'kathak', 'chikankari', 'banarasisilk',
    'uttarakhand', 'dehradun', 'kedarnath', 'rishikesh', 'haridwar',
    'valleyofflowers', 'jimcorbett', 'westbengal', 'kolkata',
    'victoriamemorial', 'sundarbans', 'darjeelingtea', 'howrahbridge',
    'rasgulla', 'durgapuja', 'kalighatpainting', 'delhi', 'redfort',
    'indiagate', 'qutubminar', 'jamamasjid', 'lotustemple',
    'jammukashmir', 'srinagar', 'dallake', 'shikara', 'vaishnodevi',
    'pashmina', 'ladakh', 'leh', 'pangonglake', 'thikseymonastery',
    'puducherry', 'frenchquarter', 'auroville', 'promenade', 'chandigarh',
    'rockgarden', 'sukhnalake', 'andamannicobarislands', 'portblair',
    'cellularjail', 'radhanagarbeach', 'lakshadweep', 'kavaratti',
    'lagoon', 'dadranagarhavelianddamandiu', 'diufort', 'daman',
  ];

  static const List<String> _history = <String>[
    'indusvalleycivilization', 'vedicage', 'mauryaempire', 'ashokanedict',
    'guptaempire', 'cholaempire', 'vijayanagaraempire', 'delhisultanate',
    'mughalempire', 'marathaempire', 'sikhempire', 'britishraj',
    'revoltof1857', 'saltmarch', 'quitindiamovement', 'independence',
    'partition', 'constitutionofindia', 'stupa', 'himalayas', 'ganga',
    'thardesert', 'westernghats', 'deccanplateau', 'aravallirange',
    'coralreef',
  ];

  static const List<String> _culture = <String>[
    'sari', 'dhoti', 'turban', 'lehenga', 'sherwani', 'bangles', 'anklet',
    'nosering', 'bindi', 'mehndi', 'incense', 'rangoli', 'kolam', 'conch',
    'kalash', 'pujathali', 'kumkum', 'toran', 'rudraksha', 'charkha',
    'sitar', 'tabla', 'veena', 'mridangam', 'shehnai', 'yoga',
    'meditation', 'namaste', 'roti', 'naan', 'paratha', 'puri',
    'makkiroti', 'dal', 'curry', 'biryani', 'pulao', 'khichdi', 'paneer',
    'butterchicken', 'tandoori', 'roganjosh', 'sambar', 'rasam', 'samosa',
    'dosa', 'idli', 'vada', 'pakora', 'pavbhaji', 'poha', 'momos',
    'gulabjamun', 'jalebi', 'laddu', 'barfi', 'kheer', 'halwa', 'kulfi',
    'lassi', 'masalachai', 'filtercoffee', 'chutney', 'pickle', 'thali',
  ];

  static const List<String> _arts = <String>[
    'kuchipudi', 'mohiniyattam', 'sattriya', 'dandiya', 'kalbelia',
    'kalamkari', 'phad', 'miniaturepainting', 'keralamural',
    'kanjeevaramsilk', 'zardozi', 'bluepottery', 'dhokra', 'terracotta',
    'meenakari',
  ];

  static const List<String> _heroes = <String>[
    'mahatmagandhi', 'bhagatsingh', 'subhaschandrabose', 'jawaharlalnehru',
    'sardarpatel', 'brambedkar', 'ranilakshmibai', 'chandrashekharazad',
    'sarojininaidu', 'balgangadhartilak', 'swamivivekananda',
    'rabindranathtagore', 'apjabdulkalam', 'ashoka', 'chandraguptamaurya',
    'samudragupta', 'vikramaditya', 'harsha', 'rajarajachola',
    'rajendrachola', 'krishnadevaraya', 'shivaji', 'maharanapratap',
    'prithvirajchauhan', 'akbar', 'shahjahan', 'aurangzeb', 'babur',
    'tipusultan', 'ranjitsingh', 'ahilyabaiholkar', 'ranidurgavati',
  ];

}