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
        ? 50
        : isTablet
            ? 60
            : 70;
  }
}
