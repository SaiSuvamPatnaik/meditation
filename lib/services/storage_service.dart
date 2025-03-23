import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  /// ✅ Save login status
  static Future<void> setLoginStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", status);
  }

  /// ✅ Get login status
  static Future<bool> getLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isLoggedIn") ?? false;
  }

  /// ✅ Clear all login data (for logout)
  static Future<void> clearLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
