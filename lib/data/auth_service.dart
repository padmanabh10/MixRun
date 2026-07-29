import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Thin wrapper over [FirebaseAuth] and Google Sign-In.
///
/// Only constructed when Firebase has been initialized (see `main.dart`); the
/// rest of the app talks to it through `AccountController`.
class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;

  Stream<User?> authState() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signInWithEmail(String email, String password) =>
      _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

  Future<void> registerWithEmail(String email, String password) =>
      _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

  /// Runs the Google sign-in flow and authenticates with Firebase. Returns
  /// `false` if the user dismissed the Google account chooser.
  Future<bool> signInWithGoogle() async {
    final GoogleSignInAccount? account = await GoogleSignIn().signIn();
    if (account == null) return false;
    final GoogleSignInAuthentication auth = await account.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
    await _auth.signInWithCredential(credential);
    return true;
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
}
