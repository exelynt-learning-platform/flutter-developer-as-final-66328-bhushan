import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:employee_management_application_flutter_assessment/framework/repository/model/employee_model/employee_model.dart';

void main() {
  // sample employee json to test with
  final testJson = {
    'id': '1',
    'name': 'John Doe',
    'email': 'john@gmail.com',
    'mobile': '9876543210',
    'country': 'India',
    'state': 'Maharashtra',
    'district': 'Pune',
    'createdAt': '2024-01-01T00:00:00.000Z',
  };

  test('EmployeeModel fromJson should parse correctly', () {
    final employee = EmployeeModel.fromJson(testJson);

    expect(employee.id, '1');
    expect(employee.name, 'John Doe');
    expect(employee.email, 'john@gmail.com');
    expect(employee.mobile, '9876543210');
    expect(employee.country, 'India');
    expect(employee.state, 'Maharashtra');
    expect(employee.district, 'Pune');
  });

  test('EmployeeModel toJson should return correct map', () {
    final employee = EmployeeModel.fromJson(testJson);
    final json = employee.toJson();

    expect(json['name'], 'John Doe');
    expect(json['email'], 'john@gmail.com');
    expect(json['country'], 'India');
  });

  test('EmployeeModel copyWith should update only changed fields', () {
    final employee = EmployeeModel.fromJson(testJson);
    final updated = employee.copyWith(name: 'Jane Doe');

    // name should change
    expect(updated.name, 'Jane Doe');
    // other fields should stay same
    expect(updated.email, 'john@gmail.com');
    expect(updated.id, '1');
  });

  test('EmployeeModel should handle missing id gracefully', () {
    final json = {
      'name': 'Test User',
      'email': 'test@gmail.com',
      'mobile': '1234567890',
      'country': 'USA',
      'state': 'NY',
      'district': 'Manhattan',
    };

    final employee = EmployeeModel.fromJson(json);
    expect(employee.id, null);
    expect(employee.name, 'Test User');
  });

  test('two employees with same id should be equal', () {
    final emp1 = EmployeeModel.fromJson(testJson);
    final emp2 = EmployeeModel.fromJson({...testJson, 'name': 'Different'});

    // equality is based on id
    expect(emp1, emp2);
  });

  test('employeeListFromJson should parse list of employees', () {
    final jsonStr = jsonEncode([testJson]);
    final list = employeeListFromJson(jsonStr);

    expect(list.length, 1);
    expect(list[0].name, 'John Doe');
  });
}
