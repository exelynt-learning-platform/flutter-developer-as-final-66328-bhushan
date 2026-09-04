import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:employee_management_application_flutter_assessment/features/auth/domain/entities/auth_user.dart';
import 'package:employee_management_application_flutter_assessment/features/auth/domain/repositories/auth_repository.dart';
import 'package:employee_management_application_flutter_assessment/features/auth/domain/usecases/auth_usecases.dart';
import 'package:employee_management_application_flutter_assessment/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:employee_management_application_flutter_assessment/features/auth/presentation/bloc/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repo;
  late AuthCubit cubit;

  const tUser = AuthUser(
    uid: 'uid1',
    email: 'test@example.com',
    displayName: 'Test User',
  );

  setUp(() {
    repo = MockAuthRepository();
    when(() => repo.authStateChanges).thenAnswer((_) => const Stream.empty());
    cubit = AuthCubit(
      repository: repo,
      signInUseCase: SignInUseCase(repo),
      registerUseCase: RegisterUseCase(repo),
      googleUseCase: GoogleSignInUseCase(repo),
      resetUseCase: ResetPasswordUseCase(repo),
      signOutUseCase: SignOutUseCase(repo),
    );
  });

  tearDown(() => cubit.close());

  // ── initial state ──────────────────────────────────────────────────────────

  test('initial state is AuthInitial', () {
    expect(cubit.state, const AuthInitial());
  });

  // ── signInWithEmail ────────────────────────────────────────────────────────

  blocTest<AuthCubit, AuthState>(
    'emits [AuthLoading, Authenticated] on signInWithEmail success',
    build: () {
      when(() => repo.signInWithEmail(any(), any()))
          .thenAnswer((_) async => tUser);
      return cubit;
    },
    act: (c) => c.signInWithEmail('test@example.com', 'pass123'),
    expect: () => [const AuthLoading(), Authenticated(tUser)],
  );

  blocTest<AuthCubit, AuthState>(
    'emits [AuthLoading, AuthError] on signInWithEmail failure',
    build: () {
      when(() => repo.signInWithEmail(any(), any()))
          .thenThrow(Exception('Invalid credentials.'));
      return cubit;
    },
    act: (c) => c.signInWithEmail('bad@example.com', 'wrong'),
    expect: () => [
      const AuthLoading(),
      const AuthError('Invalid credentials.'),
    ],
  );

  // ── registerWithEmail ──────────────────────────────────────────────────────

  blocTest<AuthCubit, AuthState>(
    'emits [AuthLoading, Authenticated] on registerWithEmail success',
    build: () {
      when(() => repo.registerWithEmail(any(), any(), any()))
          .thenAnswer((_) async => tUser);
      return cubit;
    },
    act: (c) =>
        c.registerWithEmail('test@example.com', 'pass123', 'Test User'),
    expect: () => [const AuthLoading(), Authenticated(tUser)],
  );

  blocTest<AuthCubit, AuthState>(
    'emits [AuthLoading, AuthError] on registerWithEmail failure',
    build: () {
      when(() => repo.registerWithEmail(any(), any(), any()))
          .thenThrow(Exception('An account already exists with this email.'));
      return cubit;
    },
    act: (c) =>
        c.registerWithEmail('dup@example.com', 'pass', 'Name'),
    expect: () => [
      const AuthLoading(),
      const AuthError('An account already exists with this email.'),
    ],
  );

  // ── signInWithGoogle ───────────────────────────────────────────────────────

  blocTest<AuthCubit, AuthState>(
    'emits [AuthLoading, Authenticated] on signInWithGoogle success',
    build: () {
      when(() => repo.signInWithGoogle())
          .thenAnswer((_) async => tUser);
      return cubit;
    },
    act: (c) => c.signInWithGoogle(),
    expect: () => [const AuthLoading(), Authenticated(tUser)],
  );

  blocTest<AuthCubit, AuthState>(
    'emits [AuthLoading, AuthGoogleCancelled] when user cancels Google',
    build: () {
      when(() => repo.signInWithGoogle()).thenAnswer((_) async => null);
      return cubit;
    },
    act: (c) => c.signInWithGoogle(),
    expect: () =>
        [const AuthLoading(), const AuthGoogleCancelled()],
  );

  blocTest<AuthCubit, AuthState>(
    'emits [AuthLoading, AuthError] on signInWithGoogle Firebase error',
    build: () {
      when(() => repo.signInWithGoogle())
          .thenThrow(Exception('Network error.'));
      return cubit;
    },
    act: (c) => c.signInWithGoogle(),
    expect: () => [
      const AuthLoading(),
      const AuthError('Network error.'),
    ],
  );

  // ── sendPasswordResetEmail ─────────────────────────────────────────────────

  blocTest<AuthCubit, AuthState>(
    'emits [AuthLoading, Unauthenticated] on sendPasswordResetEmail success',
    build: () {
      when(() => repo.sendPasswordResetEmail(any()))
          .thenAnswer((_) async {});
      return cubit;
    },
    act: (c) => c.sendPasswordResetEmail('test@example.com'),
    expect: () =>
        [const AuthLoading(), const Unauthenticated()],
  );

  blocTest<AuthCubit, AuthState>(
    'emits [AuthLoading, AuthError] on sendPasswordResetEmail failure',
    build: () {
      when(() => repo.sendPasswordResetEmail(any()))
          .thenThrow(Exception('No account found with this email.'));
      return cubit;
    },
    act: (c) => c.sendPasswordResetEmail('nobody@example.com'),
    expect: () => [
      const AuthLoading(),
      const AuthError('No account found with this email.'),
    ],
  );

  // ── signOut ────────────────────────────────────────────────────────────────

  blocTest<AuthCubit, AuthState>(
    'emits Unauthenticated on signOut',
    build: () {
      when(() => repo.signOut()).thenAnswer((_) async {});
      return cubit;
    },
    act: (c) => c.signOut(),
    expect: () => [const Unauthenticated()],
    verify: (_) => verify(() => repo.signOut()).called(1),
  );
}
