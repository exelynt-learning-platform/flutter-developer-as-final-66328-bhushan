import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:employee_management_application_flutter_assessment/framework/data/status_enum.dart';
import 'package:employee_management_application_flutter_assessment/framework/providers/provider/country_provider.dart';
import 'package:employee_management_application_flutter_assessment/framework/repository/contract/i_country_repository.dart';
import 'package:employee_management_application_flutter_assessment/framework/repository/model/country_model/country_model.dart';

import 'country_provider_test.mocks.dart';

@GenerateMocks([ICountryRepository])
void main() {
  late MockICountryRepository mockRepo;
  late CountryNotifier notifier;

  final india = CountryModel(id: '1', name: 'India');
  final usa = CountryModel(id: '2', name: 'USA');

  setUp(() {
    mockRepo = MockICountryRepository();
    notifier = CountryNotifier(repository: mockRepo);
  });

  // ── Initial state ─────────────────────────────────────────────────────────

  test('initial status is StatusEnum.initial', () {
    expect(notifier.status, StatusEnum.initial);
    expect(notifier.countries, isEmpty);
    expect(notifier.countryNames, isEmpty);
    expect(notifier.isLoading, isFalse);
    expect(notifier.errorMessage, isNull);
  });

  // ── fetchCountries — success ──────────────────────────────────────────────

  test('fetchCountries sets status to success and populates countries',
      () async {
    when(mockRepo.getAllCountries()).thenAnswer((_) async => [india, usa]);

    await notifier.fetchCountries();

    expect(notifier.status, StatusEnum.success);
    expect(notifier.countries.length, 2);
    expect(notifier.isLoading, isFalse);
    expect(notifier.errorMessage, isNull);
  });

  test('countryNames returns sorted unique names after fetch', () async {
    when(mockRepo.getAllCountries()).thenAnswer((_) async => [usa, india]);

    await notifier.fetchCountries();

    // Should be sorted alphabetically
    expect(notifier.countryNames, ['India', 'USA']);
  });

  test('fetchCountries deduplicates country names', () async {
    final indiaB = CountryModel(id: '3', name: 'India'); // duplicate name
    when(mockRepo.getAllCountries())
        .thenAnswer((_) async => [india, indiaB, usa]);

    await notifier.fetchCountries();

    expect(notifier.countryNames, ['India', 'USA']);
  });

  // ── fetchCountries — failure ──────────────────────────────────────────────

  test('fetchCountries sets status to error and stores message on failure',
      () async {
    when(mockRepo.getAllCountries())
        .thenThrow(Exception('Network error'));

    await notifier.fetchCountries();

    expect(notifier.status, StatusEnum.error);
    expect(notifier.errorMessage, contains('Network error'));
    expect(notifier.countries, isEmpty);
  });

  // ── In-memory cache / forceRefresh ────────────────────────────────────────

  test('fetchCountries does NOT call API again when data is already loaded',
      () async {
    when(mockRepo.getAllCountries()).thenAnswer((_) async => [india]);

    await notifier.fetchCountries(); // first call loads data
    await notifier.fetchCountries(); // second call should be a no-op

    // getAllCountries should have been called only once
    verify(mockRepo.getAllCountries()).called(1);
  });

  test('fetchCountries calls API again when forceRefresh is true', () async {
    when(mockRepo.getAllCountries()).thenAnswer((_) async => [india]);

    await notifier.fetchCountries();
    await notifier.fetchCountries(forceRefresh: true);

    verify(mockRepo.getAllCountries()).called(2);
  });

  test('forceRefresh replaces stale data with fresh data', () async {
    when(mockRepo.getAllCountries())
        .thenAnswer((_) async => [india]); // first response
    await notifier.fetchCountries();
    expect(notifier.countries.length, 1);

    when(mockRepo.getAllCountries())
        .thenAnswer((_) async => [india, usa]); // refreshed response
    await notifier.fetchCountries(forceRefresh: true);

    expect(notifier.countries.length, 2);
  });

  // ── selectCountry / reset ─────────────────────────────────────────────────

  test('selectCountry stores the selected country name', () {
    notifier.selectCountry('India');
    expect(notifier.selectedCountry, 'India');
  });

  test('reset clears selectedCountry', () {
    notifier.selectCountry('USA');
    notifier.reset();
    expect(notifier.selectedCountry, isNull);
  });
}
