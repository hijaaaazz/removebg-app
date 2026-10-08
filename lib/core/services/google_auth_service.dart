import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn;

  GoogleAuthService({String? serverClientId})
      : _googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
          serverClientId: (serverClientId != null && serverClientId.isNotEmpty) ? serverClientId : null,
        );

  Future<String?> signInAndGetIdToken() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        // User dismissed / cancelled dialog
        return null;
      }
      final auth = await account.authentication;
      return auth.idToken;
    } catch (e) {
      debugPrint('[GoogleAuthService] Sign-in error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('[GoogleAuthService] Sign-out error: $e');
    }
  }
}
