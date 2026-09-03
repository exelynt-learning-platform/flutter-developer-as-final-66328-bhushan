import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/employee.dart';
import '../../domain/usecases/employee_usecases.dart';
import 'employee_state.dart';

class EmployeeCubit extends Cubit<EmployeeState> {
  final GetEmployees _getEmployees;
  final GetEmployeeById _getById;
  final CreateEmployee _createEmployee;
  final UpdateEmployee _updateEmployee;
  final DeleteEmployee _deleteEmployee;

  EmployeeCubit({
    required GetEmployees getEmployees,
    required GetEmployeeById getById,
    required CreateEmployee createEmployee,
    required UpdateEmployee updateEmployee,
    required DeleteEmployee deleteEmployee,
  })  : _getEmployees = getEmployees,
        _getById = getById,
        _createEmployee = createEmployee,
        _updateEmployee = updateEmployee,
        _deleteEmployee = deleteEmployee,
        super(const EmployeeInitial());

  // ── helpers ───────────────────────────────────────────────────────────────

  List<Employee> _currentAll() {
    final s = state;
    if (s is EmployeeLoaded) return s.all;
    if (s is EmployeeCrudLoading) return s.current;
    if (s is EmployeeCrudSuccess) return s.all;
    if (s is EmployeeCrudError) return s.current;
    return [];
  }

  String _currentQuery() {
    final s = state;
    if (s is EmployeeLoaded) return s.searchQuery;
    if (s is EmployeeCrudLoading) return s.searchQuery;
    if (s is EmployeeCrudSuccess) return s.searchQuery;
    if (s is EmployeeCrudError) return s.searchQuery;
    return '';
  }

  String _currentField() {
    final s = state;
    if (s is EmployeeLoaded) return s.filterField;
    if (s is EmployeeCrudLoading) return s.filterField;
    if (s is EmployeeCrudSuccess) return s.filterField;
    if (s is EmployeeCrudError) return s.filterField;
    return 'name';
  }

  List<Employee> _applyFilter(
      List<Employee> list, String query, String field) {
    if (query.isEmpty) return List.from(list);
    final q = query.toLowerCase();
    return list.where((e) {
      switch (field) {
        case 'email':
          return e.email.toLowerCase().contains(q);
        case 'mobile':
          return e.mobile.toLowerCase().contains(q);
        case 'country':
          return e.country.toLowerCase().contains(q);
        case 'id':
          return (e.id ?? '').toLowerCase().contains(q);
        default:
          return e.name.toLowerCase().contains(q);
      }
    }).toList();
  }

  // ── fetch ─────────────────────────────────────────────────────────────────

  Future<void> fetchAll() async {
    final query = _currentQuery();
    final field = _currentField();
    emit(const EmployeeLoading());
    try {
      final list = await _getEmployees();
      emit(EmployeeLoaded(
        all: list,
        filtered: _applyFilter(list, query, field),
        searchQuery: query,
        filterField: field,
      ));
    } catch (e) {
      emit(EmployeeError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> searchById(String id) async {
    emit(const EmployeeLoading());
    try {
      final employee = await _getById(id);
      emit(EmployeeSearchResult(employee));
    } catch (e) {
      emit(EmployeeSearchNotFound(
          e.toString().replaceFirst('Exception: ', '')));
    }
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Future<void> create(Employee employee) async {
    final all = _currentAll();
    final query = _currentQuery();
    final field = _currentField();
    emit(EmployeeCrudLoading(
        current: all,
        filtered: _applyFilter(all, query, field),
        searchQuery: query,
        filterField: field));
    try {
      final created = await _createEmployee(employee);
      final updated = [created, ...all];
      emit(EmployeeCrudSuccess(
        message: 'Employee added successfully!',
        all: updated,
        filtered: _applyFilter(updated, query, field),
        searchQuery: query,
        filterField: field,
      ));
    } catch (e) {
      emit(EmployeeCrudError(
        message: e.toString().replaceFirst('Exception: ', ''),
        current: all,
        filtered: _applyFilter(all, query, field),
        searchQuery: query,
        filterField: field,
      ));
    }
  }

  Future<void> update(Employee employee) async {
    final all = _currentAll();
    final query = _currentQuery();
    final field = _currentField();
    emit(EmployeeCrudLoading(
        current: all,
        filtered: _applyFilter(all, query, field),
        searchQuery: query,
        filterField: field));
    try {
      final updated = await _updateEmployee(employee);
      final newAll = all.map((e) => e.id == updated.id ? updated : e).toList();
      emit(EmployeeCrudSuccess(
        message: 'Employee updated successfully!',
        all: newAll,
        filtered: _applyFilter(newAll, query, field),
        searchQuery: query,
        filterField: field,
      ));
    } catch (e) {
      emit(EmployeeCrudError(
        message: e.toString().replaceFirst('Exception: ', ''),
        current: all,
        filtered: _applyFilter(all, query, field),
        searchQuery: query,
        filterField: field,
      ));
    }
  }

  Future<void> delete(String id) async {
    final all = _currentAll();
    final query = _currentQuery();
    final field = _currentField();
    emit(EmployeeCrudLoading(
        current: all,
        filtered: _applyFilter(all, query, field),
        searchQuery: query,
        filterField: field));
    try {
      await _deleteEmployee(id);
      final newAll = all.where((e) => e.id != id).toList();
      emit(EmployeeCrudSuccess(
        message: 'Employee deleted successfully!',
        all: newAll,
        filtered: _applyFilter(newAll, query, field),
        searchQuery: query,
        filterField: field,
      ));
    } catch (e) {
      emit(EmployeeCrudError(
        message: e.toString().replaceFirst('Exception: ', ''),
        current: all,
        filtered: _applyFilter(all, query, field),
        searchQuery: query,
        filterField: field,
      ));
    }
  }

  // ── search / filter ───────────────────────────────────────────────────────

  void setSearchQuery(String query) {
    final all = _currentAll();
    final field = _currentField();
    emit(EmployeeLoaded(
      all: all,
      filtered: _applyFilter(all, query, field),
      searchQuery: query,
      filterField: field,
    ));
  }

  void setFilterField(String field) {
    final all = _currentAll();
    final query = _currentQuery();
    emit(EmployeeLoaded(
      all: all,
      filtered: _applyFilter(all, query, field),
      searchQuery: query,
      filterField: field,
    ));
  }

  void clearSearch() {
    final all = _currentAll();
    final field = _currentField();
    emit(EmployeeLoaded(
      all: all,
      filtered: List.from(all),
      searchQuery: '',
      filterField: field,
    ));
  }

  void clearSearchState() => emit(const EmployeeInitial());
}
