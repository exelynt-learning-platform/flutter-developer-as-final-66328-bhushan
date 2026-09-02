import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_constants.dart';

class PreferencesHelper {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Only call this in tests to fully reset the singleton.
  static void resetForTesting() {
    _prefs = null;
  }

  static SharedPreferences get prefs {
    if (_prefs == null) throw Exception('PreferencesHelper not initialized.');
    return _prefs!;
  }

  // ── Theme ────────────────────────────────────────────────────────────────

  static bool get isDarkMode => prefs.getBool(kThemeModeKey) ?? false;

  static Future<void> setDarkMode(bool value) =>
      prefs.setBool(kThemeModeKey, value);

  // ── Cached Employees ─────────────────────────────────────────────────────

  static String? get cachedEmployees => prefs.getString(kCachedEmployeesKey);

  static Future<void> cacheEmployees(String json) =>
      prefs.setString(kCachedEmployeesKey, json);

  static Future<void> clearCachedEmployees() =>
      prefs.remove(kCachedEmployeesKey);

  // ── Last Sync ─────────────────────────────────────────────────────────────

  static String? get lastSync => prefs.getString(kLastSyncKey);

  static Future<void> setLastSync(String dateTime) =>
      prefs.setString(kLastSyncKey, dateTime);
}
