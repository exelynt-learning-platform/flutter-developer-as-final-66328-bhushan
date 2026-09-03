import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthRepository({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Stream<AuthUser?> get authStateChanges =>
      _auth.authStateChanges().map((u) =>
          u != null ? AuthRepository.fromFirebaseUser(u) : null);

  @override
  AuthUser? get currentUser {
    final u = _auth.currentUser;
    return u != null ? AuthRepository.fromFirebaseUser(u) : null;
  }

  @override
  Future<AuthUser> signInWithEmail(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);
      return AuthRepository.fromFirebaseUser(cred.user!);
    } on FirebaseAuthException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<AuthUser> registerWithEmail(
      String email, String password, String displayName) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      await cred.user?.updateDisplayName(displayName.trim());
      await cred.user?.reload();
      return AuthRepository.fromFirebaseUser(_auth.currentUser ?? cred.user!);
    } on FirebaseAuthException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<AuthUser?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final cred =
            await _auth.signInWithPopup(GoogleAuthProvider());
        return AuthRepository.fromFirebaseUser(cred.user!);
      }
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user cancelled
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final cred = await _auth.signInWithCredential(credential);
      return AuthRepository.fromFirebaseUser(cred.user!);
    } on FirebaseAuthException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }

  AppFailure _map(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const AppFailure('No account found with this email.');
      case 'wrong-password':
        return const AppFailure('Incorrect password. Please try again.');
      case 'email-already-in-use':
        return const AppFailure('An account already exists with this email.');
      case 'invalid-email':
        return const AppFailure('Please enter a valid email address.');
      case 'weak-password':
        return const AppFailure(
            'Password is too weak. Use at least 6 characters.');
      case 'user-disabled':
        return const AppFailure('This account has been disabled.');
      case 'too-many-requests':
        return const AppFailure('Too many attempts. Please try again later.');
      case 'network-request-failed':
        return const AppFailure(
            'Network error. Please check your connection.');
      case 'invalid-credential':
        return const AppFailure(
            'Invalid credentials. Please check your email and password.');
      default:
        return AppFailure(
            e.message ?? 'Authentication failed. Please try again.');
    }
  }
}
