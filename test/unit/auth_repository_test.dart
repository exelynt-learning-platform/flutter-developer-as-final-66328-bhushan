import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:employee_management_application_flutter_assessment/framwork/repository/repository/auth_repository.dart';

import 'auth_repository_test.mocks.dart';

@GenerateMocks([FirebaseAuth, GoogleSignIn, UserCredential, User])
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

    // passing email with spaces
    await repository.signInWithEmail('  test@gmail.com  ', 'pass123');

    // should be called with trimmed email
    verify(mockAuth.signInWithEmailAndPassword(
      email: 'test@gmail.com',
      password: 'pass123',
    )).called(1);
  });

  test('signOut should call both firebase and google signOut', () async {
    when(mockAuth.signOut()).thenAnswer((_) async {});
    when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);

    await repository.signOut();

    verify(mockAuth.signOut()).called(1);
    verify(mockGoogleSignIn.signOut()).called(1);
  });

  test('sendPasswordResetEmail should call firebase method', () async {
    when(mockAuth.sendPasswordResetEmail(email: anyNamed('email')))
        .thenAnswer((_) async {});

    await repository.sendPasswordResetEmail('test@gmail.com');

    verify(mockAuth.sendPasswordResetEmail(email: 'test@gmail.com')).called(1);
  });

  test('currentUser should return user from firebase', () {
    final mockUser = MockUser();
    when(mockAuth.currentUser).thenReturn(mockUser);

    expect(repository.currentUser, mockUser);
  });
}
