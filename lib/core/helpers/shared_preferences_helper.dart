import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  final SharedPreferences prefs;

  CacheHelper(this.prefs);

  String? getString(String key) => prefs.getString(key);

  Future<bool> saveData({required String key, required dynamic value}) async {
    if (value is bool) return await prefs.setBool(key, value);
    if (value is String) return await prefs.setString(key, value);
    if (value is int) return await prefs.setInt(key, value);
    if (value is double) return await prefs.setDouble(key, value);
    return false;
  }

  dynamic getData(String key) => prefs.get(key);

  Future<bool> remove(String key) async => prefs.remove(key);

  bool containsKey(String key) => prefs.containsKey(key);

  Future<bool> clear() async => prefs.clear();
}
