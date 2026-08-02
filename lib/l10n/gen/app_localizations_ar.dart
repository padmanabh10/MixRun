// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get play => 'Play';

  @override
  String get encyclopedia => 'Encyclopedia';

  @override
  String get settings => 'Settings';

  @override
  String get tagline => 'Mix the elements of India';

  @override
  String get discovered => 'Discovered';

  @override
  String get searchElements => 'Search elements';

  @override
  String get hint => 'Hint';

  @override
  String get clear => 'Clear';

  @override
  String get revert => 'Revert';

  @override
  String get close => 'Close';

  @override
  String get learnMore => 'Learn More';

  @override
  String get readMore => 'Read More';

  @override
  String get watchVideo => 'Watch a Video';

  @override
  String get newDiscovery => 'New Discovery';

  @override
  String get continueLabel => 'Continue';

  @override
  String get dragHint => 'Drag two elements together';

  @override
  String get tapToAdd => 'or tap an element below to add it';

  @override
  String get back => 'Back';

  @override
  String get language => 'Language';

  @override
  String get audio => 'Audio';

  @override
  String get sound => 'Sound effects';

  @override
  String get music => 'Background music';

  @override
  String get reset => 'Reset progress';

  @override
  String get resetConfirm => 'Yes, reset everything';

  @override
  String get gotIt => 'Take me there';

  @override
  String get about => 'About MixRun';

  @override
  String get aboutBody =>
      'A learning game that blends the elements of Indian nature, culture and science. Every discovery links to an article or video to learn more.';

  @override
  String get progress => 'Progress';

  @override
  String get all => 'All';

  @override
  String get madeFrom => 'Made from';

  @override
  String get activeHintTitle => 'Active Hint';

  @override
  String get discoverNext => 'Discover this next';

  @override
  String get figureOutRecipe => 'Combine elements on the canvas to discover it';

  @override
  String get getHint => 'Get a hint';

  @override
  String get newHint => 'New hint';

  @override
  String get noHint => 'You have discovered everything reachable. Amazing!';

  @override
  String get watchAdForHint =>
      'Watch a short video to the end to unlock a hint';

  @override
  String get adNotReady =>
      'The video isn\'t ready yet. Please try again in a moment.';

  @override
  String get loadingAd => 'Loading video…';

  @override
  String get activeHintsTitle => 'Active hints';

  @override
  String hintsLeftToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hints left today',
      one: '1 hint left today',
      zero: 'No hints left today',
    );
    return '$_temp0';
  }

  @override
  String get dailyHintLimitReached =>
      'You\'ve used all your hints for today. Come back tomorrow!';

  @override
  String get maxHintsReached =>
      'You\'ve reached the maximum number of active hints. Discover some before getting more.';

  @override
  String get alphabetical => 'Alphabetical';

  @override
  String get recentlyDiscovered => 'Recently discovered';

  @override
  String get makes => 'Makes';

  @override
  String get combinations => 'Combinations';

  @override
  String get categories => 'Categories';

  @override
  String get addToWorkspace => 'Add to workspace';

  @override
  String get discoveredStatus => 'Discovered';

  @override
  String get notDiscovered => 'Not yet discovered';

  @override
  String get noCombinations => 'No combinations yet';

  @override
  String undiscoveredCombosLine(int count, String withAnd) {
    String _temp0 = intl.Intl.selectLogic(withAnd, {
      'true': 'and ',
      'other': '',
    });
    String _temp1 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count undiscovered combinations…',
      one: '$count undiscovered combination…',
    );
    return '$_temp0$_temp1';
  }

  @override
  String andMoreUndiscovered(int count) {
    return 'and $count undiscovered…';
  }

  @override
  String get stats => 'Stats';

  @override
  String get discoveredItems => 'Discovered items';

  @override
  String get basicItems => 'Basic items';

  @override
  String get finalItems => 'Final items';

  @override
  String get combosFound => 'Combinations found';

  @override
  String get categoryCount => 'categories';

  @override
  String get depletedItems => 'Depleted items';

  @override
  String get depleted => 'Depleted';

  @override
  String get finalLabel => 'Final';

  @override
  String get account => 'Account';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get createAccount => 'Create account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get orDivider => 'or';

  @override
  String get toggleToRegister => 'New here? Create an account';

  @override
  String get toggleToSignIn => 'Already have an account? Sign in';

  @override
  String get signInBlurb => 'Sign in to save your progress to your account';

  @override
  String get accountUnavailable =>
      'Sign-in isn\'t available yet,  the backend isn\'t configured.';

  @override
  String get exitGameTitle => 'Exit game?';

  @override
  String get exitGameBody => 'Do you want to exit the game?';

  @override
  String get exitGame => 'Exit';

  @override
  String get stay => 'Stay';

  @override
  String get journey => 'Journey';

  @override
  String get yourJourney => 'Your Journey';

  @override
  String get journeyCompletion => 'Completion';

  @override
  String get journeyDiscoveries => 'Discoveries';

  @override
  String get levelComplete => 'Complete';

  @override
  String get locked => 'Locked';

  @override
  String get introSkip => 'Skip';

  @override
  String get introNext => 'Next';

  @override
  String get introStart => 'Start playing';

  @override
  String get introWelcomeTitle => 'Welcome to MixRun';

  @override
  String introWelcomeBody(int count) {
    return 'Start with four elements and combine them, two at a time, to uncover $count things,  monuments, festivals, food, art and the people who shaped India.';
  }

  @override
  String get introCombineTitle => 'Drop one item on another';

  @override
  String get introCombineBody =>
      'Drag an item out of the library, then drop it onto another item on the canvas. If the pair makes something, you\'ve made a discovery.';

  @override
  String get introCombineHint =>
      'Nothing breaks if a pair doesn\'t work,  the items just stay put, so try anything.';

  @override
  String get introLibraryTitle => 'Your library';

  @override
  String get introLibraryBody =>
      'Everything you discover joins the list on the right. Search it when it gets long, and drag from it onto the canvas.';

  @override
  String get introLibraryClear =>
      'Clear tidies the canvas. Undo puts it straight back.';

  @override
  String get introSectionsTitle => 'Getting around';

  @override
  String get introSectionsBody =>
      'The bar along the bottom takes you everywhere.';

  @override
  String get introEncyclopediaBody =>
      'Every item you\'ve found, filterable by level, with a page for each one.';

  @override
  String get introJourneyBody =>
      'Your path through the game. Appears once you unlock the second stop.';

  @override
  String get introStatsBody =>
      'Discoveries, combinations, and how far along you are.';

  @override
  String get introSettingsBody => 'Sound, music, your account,  and the FAQs.';

  @override
  String get introHintBody =>
      'Stuck? A hint nudges you toward something you haven\'t found.';

  @override
  String get introReadyTitle => 'You\'re all set';

  @override
  String get introReadyBody =>
      'Progress saves by itself after every discovery. You can replay this walkthrough any time from Settings › Help.';

  @override
  String get help => 'Help';

  @override
  String get howToPlay => 'How to play';

  @override
  String get howToPlayBlurb => 'Replay the walkthrough';

  @override
  String get faq => 'FAQs';

  @override
  String get faqBlurb => 'How the game works, answered';

  @override
  String get faqSubtitle => 'Everything about playing MixRun';

  @override
  String get faqSectionBasics => 'The basics';

  @override
  String get faqSectionPlaying => 'Playing';

  @override
  String get faqSectionJourney => 'The Journey';

  @override
  String get faqSectionProgress => 'Your progress';

  @override
  String get faqWhatIsQ => 'What is MixRun?';

  @override
  String get faqWhatIsA =>
      'A discovery game. You start with a handful of raw elements and combine them two at a time to create new things,  each one a small piece of Indian heritage, from monuments and festivals to food, art and the people who shaped it.';

  @override
  String get faqStartQ => 'What do I start with?';

  @override
  String get faqStartA =>
      'Four elements: Earth, Water, Fire and Air. Everything else in the game is built from them.';

  @override
  String get faqHowCombineQ => 'How do I combine items?';

  @override
  String get faqHowCombineA =>
      'Drag an item from the library onto the canvas, then drop it on top of another. If the pair makes something, the new item appears and is added to your collection. If it doesn\'t, the items simply stay put,  nothing is lost, so experiment freely.';

  @override
  String get faqHowManyQ => 'How many items are there?';

  @override
  String faqHowManyA(int count, int levels) {
    return '$count in total, spread across $levels stops on the Journey.';
  }

  @override
  String get faqPairQ => 'Can a pair make more than one thing?';

  @override
  String get faqPairA =>
      'No. Each pair has a single result, so re-mixing two items you have already combined just makes the same thing again.';

  @override
  String get faqCantMakeQ => 'Why won\'t two items combine?';

  @override
  String get faqCantMakeA =>
      'Either that pair has no recipe, or the item it would make belongs to a Journey level you haven\'t unlocked yet. Keep exploring the level you\'re on and it will open up.';

  @override
  String get faqBasicQ => 'What are \"basic\" items?';

  @override
  String get faqBasicA =>
      'The classical building blocks,  the four starters plus raw forces like Heat, Life and Motion that come straight from them. You can filter the Encyclopedia down to just these.';

  @override
  String get faqDepletedQ => 'What does \"Depleted\" mean?';

  @override
  String get faqDepletedA =>
      'You have already found every combination that uses that item. It stays in your library, but it has nothing new left to give.';

  @override
  String get faqFinalQ => 'What does \"Final\" mean?';

  @override
  String get faqFinalA =>
      'That item is never used as an ingredient in any recipe. It sits at the end of a chain,  a destination rather than a stepping stone.';

  @override
  String get faqJourneyQ => 'What is the Journey?';

  @override
  String get faqJourneyA =>
      'The path through the game. It opens with the Base Level and continues through five themed stops: States & UTs, History & Sites, Culture & Cuisine, Dance & Local Art, and Heroes & Kings.';

  @override
  String get faqUnlockQ => 'How do I unlock the next level?';

  @override
  String faqUnlockA(int percent) {
    return 'Discover $percent% of the level you are on. The Journey map shows how far along each stop you are.';
  }

  @override
  String get faqHintsQ => 'How do hints work?';

  @override
  String faqHintsA(int daily, int active) {
    return 'A hint points you toward an item you haven\'t found yet. You can unlock $daily a day by watching a short video, and hold up to $active unsolved hints at once,  each one clears when you discover the item it points to.';
  }

  @override
  String get faqSaveQ => 'Is my progress saved?';

  @override
  String get faqSaveA =>
      'Yes,  automatically, on this device, after every discovery. Sign in from Settings to back it up to your account and carry it to another device.';

  @override
  String get faqResetQ => 'Can I start over?';

  @override
  String get faqResetA =>
      'Yes. Settings › Progress › Reset clears every discovery and returns you to the four starting elements. It cannot be undone.';

  @override
  String get faqLearnMoreQ => 'Can I read more about an item?';

  @override
  String get faqLearnMoreA =>
      'Open any item you\'ve discovered and use Read More for an article about it, or Watch a Video to search for it on YouTube.';

  @override
  String get faqOfflineQ => 'Does it work offline?';

  @override
  String get faqOfflineA =>
      'Yes. The whole game is on your device,  only signing in, syncing to your account and videos need a connection.';

  @override
  String get faqLanguageQ => 'Can I change the language?';

  @override
  String get faqLanguageA =>
      'Not yet. MixRun is in English for now, with more languages planned.';

  @override
  String get updateTitle => 'Update available';

  @override
  String updateBody(String version) {
    return 'MixRun $version is ready. Download it to get the newest items and fixes.';
  }

  @override
  String get updateRequiredTitle => 'Update required';

  @override
  String updateRequiredBody(String version) {
    return 'This version of MixRun is no longer supported. Download $version to keep playing.';
  }

  @override
  String get updateNow => 'Update now';

  @override
  String get updateLater => 'Later';

  @override
  String get updateFailed =>
      'Couldn\'t open the download. Check your connection and try again.';
}
