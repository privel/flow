import 'package:flutter/material.dart';

class AnimatedCheckCircle extends StatefulWidget {
  final bool isChecked;
  final VoidCallback onTap;

  const AnimatedCheckCircle({
    super.key,
    required this.isChecked,
    required this.onTap,
  });

  @override
  State<AnimatedCheckCircle> createState() => _AnimatedCheckCircleState();
}

class _AnimatedCheckCircleState extends State<AnimatedCheckCircle> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: 0,
          end: widget.isChecked ? 1 : 0,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.isChecked ? Colors.green : Colors.grey,
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipOval(
                  child: Align(
                    alignment: Alignment.center,
                    widthFactor: value,
                    heightFactor: value,
                    child: Container(
                      width: 20,
                      height: 20,
                      color: Colors.green,
                    ),
                  ),
                ),
                if (widget.isChecked)
                  const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
