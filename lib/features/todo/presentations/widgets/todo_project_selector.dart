import 'package:flutter/material.dart';

import '../../../../core/constants/others.dart';
import '../../../../core/constants/sizes.dart';

class TodoProjectSelector extends StatelessWidget {
  final String selectedProject;
  final List<String> projects;
  final Function(String?) onChanged;

  const TodoProjectSelector({
    super.key,
    required this.selectedProject,
    required this.projects,
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
            Icons.folder_open_outlined,
            color: COLORS.ICON_PRIMARY,
            size: IconSizes.ICON_20,
          ),

          SizedBox(width: WIDTH_SIZED_BOX_4),

          Text(
            "Dự án:",
            style: TextStyle(
              color: COLORS.SECONDARY_TEXT,
              fontWeight: FontWeight.bold,
              fontSize: TextSizes.TITLE_14,
            ),
          ),

          SizedBox(width: WIDTH_SIZED_BOX_4 * 18),

          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedProject,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: COLORS.ICON_PRIMARY,
                ),
                dropdownColor: COLORS.PRIMARY_BG,
                style: const TextStyle(color: Colors.red, fontSize: 15),
                isExpanded: true,
                onChanged: onChanged,
                items:
                    projects.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            color:
                                value == selectedProject
                                    ? COLORS.PRIMARY_TEXT
                                    : COLORS.SECONDARY_TEXT,
                            fontWeight:
                                value == selectedProject
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
