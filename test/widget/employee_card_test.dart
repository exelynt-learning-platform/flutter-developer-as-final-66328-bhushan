import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:employee_management_application_flutter_assessment/framwork/repository/model/employee_model/employee_model.dart';
import 'package:employee_management_application_flutter_assessment/ui/helper/employee_card.dart';

void main() {
  // test employee to use in all tests
  final employee = EmployeeModel(
    id: '1',
    name: 'John Doe',
    email: 'john@gmail.com',
    mobile: '9876543210',
    country: 'India',
    state: 'Maharashtra',
    district: 'Pune',
  );

  // helper to wrap widget in MaterialApp
  Widget buildCard({
    VoidCallback? onTap,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: EmployeeCard(
          employee: employee,
          onTap: onTap,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
      ),
    );
  }

  testWidgets('should show employee name', (tester) async {
    await tester.pumpWidget(buildCard());

    expect(find.text('John Doe'), findsOneWidget);
  });

  testWidgets('should show employee email', (tester) async {
    await tester.pumpWidget(buildCard());

    expect(find.text('john@gmail.com'), findsOneWidget);
  });

  testWidgets('should show employee id badge', (tester) async {
    await tester.pumpWidget(buildCard());

    expect(find.text('#1'), findsOneWidget);
  });

  testWidgets('should show initials JD in avatar', (tester) async {
    await tester.pumpWidget(buildCard());

    expect(find.text('JD'), findsOneWidget);
  });

  testWidgets('should call onTap when card is tapped', (tester) async {
    bool tapped = false;

    await tester.pumpWidget(buildCard(onTap: () => tapped = true));
    await tester.tap(find.text('John Doe'));

    expect(tapped, true);
  });

  testWidgets('should call onEdit when edit button tapped', (tester) async {
    bool edited = false;

    await tester.pumpWidget(buildCard(onEdit: () => edited = true));
    await tester.tap(find.byIcon(Icons.edit_outlined));

    expect(edited, true);
  });

  testWidgets('should call onDelete when delete button tapped', (tester) async {
    bool deleted = false;

    await tester.pumpWidget(buildCard(onDelete: () => deleted = true));
    await tester.tap(find.byIcon(Icons.delete_outline));

    expect(deleted, true);
  });

  testWidgets('should not show delete icon when onDelete is null',
      (tester) async {
    await tester.pumpWidget(buildCard());

    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });
}
