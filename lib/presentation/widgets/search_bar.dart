import 'package:flow/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool isDark;
  final String hintText;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.isDark,
    this.onChanged, required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style:
            TextStyle(color: isDark ? Colors.white : const Color(0xFF1F1F1F)),
        // cursorColor: Colors.white54,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(
            IconlyLight.search,
            color: isDark ? Colors.white : const Color(0xFF1F1F1F),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
