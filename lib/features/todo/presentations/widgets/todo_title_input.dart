import 'package:flutter/material.dart';

import '../../../../core/constants/others.dart';
import '../../../../core/constants/sizes.dart';

class TodoTitleInput extends StatelessWidget {
  final TextEditingController controller;

  const TodoTitleInput({super.key, required this.controller});

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
      child: TextField(
        controller: controller,
        style: TextStyle(
          fontSize: TextSizes.TITLE_16,
          fontWeight: FontWeight.w500,
          color: COLORS.PRIMARY_TEXT,
        ),
        decoration: InputDecoration(
          hintText: 'Tiêu đề công việc...',
          hintStyle: TextStyle(
            color: COLORS.HINT_TEXT,
            fontWeight: FontWeight.normal,
            fontSize: TextSizes.TITLE_14,
          ),
          border: InputBorder.none,
          icon: Icon(
            Icons.title,
            color: COLORS.ICON_PRIMARY,
            size: IconSizes.ICON_20,
          ),
        ),
      ),
    );
  }
}
