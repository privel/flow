import 'package:flutter/material.dart';
import 'package:flow/core/theme/app_ext.dart';

class LoginLayout {
  final BuildContext context;

  LoginLayout(this.context);

  TextStyle get mainTextStyle => const TextStyle(
        fontFamily: 'SFProText',
        fontWeight: FontWeight.w600,
        fontSize: 24,
      );

  TextStyle get subTextStyle => TextStyle(
        fontFamily: 'SFProText',
        fontWeight: FontWeight.w100,
        color: Theme.of(context).extension<AppColorsExtension>()?.subText,
        fontSize: 15,
      );

  TextStyle get hintTextStyle => const TextStyle(
        fontFamily: 'SFProText',
        fontWeight: FontWeight.w100,
        color: Colors.grey,
        fontSize: 14,
      );
}
