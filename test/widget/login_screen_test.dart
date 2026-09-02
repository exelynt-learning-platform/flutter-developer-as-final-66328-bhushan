import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:employee_management_application_flutter_assessment/framwork/providers/provider/auth_provider.dart';
import 'package:employee_management_application_flutter_assessment/framwork/repository/repository/auth_repository.dart';
import 'package:employee_management_application_flutter_assessment/ui/auth_screen/login_screen.dart';

import 'login_screen_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  // build login screen with a mocked auth provider
  // so Firebase is never called in tests
  Widget buildLoginScreen() {
    final mockRepo = MockAuthRepository();
    when(mockRepo.authStateChanges).thenAnswer((_) => const Stream.empty());

    final authNotifier = AuthNotifier(repository: mockRepo);

    return ProviderScope(
      overrides: [
        authProvider.overrideWith((_) => authNotifier),
      ],
      child: const MaterialApp(home: LoginScreen()),
    );
  }

  testWidgets('should show email and password fields', (tester) async {
    await tester.pumpWidget(buildLoginScreen());
    await tester.pump();

    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('should show error when email is empty', (tester) async {
    await tester.pumpWidget(buildLoginScreen());
    await tester.pump();

    // tap sign in without filling anything
    await tester.tap(find.text('Sign In'));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
  });

  testWidgets('should show error when password is empty', (tester) async {
    await tester.pumpWidget(buildLoginScreen());
    await tester.pump();

    await tester.tap(find.text('Sign In'));
    await tester.pump();

    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('should show error for invalid email format', (tester) async {
    await tester.pumpWidget(buildLoginScreen());
    await tester.pump();

    await tester.enterText(find.byType(TextFormField).first, 'notvalid');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.text('Sign In'));
    await tester.pump();

    expect(find.text('Enter a valid email address'), findsOneWidget);
  });

  testWidgets('should show error when password is too short', (tester) async {
    await tester.pumpWidget(buildLoginScreen());
    await tester.pump();

    await tester.enterText(find.byType(TextFormField).first, 'test@gmail.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123');
    await tester.tap(find.text('Sign In'));
    await tester.pump();

    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
  });

  testWidgets('should show Google Sign-In button', (tester) async {
    await tester.pumpWidget(buildLoginScreen());
    await tester.pump();

    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('should show Forgot Password button', (tester) async {
    await tester.pumpWidget(buildLoginScreen());
    await tester.pump();

    expect(find.text('Forgot Password?'), findsOneWidget);
  });

  testWidgets('should show Register link', (tester) async {
    await tester.pumpWidget(buildLoginScreen());
    await tester.pump();

    expect(find.text('Register'), findsOneWidget);
  });
}
