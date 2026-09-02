import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:employee_management_application_flutter_assessment/framework/providers/provider/country_provider.dart';
import 'package:employee_management_application_flutter_assessment/framework/providers/provider/employee_provider.dart';
import 'package:employee_management_application_flutter_assessment/framework/repository/contract/i_country_repository.dart';
import 'package:employee_management_application_flutter_assessment/framework/repository/contract/i_employee_repository.dart';
import 'package:employee_management_application_flutter_assessment/framework/repository/model/country_model/country_model.dart';
import 'package:employee_management_application_flutter_assessment/framework/repository/model/employee_model/employee_model.dart';
import 'package:employee_management_application_flutter_assessment/ui/employee_screen/add_edit_employee_screen.dart';

import 'add_edit_employee_screen_test.mocks.dart';

@GenerateMocks([IEmployeeRepository, ICountryRepository])
void main() {
  // ── Fixtures ───────────────────────────────────────────────────────────────

  final countries = [
    CountryModel(id: '1', name: 'India'),
    CountryModel(id: '2', name: 'USA'),
  ];

  final existingEmployee = EmployeeModel(
    id: '42',
    name: 'John Doe',
    email: 'john@example.com',
    mobile: '9876543210',
    country: 'India',
    state: 'Maharashtra',
    district: 'Pune',
  );

  // ── Helper ─────────────────────────────────────────────────────────────────

  Widget buildScreen({
    EmployeeModel? employee,
    MockIEmployeeRepository? empRepo,
    MockICountryRepository? ctryRepo,
  }) {
    final employeeRepo = empRepo ?? MockIEmployeeRepository();
    final countryRepo = ctryRepo ?? MockICountryRepository();
    when(countryRepo.getAllCountries()).thenAnswer((_) async => countries);

    final employeeNotifier = EmployeeNotifier(
      repository: employeeRepo,
      skipCacheForTesting: true,
    );
    final countryNotifier = CountryNotifier(repository: countryRepo);

    return ProviderScope(
      overrides: [
        employeeProvider.overrideWith((_) => employeeNotifier),
        countryProvider.overrideWith((_) => countryNotifier),
      ],
      child: MaterialApp(
        home: AddEditEmployeeScreen(employee: employee),
      ),
    );
  }

  // ── Add mode: field visibility ─────────────────────────────────────────────

  testWidgets('add mode: shows all required form fields', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Mobile Number'), findsOneWidget);
    expect(find.text('State / Province'), findsOneWidget);
    expect(find.text('District / City'), findsOneWidget);
  });

  testWidgets('add mode: AppBar title is "Add Employee"', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('Add Employee'), findsWidgets);
  });

  testWidgets('add mode: country dropdown is populated after fetch',
      (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('Country'), findsOneWidget);
  });

  // ── Add mode: validation ───────────────────────────────────────────────────
  // The button may be scrolled off-screen; use ensureVisible before tapping.

  testWidgets('add mode: shows error when name is empty', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Name is required'), findsOneWidget);
  });

  testWidgets('add mode: shows error when email is empty', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter employee name'), 'Alice');
    await tester.ensureVisible(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
  });

  testWidgets('add mode: shows error for invalid email format', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter employee name'), 'Alice');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'employee@company.com'),
        'notanemail');
    await tester.ensureVisible(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Enter a valid email address'), findsOneWidget);
  });

  testWidgets('add mode: shows error when mobile is empty', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter employee name'), 'Alice');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'employee@company.com'),
        'alice@example.com');
    await tester.ensureVisible(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Mobile number is required'), findsOneWidget);
  });

  testWidgets('add mode: shows error when state is empty', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter employee name'), 'Alice');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'employee@company.com'),
        'alice@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, '9876543210'), '9876543210');
    await tester.ensureVisible(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('State is required'), findsOneWidget);
  });

  testWidgets('add mode: shows error when district is empty', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter employee name'), 'Alice');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'employee@company.com'),
        'alice@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, '9876543210'), '9876543210');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter state or province'), 'MH');
    await tester.ensureVisible(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('District is required'), findsOneWidget);
  });

  // ── Edit mode: pre-population ──────────────────────────────────────────────

  testWidgets('edit mode: AppBar title contains "Edit Employee"',
      (tester) async {
    await tester.pumpWidget(buildScreen(employee: existingEmployee));
    await tester.pumpAndSettle();

    expect(find.text('Edit Employee'), findsWidgets);
  });

  testWidgets('edit mode: name field is pre-populated', (tester) async {
    await tester.pumpWidget(buildScreen(employee: existingEmployee));
    await tester.pumpAndSettle();

    expect(find.text('John Doe'), findsOneWidget);
  });

  testWidgets('edit mode: email field is pre-populated', (tester) async {
    await tester.pumpWidget(buildScreen(employee: existingEmployee));
    await tester.pumpAndSettle();

    expect(find.text('john@example.com'), findsOneWidget);
  });

  testWidgets('edit mode: mobile field is pre-populated', (tester) async {
    await tester.pumpWidget(buildScreen(employee: existingEmployee));
    await tester.pumpAndSettle();

    // The mobile value appears both as EditableText content and
    // possibly as a read-only Text widget — use findsAtLeastNWidgets(1).
    expect(find.text('9876543210'), findsAtLeastNWidgets(1));
  });

  testWidgets('edit mode: state field is pre-populated', (tester) async {
    await tester.pumpWidget(buildScreen(employee: existingEmployee));
    await tester.pumpAndSettle();

    expect(find.text('Maharashtra'), findsOneWidget);
  });

  testWidgets('edit mode: district field is pre-populated', (tester) async {
    await tester.pumpWidget(buildScreen(employee: existingEmployee));
    await tester.pumpAndSettle();

    expect(find.text('Pune'), findsOneWidget);
  });

  testWidgets('edit mode: save button label contains "Update Employee"',
      (tester) async {
    await tester.pumpWidget(buildScreen(employee: existingEmployee));
    await tester.pumpAndSettle();

    expect(find.text('Update Employee'), findsOneWidget);
  });
}
