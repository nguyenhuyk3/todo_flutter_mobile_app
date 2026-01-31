import 'package:flutter/material.dart';

import '../../../../../../core/constants/others.dart';
import '../../../../../../core/constants/sizes.dart';

class ModifyTodoRecurrenceInfoDialog extends StatelessWidget {
  final String title;
  final String description;

  const ModifyTodoRecurrenceInfoDialog({
    super.key,
    required this.title,
    required this.description,
  });

  static void show(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    showDialog(
      context: context,
      builder:
          (ctx) => ModifyTodoRecurrenceInfoDialog(
            title: title,
            description: description,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: COLORS.PRIMARY_BG,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: COLORS.PRIMARY,
            size: IconSizes.ICON_20,
          ),

          const SizedBox(width: WIDTH_SIZED_BOX_4),

          Text(
            title,
            style: TextStyle(
              fontSize: TextSizes.TITLE_18,
              color: COLORS.PRIMARY_TEXT,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      content: Text(
        description,
        style: TextStyle(
          fontSize: TextSizes.TITLE_16,
          color: COLORS.SECONDARY_TEXT,
          fontWeight: FontWeight.w300,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Đã hiểu",
            style: TextStyle(
              color: COLORS.PRIMARY,
              fontWeight: FontWeight.bold,
              fontSize: TextSizes.TITLE_16,
            ),
          ),
        ),
      ],
    );
  }
}
