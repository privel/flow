import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

//   // Убери вызов loadTheme() из конструктора
//   Future<void> loadTheme() async {
//   final prefs = await SharedPreferences.getInstance();

//   if (prefs.containsKey('isDarkTheme')) {
//     final isDark = prefs.getBool('isDarkTheme')!;
//     _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
//   } else {
//     _themeMode = ThemeMode.system;
//   }

//   notifyListeners();
// }


//   void toggleTheme(bool isDark) {
//     _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
//     _saveTheme();
//     notifyListeners();
//   }


  // Загружает тему из SharedPreferences
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('themeMode')) {
      final modeString = prefs.getString('themeMode');
      switch (modeString) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
    } else {
      _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }

  // Новый универсальный метод
  void toggleThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();

    // Сохраняем строковое значение
    switch (mode) {
      case ThemeMode.light:
        prefs.setString('themeMode', 'light');
        break;
      case ThemeMode.dark:
        prefs.setString('themeMode', 'dark');
        break;
      default:
        prefs.setString('themeMode', 'system');
    }

    notifyListeners();
  }


  void _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkTheme', _themeMode == ThemeMode.dark);
  }
}
