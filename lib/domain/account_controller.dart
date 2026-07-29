import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../data/auth_service.dart';
import '../data/cloud_progress_repository.dart';
import 'game_controller.dart';

/// Owns the player's account: sign-in/out and syncing progress to the cloud.
///
/// When Firebase isn't configured ([available] is false) this becomes an inert
/// stub so the app still runs fully offline.
class AccountController extends ChangeNotifier {
  AccountController({
    required GameController game,
    required this.available,
    AuthService? auth,
    CloudProgressRepository? cloud,
  })  : _game = game,
        _auth = auth,
        _cloud = cloud {
    if (available && _auth != null) {
      _user = _auth.currentUser;
      _sub = _auth.authState().listen(_onAuthChanged);
      // Mirror durable progress changes to the cloud while signed in.
      _game.onDurableChange = _uploadIfSignedIn;
    }
  }

  final GameController _game;
  final AuthService? _auth;
  final CloudProgressRepository? _cloud;

  /// Whether a backend is configured and auth is usable.
  final bool available;

  StreamSubscription<User?>? _sub;
  User? _user;
  bool _busy = false;
  String? _error;

  User? get user => _user;
  bool get isSignedIn => _user != null;
  bool get busy => _busy;
  String? get error => _error;

  /// A friendly label for the current account (display name or email).
  String get accountLabel =>
      _user?.displayName?.trim().isNotEmpty == true
          ? _user!.displayName!
          : (_user?.email ?? '');

  Future<void> _onAuthChanged(User? user) async {
    final User? previous = _user;
    _user = user;
    notifyListeners();
    if (previous == null && user != null) await _mergeOnSignIn(user.uid);
  }

  /// On sign-in, union the device's progress with the account's so nothing is
  /// lost, adopt the result locally and write it back to the cloud.
  Future<void> _mergeOnSignIn(String uid) async {
    if (_cloud == null) return;
    try {
      final CloudProgress? cloud = await _cloud.fetch(uid);
      _game.mergeCloud(
        discovered: cloud?.discovered ?? const <String>[],
        activeHints: cloud?.activeHints ?? const <String>[],
        adsWatched: cloud?.adsWatched ?? 0,
        hintDayKey: cloud?.hintDayKey,
        hintsUsedToday: cloud?.hintsUsedToday,
      );
      _uploadIfSignedIn();
    } catch (_) {
      // A sync failure must not break gameplay; local progress stands.
    }
  }

  void _uploadIfSignedIn() {
    final User? u = _user;
    if (u == null || _cloud == null) return;
    // Fire and forget; failures are non-fatal.
    _cloud.save(
      u.uid,
      discovered: _game.discovered,
      localeCode: _game.locale.languageCode,
      activeHints: _game.activeHints,
      adsWatched: _game.adsWatched,
      hintDayKey: _game.hintDayKey,
      hintsUsedToday: _game.hintsUsedToday,
    );
  }

  Future<void> signInWithGoogle() => _run(() => _auth!.signInWithGoogle());

  Future<void> signInWithEmail(String email, String password) =>
      _run(() => _auth!.signInWithEmail(email, password));

  Future<void> registerWithEmail(String email, String password) =>
      _run(() => _auth!.registerWithEmail(email, password));

  Future<void> signOut() => _run(() => _auth!.signOut());

  /// Runs an auth [action], tracking busy state and surfacing a friendly error.
  Future<void> _run(Future<void> Function() action) async {
    if (!available || _auth == null) return;
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? e.code;
    } catch (e) {
      _error = e.toString();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  /// Clears the last error (e.g. when the user edits the form).
  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _game.onDurableChange = null;
    super.dispose();
  }
}
