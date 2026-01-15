import 'package:flutter/material.dart';

import '../../../../core/constants/others.dart';
import '../../../../core/constants/sizes.dart';

class TodoParentTaskSelector extends StatelessWidget {
  final String? selectedParentTask; // Có thể null nếu chưa chọn
  final List<String> availableTasks; // Danh sách công việc cha khả dụng
  final Function(String?) onChanged;

  const TodoParentTaskSelector({
    super.key,
    required this.selectedParentTask,
    required this.availableTasks,
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
            Icons.subdirectory_arrow_right,
            color: COLORS.ICON_PRIMARY,
            size: IconSizes.ICON_20,
          ),

          SizedBox(width: WIDTH_SIZED_BOX_4),

          Text(
            "Công việc cha:",
            style: TextStyle(
              color: COLORS.SECONDARY_TEXT,
              fontWeight: FontWeight.bold,
              fontSize: TextSizes.TITLE_14,
            ),
          ),

          SizedBox(width: WIDTH_SIZED_BOX_4 * 3),

          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedParentTask,
                hint: Text(
                  "Chọn công việc...",
                  style: TextStyle(
                    color: COLORS.HINT_TEXT,
                    fontWeight: FontWeight.normal,
                    fontSize: TextSizes.TITLE_14,
                  ),
                ),
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: COLORS.ICON_PRIMARY,
                ),
                dropdownColor: COLORS.PRIMARY_BG,
                style: const TextStyle(color: Colors.red, fontSize: 15),
                isExpanded: true,
                onChanged: onChanged,
                items:
                    availableTasks.map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            color:
                                value == selectedParentTask
                                    ? COLORS.PRIMARY_TEXT
                                    : COLORS.SECONDARY_TEXT,
                            fontWeight:
                                value == selectedParentTask
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                          overflow:
                              TextOverflow
                                  .ellipsis, // Cắt bớt nếu tên việc quá dài
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
