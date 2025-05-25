import 'package:flutter/material.dart';

class RoundedContainerCustom extends StatelessWidget {
  final double? width;
  final double? height;
  final bool isDark;
  final Alignment? alignment;
  final EdgeInsets? padding;
  final double howRounded;
  final Widget childWidget;

  const RoundedContainerCustom({
    super.key,
    this.width,
    this.height,
    required this.isDark,
    this.alignment,
    this.padding = const EdgeInsets.symmetric(horizontal: 6),
    this.howRounded = 25.0,
    required this.childWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      alignment: alignment,
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF333333) : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(howRounded),
      ),
      child: childWidget,
    );
  }
}
