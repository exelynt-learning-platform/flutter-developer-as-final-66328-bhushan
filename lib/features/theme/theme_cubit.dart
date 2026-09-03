import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final dark = prefs.getBool(kThemeModeKey) ?? false;
    emit(dark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> toggleTheme() async {
    final next =
        state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    emit(next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kThemeModeKey, next == ThemeMode.dark);
  }

  bool get isDarkMode => state == ThemeMode.dark;
}
