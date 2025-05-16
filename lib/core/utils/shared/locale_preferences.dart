import 'package:shared_preferences/shared_preferences.dart';

class LocalePreferences {
  static const _key = 'locale';

  static Future<void> saveLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, languageCode);
  }

  static Future<String?> getSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }
}
