import 'package:flutter/material.dart';

import '../../../../core/constants/others.dart';
import '../../../../core/constants/sizes.dart';

class TodoRecurrenceSelector extends StatelessWidget {
  final String selectedRecurrence; // Giá trị: 'none', 'daily', ...
  final Function(String?) onChanged;

  const TodoRecurrenceSelector({
    super.key,
    required this.selectedRecurrence,
    required this.onChanged,
  });

  // Map hiển thị Tiếng Việt tương ứng với Enum database
  final Map<String, String> displayMap = const {
    'none': 'Không lặp lại',
    'daily': 'Hàng ngày',
    'weekly': 'Hàng tuần',
    'monthly': 'Hàng tháng',
    'yearly': 'Hàng năm',
  };

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: COLORS.INPUT_BG,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: COLORS.FOCUSED_BORDER_IP, width: 1),
        boxShadow: [
          BoxShadow(
            color: COLORS.PRIMARY_SHADOW,
            offset: const Offset(0, 3), // Bóng cứng đổ xuống dưới
            blurRadius: 0, // Không làm mờ
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.repeat,
            color: COLORS.ICON_PRIMARY,
            size: IconSizes.ICON_20,
          ),

          SizedBox(width: WIDTH_SIZED_BOX_4),

          Text(
            "Lặp lại:",
            style: TextStyle(
              color: COLORS.SECONDARY_TEXT,
              fontWeight: FontWeight.bold,
              fontSize: TextSizes.TITLE_14,
            ),
          ),

          SizedBox(width: WIDTH_SIZED_BOX_4 * 16),

          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedRecurrence,
                dropdownColor: COLORS.PRIMARY_BG,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                style: const TextStyle(color: Colors.red, fontSize: 15),
                isExpanded: true,
                onChanged: onChanged,
                items:
                    displayMap.entries.map<DropdownMenuItem<String>>((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key, // Giá trị trả về (Enum key)
                        child: Text(
                          entry.value, // Giá trị hiển thị (Tiếng Việt)
                          style: TextStyle(
                            color:
                                entry.key == selectedRecurrence
                                    ? COLORS.PRIMARY_TEXT
                                    : COLORS.SECONDARY_TEXT,
                            fontWeight:
                                entry.key == selectedRecurrence
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
