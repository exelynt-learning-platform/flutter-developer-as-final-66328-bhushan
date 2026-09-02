import '../entities/employee.dart';
import '../repositories/employee_repository.dart';

class GetEmployees {
  final EmployeeRepository _repo;
  const GetEmployees(this._repo);
  Future<List<Employee>> call() => _repo.getAll();
}

class GetEmployeeById {
  final EmployeeRepository _repo;
  const GetEmployeeById(this._repo);
  Future<Employee> call(String id) => _repo.getById(id);
}

class CreateEmployee {
  final EmployeeRepository _repo;
  const CreateEmployee(this._repo);
  Future<Employee> call(Employee employee) => _repo.create(employee);
}

class UpdateEmployee {
  final EmployeeRepository _repo;
  const UpdateEmployee(this._repo);
  Future<Employee> call(Employee employee) => _repo.update(employee);
}

class DeleteEmployee {
  final EmployeeRepository _repo;
  const DeleteEmployee(this._repo);
  Future<void> call(String id) => _repo.delete(id);
}
