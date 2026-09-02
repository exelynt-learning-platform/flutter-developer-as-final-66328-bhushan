import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:employee_management_application_flutter_assessment/framework/repository/repository/auth_repository.dart';

import 'auth_repository_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  GoogleSignIn,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
  UserCredential,
  User,
  AuthRepository,
])
void main() {
  late MockFirebaseAuth mockAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late AuthRepository repository;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    repository = AuthRepository(
      firebaseAuth: mockAuth,
      googleSignIn: mockGoogleSignIn,
    );
  });

  // ── signInWithEmail ───────────────────────────────────────────────────────

  test('signInWithEmail should call firebase signIn method', () async {
    final mockCredential = MockUserCredential();
    when(mockCredential.user).thenReturn(null);

    when(mockAuth.signInWithEmailAndPassword(
      email: anyNamed('email'),
      password: anyNamed('password'),
    )).thenAnswer((_) async => mockCredential);

    final result = await repository.signInWithEmail('test@gmail.com', 'pass123');

    expect(result, mockCredential);
  });

  test('signInWithEmail should trim spaces from email', () async {
    final mockCredential = MockUserCredential();
    when(mockCredential.user).thenReturn(null);

    when(mockAuth.signInWithEmailAndPassword(
      email: anyNamed('email'),
      password: anyNamed('password'),
    )).thenAnswer((_) async => mockCredential);

    await repository.signInWithEmail('  test@gmail.com  ', 'pass123');

    // should be called with trimmed email
    verify(mockAuth.signInWithEmailAndPassword(
      email: 'test@gmail.com',
      password: 'pass123',
    )).called(1);
  });

  test('signInWithEmail should throw friendly message on user-not-found', () async {
    when(mockAuth.signInWithEmailAndPassword(
      email: anyNamed('email'),
      password: anyNamed('password'),
    )).thenThrow(
      FirebaseAuthException(code: 'user-not-found'),
    );

    expect(
      () => repository.signInWithEmail('x@x.com', 'pass'),
      throwsA(predicate((e) =>
          e.toString().contains('No account found with this email'))),
    );
  });

  test('signInWithEmail should throw friendly message on wrong-password', () async {
    when(mockAuth.signInWithEmailAndPassword(
      email: anyNamed('email'),
      password: anyNamed('password'),
    )).thenThrow(
      FirebaseAuthException(code: 'wrong-password'),
    );

    expect(
      () => repository.signInWithEmail('x@x.com', 'wrong'),
      throwsA(predicate((e) =>
          e.toString().contains('Incorrect password'))),
    );
  });

  // ── registerWithEmail ─────────────────────────────────────────────────────

  test('registerWithEmail should call createUserWithEmailAndPassword', () async {
    final mockCredential = MockUserCredential();
    final mockUser = MockUser();

    when(mockUser.updateDisplayName(any)).thenAnswer((_) async {});
    when(mockUser.reload()).thenAnswer((_) async {});
    when(mockCredential.user).thenReturn(mockUser);

    when(mockAuth.createUserWithEmailAndPassword(
      email: anyNamed('email'),
      password: anyNamed('password'),
    )).thenAnswer((_) async => mockCredential);

    final result = await repository.registerWithEmail(
        'test@gmail.com', 'pass123', 'John Doe');

    expect(result, mockCredential);
    verify(mockAuth.createUserWithEmailAndPassword(
      email: 'test@gmail.com',
      password: 'pass123',
    )).called(1);
  });

  test('registerWithEmail should set display name on user', () async {
    final mockCredential = MockUserCredential();
    final mockUser = MockUser();

    when(mockUser.updateDisplayName(any)).thenAnswer((_) async {});
    when(mockUser.reload()).thenAnswer((_) async {});
    when(mockCredential.user).thenReturn(mockUser);

    when(mockAuth.createUserWithEmailAndPassword(
      email: anyNamed('email'),
      password: anyNamed('password'),
    )).thenAnswer((_) async => mockCredential);

    await repository.registerWithEmail('test@gmail.com', 'pass123', 'John Doe');

    verify(mockUser.updateDisplayName('John Doe')).called(1);
  });

  test('registerWithEmail should throw on email-already-in-use', () async {
    when(mockAuth.createUserWithEmailAndPassword(
      email: anyNamed('email'),
      password: anyNamed('password'),
    )).thenThrow(
      FirebaseAuthException(code: 'email-already-in-use'),
    );

    expect(
      () => repository.registerWithEmail('x@x.com', 'pass', 'Name'),
      throwsA(predicate((e) =>
          e.toString().contains('already exists with this email'))),
    );
  });

  test('registerWithEmail should throw on weak-password', () async {
    when(mockAuth.createUserWithEmailAndPassword(
      email: anyNamed('email'),
      password: anyNamed('password'),
    )).thenThrow(
      FirebaseAuthException(code: 'weak-password'),
    );

    expect(
      () => repository.registerWithEmail('x@x.com', '123', 'Name'),
      throwsA(predicate((e) =>
          e.toString().contains('Password is too weak'))),
    );
  });

  // ── signInWithGoogle ──────────────────────────────────────────────────────

  test('signInWithGoogle should return credential on success', () async {
    final mockGoogleAccount = MockGoogleSignInAccount();
    final mockGoogleAuth = MockGoogleSignInAuthentication();
    final mockCredential = MockUserCredential();

    when(mockGoogleAccount.authentication)
        .thenAnswer((_) async => mockGoogleAuth);
    when(mockGoogleAuth.accessToken).thenReturn('access_token');
    when(mockGoogleAuth.idToken).thenReturn('id_token');
    when(mockGoogleSignIn.signIn())
        .thenAnswer((_) async => mockGoogleAccount);
    when(mockAuth.signInWithCredential(any))
        .thenAnswer((_) async => mockCredential);

    final result = await repository.signInWithGoogle();

    expect(result, mockCredential);
    verify(mockAuth.signInWithCredential(any)).called(1);
  });

  test('signInWithGoogle should return null when user cancels', () async {
    // user cancels = signIn() returns null → no throw, just null returned
    when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

    final result = await repository.signInWithGoogle();

    expect(result, isNull);
    verifyNever(mockAuth.signInWithCredential(any));
  });

  // ── signOut ───────────────────────────────────────────────────────────────

  test('signOut should call both firebase and google signOut', () async {
    when(mockAuth.signOut()).thenAnswer((_) async {});
    when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);

    await repository.signOut();

    verify(mockAuth.signOut()).called(1);
    verify(mockGoogleSignIn.signOut()).called(1);
  });

  // ── sendPasswordResetEmail ────────────────────────────────────────────────

  test('sendPasswordResetEmail should call firebase method', () async {
    when(mockAuth.sendPasswordResetEmail(email: anyNamed('email')))
        .thenAnswer((_) async {});

    await repository.sendPasswordResetEmail('test@gmail.com');

    verify(mockAuth.sendPasswordResetEmail(email: 'test@gmail.com')).called(1);
  });

  // ── currentUser ───────────────────────────────────────────────────────────

  test('currentUser should return user from firebase', () {
    final mockUser = MockUser();
    when(mockAuth.currentUser).thenReturn(mockUser);

    expect(repository.currentUser, mockUser);
  });

  test('currentUser should return null when not logged in', () {
    when(mockAuth.currentUser).thenReturn(null);

    expect(repository.currentUser, null);
  });
}
