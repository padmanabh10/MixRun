import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_or.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bn'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('gu'),
    Locale('hi'),
    Locale('kn'),
    Locale('ml'),
    Locale('mr'),
    Locale('or'),
    Locale('pa'),
    Locale('ta'),
    Locale('te'),
    Locale('zh'),
  ];

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @encyclopedia.
  ///
  /// In en, this message translates to:
  /// **'Encyclopedia'**
  String get encyclopedia;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Mix the elements of India'**
  String get tagline;

  /// No description provided for @discovered.
  ///
  /// In en, this message translates to:
  /// **'Discovered'**
  String get discovered;

  /// No description provided for @searchElements.
  ///
  /// In en, this message translates to:
  /// **'Search elements'**
  String get searchElements;

  /// No description provided for @hint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hint;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @revert.
  ///
  /// In en, this message translates to:
  /// **'Revert'**
  String get revert;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get learnMore;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read More'**
  String get readMore;

  /// No description provided for @watchVideo.
  ///
  /// In en, this message translates to:
  /// **'Watch a Video'**
  String get watchVideo;

  /// No description provided for @newDiscovery.
  ///
  /// In en, this message translates to:
  /// **'New Discovery'**
  String get newDiscovery;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @dragHint.
  ///
  /// In en, this message translates to:
  /// **'Drag two elements together'**
  String get dragHint;

  /// No description provided for @tapToAdd.
  ///
  /// In en, this message translates to:
  /// **'or tap an element below to add it'**
  String get tapToAdd;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get sound;

  /// No description provided for @music.
  ///
  /// In en, this message translates to:
  /// **'Background music'**
  String get music;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset progress'**
  String get reset;

  /// No description provided for @resetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes, reset everything'**
  String get resetConfirm;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Take me there'**
  String get gotIt;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About MixRun'**
  String get about;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'A learning game that blends the elements of Indian nature, culture and science. Every discovery links to an article or video to learn more.'**
  String get aboutBody;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @madeFrom.
  ///
  /// In en, this message translates to:
  /// **'Made from'**
  String get madeFrom;

  /// No description provided for @activeHintTitle.
  ///
  /// In en, this message translates to:
  /// **'Active Hint'**
  String get activeHintTitle;

  /// No description provided for @discoverNext.
  ///
  /// In en, this message translates to:
  /// **'Discover this next'**
  String get discoverNext;

  /// No description provided for @figureOutRecipe.
  ///
  /// In en, this message translates to:
  /// **'Combine elements on the canvas to discover it'**
  String get figureOutRecipe;

  /// No description provided for @getHint.
  ///
  /// In en, this message translates to:
  /// **'Get a hint'**
  String get getHint;

  /// No description provided for @newHint.
  ///
  /// In en, this message translates to:
  /// **'New hint'**
  String get newHint;

  /// No description provided for @noHint.
  ///
  /// In en, this message translates to:
  /// **'You have discovered everything reachable. Amazing!'**
  String get noHint;

  /// No description provided for @watchAdForHint.
  ///
  /// In en, this message translates to:
  /// **'Watch a short video to the end to unlock a hint'**
  String get watchAdForHint;

  /// No description provided for @adNotReady.
  ///
  /// In en, this message translates to:
  /// **'The video isn\'t ready yet. Please try again in a moment.'**
  String get adNotReady;

  /// No description provided for @loadingAd.
  ///
  /// In en, this message translates to:
  /// **'Loading video…'**
  String get loadingAd;

  /// No description provided for @activeHintsTitle.
  ///
  /// In en, this message translates to:
  /// **'Active hints'**
  String get activeHintsTitle;

  /// No description provided for @hintsLeftToday.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No hints left today} one{1 hint left today} other{{count} hints left today}}'**
  String hintsLeftToday(int count);

  /// No description provided for @dailyHintLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used all your hints for today. Come back tomorrow!'**
  String get dailyHintLimitReached;

  /// No description provided for @maxHintsReached.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the maximum number of active hints. Discover some before getting more.'**
  String get maxHintsReached;

  /// No description provided for @alphabetical.
  ///
  /// In en, this message translates to:
  /// **'Alphabetical'**
  String get alphabetical;

  /// No description provided for @recentlyDiscovered.
  ///
  /// In en, this message translates to:
  /// **'Recently discovered'**
  String get recentlyDiscovered;

  /// No description provided for @makes.
  ///
  /// In en, this message translates to:
  /// **'Makes'**
  String get makes;

  /// No description provided for @combinations.
  ///
  /// In en, this message translates to:
  /// **'Combinations'**
  String get combinations;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @addToWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Add to workspace'**
  String get addToWorkspace;

  /// No description provided for @discoveredStatus.
  ///
  /// In en, this message translates to:
  /// **'Discovered'**
  String get discoveredStatus;

  /// No description provided for @notDiscovered.
  ///
  /// In en, this message translates to:
  /// **'Not yet discovered'**
  String get notDiscovered;

  /// No description provided for @noCombinations.
  ///
  /// In en, this message translates to:
  /// **'No combinations yet'**
  String get noCombinations;

  /// No description provided for @undiscoveredCombosLine.
  ///
  /// In en, this message translates to:
  /// **'{withAnd, select, true{and } other{}}{count, plural, one{{count} undiscovered combination…} other{{count} undiscovered combinations…}}'**
  String undiscoveredCombosLine(int count, String withAnd);

  /// No description provided for @andMoreUndiscovered.
  ///
  /// In en, this message translates to:
  /// **'and {count} undiscovered…'**
  String andMoreUndiscovered(int count);

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @discoveredItems.
  ///
  /// In en, this message translates to:
  /// **'Discovered items'**
  String get discoveredItems;

  /// No description provided for @basicItems.
  ///
  /// In en, this message translates to:
  /// **'Basic items'**
  String get basicItems;

  /// No description provided for @finalItems.
  ///
  /// In en, this message translates to:
  /// **'Final items'**
  String get finalItems;

  /// No description provided for @combosFound.
  ///
  /// In en, this message translates to:
  /// **'Combinations found'**
  String get combosFound;

  /// No description provided for @categoryCount.
  ///
  /// In en, this message translates to:
  /// **'categories'**
  String get categoryCount;

  /// No description provided for @depletedItems.
  ///
  /// In en, this message translates to:
  /// **'Depleted items'**
  String get depletedItems;

  /// No description provided for @depleted.
  ///
  /// In en, this message translates to:
  /// **'Depleted'**
  String get depleted;

  /// No description provided for @finalLabel.
  ///
  /// In en, this message translates to:
  /// **'Final'**
  String get finalLabel;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orDivider;

  /// No description provided for @toggleToRegister.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get toggleToRegister;

  /// No description provided for @toggleToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get toggleToSignIn;

  /// No description provided for @signInBlurb.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save your progress to your account'**
  String get signInBlurb;

  /// No description provided for @accountUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Sign-in isn\'t available yet,  the backend isn\'t configured.'**
  String get accountUnavailable;

  /// No description provided for @exitGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit game?'**
  String get exitGameTitle;

  /// No description provided for @exitGameBody.
  ///
  /// In en, this message translates to:
  /// **'Do you want to exit the game?'**
  String get exitGameBody;

  /// No description provided for @exitGame.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exitGame;

  /// No description provided for @stay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// No description provided for @journey.
  ///
  /// In en, this message translates to:
  /// **'Journey'**
  String get journey;

  /// No description provided for @yourJourney.
  ///
  /// In en, this message translates to:
  /// **'Your Journey'**
  String get yourJourney;

  /// No description provided for @journeyCompletion.
  ///
  /// In en, this message translates to:
  /// **'Completion'**
  String get journeyCompletion;

  /// No description provided for @journeyDiscoveries.
  ///
  /// In en, this message translates to:
  /// **'Discoveries'**
  String get journeyDiscoveries;

  /// No description provided for @levelComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get levelComplete;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @introSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get introSkip;

  /// No description provided for @introNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get introNext;

  /// No description provided for @introStart.
  ///
  /// In en, this message translates to:
  /// **'Start playing'**
  String get introStart;

  /// No description provided for @introWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to MixRun'**
  String get introWelcomeTitle;

  /// No description provided for @introWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Start with four elements and combine them, two at a time, to uncover {count} things,  monuments, festivals, food, art and the people who shaped India.'**
  String introWelcomeBody(int count);

  /// No description provided for @introCombineTitle.
  ///
  /// In en, this message translates to:
  /// **'Drop one item on another'**
  String get introCombineTitle;

  /// No description provided for @introCombineBody.
  ///
  /// In en, this message translates to:
  /// **'Drag an item out of the library, then drop it onto another item on the canvas. If the pair makes something, you\'ve made a discovery.'**
  String get introCombineBody;

  /// No description provided for @introCombineHint.
  ///
  /// In en, this message translates to:
  /// **'Nothing breaks if a pair doesn\'t work,  the items just stay put, so try anything.'**
  String get introCombineHint;

  /// No description provided for @introLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Your library'**
  String get introLibraryTitle;

  /// No description provided for @introLibraryBody.
  ///
  /// In en, this message translates to:
  /// **'Everything you discover joins the list on the right. Search it when it gets long, and drag from it onto the canvas.'**
  String get introLibraryBody;

  /// No description provided for @introLibraryClear.
  ///
  /// In en, this message translates to:
  /// **'Clear tidies the canvas. Undo puts it straight back.'**
  String get introLibraryClear;

  /// No description provided for @introSectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Getting around'**
  String get introSectionsTitle;

  /// No description provided for @introSectionsBody.
  ///
  /// In en, this message translates to:
  /// **'The bar along the bottom takes you everywhere.'**
  String get introSectionsBody;

  /// No description provided for @introEncyclopediaBody.
  ///
  /// In en, this message translates to:
  /// **'Every item you\'ve found, filterable by level, with a page for each one.'**
  String get introEncyclopediaBody;

  /// No description provided for @introJourneyBody.
  ///
  /// In en, this message translates to:
  /// **'Your path through the game. Appears once you unlock the second stop.'**
  String get introJourneyBody;

  /// No description provided for @introStatsBody.
  ///
  /// In en, this message translates to:
  /// **'Discoveries, combinations, and how far along you are.'**
  String get introStatsBody;

  /// No description provided for @introSettingsBody.
  ///
  /// In en, this message translates to:
  /// **'Sound, music, your account,  and the FAQs.'**
  String get introSettingsBody;

  /// No description provided for @introHintBody.
  ///
  /// In en, this message translates to:
  /// **'Stuck? A hint nudges you toward something you haven\'t found.'**
  String get introHintBody;

  /// No description provided for @introReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set'**
  String get introReadyTitle;

  /// No description provided for @introReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Progress saves by itself after every discovery. You can replay this walkthrough any time from Settings › Help.'**
  String get introReadyBody;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @howToPlay.
  ///
  /// In en, this message translates to:
  /// **'How to play'**
  String get howToPlay;

  /// No description provided for @howToPlayBlurb.
  ///
  /// In en, this message translates to:
  /// **'Replay the walkthrough'**
  String get howToPlayBlurb;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'FAQs'**
  String get faq;

  /// No description provided for @faqBlurb.
  ///
  /// In en, this message translates to:
  /// **'How the game works, answered'**
  String get faqBlurb;

  /// No description provided for @faqSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everything about playing MixRun'**
  String get faqSubtitle;

  /// No description provided for @faqSectionBasics.
  ///
  /// In en, this message translates to:
  /// **'The basics'**
  String get faqSectionBasics;

  /// No description provided for @faqSectionPlaying.
  ///
  /// In en, this message translates to:
  /// **'Playing'**
  String get faqSectionPlaying;

  /// No description provided for @faqSectionJourney.
  ///
  /// In en, this message translates to:
  /// **'The Journey'**
  String get faqSectionJourney;

  /// No description provided for @faqSectionProgress.
  ///
  /// In en, this message translates to:
  /// **'Your progress'**
  String get faqSectionProgress;

  /// No description provided for @faqWhatIsQ.
  ///
  /// In en, this message translates to:
  /// **'What is MixRun?'**
  String get faqWhatIsQ;

  /// No description provided for @faqWhatIsA.
  ///
  /// In en, this message translates to:
  /// **'A discovery game. You start with a handful of raw elements and combine them two at a time to create new things,  each one a small piece of Indian heritage, from monuments and festivals to food, art and the people who shaped it.'**
  String get faqWhatIsA;

  /// No description provided for @faqStartQ.
  ///
  /// In en, this message translates to:
  /// **'What do I start with?'**
  String get faqStartQ;

  /// No description provided for @faqStartA.
  ///
  /// In en, this message translates to:
  /// **'Four elements: Earth, Water, Fire and Air. Everything else in the game is built from them.'**
  String get faqStartA;

  /// No description provided for @faqHowCombineQ.
  ///
  /// In en, this message translates to:
  /// **'How do I combine items?'**
  String get faqHowCombineQ;

  /// No description provided for @faqHowCombineA.
  ///
  /// In en, this message translates to:
  /// **'Drag an item from the library onto the canvas, then drop it on top of another. If the pair makes something, the new item appears and is added to your collection. If it doesn\'t, the items simply stay put,  nothing is lost, so experiment freely.'**
  String get faqHowCombineA;

  /// No description provided for @faqHowManyQ.
  ///
  /// In en, this message translates to:
  /// **'How many items are there?'**
  String get faqHowManyQ;

  /// No description provided for @faqHowManyA.
  ///
  /// In en, this message translates to:
  /// **'{count} in total, spread across {levels} stops on the Journey.'**
  String faqHowManyA(int count, int levels);

  /// No description provided for @faqPairQ.
  ///
  /// In en, this message translates to:
  /// **'Can a pair make more than one thing?'**
  String get faqPairQ;

  /// No description provided for @faqPairA.
  ///
  /// In en, this message translates to:
  /// **'No. Each pair has a single result, so re-mixing two items you have already combined just makes the same thing again.'**
  String get faqPairA;

  /// No description provided for @faqCantMakeQ.
  ///
  /// In en, this message translates to:
  /// **'Why won\'t two items combine?'**
  String get faqCantMakeQ;

  /// No description provided for @faqCantMakeA.
  ///
  /// In en, this message translates to:
  /// **'Either that pair has no recipe, or the item it would make belongs to a Journey level you haven\'t unlocked yet. Keep exploring the level you\'re on and it will open up.'**
  String get faqCantMakeA;

  /// No description provided for @faqBasicQ.
  ///
  /// In en, this message translates to:
  /// **'What are \"basic\" items?'**
  String get faqBasicQ;

  /// No description provided for @faqBasicA.
  ///
  /// In en, this message translates to:
  /// **'The classical building blocks,  the four starters plus raw forces like Heat, Life and Motion that come straight from them. You can filter the Encyclopedia down to just these.'**
  String get faqBasicA;

  /// No description provided for @faqDepletedQ.
  ///
  /// In en, this message translates to:
  /// **'What does \"Depleted\" mean?'**
  String get faqDepletedQ;

  /// No description provided for @faqDepletedA.
  ///
  /// In en, this message translates to:
  /// **'You have already found every combination that uses that item. It stays in your library, but it has nothing new left to give.'**
  String get faqDepletedA;

  /// No description provided for @faqFinalQ.
  ///
  /// In en, this message translates to:
  /// **'What does \"Final\" mean?'**
  String get faqFinalQ;

  /// No description provided for @faqFinalA.
  ///
  /// In en, this message translates to:
  /// **'That item is never used as an ingredient in any recipe. It sits at the end of a chain,  a destination rather than a stepping stone.'**
  String get faqFinalA;

  /// No description provided for @faqJourneyQ.
  ///
  /// In en, this message translates to:
  /// **'What is the Journey?'**
  String get faqJourneyQ;

  /// No description provided for @faqJourneyA.
  ///
  /// In en, this message translates to:
  /// **'The path through the game. It opens with the Base Level and continues through five themed stops: States & UTs, History & Sites, Culture & Cuisine, Dance & Local Art, and Heroes & Kings.'**
  String get faqJourneyA;

  /// No description provided for @faqUnlockQ.
  ///
  /// In en, this message translates to:
  /// **'How do I unlock the next level?'**
  String get faqUnlockQ;

  /// No description provided for @faqUnlockA.
  ///
  /// In en, this message translates to:
  /// **'Discover {percent}% of the level you are on. The Journey map shows how far along each stop you are.'**
  String faqUnlockA(int percent);

  /// No description provided for @faqHintsQ.
  ///
  /// In en, this message translates to:
  /// **'How do hints work?'**
  String get faqHintsQ;

  /// No description provided for @faqHintsA.
  ///
  /// In en, this message translates to:
  /// **'A hint points you toward an item you haven\'t found yet. You can unlock {daily} a day by watching a short video, and hold up to {active} unsolved hints at once,  each one clears when you discover the item it points to.'**
  String faqHintsA(int daily, int active);

  /// No description provided for @faqSaveQ.
  ///
  /// In en, this message translates to:
  /// **'Is my progress saved?'**
  String get faqSaveQ;

  /// No description provided for @faqSaveA.
  ///
  /// In en, this message translates to:
  /// **'Yes,  automatically, on this device, after every discovery. Sign in from Settings to back it up to your account and carry it to another device.'**
  String get faqSaveA;

  /// No description provided for @faqResetQ.
  ///
  /// In en, this message translates to:
  /// **'Can I start over?'**
  String get faqResetQ;

  /// No description provided for @faqResetA.
  ///
  /// In en, this message translates to:
  /// **'Yes. Settings › Progress › Reset clears every discovery and returns you to the four starting elements. It cannot be undone.'**
  String get faqResetA;

  /// No description provided for @faqLearnMoreQ.
  ///
  /// In en, this message translates to:
  /// **'Can I read more about an item?'**
  String get faqLearnMoreQ;

  /// No description provided for @faqLearnMoreA.
  ///
  /// In en, this message translates to:
  /// **'Open any item you\'ve discovered and use Read More for an article about it, or Watch a Video to search for it on YouTube.'**
  String get faqLearnMoreA;

  /// No description provided for @faqOfflineQ.
  ///
  /// In en, this message translates to:
  /// **'Does it work offline?'**
  String get faqOfflineQ;

  /// No description provided for @faqOfflineA.
  ///
  /// In en, this message translates to:
  /// **'Yes. The whole game is on your device,  only signing in, syncing to your account and videos need a connection.'**
  String get faqOfflineA;

  /// No description provided for @faqLanguageQ.
  ///
  /// In en, this message translates to:
  /// **'Can I change the language?'**
  String get faqLanguageQ;

  /// No description provided for @faqLanguageA.
  ///
  /// In en, this message translates to:
  /// **'Not yet. MixRun is in English for now, with more languages planned.'**
  String get faqLanguageA;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'bn',
    'de',
    'en',
    'es',
    'fr',
    'gu',
    'hi',
    'kn',
    'ml',
    'mr',
    'or',
    'pa',
    'ta',
    'te',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'ml':
      return AppLocalizationsMl();
    case 'mr':
      return AppLocalizationsMr();
    case 'or':
      return AppLocalizationsOr();
    case 'pa':
      return AppLocalizationsPa();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
