import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../contract/i_auth_repository.dart';

class AuthRepository implements IAuthRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current user
  User? get currentUser => _auth.currentUser;

  /// Sign in with email and password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  /// Register with email and password
  Future<UserCredential> registerWithEmail(
      String email, String password, String displayName) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(displayName.trim());
      await credential.user?.reload();
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  /// Google Sign-In
  Future<UserCredential> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google Sign-In was cancelled.');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  /// Forgot password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Exception _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No account found with this email.');
      case 'wrong-password':
        return Exception('Incorrect password. Please try again.');
      case 'email-already-in-use':
        return Exception('An account already exists with this email.');
      case 'invalid-email':
        return Exception('Please enter a valid email address.');
      case 'weak-password':
        return Exception('Password is too weak. Use at least 6 characters.');
      case 'user-disabled':
        return Exception('This account has been disabled.');
      case 'too-many-requests':
        return Exception('Too many attempts. Please try again later.');
      case 'network-request-failed':
        return Exception('Network error. Please check your connection.');
      case 'invalid-credential':
        return Exception('Invalid credentials. Please check your email and password.');
      default:
        return Exception(e.message ?? 'Authentication failed. Please try again.');
    }
  }
}
