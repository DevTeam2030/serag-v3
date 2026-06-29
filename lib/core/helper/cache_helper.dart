import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveData(String key, dynamic value) async {
    if (_prefs == null) await init();
    if (value is String) {
      await _prefs!.setString(key, value);
    } else if (value is int) {
      await _prefs!.setInt(key, value);
    } else if (value is bool) {
      await _prefs!.setBool(key, value);
    } else if (value is double) {
      await _prefs!.setDouble(key, value);
    } else if (value is Map || value is List) {
      await _prefs!.setString(key, jsonEncode(value));
    }
  }

  static dynamic getData(String key) {
    return _prefs?.get(key);
  }

  static Future<void> removeData(String key) async {
    await _prefs?.remove(key);
  }

  static Future<void> saveToken(String token) async {
    await _prefs?.setString('access_token', token);
  }

  static String? getToken() {
    return _prefs?.getString('access_token');
  }

  static Future<void> removeToken() async {
    await _prefs?.remove('access_token');
  }

  static Future<void> clearData() async {
    await _prefs?.clear();

  }



}
