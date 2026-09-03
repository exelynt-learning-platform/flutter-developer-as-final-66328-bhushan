import 'package:firebase_auth/firebase_auth.dart';
import '../entities/auth_user.dart';

abstract class AuthRepository {
  Stream<AuthUser?> get authStateChanges;
  AuthUser? get currentUser;
  Future<AuthUser> signInWithEmail(String email, String password);
  Future<AuthUser> registerWithEmail(
      String email, String password, String displayName);
  /// Returns null when user cancels Google sign-in.
  Future<AuthUser?> signInWithGoogle();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();

  /// Helper to map Firebase User → AuthUser
  static AuthUser fromFirebaseUser(User user) => AuthUser(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoURL: user.photoURL,
      );
}
