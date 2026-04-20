import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static Future<SharedPreferences> get _prefs =>
      SharedPreferences.getInstance();

  static Future<void> saveDouble(String key, double value) async =>
      (await _prefs).setDouble(key, value);

  static Future<double?> getDouble(String key) async =>
      (await _prefs).getDouble(key);

  static Future<void> saveString(String key, String value) async =>
      (await _prefs).setString(key, value);

  static Future<String?> getString(String key) async =>
      (await _prefs).getString(key);

  static Future<void> remove(String key) async =>
      (await _prefs).remove(key);
}
