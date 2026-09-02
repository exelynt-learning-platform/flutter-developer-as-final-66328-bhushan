import '../model/country_model/country_model.dart';

/// Abstract contract for country lookup operations.
/// Concrete: [CountryRepository]. Mocked in tests.
abstract class ICountryRepository {
  Future<List<CountryModel>> getAllCountries();
}
