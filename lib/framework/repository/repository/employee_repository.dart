import 'dart:convert';

import '../../providers/networks/dio_helper.dart';
import '../../utils/app_constants.dart';
import '../contract/i_employee_repository.dart';
import '../model/employee_model/employee_model.dart';

class EmployeeRepository implements IEmployeeRepository {
  final DioHelper _dioHelper;

  EmployeeRepository({DioHelper? dioHelper})
      : _dioHelper = dioHelper ?? DioHelper();

  /// Get all employees
  @override
  Future<List<EmployeeModel>> getAllEmployees() async {
    final response = await _dioHelper.get(kEmployeeEndpoint);
    final jsonStr = jsonEncode(response);
    return employeeListFromJson(jsonStr);
  }

  /// Get employee by ID
  @override
  Future<EmployeeModel> getEmployeeById(String id) async {
    final response = await _dioHelper.get('$kEmployeeEndpoint/$id');
    final jsonStr = jsonEncode(response);
    return employeeFromJson(jsonStr);
  }

  /// Create a new employee
  @override
  Future<EmployeeModel> createEmployee(EmployeeModel employee) async {
    final response =
        await _dioHelper.post(kEmployeeEndpoint, employee.toJson());
    final jsonStr = jsonEncode(response);
    return employeeFromJson(jsonStr);
  }

  /// Update an existing employee
  @override
  Future<EmployeeModel> updateEmployee(
      String id, EmployeeModel employee) async {
    final response =
        await _dioHelper.put('$kEmployeeEndpoint/$id', employee.toJson());
    final jsonStr = jsonEncode(response);
    return employeeFromJson(jsonStr);
  }

  /// Delete an employee
  @override
  Future<void> deleteEmployee(String id) async {
    await _dioHelper.delete('$kEmployeeEndpoint/$id');
  }
}
