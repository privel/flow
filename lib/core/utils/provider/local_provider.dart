import 'package:flow/core/utils/shared/locale_preferences.dart';
import 'package:flutter/material.dart';


class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  /// Загрузить язык из SharedPreferences при старте
  Future<void> loadLocale() async {
    final code = await LocalePreferences.getSavedLocale();
    if (code != null) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  /// Установить язык и сохранить в SharedPreferences
  void setLocale(Locale locale) {
    _locale = locale;
    LocalePreferences.saveLocale(locale.languageCode);
    notifyListeners();
  }
}
