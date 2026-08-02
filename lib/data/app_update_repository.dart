import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A release published in Firestore at `config/app_version`.
///
/// Versions are compared by *build number* (`versionCode` on Android, the `+N`
/// suffix in `pubspec.yaml`), never by the human-facing name: string comparison
/// would put `1.10.0` before `1.9.0`.
@immutable
class AppRelease {
  const AppRelease({
    required this.versionCode,
    required this.versionName,
    required this.minVersionCode,
    required this.downloadUrl,
    this.notes,
  });

  /// Build number of the newest published build.
  final int versionCode;

  /// Human-facing version of that build, e.g. `1.1.0`.
  final String versionName;

  /// Oldest build still supported. Anything below it is forced to update.
  final int minVersionCode;

  /// Where the APK lives. Opened in the browser, which hands the file to
  /// Android's download manager.
  final String downloadUrl;

  /// Optional "what's new" blurb shown in the prompt.
  final String? notes;

  static AppRelease? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final int? code = _int(raw['versionCode']);
    final String? url = _string(raw['downloadUrl']);
    if (code == null || url == null) return null;
    return AppRelease(
      versionCode: code,
      versionName: _string(raw['versionName']) ?? '',
      // A document that omits it forces nothing; only builds newer than the
      // running one are ever offered.
      minVersionCode: _int(raw['minVersionCode']) ?? 0,
      downloadUrl: url,
      notes: _string(raw['notes']),
    );
  }

  Map<String, Object> toMap() => <String, Object>{
        'versionCode': versionCode,
        'versionName': versionName,
        'minVersionCode': minVersionCode,
        'downloadUrl': downloadUrl,
        if (notes != null) 'notes': notes!,
      };

  static int? _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static String? _string(Object? value) {
    if (value is! String) return null;
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

/// What the app should do about the release it just learned about.
enum UpdateUrgency {
  /// The running build is current (or newer). Say nothing.
  none,

  /// A newer build exists. Prompt, but let the player dismiss and keep playing.
  optional,

  /// The running build is below `minVersionCode`. Block until they update.
  required,
}

/// The outcome of an update check.
@immutable
class UpdateStatus {
  const UpdateStatus(this.urgency, [this.release]);

  static const UpdateStatus upToDate = UpdateStatus(UpdateUrgency.none);

  final UpdateUrgency urgency;

  /// The published release. Null when [urgency] is [UpdateUrgency.none].
  final AppRelease? release;

  bool get shouldPrompt => urgency != UpdateUrgency.none;
  bool get isRequired => urgency == UpdateUrgency.required;
}

/// Checks Firestore for a newer side-loaded build of the app.
///
/// MixRun is distributed as an APK rather than through a store, so nothing tells
/// a player a new version exists. A single world-readable document does:
///
/// ```json
/// {
///   "android": {
///     "versionCode": 7,
///     "versionName": "1.1.0",
///     "minVersionCode": 5,
///     "downloadUrl": "https://.../mixrun-1.1.0.apk",
///     "notes": "New Heroes level, faster canvas."
///   }
/// }
/// ```
///
/// Keying by platform leaves room for an iOS/store entry later without a schema
/// change. The last successful fetch is cached in [SharedPreferences] so a
/// *required* update still blocks on the next launch even when the check itself
/// is skipped (see [cacheTtl]) or fails.
///
/// Everything degrades to "no prompt": no Firebase, no network, a malformed
/// document or a missing field all leave the app exactly as it runs today.
class AppUpdateRepository {
  AppUpdateRepository({
    required SharedPreferences prefs,
    required int currentVersionCode,
    FirebaseFirestore? db,
    TargetPlatform? platform,
  })  : _prefs = prefs,
        _currentVersionCode = currentVersionCode,
        _db = db,
        _platform = platform ?? defaultTargetPlatform;

  final SharedPreferences _prefs;

  /// Build number of the running app, from `package_info_plus`.
  final int _currentVersionCode;

  /// Null when Firebase was never initialized (no `google-services.json`), in
  /// which case only the cached release is ever considered.
  final FirebaseFirestore? _db;

  final TargetPlatform _platform;

  static const String _cacheKey = 'mixrun.latestRelease';
  static const String _fetchedAtKey = 'mixrun.latestReleaseFetchedAt';
  static const String _snoozedCodeKey = 'mixrun.updateSnoozedCode';
  static const String _snoozedAtKey = 'mixrun.updateSnoozedAt';

  /// How long a fetched release is considered fresh. Releases are rare, so this
  /// keeps launches from costing a Firestore read each.
  static const Duration cacheTtl = Duration(hours: 6);

  /// How long "Later" silences an *optional* prompt for one build. A required
  /// update can never be snoozed.
  static const Duration snoozeFor = Duration(days: 3);

  /// Builds a repository for the running app, reading its build number from the
  /// platform.
  static Future<AppUpdateRepository> create({FirebaseFirestore? db}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final PackageInfo info = await PackageInfo.fromPlatform();
    return AppUpdateRepository(
      prefs: prefs,
      // A non-numeric build number means we cannot compare anything; 0 keeps
      // the app quiet unless the document itself is newer, which it always is.
      currentVersionCode: int.tryParse(info.buildNumber) ?? 0,
      db: db,
    );
  }

  /// Whether [check] has run since launch.
  ///
  /// The prompt is a launch-time courtesy, so the caller uses this to avoid
  /// re-running the check every time the player walks back to the home screen.
  bool get checkedThisSession => _checked;
  bool _checked = false;

  /// Refreshes the published release when stale, then compares it against the
  /// running build.
  ///
  /// Safe to call on every launch: it never throws, and does at most one
  /// Firestore read per [cacheTtl].
  Future<UpdateStatus> check() async {
    _checked = true;
    AppRelease? release;
    if (_isStale) {
      release = await _fetch();
    }
    release ??= _loadCached();
    if (release == null) return UpdateStatus.upToDate;

    if (_currentVersionCode < release.minVersionCode) {
      return UpdateStatus(UpdateUrgency.required, release);
    }
    if (_currentVersionCode >= release.versionCode) return UpdateStatus.upToDate;
    if (_isSnoozed(release.versionCode)) return UpdateStatus.upToDate;
    return UpdateStatus(UpdateUrgency.optional, release);
  }

  /// Silences the prompt for [release] for [snoozeFor]. A newer build published
  /// in the meantime prompts again immediately.
  Future<void> snooze(AppRelease release) async {
    await _prefs.setInt(_snoozedCodeKey, release.versionCode);
    await _prefs.setInt(_snoozedAtKey, DateTime.now().millisecondsSinceEpoch);
  }

  bool get _isStale {
    final int? at = _prefs.getInt(_fetchedAtKey);
    if (at == null) return true;
    final DateTime fetched = DateTime.fromMillisecondsSinceEpoch(at);
    return DateTime.now().difference(fetched) > cacheTtl;
  }

  bool _isSnoozed(int versionCode) {
    if (_prefs.getInt(_snoozedCodeKey) != versionCode) return false;
    final int? at = _prefs.getInt(_snoozedAtKey);
    if (at == null) return false;
    final DateTime snoozed = DateTime.fromMillisecondsSinceEpoch(at);
    return DateTime.now().difference(snoozed) < snoozeFor;
  }

  /// The release from the last successful fetch, if any.
  AppRelease? _loadCached() {
    final String? raw = _prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return AppRelease.fromMap(jsonDecode(raw));
    } on FormatException {
      // A corrupt cache is not worth crashing over; behave like a fresh install.
      return null;
    }
  }

  /// Reads `config/app_version` and caches the entry for this platform.
  Future<AppRelease?> _fetch() async {
    final FirebaseFirestore? db = _db;
    if (db == null) return null;
    try {
      final DocumentSnapshot<Map<String, dynamic>> snap =
          await db.collection('config').doc('app_version').get();
      final AppRelease? release =
          AppRelease.fromMap(snap.data()?[_platformKey]);
      // Record the attempt either way, so a document without an entry for this
      // platform doesn't re-read on every launch.
      await _prefs.setInt(
        _fetchedAtKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      if (release == null) {
        await _prefs.remove(_cacheKey);
        return null;
      }
      await _prefs.setString(_cacheKey, jsonEncode(release.toMap()));
      return release;
    } catch (_) {
      // Offline, permission denied, malformed doc: fall back to the cache.
      return null;
    }
  }

  /// Which entry of the document applies. MixRun ships Android only, so every
  /// other platform reads the same entry rather than going unchecked; publish an
  /// `ios` entry and it is picked up without a code change.
  String get _platformKey =>
      _platform == TargetPlatform.iOS ? 'ios' : 'android';
}
