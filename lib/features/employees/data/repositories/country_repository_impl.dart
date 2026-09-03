import '../../domain/entities/country.dart';
import '../../domain/repositories/country_repository.dart';
import '../datasources/country_remote_data_source.dart';

class CountryRepositoryImpl implements CountryRepository {
  final CountryRemoteDataSource _remote;
  CountryRepositoryImpl(this._remote);

  @override
  Future<List<Country>> getAll() => _remote.getAll();
}
