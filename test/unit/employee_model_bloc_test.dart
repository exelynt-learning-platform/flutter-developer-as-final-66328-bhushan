import 'package:flutter_test/flutter_test.dart';
import 'package:employee_management_application_flutter_assessment/features/employees/data/models/employee_model.dart';
import 'package:employee_management_application_flutter_assessment/features/employees/domain/entities/employee.dart';

void main() {
  const tJson = {
    'id': '1',
    'name': 'Alice',
    'email': 'alice@example.com',
    'mobile': '9876543210',
    'country': 'India',
    'state': 'MH',
    'district': 'Pune',
    'createdAt': '2024-01-01T00:00:00.000Z',
  };

  group('EmployeeModel', () {
    test('fromJson parses all fields correctly', () {
      final model = EmployeeModel.fromJson(tJson);
      expect(model.id, '1');
      expect(model.name, 'Alice');
      expect(model.email, 'alice@example.com');
      expect(model.mobile, '9876543210');
      expect(model.country, 'India');
      expect(model.state, 'MH');
      expect(model.district, 'Pune');
    });

    test('fromJson accepts phone key as mobile', () {
      final model = EmployeeModel.fromJson({...tJson, 'phone': '1111'});
      // mobile key takes priority
      expect(model.mobile, '9876543210');
    });

    test('fromJson uses phone when mobile is absent', () {
      final noMobile = Map<String, dynamic>.from(tJson)
        ..remove('mobile')
        ..['phone'] = '0000000000';
      final model = EmployeeModel.fromJson(noMobile);
      expect(model.mobile, '0000000000');
    });

    test('toJson round-trips correctly', () {
      final model = EmployeeModel.fromJson(tJson);
      final json = model.toJson();
      final restored = EmployeeModel.fromJson(json);
      expect(restored.name, model.name);
      expect(restored.email, model.email);
    });

    test('fromEntity maps Employee domain object to EmployeeModel', () {
      const entity = Employee(
        id: '5',
        name: 'Bob',
        email: 'bob@test.com',
        mobile: '1234567890',
        country: 'USA',
        state: 'CA',
        district: 'LA',
      );
      final model = EmployeeModel.fromEntity(entity);
      expect(model.id, '5');
      expect(model.name, 'Bob');
      expect(model.country, 'USA');
    });

    test('Employee copyWith updates specified fields only', () {
      const original = Employee(
        id: '1',
        name: 'Alice',
        email: 'a@b.com',
        mobile: '0',
        country: 'India',
        state: 'MH',
        district: 'Pune',
      );
      final copy = original.copyWith(name: 'Alice Updated');
      expect(copy.name, 'Alice Updated');
      expect(copy.email, original.email);
    });

    test('Employee equality is based on all props', () {
      const a = Employee(
          id: '1', name: 'A', email: 'a@b.com',
          mobile: '0', country: 'X', state: 'Y', district: 'Z');
      const b = Employee(
          id: '1', name: 'A', email: 'a@b.com',
          mobile: '0', country: 'X', state: 'Y', district: 'Z');
      expect(a, equals(b));
    });
  });
}
