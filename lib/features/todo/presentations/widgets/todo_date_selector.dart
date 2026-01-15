import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/others.dart';
import '../../../../core/constants/sizes.dart'; // Cần thêm package intl vào pubspec.yaml để format ngày đẹp

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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: COLORS.INPUT_BG,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: COLORS.FOCUSED_BORDER_IP, width: 1),
          boxShadow: [
            BoxShadow(
              color: COLORS.PRIMARY_SHADOW,
              offset: const Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_outlined,
              color:
                  selectedDateRange == null
                      ? COLORS.ICON_PRIMARY
                      : COLORS.ICON_DEFAULT,
              size: IconSizes.ICON_20,
            ),

            SizedBox(width: WIDTH_SIZED_BOX_4),

            Text(
              "Thời gian:",
              style: TextStyle(
                color: COLORS.SECONDARY_TEXT,
                fontWeight: FontWeight.bold,
                fontSize: TextSizes.TITLE_14,
              ),
            ),

            SizedBox(
              width: WIDTH_SIZED_BOX_4 * (selectedDateRange == null ? 12 : 8),
            ),

            Expanded(
              child: Text(
                _dateText,
                style: TextStyle(
                  color:
                      selectedDateRange == null
                          ? COLORS.SECONDARY_TEXT
                          : COLORS.PRIMARY_TEXT,
                  fontWeight:
                      selectedDateRange == null
                          ? FontWeight.normal
                          : FontWeight.bold,
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
