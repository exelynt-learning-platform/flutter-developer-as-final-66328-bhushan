import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:employee_management_application_flutter_assessment/features/employees/domain/entities/country.dart';
import 'package:employee_management_application_flutter_assessment/features/employees/domain/repositories/country_repository.dart';
import 'package:employee_management_application_flutter_assessment/features/employees/presentation/bloc/country_cubit.dart';

class MockCountryRepository extends Mock implements CountryRepository {}

void main() {
  late MockCountryRepository repo;
  late CountryCubit cubit;

  final countries = [
    const Country(id: '1', name: 'India'),
    const Country(id: '2', name: 'USA'),
  ];

  setUp(() {
    repo = MockCountryRepository();
    cubit = CountryCubit(repo);
  });

  tearDown(() => cubit.close());

  test('initial state is CountryInitial', () {
    expect(cubit.state, const CountryInitial());
  });

  blocTest<CountryCubit, CountryState>(
    'emits [CountryLoading, CountryLoaded] on fetchCountries success',
    build: () {
      when(() => repo.getAll()).thenAnswer((_) async => countries);
      return cubit;
    },
    act: (c) => c.fetchCountries(),
    expect: () => [
      const CountryLoading(),
      isA<CountryLoaded>()
          .having((s) => s.countries.length, 'length', 2),
    ],
  );

  blocTest<CountryCubit, CountryState>(
    'emits [CountryLoading, CountryError] on failure',
    build: () {
      when(() => repo.getAll())
          .thenThrow(Exception('Network error'));
      return cubit;
    },
    act: (c) => c.fetchCountries(),
    expect: () => [
      const CountryLoading(),
      isA<CountryError>(),
    ],
  );

  blocTest<CountryCubit, CountryState>(
    'does NOT call API again if already loaded without forceRefresh',
    build: () {
      when(() => repo.getAll()).thenAnswer((_) async => countries);
      return cubit;
    },
    act: (c) async {
      await c.fetchCountries();
      await c.fetchCountries(); // second call — should be no-op
    },
    verify: (_) => verify(() => repo.getAll()).called(1),
  );

  blocTest<CountryCubit, CountryState>(
    'calls API again when forceRefresh is true',
    build: () {
      when(() => repo.getAll()).thenAnswer((_) async => countries);
      return cubit;
    },
    act: (c) async {
      await c.fetchCountries();
      await c.fetchCountries(forceRefresh: true);
    },
    verify: (_) => verify(() => repo.getAll()).called(2),
  );

  test('CountryLoaded.names returns sorted unique names', () {
    final state = CountryLoaded([
      const Country(id: '1', name: 'USA'),
      const Country(id: '2', name: 'India'),
      const Country(id: '3', name: 'USA'), // duplicate
    ]);
    expect(state.names, ['India', 'USA']);
  });
}
