import 'package:flutter/material.dart';

class HomeLayout {
  bool isMobile;
  bool isTablet;

  HomeLayout(
    this.isMobile,
    this.isTablet,
  );

  double get ImageScaleIcon {
    return isMobile
        ? 8.0
        : isTablet
            ? 10.0
            : 10.0;
  }

  TextStyle get h2Style {
    return TextStyle(
      fontFamily: 'SFProText',
      fontWeight: FontWeight.w600,
      fontSize: 14,
    );
  }
}
