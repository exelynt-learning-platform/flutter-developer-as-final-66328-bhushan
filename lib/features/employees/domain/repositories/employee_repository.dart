import '../entities/employee.dart';

abstract class EmployeeRepository {
  Future<List<Employee>> getAll();
  Future<Employee> getById(String id);
  Future<Employee> create(Employee employee);
  Future<Employee> update(Employee employee);
  Future<void> delete(String id);
}
