import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  // 保存数据到 Shared Preferences
  static saveData(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  // 从 Shared Preferences 加载数据
  static Future<String?> loadData(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String value = prefs.getString(key) ?? '';
    return value;
  }
}
