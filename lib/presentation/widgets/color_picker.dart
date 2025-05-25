import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerWidget extends StatefulWidget {
  final Color initialColor;
  final void Function(Color) onColorSelected;

  const ColorPickerWidget({
    super.key,
    required this.initialColor,
    required this.onColorSelected,
  });

  @override
  State<ColorPickerWidget> createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  late Color currentColor;

  @override
  void initState() {
    super.initState();
    currentColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ColorPicker(
          pickerColor: currentColor,
          onColorChanged: (Color color) {
            setState(() {
              currentColor = color;
            });
            widget.onColorSelected(color);
          },
          showLabel: true,
          pickerAreaHeightPercent: 0.7,
          enableAlpha: false,
        ),
        
      ],
    );
  }
}
