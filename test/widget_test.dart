// Smoke test verifying core models and enums are importable and function
// correctly in isolation — no Flutter framework or Firebase required.

import 'package:flutter_test/flutter_test.dart';

import 'package:employee_management_application_flutter_assessment/framework/data/status_enum.dart';
import 'package:employee_management_application_flutter_assessment/framework/repository/model/employee_model/employee_model.dart';
import 'package:employee_management_application_flutter_assessment/framework/repository/model/country_model/country_model.dart';

void main() {
  group('StatusEnum', () {
    test('has four values', () {
      expect(StatusEnum.values.length, 4);
    });

    test('initial is not loading or error', () {
      const s = StatusEnum.initial;
      expect(s == StatusEnum.loading, isFalse);
      expect(s == StatusEnum.error, isFalse);
    });
  });

  group('EmployeeModel', () {
    test('fromJson parses all fields correctly', () {
      final json = {
        'id': '7',
        'name': 'Alice',
        'email': 'alice@example.com',
        'mobile': '9999999999',
        'country': 'India',
        'state': 'MH',
        'district': 'Pune',
        'createdAt': '2024-01-01T00:00:00.000Z',
      };
      final model = EmployeeModel.fromJson(json);
      expect(model.id, '7');
      expect(model.name, 'Alice');
      expect(model.email, 'alice@example.com');
      expect(model.country, 'India');
    });

    test('toJson round-trips correctly', () {
      final model = EmployeeModel(
        id: '1',
        name: 'Bob',
        email: 'bob@example.com',
        mobile: '1234567890',
        country: 'USA',
        state: 'CA',
        district: 'LA',
      );
      final json = model.toJson();
      final restored = EmployeeModel.fromJson(json);
      expect(restored.name, model.name);
      expect(restored.email, model.email);
    });

    test('equality is based on id', () {
      final a = EmployeeModel(
          id: '5', name: 'A', email: 'a@b.com',
          mobile: '0', country: 'X', state: 'Y', district: 'Z');
      final b = EmployeeModel(
          id: '5', name: 'B', email: 'b@c.com',
          mobile: '1', country: 'X', state: 'Y', district: 'Z');
      expect(a, equals(b));
    });

    test('copyWith updates specified fields only', () {
      final original = EmployeeModel(
          id: '1', name: 'Alice', email: 'alice@x.com',
          mobile: '0', country: 'India', state: 'MH', district: 'Pune');
      final copy = original.copyWith(name: 'Bob');
      expect(copy.name, 'Bob');
      expect(copy.email, original.email);
    });
  });

  group('CountryModel', () {
    test('fromJson reads country key as name', () {
      final json = {'id': '1', 'country': 'Germany'};
      final model = CountryModel.fromJson(json);
      expect(model.name, 'Germany');
      expect(model.id, '1');
    });

    test('fromJson falls back to name key when country key absent', () {
      final json = {'id': '2', 'name': 'France'};
      final model = CountryModel.fromJson(json);
      expect(model.name, 'France');
    });
  });
}
