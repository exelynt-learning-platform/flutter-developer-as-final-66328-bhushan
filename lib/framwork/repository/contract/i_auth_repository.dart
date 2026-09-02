import 'package:firebase_auth/firebase_auth.dart';

/// Abstract contract for Firebase Auth operations.
/// Concrete: [AuthRepository]. Mocked in tests.
abstract class IAuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;

  Future<UserCredential> signInWithEmail(String email, String password);
  Future<UserCredential> registerWithEmail(
      String email, String password, String displayName);
  Future<UserCredential> signInWithGoogle();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
}
