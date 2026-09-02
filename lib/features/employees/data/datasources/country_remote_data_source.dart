import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/country_model.dart';

class CountryRemoteDataSource {
  final DioClient _client;
  const CountryRemoteDataSource(this._client);

  Future<List<CountryModel>> getAll() async {
    final response = await _client.get(kCountryEndpoint);
    return (response as List)
        .map((e) => CountryModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
