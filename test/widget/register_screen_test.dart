import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:employee_management_application_flutter_assessment/framework/providers/provider/auth_provider.dart';
import 'package:employee_management_application_flutter_assessment/framework/repository/contract/i_auth_repository.dart';
import 'package:employee_management_application_flutter_assessment/ui/auth_screen/register_screen.dart';

import 'register_screen_test.mocks.dart';

@GenerateMocks([IAuthRepository])
void main() {
  Widget buildRegisterScreen({MockIAuthRepository? mockRepo}) {
    final repo = mockRepo ?? MockIAuthRepository();
    when(repo.authStateChanges).thenAnswer((_) => const Stream.empty());
    final authNotifier = AuthNotifier(repository: repo);
    return ProviderScope(
      overrides: [authProvider.overrideWith((_) => authNotifier)],
      child: const MaterialApp(home: RegisterScreen()),
    );
  }

  // The AppBar title is "Create Account" and the button also says "Create Account".
  // Use find.byType(ElevatedButton) to avoid ambiguity when tapping.

  testWidgets('shows Full Name, Email, Password and Confirm Password fields',
      (tester) async {
    await tester.pumpWidget(buildRegisterScreen());
    await tester.pump();

    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
  });

  testWidgets('shows Create Account button', (tester) async {
    await tester.pumpWidget(buildRegisterScreen());
    await tester.pump();

    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('shows Sign In link', (tester) async {
    await tester.pumpWidget(buildRegisterScreen());
    await tester.pump();

    expect(find.text('Sign In'), findsOneWidget);
  });

  // ── Validation ─────────────────────────────────────────────────────────────

  testWidgets('shows error when name is empty on submit', (tester) async {
    await tester.pumpWidget(buildRegisterScreen());
    await tester.pump();

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Name is required'), findsOneWidget);
  });

  testWidgets('shows error when name is too short', (tester) async {
    await tester.pumpWidget(buildRegisterScreen());
    await tester.pump();

    await tester.enterText(find.byType(TextFormField).at(0), 'A');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Name must be at least 2 characters'), findsOneWidget);
  });

  testWidgets('shows error when email is empty', (tester) async {
    await tester.pumpWidget(buildRegisterScreen());
    await tester.pump();

    await tester.enterText(find.byType(TextFormField).at(0), 'Alice');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
  });

  testWidgets('shows error when email format is invalid', (tester) async {
    await tester.pumpWidget(buildRegisterScreen());
    await tester.pump();

    await tester.enterText(find.byType(TextFormField).at(0), 'Alice');
    await tester.enterText(find.byType(TextFormField).at(1), 'notanemail');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Enter a valid email address'), findsOneWidget);
  });

  testWidgets('shows error when password is empty', (tester) async {
    await tester.pumpWidget(buildRegisterScreen());
    await tester.pump();

    await tester.enterText(find.byType(TextFormField).at(0), 'Alice');
    await tester.enterText(
        find.byType(TextFormField).at(1), 'alice@example.com');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('shows error when password is too short', (tester) async {
    await tester.pumpWidget(buildRegisterScreen());
    await tester.pump();

    await tester.enterText(find.byType(TextFormField).at(0), 'Alice');
    await tester.enterText(
        find.byType(TextFormField).at(1), 'alice@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), '123');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(
        find.text('Password must be at least 6 characters'), findsOneWidget);
  });

  testWidgets('shows error when confirm password does not match',
      (tester) async {
    await tester.pumpWidget(buildRegisterScreen());
    await tester.pump();

    await tester.enterText(find.byType(TextFormField).at(0), 'Alice');
    await tester.enterText(
        find.byType(TextFormField).at(1), 'alice@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'password1');
    await tester.enterText(find.byType(TextFormField).at(3), 'different1');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  // ── Happy path ─────────────────────────────────────────────────────────────

  testWidgets('calls registerWithEmail when all fields are valid',
      (tester) async {
    final mockRepo = MockIAuthRepository();
    when(mockRepo.authStateChanges).thenAnswer((_) => const Stream.empty());
    when(mockRepo.registerWithEmail(any, any, any))
        .thenAnswer((_) async => throw Exception('test exit'));

    await tester.pumpWidget(buildRegisterScreen(mockRepo: mockRepo));
    await tester.pump();

    await tester.enterText(find.byType(TextFormField).at(0), 'Alice Smith');
    await tester.enterText(
        find.byType(TextFormField).at(1), 'alice@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'password1');
    await tester.enterText(find.byType(TextFormField).at(3), 'password1');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    verify(mockRepo.registerWithEmail(
            'alice@example.com', 'password1', 'Alice Smith'))
        .called(1);
  });
}
