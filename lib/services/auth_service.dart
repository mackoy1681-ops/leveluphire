import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../config/supabase.dart';

class AuthService {
  static final _client = SupabaseConfig.client;
  static final _googleSignIn = GoogleSignIn();

  // ─── Email / Password ─────────────────────────────────────────────────────

  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // ─── Google Sign-In ───────────────────────────────────────────────────────

  /// NOTE: Requires google-services.json (Android) / GoogleService-Info.plist (iOS)
  static Future<AuthResponse?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) throw Exception('No ID token from Google');

      return await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  // ─── Sign Out ─────────────────────────────────────────────────────────────

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _client.auth.signOut();
  }

  // ─── Current User ─────────────────────────────────────────────────────────

  static User? get currentUser => _client.auth.currentUser;

  static Stream<AuthState> get authStateStream =>
      _client.auth.onAuthStateChange;
}
