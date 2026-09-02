import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:employee_management_application_flutter_assessment/framework/providers/networks/dio_helper.dart';
import 'package:employee_management_application_flutter_assessment/framework/repository/repository/employee_repository.dart';
import 'package:employee_management_application_flutter_assessment/framework/repository/model/employee_model/employee_model.dart';

import 'employee_repository_test.mocks.dart';

@GenerateMocks([DioHelper])
void main() {
  late MockDioHelper mockDio;
  late EmployeeRepository repository;

  // sample data
  final employeeData = {
    'id': '1',
    'name': 'John Doe',
    'email': 'john@gmail.com',
    'mobile': '9876543210',
    'country': 'India',
    'state': 'Maharashtra',
    'district': 'Pune',
  };

  setUp(() {
    mockDio = MockDioHelper();
    repository = EmployeeRepository(dioHelper: mockDio);
  });

  test('getAllEmployees should return list of employees', () async {
    when(mockDio.get('/employee')).thenAnswer((_) async => [employeeData]);

    final result = await repository.getAllEmployees();

    expect(result.length, 1);
    expect(result[0].name, 'John Doe');
  });

  test('getEmployeeById should return single employee', () async {
    when(mockDio.get('/employee/1')).thenAnswer((_) async => employeeData);

    final result = await repository.getEmployeeById('1');

    expect(result.id, '1');
    expect(result.name, 'John Doe');
  });

  test('createEmployee should return the created employee', () async {
    when(mockDio.post('/employee', any)).thenAnswer((_) async => employeeData);

    final newEmployee = EmployeeModel(
      name: 'John Doe',
      email: 'john@gmail.com',
      mobile: '9876543210',
      country: 'India',
      state: 'Maharashtra',
      district: 'Pune',
    );

    final result = await repository.createEmployee(newEmployee);

    expect(result.id, '1');
    expect(result.name, 'John Doe');
  });

  test('updateEmployee should return updated employee', () async {
    final updatedData = {...employeeData, 'name': 'Jane Doe'};
    when(mockDio.put('/employee/1', any)).thenAnswer((_) async => updatedData);

    final employee = EmployeeModel(
      id: '1',
      name: 'Jane Doe',
      email: 'jane@gmail.com',
      mobile: '9876543210',
      country: 'India',
      state: 'Maharashtra',
      district: 'Pune',
    );

    final result = await repository.updateEmployee('1', employee);

    expect(result.name, 'Jane Doe');
  });

  test('deleteEmployee should complete without throwing error', () async {
    when(mockDio.delete('/employee/1')).thenAnswer((_) async => null);

    // should not throw
    await repository.deleteEmployee('1');
  });

  test('getAllEmployees should throw exception when api fails', () async {
    when(mockDio.get('/employee')).thenThrow(Exception('Server error'));

    expect(() => repository.getAllEmployees(), throwsException);
  });
}
