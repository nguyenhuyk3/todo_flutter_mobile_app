import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Cần thêm package intl vào pubspec.yaml để format ngày đẹp

class TodoDateSelector extends StatelessWidget {
  final DateTimeRange? selectedDateRange;
  final VoidCallback onTap;

  const TodoDateSelector({
    super.key,
    required this.selectedDateRange,
    required this.onTap,
  });

  String get _dateText {
    if (selectedDateRange == null) {
      return "Chọn thời gian";
    }
    final start = DateFormat('dd/MM/yyyy').format(selectedDateRange!.start);
    final end = DateFormat('dd/MM/yyyy').format(selectedDateRange!.end);

    // Nếu chọn cùng 1 ngày
    if (start == end) return start;

    return "$start - $end";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1F222E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_outlined,
              color:
                  selectedDateRange == null
                      ? Colors.grey
                      : const Color(0xFF22D3EE),
              size: 20,
            ),
            const SizedBox(width: 12),
            const Text(
              "Thời gian:",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _dateText,
                style: TextStyle(
                  color:
                      selectedDateRange == null ? Colors.white70 : Colors.white,
                  fontWeight:
                      selectedDateRange == null
                          ? FontWeight.normal
                          : FontWeight.bold,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
