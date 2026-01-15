import 'package:flutter/material.dart';

import '../../../../core/constants/others.dart';
import '../../../../core/constants/sizes.dart';

class TodoPrioritySelector extends StatelessWidget {
  final String selectedPriority;
  final Function(String?) onChanged;

  final Map<String, Color> priorities = const {
    'Thấp': Colors.grey,
    'Trung bình': Colors.yellowAccent,
    'Cao': Colors.redAccent,
  };

  const TodoPrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onChanged,
  });

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
            Icons.flag_outlined,
            color: COLORS.ICON_PRIMARY,
            size: IconSizes.ICON_20,
          ),

          SizedBox(width: WIDTH_SIZED_BOX_4),

          Text(
            "Độ ưu tiên:",
            style: TextStyle(
              color: COLORS.SECONDARY_TEXT,
              fontWeight: FontWeight.bold,
              fontSize: TextSizes.TITLE_14,
            ),
          ),

          SizedBox(width: WIDTH_SIZED_BOX_4 * 10),

          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedPriority,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: COLORS.ICON_PRIMARY,
                ),
                dropdownColor: COLORS.PRIMARY_BG,
                style: const TextStyle(color: Colors.red, fontSize: 15),
                isExpanded: true,
                onChanged: onChanged,
                items:
                    priorities.keys.map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            // Chấm tròn màu sắc thể hiện mức độ
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: priorities[value],
                                shape: BoxShape.circle,
                              ),
                            ),

                            const SizedBox(width: WIDTH_SIZED_BOX_4 * 3),

                            Text(
                              value,
                              style: TextStyle(
                                color:
                                    value == selectedPriority
                                        ? COLORS.PRIMARY_TEXT
                                        : COLORS.SECONDARY_TEXT,
                                fontWeight:
                                    value == selectedPriority
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ],
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
