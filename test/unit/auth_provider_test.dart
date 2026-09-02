import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:employee_management_application_flutter_assessment/framwork/data/status_enum.dart';
import 'package:employee_management_application_flutter_assessment/framwork/providers/provider/auth_provider.dart';
import 'package:employee_management_application_flutter_assessment/framwork/repository/contract/i_auth_repository.dart';

import 'auth_provider_test.mocks.dart';

@GenerateMocks([IAuthRepository, UserCredential, User])
void main() {
  late MockIAuthRepository mockRepo;
  late AuthNotifier notifier;

  setUp(() {
    mockRepo = MockIAuthRepository();
    // authStateChanges must be stubbed because AuthNotifier.init() subscribes to it
    when(mockRepo.authStateChanges).thenAnswer((_) => const Stream.empty());
    notifier = AuthNotifier(repository: mockRepo);
  });

  // ── Initial state ─────────────────────────────────────────────────────────

  test('initial status is StatusEnum.initial', () {
    expect(notifier.status, StatusEnum.initial);
    expect(notifier.user, isNull);
    expect(notifier.errorMessage, isNull);
    expect(notifier.isLoading, isFalse);
    expect(notifier.isAuthenticated, isFalse);
  });

  // ── signInWithEmail ───────────────────────────────────────────────────────

  test('signInWithEmail returns true and sets user on success', () async {
    final mockCredential = MockUserCredential();
    final mockUser = MockUser();
    when(mockCredential.user).thenReturn(mockUser);
    when(mockRepo.signInWithEmail(any, any))
        .thenAnswer((_) async => mockCredential);

    final result =
        await notifier.signInWithEmail('test@example.com', 'pass123');

    expect(result, isTrue);
    expect(notifier.status, StatusEnum.success);
    expect(notifier.user, mockUser);
    expect(notifier.errorMessage, isNull);
  });

  test('signInWithEmail returns false and sets error on failure', () async {
    when(mockRepo.signInWithEmail(any, any))
        .thenThrow(Exception('No account found with this email.'));

    final result =
        await notifier.signInWithEmail('bad@example.com', 'wrong');

    expect(result, isFalse);
    expect(notifier.status, StatusEnum.error);
    expect(notifier.errorMessage, contains('No account found'));
    expect(notifier.user, isNull);
  });

  test('signInWithEmail sets loading state before completing', () async {
    final statuses = <StatusEnum>[];
    notifier.addListener(() => statuses.add(notifier.status));

    final mockCredential = MockUserCredential();
    when(mockCredential.user).thenReturn(null);
    when(mockRepo.signInWithEmail(any, any))
        .thenAnswer((_) async => mockCredential);

    await notifier.signInWithEmail('t@t.com', 'pass123');

    expect(statuses.first, StatusEnum.loading);
    expect(statuses.last, StatusEnum.success);
  });

  // ── registerWithEmail ─────────────────────────────────────────────────────

  test('registerWithEmail returns true and sets user on success', () async {
    final mockCredential = MockUserCredential();
    final mockUser = MockUser();
    when(mockCredential.user).thenReturn(mockUser);
    when(mockRepo.registerWithEmail(any, any, any))
        .thenAnswer((_) async => mockCredential);

    final result = await notifier.registerWithEmail(
        'new@example.com', 'password1', 'Jane Doe');

    expect(result, isTrue);
    expect(notifier.status, StatusEnum.success);
    expect(notifier.user, mockUser);
  });

  test('registerWithEmail returns false and sets error on failure', () async {
    when(mockRepo.registerWithEmail(any, any, any))
        .thenThrow(Exception('An account already exists with this email.'));

    final result =
        await notifier.registerWithEmail('dup@example.com', 'pass1', 'Name');

    expect(result, isFalse);
    expect(notifier.status, StatusEnum.error);
    expect(notifier.errorMessage, contains('already exists'));
  });

  // ── signInWithGoogle ──────────────────────────────────────────────────────

  test('signInWithGoogle returns true and sets user on success', () async {
    final mockCredential = MockUserCredential();
    final mockUser = MockUser();
    when(mockCredential.user).thenReturn(mockUser);
    when(mockRepo.signInWithGoogle())
        .thenAnswer((_) async => mockCredential);

    final result = await notifier.signInWithGoogle();

    expect(result, isTrue);
    expect(notifier.status, StatusEnum.success);
    expect(notifier.user, mockUser);
  });

  test('signInWithGoogle returns false and sets error when cancelled', () async {
    when(mockRepo.signInWithGoogle())
        .thenThrow(Exception('Google Sign-In was cancelled.'));

    final result = await notifier.signInWithGoogle();

    expect(result, isFalse);
    expect(notifier.status, StatusEnum.error);
    expect(notifier.errorMessage, contains('cancelled'));
  });

  // ── sendPasswordResetEmail ────────────────────────────────────────────────

  test('sendPasswordResetEmail returns true on success', () async {
    when(mockRepo.sendPasswordResetEmail(any)).thenAnswer((_) async {});

    final result =
        await notifier.sendPasswordResetEmail('test@example.com');

    expect(result, isTrue);
    expect(notifier.status, StatusEnum.success);
  });

  test('sendPasswordResetEmail returns false and sets error on failure',
      () async {
    when(mockRepo.sendPasswordResetEmail(any))
        .thenThrow(Exception('No account found with this email.'));

    final result =
        await notifier.sendPasswordResetEmail('nobody@example.com');

    expect(result, isFalse);
    expect(notifier.status, StatusEnum.error);
    expect(notifier.errorMessage, contains('No account found'));
  });

  // ── signOut ───────────────────────────────────────────────────────────────

  test('signOut clears user and resets status to initial', () async {
    // First sign in to have a user
    final mockCredential = MockUserCredential();
    final mockUser = MockUser();
    when(mockCredential.user).thenReturn(mockUser);
    when(mockRepo.signInWithEmail(any, any))
        .thenAnswer((_) async => mockCredential);
    await notifier.signInWithEmail('t@t.com', 'pass');
    expect(notifier.user, mockUser);

    // Now sign out
    when(mockRepo.signOut()).thenAnswer((_) async {});
    await notifier.signOut();

    expect(notifier.user, isNull);
    expect(notifier.status, StatusEnum.initial);
    expect(notifier.errorMessage, isNull);
    expect(notifier.isAuthenticated, isFalse);
    verify(mockRepo.signOut()).called(1);
  });

  // ── clearError ────────────────────────────────────────────────────────────

  test('clearError resets status and errorMessage', () async {
    // Produce an error first
    when(mockRepo.signInWithEmail(any, any))
        .thenThrow(Exception('Something went wrong'));
    await notifier.signInWithEmail('x@x.com', 'bad');
    expect(notifier.status, StatusEnum.error);
    expect(notifier.errorMessage, isNotNull);

    notifier.clearError();

    expect(notifier.status, StatusEnum.initial);
    expect(notifier.errorMessage, isNull);
  });
}
