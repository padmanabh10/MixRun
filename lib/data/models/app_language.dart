import 'dart:ui';

/// A language MixRun can display in, paired with its native and English names
/// for the settings picker.
///
/// The list mirrors `AppLocalizations.supportedLocales`; English is the only
/// fully translated locale today and every other one falls back to English
/// until its `lib/l10n/app_<code>.arb` (UI) and content maps are filled in.
class AppLanguage {
  const AppLanguage(this.code, this.nativeName, this.englishName);

  final String code;
  final String nativeName;
  final String englishName;

  Locale get locale => Locale(code);

  static const List<AppLanguage> all = <AppLanguage>[
    AppLanguage('en', 'English', 'English'),
    // Core Indian languages.
    AppLanguage('hi', 'हिन्दी', 'Hindi'),
    AppLanguage('mr', 'मराठी', 'Marathi'),
    AppLanguage('ta', 'தமிழ்', 'Tamil'),
    AppLanguage('te', 'తెలుగు', 'Telugu'),
    AppLanguage('gu', 'ગુજરાતી', 'Gujarati'),
    // More Indian languages.
    AppLanguage('bn', 'বাংলা', 'Bengali'),
    AppLanguage('kn', 'ಕನ್ನಡ', 'Kannada'),
    AppLanguage('ml', 'മലയാളം', 'Malayalam'),
    AppLanguage('pa', 'ਪੰਜਾਬੀ', 'Punjabi'),
    AppLanguage('or', 'ଓଡ଼ିଆ', 'Odia'),
    // International languages.
    AppLanguage('es', 'Español', 'Spanish'),
    AppLanguage('fr', 'Français', 'French'),
    AppLanguage('de', 'Deutsch', 'German'),
    AppLanguage('ar', 'العربية', 'Arabic'),
    AppLanguage('zh', '中文', 'Chinese'),
  ];

  /// The language for [code], or English if it isn't a supported one.
  static AppLanguage fromCode(String? code) => all.firstWhere(
        (AppLanguage l) => l.code == code,
        orElse: () => all.first,
      );
}
