import 'package:flutter/material.dart';

@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color mainText;
  final Color subText;
   


  const AppColorsExtension({
    required this.mainText,
    required this.subText,
  });

  @override
  AppColorsExtension copyWith({
    Color? text,
    Color? secondaryText,
  }) {
    return AppColorsExtension(
      mainText: text ?? this.mainText,
      subText: secondaryText ?? this.subText,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      mainText: Color.lerp(mainText, other.mainText, t)!,
      subText: Color.lerp(subText, other.subText, t)!,
    );
  }
}
