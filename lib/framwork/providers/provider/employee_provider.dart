import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/status_enum.dart';
import '../../providers/local/preferences_helper.dart';
import '../../repository/model/employee_model/employee_model.dart';
import '../../repository/repository/employee_repository.dart';

final employeeProvider = ChangeNotifierProvider<EmployeeNotifier>((ref) {
  return EmployeeNotifier();
});

class EmployeeNotifier extends ChangeNotifier {
  final EmployeeRepository _repository;
  final bool skipCacheForTesting;

  EmployeeNotifier({
    EmployeeRepository? repository,
    this.skipCacheForTesting = false,
  }) : _repository = repository ?? EmployeeRepository();

  // ── State ────────────────────────────────────────────────────────────────

  StatusEnum _status = StatusEnum.initial;
  StatusEnum _crudStatus = StatusEnum.initial;
  String? _errorMessage;
  String? _crudErrorMessage;
  String? _crudSuccessMessage;

  List<EmployeeModel> _employees = [];
  List<EmployeeModel> _filteredEmployees = [];
  EmployeeModel? _selectedEmployee;

  String _searchQuery = '';
  String _filterField = 'name'; // name | email | mobile | country

  // ── Getters ───────────────────────────────────────────────────────────────

  StatusEnum get status => _status;
  StatusEnum get crudStatus => _crudStatus;
  String? get errorMessage => _errorMessage;
  String? get crudErrorMessage => _crudErrorMessage;
  String? get crudSuccessMessage => _crudSuccessMessage;
  bool get isLoading => _status == StatusEnum.loading;
  bool get isCrudLoading => _crudStatus == StatusEnum.loading;
  List<EmployeeModel> get employees => _filteredEmployees;
  EmployeeModel? get selectedEmployee => _selectedEmployee;
  String get searchQuery => _searchQuery;
  String get filterField => _filterField;

  // ── Fetch ─────────────────────────────────────────────────────────────────

  Future<void> fetchAllEmployees({bool fromCache = false}) async {
    _status = StatusEnum.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Try loading from cache first if offline
      if (fromCache) {
        final cached = PreferencesHelper.cachedEmployees;
        if (cached != null) {
          _employees = employeeListFromJson(cached);
          _applyFilter();
          _status = StatusEnum.success;
          notifyListeners();
          return;
        }
      }

      _employees = await _repository.getAllEmployees();
      _applyFilter();

      // Cache the fresh data (skip in test mode)
      if (!skipCacheForTesting) {
        await PreferencesHelper.cacheEmployees(employeeListToJson(_employees));
        await PreferencesHelper.setLastSync(DateTime.now().toIso8601String());
      }

      _status = StatusEnum.success;
    } catch (e) {
      // Fallback to cached data (skip in test mode)
      final cached =
          skipCacheForTesting ? null : PreferencesHelper.cachedEmployees;
      if (cached != null) {
        _employees = employeeListFromJson(cached);
        _applyFilter();
        _status = StatusEnum.success;
        _errorMessage = 'Showing cached data. ${e.toString().replaceFirst("Exception: ", "")}';
      } else {
        _status = StatusEnum.error;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      }
    }
    notifyListeners();
  }

  Future<void> fetchEmployeeById(String id) async {
    _crudStatus = StatusEnum.loading;
    _crudErrorMessage = null;
    notifyListeners();

    try {
      _selectedEmployee = await _repository.getEmployeeById(id);
      _crudStatus = StatusEnum.success;
    } catch (e) {
      _crudStatus = StatusEnum.error;
      _crudErrorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }

  // ── Create ────────────────────────────────────────────────────────────────

  Future<bool> createEmployee(EmployeeModel employee) async {
    _crudStatus = StatusEnum.loading;
    _crudErrorMessage = null;
    _crudSuccessMessage = null;
    notifyListeners();

    try {
      final created = await _repository.createEmployee(employee);
      _employees.insert(0, created);
      _applyFilter();
      await _updateCache();

      _crudStatus = StatusEnum.success;
      _crudSuccessMessage = 'Employee added successfully!';
      notifyListeners();
      return true;
    } catch (e) {
      _crudStatus = StatusEnum.error;
      _crudErrorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ── Update ────────────────────────────────────────────────────────────────

  Future<bool> updateEmployee(String id, EmployeeModel employee) async {
    _crudStatus = StatusEnum.loading;
    _crudErrorMessage = null;
    _crudSuccessMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.updateEmployee(id, employee);
      final index = _employees.indexWhere((e) => e.id == id);
      if (index != -1) _employees[index] = updated;
      _applyFilter();
      await _updateCache();

      _crudStatus = StatusEnum.success;
      _crudSuccessMessage = 'Employee updated successfully!';
      notifyListeners();
      return true;
    } catch (e) {
      _crudStatus = StatusEnum.error;
      _crudErrorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<bool> deleteEmployee(String id) async {
    _crudStatus = StatusEnum.loading;
    _crudErrorMessage = null;
    _crudSuccessMessage = null;
    notifyListeners();

    try {
      await _repository.deleteEmployee(id);
      _employees.removeWhere((e) => e.id == id);
      _applyFilter();
      await _updateCache();

      _crudStatus = StatusEnum.success;
      _crudSuccessMessage = 'Employee deleted successfully!';
      notifyListeners();
      return true;
    } catch (e) {
      _crudStatus = StatusEnum.error;
      _crudErrorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ── Search & Filter ───────────────────────────────────────────────────────

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void setFilterField(String field) {
    _filterField = field;
    _applyFilter();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredEmployees = List.from(_employees);
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredEmployees = List.from(_employees);
      return;
    }

    final query = _searchQuery.toLowerCase();
    _filteredEmployees = _employees.where((e) {
      switch (_filterField) {
        case 'email':
          return e.email.toLowerCase().contains(query);
        case 'mobile':
          return e.mobile.toLowerCase().contains(query);
        case 'country':
          return e.country.toLowerCase().contains(query);
        case 'id':
          return (e.id ?? '').toLowerCase().contains(query);
        default:
          return e.name.toLowerCase().contains(query);
      }
    }).toList();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void setSelectedEmployee(EmployeeModel? employee) {
    _selectedEmployee = employee;
    notifyListeners();
  }

  void clearCrudStatus() {
    _crudStatus = StatusEnum.initial;
    _crudErrorMessage = null;
    _crudSuccessMessage = null;
    notifyListeners();
  }

  Future<void> _updateCache() async {
    if (skipCacheForTesting) return;
    try {
      await PreferencesHelper.cacheEmployees(employeeListToJson(_employees));
    } catch (_) {}
  }
}
