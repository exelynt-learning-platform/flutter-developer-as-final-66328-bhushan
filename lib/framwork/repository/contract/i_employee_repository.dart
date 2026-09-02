import '../model/employee_model/employee_model.dart';

/// Abstract contract for employee CRUD operations.
/// Concrete: [EmployeeRepository]. Mocked in tests.
abstract class IEmployeeRepository {
  Future<List<EmployeeModel>> getAllEmployees();
  Future<EmployeeModel> getEmployeeById(String id);
  Future<EmployeeModel> createEmployee(EmployeeModel employee);
  Future<EmployeeModel> updateEmployee(String id, EmployeeModel employee);
  Future<void> deleteEmployee(String id);
}
