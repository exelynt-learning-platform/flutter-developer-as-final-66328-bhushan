// Smoke tests — verify core models and enums work in isolation
// (no Firebase or Flutter framework required)

import 'package:flutter_test/flutter_test.dart';

import 'package:employee_management_application_flutter_assessment/features/employees/data/models/employee_model.dart';
import 'package:employee_management_application_flutter_assessment/features/employees/domain/entities/country.dart';
import 'package:employee_management_application_flutter_assessment/features/auth/domain/entities/auth_user.dart';
import 'package:employee_management_application_flutter_assessment/core/errors/app_failure.dart';

void main() {
  group('EmployeeModel smoke', () {
    test('fromJson → toJson round-trips', () {
      final json = {
        'id': '7',
        'name': 'Alice',
        'email': 'alice@example.com',
        'mobile': '9999999999',
        'country': 'India',
        'state': 'MH',
        'district': 'Pune',
      };
      final model = EmployeeModel.fromJson(json);
      expect(EmployeeModel.fromJson(model.toJson()).name, 'Alice');
    });
  });

  group('Country', () {
    test('equality is based on id and name', () {
      const a = Country(id: '1', name: 'India');
      const b = Country(id: '1', name: 'India');
      expect(a, equals(b));
    });
  });

  group('AuthUser', () {
    test('props include uid, email, displayName, photoURL', () {
      const user = AuthUser(
          uid: 'u1', email: 'a@b.com', displayName: 'Alice');
      expect(user.props, ['u1', 'a@b.com', 'Alice', null]);
    });
  });

  group('AppFailure', () {
    test('message is accessible and toString returns it', () {
      const f = AppFailure('Something went wrong');
      expect(f.message, 'Something went wrong');
      expect(f.toString(), 'Something went wrong');
    });

    test('two AppFailures with same message are equal', () {
      const a = AppFailure('err');
      const b = AppFailure('err');
      expect(a, equals(b));
    });
  });
}
