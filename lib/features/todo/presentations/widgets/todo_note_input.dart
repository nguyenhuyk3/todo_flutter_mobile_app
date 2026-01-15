import 'package:flutter/material.dart';

import '../../../../core/constants/others.dart';
import '../../../../core/constants/sizes.dart';

class TodoNoteInput extends StatelessWidget {
  const TodoNoteInput({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: 200,
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
      child: Column(
        children: [
          Expanded(
            child: TextField(
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Viết mô tả của công việc ...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: COLORS.HINT_TEXT,
                  fontWeight: FontWeight.normal,
                  fontSize: TextSizes.TITLE_14,
                ),
              ),
              style: TextStyle(
                fontSize: TextSizes.TITLE_16,
                fontWeight: FontWeight.w500,
                color: COLORS.PRIMARY_TEXT,
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '(0/1000)',
                  style: TextStyle(
                    color: COLORS.PRIMARY_TEXT,
                    fontSize: TextSizes.TITLE_12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
