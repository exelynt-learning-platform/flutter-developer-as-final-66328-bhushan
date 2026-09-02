import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/status_enum.dart';
import '../../repository/model/country_model/country_model.dart';
import '../../repository/repository/country_repository.dart';

final countryProvider = ChangeNotifierProvider<CountryNotifier>((ref) {
  return CountryNotifier();
});

class CountryNotifier extends ChangeNotifier {
  final CountryRepository _repository;

  CountryNotifier({CountryRepository? repository})
      : _repository = repository ?? CountryRepository();

  StatusEnum _status = StatusEnum.initial;
  String? _errorMessage;
  List<CountryModel> _countries = [];
  String? _selectedCountry;

  StatusEnum get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == StatusEnum.loading;
  List<CountryModel> get countries => _countries;
  String? get selectedCountry => _selectedCountry;

  /// All country names for use in dropdowns
  List<String> get countryNames =>
      _countries.map((c) => c.name).toSet().toList()..sort();

  Future<void> fetchCountries({bool forceRefresh = false}) async {
    if (_countries.isNotEmpty && !forceRefresh) return;

    _status = StatusEnum.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _countries = await _repository.getAllCountries();
      _status = StatusEnum.success;
    } catch (e) {
      _status = StatusEnum.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }

  void selectCountry(String countryName) {
    _selectedCountry = countryName;
    notifyListeners();
  }

  void reset() {
    _selectedCountry = null;
    notifyListeners();
  }
}
