import 'element_category.dart';

/// An immutable description of a single discoverable element.
///
/// Every element has a stable [id] used in recipes and persistence, a name and
/// description, a transliteration of its original Indian-language name, and
/// links to an article and a video where a curious player can learn more.
class GameElement {
  const GameElement({
    required this.id,
    required this.nameEn,
    required this.transliteration,
    required this.category,
    required this.descriptionEn,
    required this.url,
    this.videoUrl = '',
  });

  final String id;
  final String nameEn;
  final String transliteration;

  /// The Journey stage this element unlocks at.
  final ElementCategory category;
  final String descriptionEn;

  /// Article about this element, opened by "Read More".
  final String url;

  /// A single curated video explaining this element, opened by "Watch a Video".
  ///
  /// Empty when no video has been picked yet, in which case the UI falls back
  /// to a YouTube search for the element's name (see `videoUrlFor`). Populate
  /// it with `tools/fill_video_urls.py`.
  final String videoUrl;

  /// Whether a curated video has been chosen for this element.
  bool get hasVideo => videoUrl.isNotEmpty;

  String get name => nameEn;

  String get description => descriptionEn;
}
