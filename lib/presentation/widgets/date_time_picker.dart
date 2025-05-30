import 'package:flow/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';

class DateTimePickerWidget extends StatefulWidget {
  final DateTime? initialDateTime;
  final void Function(DateTime) onDateTimeSelected;
  final String label;

  const DateTimePickerWidget({
    Key? key,
    this.initialDateTime,
    required this.onDateTimeSelected,
    required this.label,
  }) : super(key: key);

  @override
  State<DateTimePickerWidget> createState() => _DateTimePickerWidgetState();
}

class _DateTimePickerWidgetState extends State<DateTimePickerWidget> {
  DateTime? selectedDateTime;

  @override
  void initState() {
    super.initState();
    selectedDateTime = widget.initialDateTime;
  }

  Future<void> _pickDateTime() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: isDark ? ThemeData.dark() : ThemeData.light(),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime ?? DateTime.now()),
      builder: (context, child) {
        return Theme(
          data: isDark ? ThemeData.dark() : ThemeData.light(),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

    final DateTime combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      selectedDateTime = combined;
    });

    widget.onDateTimeSelected(combined);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // final displayText = selectedDateTime != null
    //     ? "${selectedDateTime!.day.toString().padLeft(2, '0')}.${selectedDateTime!.month.toString().padLeft(2, '0')}.${selectedDateTime!.year} "
    //         "${selectedDateTime!.hour.toString().padLeft(2, '0')}:${selectedDateTime!.minute.toString().padLeft(2, '0')}"
    //     : "Не выбрано";
    final displayText = selectedDateTime != null
        ? DateFormat("d MMMM hh:mm", S.of(context).en_ru).format(selectedDateTime!)
        : S.of(context).notSelected;
   

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDateTime,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF333333) : const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  displayText,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontFamily: 'SFProText',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 5),
                Icon(
                  IconlyLight.calendar,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
