import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/country.dart';
import '../../domain/repositories/country_repository.dart';

// ── States ────────────────────────────────────────────────────────────────────

abstract class CountryState extends Equatable {
  const CountryState();
  @override
  List<Object?> get props => [];
}

class CountryInitial extends CountryState {
  const CountryInitial();
}

class CountryLoading extends CountryState {
  const CountryLoading();
}

class CountryLoaded extends CountryState {
  final List<Country> countries;
  const CountryLoaded(this.countries);

  List<String> get names =>
      countries.map((c) => c.name).toSet().toList()..sort();

  @override
  List<Object?> get props => [countries];
}

class CountryError extends CountryState {
  final String message;
  const CountryError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class CountryCubit extends Cubit<CountryState> {
  final CountryRepository _repo;
  CountryCubit(this._repo) : super(const CountryInitial());

  Future<void> fetchCountries({bool forceRefresh = false}) async {
    if (state is CountryLoaded && !forceRefresh) return;
    emit(const CountryLoading());
    try {
      final list = await _repo.getAll();
      emit(CountryLoaded(list));
    } catch (e) {
      emit(CountryError(
          e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
