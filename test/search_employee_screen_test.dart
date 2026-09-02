import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:employee_management_application_flutter_assessment/framework/providers/provider/employee_provider.dart';
import 'package:employee_management_application_flutter_assessment/framework/repository/contract/i_employee_repository.dart';
import 'package:employee_management_application_flutter_assessment/framework/repository/model/employee_model/employee_model.dart';
import 'package:employee_management_application_flutter_assessment/ui/employee_screen/search_employee_screen.dart';

import 'search_employee_screen_test.mocks.dart';

@GenerateMocks([IEmployeeRepository])
void main() {
  final emp = EmployeeModel(
    id: '42',
    name: 'Alice Smith',
    email: 'alice@example.com',
    mobile: '9876543210',
    country: 'India',
    state: 'MH',
    district: 'Pune',
  );

  // ── Helper ─────────────────────────────────────────────────────────────────

  Widget buildScreen({required MockIEmployeeRepository empRepo}) {
    final notifier = EmployeeNotifier(
      repository: empRepo,
      skipCacheForTesting: true,
    );
    return ProviderScope(
      overrides: [employeeProvider.overrideWith((_) => notifier)],
      child: const MaterialApp(home: SearchEmployeeScreen()),
    );
  }

  // ── Idle state ─────────────────────────────────────────────────────────────

  testWidgets('shows idle prompt on first open', (tester) async {
    final mockRepo = MockIEmployeeRepository();
    await tester.pumpWidget(buildScreen(empRepo: mockRepo));
    await tester.pump();

    expect(find.text('Enter an ID to search'), findsOneWidget);
    expect(find.text('Find any employee by their numeric ID'), findsOneWidget);
  });

  testWidgets('shows Employee ID text field and search button', (tester) async {
    final mockRepo = MockIEmployeeRepository();
    await tester.pumpWidget(buildScreen(empRepo: mockRepo));
    await tester.pump();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('AppBar title is "Search by ID"', (tester) async {
    final mockRepo = MockIEmployeeRepository();
    await tester.pumpWidget(buildScreen(empRepo: mockRepo));
    await tester.pump();

    expect(find.text('Search by ID'), findsOneWidget);
  });

  // ── Empty-input guard ─────────────────────────────────────────────────────

  testWidgets('tapping search with empty field shows snackbar', (tester) async {
    final mockRepo = MockIEmployeeRepository();
    await tester.pumpWidget(buildScreen(empRepo: mockRepo));
    await tester.pump();

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Please enter an employee ID'), findsOneWidget);
  });

  // ── Found state ───────────────────────────────────────────────────────────
  // On success, SearchEmployeeScreen navigates to EmployeeDetailScreen.
  // The inline result card (_ResultCard) is visible briefly, but the
  // navigator pushes the detail screen before pumpAndSettle completes.
  // We verify that the repository was called with the correct ID and that
  // the navigation target (EmployeeDetailScreen) receives the employee data.

  testWidgets('successful search calls getEmployeeById with entered ID',
      (tester) async {
    final mockRepo = MockIEmployeeRepository();
    when(mockRepo.getEmployeeById('42')).thenAnswer((_) async => emp);

    await tester.pumpWidget(buildScreen(empRepo: mockRepo));
    await tester.pump();

    await tester.enterText(find.byType(TextField), '42');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    verify(mockRepo.getEmployeeById('42')).called(1);
  });

  testWidgets('successful search navigates to a screen showing employee name',
      (tester) async {
    final mockRepo = MockIEmployeeRepository();
    when(mockRepo.getEmployeeById('42')).thenAnswer((_) async => emp);

    await tester.pumpWidget(buildScreen(empRepo: mockRepo));
    await tester.pump();

    await tester.enterText(find.byType(TextField), '42');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // After navigation the employee name appears somewhere in the tree
    expect(find.text('Alice Smith'), findsAtLeastNWidgets(1));
  });

  // ── Not-found / error state ───────────────────────────────────────────────

  testWidgets('shows employee-not-found message on error state', (tester) async {
    final mockRepo = MockIEmployeeRepository();
    when(mockRepo.getEmployeeById(any))
        .thenThrow(Exception('Resource not found.'));

    await tester.pumpWidget(buildScreen(empRepo: mockRepo));
    await tester.pump();

    await tester.enterText(find.byType(TextField), '999');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Employee not found'), findsOneWidget);
  });

  // ── Loading state ─────────────────────────────────────────────────────────

  testWidgets('shows Searching… spinner while fetch is in progress',
      (tester) async {
    final mockRepo = MockIEmployeeRepository();
    final completer = Completer<EmployeeModel>();
    when(mockRepo.getEmployeeById(any)).thenAnswer((_) => completer.future);

    await tester.pumpWidget(buildScreen(empRepo: mockRepo));
    await tester.pump();

    await tester.enterText(find.byType(TextField), '1');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); // one frame — should be in loading

    expect(find.text('Searching...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));

    // Clean up — complete the future so no pending timers remain
    completer.complete(emp);
    await tester.pumpAndSettle();
  });
}
