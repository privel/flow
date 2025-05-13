import 'package:flutter/material.dart';

class AppColors {
  static const dark = _AppColorScheme(
    primary: Color(0xFF1EBA55), // Зелёная кнопка
    background: Color(0xFF111313), // Фон
    surface: Color(0xFF282A2C), // Поля/карточки
    text: Color(0xFFFFFFFF), // Белый текст
    secondaryText: Color(0xFFA0A0A0), // Подписи/серый текст
    googleText: Color(0xFF000000), // Текст Google
    googleBackground: Color(0xFFFFFFFF), // Белая кнопка Google
  );

  static const light = _AppColorScheme(
    primary: Color(0xFF1EBA55), // Зелёная кнопка
    background: Color(0xFFFFFFFF), // Белый фон
    surface: Color(0xFFF1F1F1), // Поля/карточки
    text: Color(0xFF000000), // Чёрный текст
    secondaryText: Color(0xFF666666), // Серый текст
    googleText: Color(0xFF000000),
    googleBackground: Color(0xFFFFFFFF),
  );
}

class _AppColorScheme {
  final Color primary;
  final Color background;
  final Color surface;
  final Color text;
  final Color secondaryText;
  final Color googleText;
  final Color googleBackground;

  const _AppColorScheme({
    required this.primary,
    required this.background,
    required this.surface,
    required this.text,
    required this.secondaryText,
    required this.googleText,
    required this.googleBackground,
  });
}
