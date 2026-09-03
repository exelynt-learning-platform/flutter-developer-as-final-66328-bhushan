import '../entities/country.dart';

abstract class CountryRepository {
  Future<List<Country>> getAll();
}
