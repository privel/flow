import 'package:flutter/material.dart';

enum SnackType { success, error }

class SnackBarHelper {
  static void show(
    BuildContext context,
    String message, {
    SnackType type = SnackType.success,
    Duration duration = const Duration(seconds: 3),
  }) {
    final backgroundColor = type == SnackType.success
        ? Colors.green
        : Colors.red;

    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      duration: duration,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}


/*// Успешно
SnackBarHelper.show(context, "Успешно сохранено");

// Ошибка
SnackBarHelper.show(
  context,
  "Ошибка загрузки данных",
  type: SnackType.error,
);
 */