import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:employee_management_application_flutter_assessment/features/employees/domain/entities/employee.dart';
import 'package:employee_management_application_flutter_assessment/features/employees/domain/repositories/employee_repository.dart';
import 'package:employee_management_application_flutter_assessment/features/employees/domain/usecases/employee_usecases.dart';
import 'package:employee_management_application_flutter_assessment/features/employees/presentation/bloc/employee_cubit.dart';
import 'package:employee_management_application_flutter_assessment/features/employees/presentation/bloc/employee_state.dart';

class MockEmployeeRepository extends Mock implements EmployeeRepository {}

// Needed for mocktail when passing Employee as any()
class FakeEmployee extends Fake implements Employee {}

void main() {
  late MockEmployeeRepository repo;
  late EmployeeCubit cubit;

  final emp1 = const Employee(
    id: '1',
    name: 'Alice',
    email: 'alice@example.com',
    mobile: '1111111111',
    country: 'India',
    state: 'MH',
    district: 'Pune',
  );

  final emp2 = const Employee(
    id: '2',
    name: 'Bob',
    email: 'bob@example.com',
    mobile: '2222222222',
    country: 'USA',
    state: 'CA',
    district: 'LA',
  );

  setUpAll(() => registerFallbackValue(FakeEmployee()));

  setUp(() {
    repo = MockEmployeeRepository();
    cubit = EmployeeCubit(
      getEmployees: GetEmployees(repo),
      getById: GetEmployeeById(repo),
      createEmployee: CreateEmployee(repo),
      updateEmployee: UpdateEmployee(repo),
      deleteEmployee: DeleteEmployee(repo),
    );
  });

  tearDown(() => cubit.close());

  // ── initial state ──────────────────────────────────────────────────────────

  test('initial state is EmployeeInitial', () {
    expect(cubit.state, const EmployeeInitial());
  });

  // ── fetchAll ───────────────────────────────────────────────────────────────

  blocTest<EmployeeCubit, EmployeeState>(
    'emits [EmployeeLoading, EmployeeLoaded] on fetchAll success',
    build: () {
      when(() => repo.getAll()).thenAnswer((_) async => [emp1, emp2]);
      return cubit;
    },
    act: (c) => c.fetchAll(),
    expect: () => [
      const EmployeeLoading(),
      isA<EmployeeLoaded>()
          .having((s) => s.all.length, 'all.length', 2)
          .having((s) => s.filtered.length, 'filtered.length', 2),
    ],
  );

  blocTest<EmployeeCubit, EmployeeState>(
    'emits [EmployeeLoading, EmployeeError] on fetchAll failure',
    build: () {
      when(() => repo.getAll()).thenThrow(Exception('Network error'));
      return cubit;
    },
    act: (c) => c.fetchAll(),
    expect: () => [
      const EmployeeLoading(),
      isA<EmployeeError>()
          .having((s) => s.message, 'message', contains('Network error')),
    ],
  );

  // ── search / filter ────────────────────────────────────────────────────────

  blocTest<EmployeeCubit, EmployeeState>(
    'setSearchQuery filters employees by name',
    build: () {
      when(() => repo.getAll()).thenAnswer((_) async => [emp1, emp2]);
      return cubit;
    },
    act: (c) async {
      await c.fetchAll();
      c.setSearchQuery('alice');
    },
    skip: 2, // skip loading + initial loaded
    expect: () => [
      isA<EmployeeLoaded>()
          .having((s) => s.filtered.length, 'filtered.length', 1)
          .having((s) => s.filtered.first.name, 'name', 'Alice'),
    ],
  );

  blocTest<EmployeeCubit, EmployeeState>(
    'setFilterField changes filter field',
    build: () {
      when(() => repo.getAll()).thenAnswer((_) async => [emp1, emp2]);
      return cubit;
    },
    act: (c) async {
      await c.fetchAll();
      c.setFilterField('email');
      c.setSearchQuery('bob');
    },
    skip: 2,
    expect: () => [
      isA<EmployeeLoaded>()
          .having((s) => s.filterField, 'filterField', 'email'),
      isA<EmployeeLoaded>()
          .having((s) => s.filtered.length, 'filtered.length', 1),
    ],
  );

  blocTest<EmployeeCubit, EmployeeState>(
    'clearSearch restores all employees',
    build: () {
      when(() => repo.getAll()).thenAnswer((_) async => [emp1, emp2]);
      return cubit;
    },
    act: (c) async {
      await c.fetchAll();
      c.setSearchQuery('alice');
      c.clearSearch();
    },
    skip: 3,
    expect: () => [
      isA<EmployeeLoaded>()
          .having((s) => s.filtered.length, 'filtered.length', 2)
          .having((s) => s.searchQuery, 'searchQuery', ''),
    ],
  );

  // ── create ─────────────────────────────────────────────────────────────────

  blocTest<EmployeeCubit, EmployeeState>(
    'create adds employee and emits EmployeeCrudSuccess',
    build: () {
      when(() => repo.getAll()).thenAnswer((_) async => [emp1]);
      when(() => repo.create(any())).thenAnswer((_) async => emp2);
      return cubit;
    },
    act: (c) async {
      await c.fetchAll();
      await c.create(emp2);
    },
    skip: 2,
    expect: () => [
      isA<EmployeeCrudLoading>(),
      isA<EmployeeCrudSuccess>()
          .having((s) => s.all.length, 'all.length', 2)
          .having((s) => s.message, 'message',
              'Employee added successfully!'),
    ],
  );

  // ── delete ─────────────────────────────────────────────────────────────────

  blocTest<EmployeeCubit, EmployeeState>(
    'delete removes employee and emits EmployeeCrudSuccess',
    build: () {
      when(() => repo.getAll()).thenAnswer((_) async => [emp1, emp2]);
      when(() => repo.delete(any())).thenAnswer((_) async {});
      return cubit;
    },
    act: (c) async {
      await c.fetchAll();
      await c.delete('1');
    },
    skip: 2,
    expect: () => [
      isA<EmployeeCrudLoading>(),
      isA<EmployeeCrudSuccess>()
          .having((s) => s.all.length, 'all.length', 1)
          .having((s) => s.all.first.id, 'remaining id', '2'),
    ],
  );

  blocTest<EmployeeCubit, EmployeeState>(
    'delete emits EmployeeCrudError on failure',
    build: () {
      when(() => repo.getAll()).thenAnswer((_) async => [emp1]);
      when(() => repo.delete(any()))
          .thenThrow(Exception('Server error'));
      return cubit;
    },
    act: (c) async {
      await c.fetchAll();
      await c.delete('1');
    },
    skip: 2,
    expect: () => [
      isA<EmployeeCrudLoading>(),
      isA<EmployeeCrudError>()
          .having((s) => s.message, 'message', contains('Server error')),
    ],
  );

  // ── update ─────────────────────────────────────────────────────────────────

  blocTest<EmployeeCubit, EmployeeState>(
    'update replaces employee in list on success',
    build: () {
      final updated = emp1.copyWith(name: 'Alice Updated');
      when(() => repo.getAll()).thenAnswer((_) async => [emp1, emp2]);
      when(() => repo.update(any())).thenAnswer((_) async => updated);
      return cubit;
    },
    act: (c) async {
      await c.fetchAll();
      await c.update(emp1.copyWith(name: 'Alice Updated'));
    },
    skip: 2,
    expect: () => [
      isA<EmployeeCrudLoading>(),
      isA<EmployeeCrudSuccess>().having(
        (s) => s.all.firstWhere((e) => e.id == '1').name,
        'updated name',
        'Alice Updated',
      ),
    ],
  );
}
