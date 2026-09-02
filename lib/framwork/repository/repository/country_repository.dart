import 'dart:convert';

import '../../providers/networks/dio_helper.dart';
import '../../utils/app_constants.dart';
import '../contract/i_country_repository.dart';
import '../model/country_model/country_model.dart';

class CountryRepository implements ICountryRepository {
  final DioHelper _dioHelper;

  CountryRepository({DioHelper? dioHelper})
      : _dioHelper = dioHelper ?? DioHelper();

  /// Get all countries with their states
  Future<List<CountryModel>> getAllCountries() async {
    final response = await _dioHelper.get(kCountryEndpoint);
    final jsonStr = jsonEncode(response);
    return countryListFromJson(jsonStr);
  }
}
