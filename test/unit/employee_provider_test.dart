import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:employee_management_application_flutter_assessment/framwork/data/status_enum.dart';
import 'package:employee_management_application_flutter_assessment/framwork/providers/provider/employee_provider.dart';
import 'package:employee_management_application_flutter_assessment/framwork/repository/model/employee_model/employee_model.dart';
import 'package:employee_management_application_flutter_assessment/framwork/repository/repository/employee_repository.dart';

import 'employee_provider_test.mocks.dart';

@GenerateMocks([EmployeeRepository])
void main() {
  late MockEmployeeRepository mockRepo;
  late EmployeeNotifier notifier;

  // some test employees
  final emp1 = EmployeeModel(
    id: '1',
    name: 'Alice',
    email: 'alice@gmail.com',
    mobile: '1111111111',
    country: 'India',
    state: 'MH',
    district: 'Pune',
  );

  final emp2 = EmployeeModel(
    id: '2',
    name: 'Bob',
    email: 'bob@gmail.com',
    mobile: '2222222222',
    country: 'USA',
    state: 'CA',
    district: 'LA',
  );

  setUp(() {
    mockRepo = MockEmployeeRepository();
    // skipCacheForTesting = true to avoid SharedPreferences in tests
    notifier = EmployeeNotifier(repository: mockRepo, skipCacheForTesting: true);
  });

  test('initial status should be StatusEnum.initial', () {
    expect(notifier.status, StatusEnum.initial);
    expect(notifier.employees, isEmpty);
  });

  test('fetchAllEmployees should load employees on success', () async {
    when(mockRepo.getAllEmployees()).thenAnswer((_) async => [emp1, emp2]);

    await notifier.fetchAllEmployees();

    expect(notifier.status, StatusEnum.success);
    expect(notifier.employees.length, 2);
  });

  test('fetchAllEmployees should set error status on failure', () async {
    when(mockRepo.getAllEmployees()).thenThrow(Exception('Network error'));

    await notifier.fetchAllEmployees();

    expect(notifier.status, StatusEnum.error);
  });

  test('search by name should filter correctly', () async {
    when(mockRepo.getAllEmployees())
        .thenAnswer((_) async => [emp1, emp2]);
    await notifier.fetchAllEmployees();

    notifier.setSearchQuery('alice');

    expect(notifier.employees.length, 1);
    expect(notifier.employees[0].name, 'Alice');
  });

  test('filter by country should work', () async {
    when(mockRepo.getAllEmployees())
        .thenAnswer((_) async => [emp1, emp2]);
    await notifier.fetchAllEmployees();

    notifier.setFilterField('country');
    notifier.setSearchQuery('usa');

    expect(notifier.employees.length, 1);
    expect(notifier.employees[0].country, 'USA');
  });

  test('clearSearch should show all employees again', () async {
    when(mockRepo.getAllEmployees())
        .thenAnswer((_) async => [emp1, emp2]);
    await notifier.fetchAllEmployees();

    notifier.setSearchQuery('alice');
    expect(notifier.employees.length, 1);

    notifier.clearSearch();
    expect(notifier.employees.length, 2);
  });

  test('createEmployee should add employee to list', () async {
    when(mockRepo.getAllEmployees())
        .thenAnswer((_) async => [emp1, emp2]);
    await notifier.fetchAllEmployees();

    final newEmp = EmployeeModel(
      id: '3',
      name: 'Charlie',
      email: 'charlie@gmail.com',
      mobile: '3333333333',
      country: 'UK',
      state: 'England',
      district: 'London',
    );
    when(mockRepo.createEmployee(newEmp)).thenAnswer((_) async => newEmp);

    final success = await notifier.createEmployee(newEmp);

    expect(success, true);
    expect(notifier.employees.any((e) => e.id == '3'), true);
  });

  test('deleteEmployee should remove employee from list', () async {
    when(mockRepo.getAllEmployees())
        .thenAnswer((_) async => [emp1, emp2]);
    await notifier.fetchAllEmployees();

    when(mockRepo.deleteEmployee('1')).thenAnswer((_) async {});

    final success = await notifier.deleteEmployee('1');

    expect(success, true);
    expect(notifier.employees.any((e) => e.id == '1'), false);
  });

  test('deleteEmployee should return false when api throws', () async {
    when(mockRepo.getAllEmployees())
        .thenAnswer((_) async => [emp1, emp2]);
    await notifier.fetchAllEmployees();

    when(mockRepo.deleteEmployee('1')).thenThrow(Exception('Delete failed'));

    final success = await notifier.deleteEmployee('1');

    expect(success, false);
    expect(notifier.crudStatus, StatusEnum.error);
  });

  test('updateEmployee should update name in list', () async {
    when(mockRepo.getAllEmployees())
        .thenAnswer((_) async => [emp1, emp2]);
    await notifier.fetchAllEmployees();

    final updated = emp1.copyWith(name: 'Alice Updated');
    // emp1 == updated by id, so stub matches
    when(mockRepo.updateEmployee('1', emp1))
        .thenAnswer((_) async => updated);

    final success = await notifier.updateEmployee('1', emp1);

    expect(success, true);
    expect(
      notifier.employees.firstWhere((e) => e.id == '1').name,
      'Alice Updated',
    );
  });
}
