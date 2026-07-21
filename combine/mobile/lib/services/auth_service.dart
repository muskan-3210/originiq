import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show debugPrint;

/// Wraps Firebase Authentication for ORACLE.
///
/// The app signs every user in anonymously and silently on launch — there
/// is no sign-in screen and no sign-in gate. Per §5 screen 1, a failure
/// here is logged and swallowed so it never blocks entry to Home.
/// Anonymous accounts can later be upgraded (Google/Apple) without losing
/// their uid, so a user's Legacy Wall history survives the upgrade.
///
/// `FirebaseAuth.instance` itself throws synchronously if no Firebase app
/// has been initialized (e.g. `main.dart`'s guarded `Firebase.initializeApp()`
/// failed — no config supplied yet, see the mobile README). A method-level
/// try/catch can't help with that, since the throw happens while just
/// *constructing* this service — so `_auth` is null whenever no app exists,
/// and every member below degrades to a harmless no-op/default instead.
class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth ?? (Firebase.apps.isEmpty ? null : FirebaseAuth.instance) {
    _idTokenSubscription = _auth?.idTokenChanges().listen(_onIdTokenChanged);
  }

  final FirebaseAuth? _auth;
  StreamSubscription<User?>? _idTokenSubscription;

  String? _cachedIdToken;

  /// The signed-in user's uid, or null before any sign-in has completed.
  String? get currentUid => _auth?.currentUser?.uid;

  /// The most recently cached Firebase ID token, if any. Kept fresh by
  /// listening to `idTokenChanges()` (fires on sign-in, sign-out, and
  /// silent token refresh) rather than re-fetched on every read, since
  /// `ApiService` needs a synchronous value to attach to each request.
  String? get currentIdToken => _cachedIdToken;

  bool get isSignedIn => _auth?.currentUser != null;
  bool get isAnonymous => _auth?.currentUser?.isAnonymous ?? true;

  Stream<User?> get authStateChanges =>
      _auth?.authStateChanges() ?? Stream<User?>.value(null);

  /// Emits whenever the ID token changes (sign-in, sign-out, or a silent
  /// refresh), for anything that wants to react rather than poll
  /// [currentIdToken].
  Stream<String?> get idTokenChanges {
    final FirebaseAuth? auth = _auth;
    if (auth == null) return Stream<String?>.value(null);
    return auth.idTokenChanges().asyncMap((User? user) => user?.getIdToken());
  }

  Future<void> _onIdTokenChanged(User? user) async {
    if (user == null) {
      _cachedIdToken = null;
      return;
    }
    try {
      _cachedIdToken = await user.getIdToken();
    } catch (error) {
      // A transient failure to refresh shouldn't crash anything reading
      // currentIdToken — the previous cached value (possibly null) just
      // stays in place until the next successful refresh.
      debugPrint('AuthService: id token refresh failed: $error');
    }
  }

  /// Signs in anonymously if there's no current user yet. Safe to call on
  /// every app launch. Never throws — failures are swallowed so a Firebase
  /// outage can't block entry to the app (per §5 screen 1: "If Firebase
  /// anon auth fails, log silently and proceed anyway").
  Future<void> signInAnonymouslySilently() async {
    final FirebaseAuth? auth = _auth;
    if (auth == null || auth.currentUser != null) return;
    try {
      await auth.signInAnonymously();
    } catch (error) {
      debugPrint('AuthService: silent anonymous sign-in failed: $error');
    }
  }

  /// Links the current anonymous account to a Google identity, preserving
  /// the existing uid (and therefore the user's Legacy Wall history).
  ///
  /// Takes an already-obtained Google [idToken]/[accessToken] rather than
  /// performing the native Google sign-in flow itself — that flow needs the
  /// `google_sign_in` package, which isn't in this scaffold's dependency
  /// list. Add it, run its sign-in flow, then pass the resulting tokens
  /// here.
  Future<UserCredential> linkWithGoogleCredential({
    required String idToken,
    String? accessToken,
  }) {
    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: idToken,
      accessToken: accessToken,
    );
    return _linkOrSignIn(credential);
  }

  /// Links the current anonymous account to an Apple identity, preserving
  /// the existing uid. Same caveat as [linkWithGoogleCredential]: obtain
  /// [idToken]/[rawNonce] via the `sign_in_with_apple` package (not yet in
  /// this scaffold's dependency list) and pass them in here.
  Future<UserCredential> linkWithAppleCredential({
    required String idToken,
    required String rawNonce,
  }) {
    final OAuthProvider provider = OAuthProvider('apple.com');
    final AuthCredential credential = provider.credential(
      idToken: idToken,
      rawNonce: rawNonce,
    );
    return _linkOrSignIn(credential);
  }

  /// Links [credential] to the current anonymous user when possible. If
  /// there's no anonymous user to link (e.g. anonymous sign-in never
  /// completed), falls back to a normal sign-in with the credential so the
  /// user isn't stuck — just without preserving a prior uid.
  ///
  /// Unlike the startup path, this is a user-initiated action (tapping
  /// "sign in to keep this safe"), so — unlike [signInAnonymouslySilently] —
  /// it's correct to throw when Firebase isn't configured: there's a caller
  /// right there to catch it and show an error, instead of a silent no-op
  /// that would look like the button just didn't work.
  Future<UserCredential> _linkOrSignIn(AuthCredential credential) async {
    final FirebaseAuth? auth = _auth;
    if (auth == null) {
      throw StateError(
        'Sign-in is unavailable: Firebase was not initialized.',
      );
    }
    final User? user = auth.currentUser;
    if (user != null && user.isAnonymous) {
      try {
        return await user.linkWithCredential(credential);
      } on FirebaseAuthException catch (error) {
        if (error.code == 'credential-already-in-use' ||
            error.code == 'email-already-in-use') {
          // This identity already has a non-anonymous account elsewhere —
          // sign into that account instead of failing outright.
          return auth.signInWithCredential(credential);
        }
        rethrow;
      }
    }
    return auth.signInWithCredential(credential);
  }

  Future<void> signOut() => _auth?.signOut() ?? Future<void>.value();

  void dispose() {
    unawaited(_idTokenSubscription?.cancel() ?? Future<void>.value());
  }
}
