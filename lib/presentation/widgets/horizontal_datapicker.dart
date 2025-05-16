import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HorizontalDatePicker extends StatefulWidget {
  const HorizontalDatePicker({super.key});

  @override
  State<HorizontalDatePicker> createState() => _HorizontalDatePickerState();
}

class _HorizontalDatePickerState extends State<HorizontalDatePicker> {
  final DateTime _today = DateTime.now();
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = _today;
  }

  @override
  Widget build(BuildContext context) {
    final start = _today.subtract(const Duration(days: 3));
    final dates = List.generate(14, (i) => start.add(Duration(days: i)));
    final monthName = DateFormat.MMMM().format(_selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Верхняя часть: текст + месяц
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Your Timeline',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            Row(
              children: [
                Text(
                  monthName,
                  style: const TextStyle(color: Colors.white70),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 75,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final isSelected = isSameDay(date, _selectedDate);

              return GestureDetector(
                onTap: () => setState(() => _selectedDate = date),
                child: Container(
                  width: 55,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.redAccent : const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat.d().format(date), // число
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[300],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        DateFormat.E().format(date), // день недели (Wed, Thu)
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[500],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
