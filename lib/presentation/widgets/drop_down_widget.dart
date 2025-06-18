import 'package:flutter/material.dart';

class DropDownWidget extends StatefulWidget {
  final double widthContainer;
  final bool isDark;
  final Widget header;
  final Color BackGroundColor; 
  final List<Widget> children;

  const DropDownWidget({
    super.key,
    required this.widthContainer,
    required this.isDark,
    required this.header,
    required this.BackGroundColor,
    required this.children,
  });

  @override
  State<DropDownWidget> createState() => _DropDownWidgetState();
}

class _DropDownWidgetState extends State<DropDownWidget>
    with SingleTickerProviderStateMixin {
  bool showExtraOptions = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.widthContainer,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: widget.BackGroundColor,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                showExtraOptions = !showExtraOptions;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: widget.header),
                const SizedBox(width: 8),
                Icon(
                  showExtraOptions
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: showExtraOptions
                ? Column(
                    children: [
                      Divider(
                        height: 25,
                        color:
                            widget.isDark ? Colors.white38 : Colors.black45,
                        thickness: 0.6,
                      ),
                      ...widget.children,
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
