import 'game_data.dart';
import 'models/element_category.dart';

/// Localized game *content*,  element names, descriptions and category labels.
///
/// Unlike UI chrome (handled by the generated `AppLocalizations`), this content
/// is keyed by element id, so it lives in plain locale-keyed maps that can be
/// read without a [BuildContext] (the controller sorts the library by name).
///
/// English is the canonical source and lives in [GameData]/[ElementCategory];
/// any locale absent from the maps below falls back to it. To translate a
/// language, add an entry keyed by its language code, e.g.:
///
/// ```dart
/// static const Map<String, Map<String, String>> _names = {
///   'hi': {'earth': 'पृथ्वी', 'water': 'जल', ...},
/// };
/// ```
abstract final class ContentL10n {
  /// The localized name of element [id] for [localeCode], or English.
  static String name(String id, String localeCode) =>
      _names[localeCode]?[id] ?? GameData.element(id).nameEn;

  /// The localized description of element [id] for [localeCode], or English.
  static String description(String id, String localeCode) =>
      _descriptions[localeCode]?[id] ?? GameData.element(id).descriptionEn;

  /// The localized label for [category] in [localeCode], or English.
  static String category(ElementCategory category, String localeCode) =>
      _categories[localeCode]?[category] ?? category.label;

  // Translations go here, keyed by language code. Empty today (English only).
  static const Map<String, Map<String, String>> _names =
      <String, Map<String, String>>{};
  static const Map<String, Map<String, String>> _descriptions =
      <String, Map<String, String>>{};
  static const Map<String, Map<ElementCategory, String>> _categories =
      <String, Map<ElementCategory, String>>{};
}
