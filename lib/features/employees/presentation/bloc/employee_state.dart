import 'package:equatable/equatable.dart';
import '../../domain/entities/employee.dart';

abstract class EmployeeState extends Equatable {
  const EmployeeState();
  @override
  List<Object?> get props => [];
}

class EmployeeInitial extends EmployeeState {
  const EmployeeInitial();
}

class EmployeeLoading extends EmployeeState {
  const EmployeeLoading();
}

class EmployeeLoaded extends EmployeeState {
  final List<Employee> all;
  final List<Employee> filtered;
  final String searchQuery;
  final String filterField;
  final String? warningMessage;

  const EmployeeLoaded({
    required this.all,
    required this.filtered,
    this.searchQuery = '',
    this.filterField = 'name',
    this.warningMessage,
  });

  EmployeeLoaded copyWith({
    List<Employee>? all,
    List<Employee>? filtered,
    String? searchQuery,
    String? filterField,
    String? warningMessage,
    bool clearWarning = false,
  }) =>
      EmployeeLoaded(
        all: all ?? this.all,
        filtered: filtered ?? this.filtered,
        searchQuery: searchQuery ?? this.searchQuery,
        filterField: filterField ?? this.filterField,
        warningMessage:
            clearWarning ? null : (warningMessage ?? this.warningMessage),
      );

  @override
  List<Object?> get props =>
      [all, filtered, searchQuery, filterField, warningMessage];
}

class EmployeeError extends EmployeeState {
  final String message;
  const EmployeeError(this.message);
  @override
  List<Object?> get props => [message];
}

class EmployeeCrudLoading extends EmployeeState {
  final List<Employee> current;
  final List<Employee> filtered;
  final String searchQuery;
  final String filterField;
  const EmployeeCrudLoading({
    required this.current,
    required this.filtered,
    required this.searchQuery,
    required this.filterField,
  });
  @override
  List<Object?> get props => [current, filtered];
}

class EmployeeCrudSuccess extends EmployeeState {
  final String message;
  final List<Employee> all;
  final List<Employee> filtered;
  final String searchQuery;
  final String filterField;
  final Employee? selected;

  const EmployeeCrudSuccess({
    required this.message,
    required this.all,
    required this.filtered,
    this.searchQuery = '',
    this.filterField = 'name',
    this.selected,
  });

  @override
  List<Object?> get props =>
      [message, all, filtered, searchQuery, filterField, selected];
}

class EmployeeCrudError extends EmployeeState {
  final String message;
  final List<Employee> current;
  final List<Employee> filtered;
  final String searchQuery;
  final String filterField;
  const EmployeeCrudError({
    required this.message,
    required this.current,
    required this.filtered,
    required this.searchQuery,
    required this.filterField,
  });
  @override
  List<Object?> get props => [message, current];
}

class EmployeeSearchResult extends EmployeeState {
  final Employee employee;
  const EmployeeSearchResult(this.employee);
  @override
  List<Object?> get props => [employee];
}

class EmployeeSearchNotFound extends EmployeeState {
  final String message;
  const EmployeeSearchNotFound(this.message);
  @override
  List<Object?> get props => [message];
}
