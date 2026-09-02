import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:employee_management_application_flutter_assessment/framework/providers/provider/auth_provider.dart';
import 'package:employee_management_application_flutter_assessment/framework/repository/contract/i_auth_repository.dart';
import 'package:employee_management_application_flutter_assessment/ui/auth_screen/forgot_password_screen.dart';

import 'forgot_password_screen_test.mocks.dart';

@GenerateMocks([IAuthRepository])
void main() {
  /// Helper: builds ForgotPasswordScreen with a fully mocked [IAuthRepository].
  Widget buildScreen({MockIAuthRepository? mockRepo}) {
    final repo = mockRepo ?? MockIAuthRepository();
    when(repo.authStateChanges).thenAnswer((_) => const Stream.empty());
    final authNotifier = AuthNotifier(repository: repo);
    return ProviderScope(
      overrides: [authProvider.overrideWith((_) => authNotifier)],
      child: const MaterialApp(home: ForgotPasswordScreen()),
    );
  }

  // ── Field visibility ───────────────────────────────────────────────────────

  testWidgets('shows email field and Send Reset Link button', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();

    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Send Reset Link'), findsOneWidget);
  });

  testWidgets('shows Reset Password heading', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();

    expect(find.text('Reset Password'), findsOneWidget);
  });

  // ── Validation ─────────────────────────────────────────────────────────────

  testWidgets('shows error when email is empty on submit', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();

    await tester.tap(find.text('Send Reset Link'));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
  });

  testWidgets('shows error for invalid email format', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();

    await tester.enterText(find.byType(TextFormField).first, 'notvalid');
    await tester.tap(find.text('Send Reset Link'));
    await tester.pump();

    expect(find.text('Enter a valid email address'), findsOneWidget);
  });

  // ── Happy path: success view ───────────────────────────────────────────────

  testWidgets('shows success view after reset email is sent', (tester) async {
    final mockRepo = MockIAuthRepository();
    when(mockRepo.authStateChanges).thenAnswer((_) => const Stream.empty());
    when(mockRepo.sendPasswordResetEmail(any)).thenAnswer((_) async {});

    await tester.pumpWidget(buildScreen(mockRepo: mockRepo));
    await tester.pump();

    await tester.enterText(
        find.byType(TextFormField).first, 'user@example.com');
    await tester.tap(find.text('Send Reset Link'));
    await tester.pumpAndSettle();

    // Success view should appear
    expect(find.text('Email Sent!'), findsOneWidget);
    expect(find.text('Back to Login'), findsOneWidget);
  });

  testWidgets('success view shows the submitted email address', (tester) async {
    final mockRepo = MockIAuthRepository();
    when(mockRepo.authStateChanges).thenAnswer((_) => const Stream.empty());
    when(mockRepo.sendPasswordResetEmail(any)).thenAnswer((_) async {});

    await tester.pumpWidget(buildScreen(mockRepo: mockRepo));
    await tester.pump();

    await tester.enterText(
        find.byType(TextFormField).first, 'user@example.com');
    await tester.tap(find.text('Send Reset Link'));
    await tester.pumpAndSettle();

    // The submitted email should appear in the success message
    expect(find.textContaining('user@example.com'), findsOneWidget);
  });

  // ── Error path ─────────────────────────────────────────────────────────────

  testWidgets('calls sendPasswordResetEmail with the entered email',
      (tester) async {
    final mockRepo = MockIAuthRepository();
    when(mockRepo.authStateChanges).thenAnswer((_) => const Stream.empty());
    when(mockRepo.sendPasswordResetEmail(any)).thenAnswer((_) async {});

    await tester.pumpWidget(buildScreen(mockRepo: mockRepo));
    await tester.pump();

    await tester.enterText(
        find.byType(TextFormField).first, 'test@example.com');
    await tester.tap(find.text('Send Reset Link'));
    await tester.pumpAndSettle();

    verify(mockRepo.sendPasswordResetEmail('test@example.com')).called(1);
  });
}
