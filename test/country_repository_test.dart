import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:employee_management_application_flutter_assessment/framework/providers/networks/dio_helper.dart';
import 'package:employee_management_application_flutter_assessment/framework/repository/repository/country_repository.dart';

import 'country_repository_test.mocks.dart';

@GenerateMocks([DioHelper])
void main() {
  late MockDioHelper mockDio;
  late CountryRepository repository;

  // Sample API response — matches the shape the mock API returns.
  // CountryModel.fromJson reads 'country' (not 'name') as the country name.
  final countryData1 = {'id': '1', 'country': 'India'};
  final countryData2 = {'id': '2', 'country': 'USA'};

  setUp(() {
    mockDio = MockDioHelper();
    repository = CountryRepository(dioHelper: mockDio);
  });

  // ── getAllCountries — success ───────────────────────────────────────────────

  test('getAllCountries returns a list of CountryModel on success', () async {
    when(mockDio.get('/country'))
        .thenAnswer((_) async => [countryData1, countryData2]);

    final result = await repository.getAllCountries();

    expect(result.length, 2);
    expect(result[0].name, 'India');
    expect(result[1].name, 'USA');
  });

  test('getAllCountries maps id correctly', () async {
    when(mockDio.get('/country')).thenAnswer((_) async => [countryData1]);

    final result = await repository.getAllCountries();

    expect(result[0].id, '1');
  });

  test('getAllCountries returns empty list when API returns empty array',
      () async {
    when(mockDio.get('/country')).thenAnswer((_) async => []);

    final result = await repository.getAllCountries();

    expect(result, isEmpty);
  });

  // ── getAllCountries — failure ───────────────────────────────────────────────

  test('getAllCountries rethrows exception when DioHelper throws', () async {
    when(mockDio.get('/country')).thenThrow(Exception('Network error'));

    expect(
      () => repository.getAllCountries(),
      throwsA(predicate(
          (e) => e.toString().contains('Network error'))),
    );
  });

  test('getAllCountries rethrows 404 exception from DioHelper', () async {
    when(mockDio.get('/country'))
        .thenThrow(Exception('Resource not found.'));

    expect(
      () => repository.getAllCountries(),
      throwsA(predicate(
          (e) => e.toString().contains('not found'))),
    );
  });
}
