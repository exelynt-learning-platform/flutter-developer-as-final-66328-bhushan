import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:employee_management_application_flutter_assessment/framwork/data/status_enum.dart';
import 'package:employee_management_application_flutter_assessment/framwork/providers/provider/auth_provider.dart';
import 'package:employee_management_application_flutter_assessment/framwork/providers/provider/employee_provider.dart';
import 'package:employee_management_application_flutter_assessment/framwork/repository/contract/i_auth_repository.dart';
import 'package:employee_management_application_flutter_assessment/framwork/repository/contract/i_employee_repository.dart';
import 'package:employee_management_application_flutter_assessment/framwork/repository/model/employee_model/employee_model.dart';
import 'package:employee_management_application_flutter_assessment/ui/employee_screen/employee_list_screen.dart';
import 'package:employee_management_application_flutter_assessment/ui/helper/loading_widget.dart';

import 'employee_list_screen_test.mocks.dart';

@GenerateMocks([IAuthRepository, IEmployeeRepository])
void main() {
  // ── Fixtures ───────────────────────────────────────────────────────────────

  final emp1 = EmployeeModel(
    id: '1',
    name: 'Alice Smith',
    email: 'alice@example.com',
    mobile: '1111111111',
    country: 'India',
    state: 'MH',
    district: 'Pune',
  );

  final emp2 = EmployeeModel(
    id: '2',
    name: 'Bob Jones',
    email: 'bob@example.com',
    mobile: '2222222222',
    country: 'USA',
    state: 'CA',
    district: 'LA',
  );

  // ── Helper ─────────────────────────────────────────────────────────────────

  Widget buildScreen({
    required EmployeeNotifier employeeNotifier,
    MockIAuthRepository? authRepo,
  }) {
    final repo = authRepo ?? MockIAuthRepository();
    when(repo.authStateChanges).thenAnswer((_) => const Stream.empty());
    when(repo.currentUser).thenReturn(null);
    final authNotifier = AuthNotifier(repository: repo);

    return ProviderScope(
      overrides: [
        authProvider.overrideWith((_) => authNotifier),
        employeeProvider.overrideWith((_) => employeeNotifier),
      ],
      child: const MediaQuery(
        // Give enough height so cards don't overflow in test layout
        data: MediaQueryData(size: Size(400, 800)),
        child: MaterialApp(home: EmployeeListScreen()),
      ),
    );
  }

  // ── Loading state ──────────────────────────────────────────────────────────

  testWidgets('shows shimmer loading when status is loading and list is empty',
      (tester) async {
    final mockRepo = MockIEmployeeRepository();
    // Use a Completer so the future never resolves during the test
    // and there are no pending timers when the test ends.
    // We achieve this by not stubbing getAllEmployees at all and
    // checking EmployeeListShimmer is shown in the initial loading frame.
    final notifier = EmployeeNotifier(
      repository: mockRepo,
      skipCacheForTesting: true,
    );
    // Never-completing completer — no timer involved
    final neverCompletes = Completer<List<EmployeeModel>>();
    when(mockRepo.getAllEmployees())
        .thenAnswer((_) => neverCompletes.future);

    unawaited(notifier.fetchAllEmployees()); // sets status=loading

    await tester.pumpWidget(buildScreen(employeeNotifier: notifier));
    await tester.pump(); // one frame

    expect(find.byType(EmployeeListShimmer), findsOneWidget);

    // Complete the completer so the Dart async runtime cleans up
    neverCompletes.complete([]);
    await tester.pumpAndSettle();
  });

  // ── Error state ────────────────────────────────────────────────────────────

  testWidgets('shows error widget when status is error and list is empty',
      (tester) async {
    final mockRepo = MockIEmployeeRepository();
    when(mockRepo.getAllEmployees()).thenThrow(Exception('Network error'));

    final notifier = EmployeeNotifier(
      repository: mockRepo,
      skipCacheForTesting: true,
    );
    await notifier.fetchAllEmployees();

    await tester.pumpWidget(buildScreen(employeeNotifier: notifier));
    await tester.pump();

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(notifier.status, StatusEnum.error);
  });

  testWidgets('error widget shows Retry button', (tester) async {
    final mockRepo = MockIEmployeeRepository();
    when(mockRepo.getAllEmployees()).thenThrow(Exception('Network error'));

    final notifier = EmployeeNotifier(
      repository: mockRepo,
      skipCacheForTesting: true,
    );
    await notifier.fetchAllEmployees();

    await tester.pumpWidget(buildScreen(employeeNotifier: notifier));
    await tester.pump();

    expect(find.text('Retry'), findsOneWidget);
  });

  // ── Empty state ────────────────────────────────────────────────────────────

  testWidgets('shows empty state when fetch succeeds but list is empty',
      (tester) async {
    final mockRepo = MockIEmployeeRepository();
    when(mockRepo.getAllEmployees()).thenAnswer((_) async => []);

    final notifier = EmployeeNotifier(
      repository: mockRepo,
      skipCacheForTesting: true,
    );
    await notifier.fetchAllEmployees();

    await tester.pumpWidget(buildScreen(employeeNotifier: notifier));
    await tester.pump();

    expect(find.text('No Employees Yet'), findsOneWidget);
  });

  // ── Employee list ──────────────────────────────────────────────────────────

  testWidgets('renders employee names when fetch succeeds with data',
      (tester) async {
    final mockRepo = MockIEmployeeRepository();
    when(mockRepo.getAllEmployees()).thenAnswer((_) async => [emp1, emp2]);

    final notifier = EmployeeNotifier(
      repository: mockRepo,
      skipCacheForTesting: true,
    );
    await notifier.fetchAllEmployees();

    await tester.pumpWidget(buildScreen(employeeNotifier: notifier));
    await tester.pump();

    expect(find.text('Alice Smith'), findsOneWidget);
    expect(find.text('Bob Jones'), findsOneWidget);
  });

  testWidgets('renders employee email in each card', (tester) async {
    final mockRepo = MockIEmployeeRepository();
    when(mockRepo.getAllEmployees()).thenAnswer((_) async => [emp1]);

    final notifier = EmployeeNotifier(
      repository: mockRepo,
      skipCacheForTesting: true,
    );
    await notifier.fetchAllEmployees();

    await tester.pumpWidget(buildScreen(employeeNotifier: notifier));
    await tester.pump();

    expect(find.text('alice@example.com'), findsOneWidget);
  });

  // ── Search / filter ────────────────────────────────────────────────────────

  testWidgets('search bar is visible after list loads', (tester) async {
    final mockRepo = MockIEmployeeRepository();
    when(mockRepo.getAllEmployees()).thenAnswer((_) async => [emp1, emp2]);

    final notifier = EmployeeNotifier(
      repository: mockRepo,
      skipCacheForTesting: true,
    );
    await notifier.fetchAllEmployees();

    await tester.pumpWidget(buildScreen(employeeNotifier: notifier));
    await tester.pump();

    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('filter chips are visible', (tester) async {
    final mockRepo = MockIEmployeeRepository();
    when(mockRepo.getAllEmployees()).thenAnswer((_) async => [emp1]);

    final notifier = EmployeeNotifier(
      repository: mockRepo,
      skipCacheForTesting: true,
    );
    await notifier.fetchAllEmployees();

    await tester.pumpWidget(buildScreen(employeeNotifier: notifier));
    await tester.pump();

    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
  });

  testWidgets('typing in search bar filters the employee list', (tester) async {
    final mockRepo = MockIEmployeeRepository();
    when(mockRepo.getAllEmployees()).thenAnswer((_) async => [emp1, emp2]);

    final notifier = EmployeeNotifier(
      repository: mockRepo,
      skipCacheForTesting: true,
    );
    await notifier.fetchAllEmployees();

    await tester.pumpWidget(buildScreen(employeeNotifier: notifier));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'Alice');
    await tester.pump();

    expect(find.text('Alice Smith'), findsOneWidget);
    expect(find.text('Bob Jones'), findsNothing);
  });

  testWidgets('shows empty search state when query matches nothing',
      (tester) async {
    final mockRepo = MockIEmployeeRepository();
    when(mockRepo.getAllEmployees()).thenAnswer((_) async => [emp1, emp2]);

    final notifier = EmployeeNotifier(
      repository: mockRepo,
      skipCacheForTesting: true,
    );
    await notifier.fetchAllEmployees();

    await tester.pumpWidget(buildScreen(employeeNotifier: notifier));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'zzznomatch');
    await tester.pump();

    expect(find.text('No results found'), findsOneWidget);
  });

  // ── AppBar / FAB ───────────────────────────────────────────────────────────

  testWidgets('AppBar shows Employees title', (tester) async {
    final mockRepo = MockIEmployeeRepository();
    when(mockRepo.getAllEmployees()).thenAnswer((_) async => []);

    final notifier = EmployeeNotifier(
      repository: mockRepo,
      skipCacheForTesting: true,
    );
    await notifier.fetchAllEmployees();

    await tester.pumpWidget(buildScreen(employeeNotifier: notifier));
    await tester.pump();

    expect(find.text('Employees'), findsOneWidget);
  });

  testWidgets('FAB Add Employee button is visible', (tester) async {
    final mockRepo = MockIEmployeeRepository();
    when(mockRepo.getAllEmployees()).thenAnswer((_) async => []);

    final notifier = EmployeeNotifier(
      repository: mockRepo,
      skipCacheForTesting: true,
    );
    await notifier.fetchAllEmployees();

    await tester.pumpWidget(buildScreen(employeeNotifier: notifier));
    await tester.pump();

    expect(find.text('Add Employee'), findsOneWidget);
  });
}
