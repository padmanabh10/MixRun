import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A server-side correction for one element's "learn more" links.
///
/// Either field may be null, meaning "leave the baked-in link alone".
class LinkOverride {
  const LinkOverride({this.url, this.videoUrl});

  /// Replacement article URL, or null to keep the catalog's.
  final String? url;

  /// Replacement video URL, or null to keep the catalog's.
  final String? videoUrl;

  bool get isEmpty => url == null && videoUrl == null;

  static LinkOverride? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final String? url = _clean(raw['u']);
    final String? video = _clean(raw['v']);
    if (url == null && video == null) return null;
    return LinkOverride(url: url, videoUrl: video);
  }

  Map<String, String> toMap() => <String, String>{
        if (url != null) 'u': url!,
        if (videoUrl != null) 'v': videoUrl!,
      };

  static String? _clean(Object? value) {
    if (value is! String) return null;
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

/// Fetches link corrections published in Firestore at `config/links`.
///
/// The catalog baked into the app stays the source of truth; this document
/// holds only the links that have since broken, so a dead URL can be fixed
/// without shipping an update. Shape:
///
/// ```json
/// { "items": { "tajmahal": { "v": "https://youtu.be/NEW" } } }
/// ```
///
/// The last successful fetch is cached in [SharedPreferences] and loaded
/// synchronously at startup, so corrections survive going offline and are
/// applied before the first frame. Everything here degrades to "use the baked-in
/// link": no Firebase, no network, a malformed document or a missing field all
/// leave the app exactly as it ships.
class LinkOverridesRepository {
  LinkOverridesRepository(this._prefs, this._db);

  final SharedPreferences _prefs;

  /// Null when Firebase was never initialized (no `google-services.json`), in
  /// which case only the cache is ever used.
  final FirebaseFirestore? _db;

  static const String _cacheKey = 'mixrun.linkOverrides';
  static const String _fetchedAtKey = 'mixrun.linkOverridesFetchedAt';

  /// How long a cached copy is considered fresh. Links break rarely, so this
  /// avoids a read on every single launch.
  static const Duration cacheTtl = Duration(hours: 12);

  static Future<LinkOverridesRepository> create({FirebaseFirestore? db}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return LinkOverridesRepository(prefs, db);
  }

  /// The corrections from the last successful fetch. Empty on a fresh install.
  Map<String, LinkOverride> loadCached() {
    final String? raw = _prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return const <String, LinkOverride>{};
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return const <String, LinkOverride>{};
      return _parse(decoded);
    } on FormatException {
      // A corrupt cache is not worth crashing over; fall back to the catalog.
      return const <String, LinkOverride>{};
    }
  }

  /// Whether the cache is old enough to be worth refreshing.
  bool get isStale {
    final int? at = _prefs.getInt(_fetchedAtKey);
    if (at == null) return true;
    final DateTime fetched = DateTime.fromMillisecondsSinceEpoch(at);
    return DateTime.now().difference(fetched) > cacheTtl;
  }

  /// Fetches the published corrections and caches them.
  ///
  /// Returns null when there is nothing new to apply — no Firebase, or the
  /// fetch failed — so callers can leave the current values in place.
  Future<Map<String, LinkOverride>?> refresh() async {
    final FirebaseFirestore? db = _db;
    if (db == null) return null;
    try {
      final DocumentSnapshot<Map<String, dynamic>> snap =
          await db.collection('config').doc('links').get();
      final Object? items = snap.data()?['items'];
      if (items is! Map) return null;
      final Map<String, LinkOverride> parsed = _parse(items);
      await _prefs.setString(
        _cacheKey,
        jsonEncode(<String, dynamic>{
          for (final MapEntry<String, LinkOverride> e in parsed.entries)
            e.key: e.value.toMap(),
        }),
      );
      await _prefs.setInt(
        _fetchedAtKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      return parsed;
    } catch (_) {
      // Offline, permission denied, malformed doc: keep whatever we had.
      return null;
    }
  }

  static Map<String, LinkOverride> _parse(Map<Object?, Object?> items) {
    final Map<String, LinkOverride> out = <String, LinkOverride>{};
    for (final MapEntry<Object?, Object?> entry in items.entries) {
      final Object? key = entry.key;
      if (key is! String || key.isEmpty) continue;
      final LinkOverride? override = LinkOverride.fromMap(entry.value);
      if (override != null) out[key] = override;
    }
    return out;
  }
}
