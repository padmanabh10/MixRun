import 'package:cloud_firestore/cloud_firestore.dart';

/// The progress stored for a signed-in account.
class CloudProgress {
  const CloudProgress({
    required this.discovered,
    required this.localeCode,
    this.activeHints = const <String>[],
    this.adsWatched = 0,
    this.hintDayKey,
    this.hintsUsedToday,
  });

  final List<String> discovered;
  final String? localeCode;

  /// Elements with an outstanding hint, not yet discovered.
  final List<String> activeHints;

  /// Lifetime count of rewarded ads watched to completion.
  final int adsWatched;

  /// Day (YYYYMMDD) the daily hint counter refers to, and how many were used.
  final int? hintDayKey;
  final int? hintsUsedToday;
}

/// Reads and writes per-account progress in Cloud Firestore under
/// `users/{uid}`.
class CloudProgressRepository {
  CloudProgressRepository(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('users').doc(uid);

  /// The account's saved progress, or null if it has none yet.
  Future<CloudProgress?> fetch(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> snap = await _doc(uid).get();
    final Map<String, dynamic>? data = snap.data();
    if (data == null) return null;
    final List<String> discovered =
        (data['discovered'] as List<dynamic>? ?? <dynamic>[]).cast<String>();
    final List<String> activeHints =
        (data['activeHints'] as List<dynamic>? ?? <dynamic>[]).cast<String>();
    return CloudProgress(
      discovered: discovered,
      localeCode: data['locale'] as String?,
      activeHints: activeHints,
      adsWatched: (data['adsWatched'] as num?)?.toInt() ?? 0,
      hintDayKey: (data['hintDayKey'] as num?)?.toInt(),
      hintsUsedToday: (data['hintsUsedToday'] as num?)?.toInt(),
    );
  }

  Future<void> save(
    String uid, {
    required List<String> discovered,
    required String localeCode,
    required List<String> activeHints,
    required int adsWatched,
    required int hintDayKey,
    required int hintsUsedToday,
  }) {
    return _doc(uid).set(<String, dynamic>{
      'discovered': discovered,
      'locale': localeCode,
      'activeHints': activeHints,
      'activeHintCount': activeHints.length,
      'adsWatched': adsWatched,
      'hintDayKey': hintDayKey,
      'hintsUsedToday': hintsUsedToday,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
