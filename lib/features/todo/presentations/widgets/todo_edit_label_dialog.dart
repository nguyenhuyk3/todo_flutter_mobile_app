import 'package:flutter/material.dart';

import '../../../../core/constants/others.dart';
import '../../../../core/constants/sizes.dart';

import 'todo_model.dart';

class TodoEditLabelDialog extends StatelessWidget {
  final TodoLabelItem label;
  final Function(String) onSave;

  const TodoEditLabelDialog({
    super.key,
    required this.label,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController textController = TextEditingController();
    return Dialog(
      backgroundColor: COLORS.PRIMARY_BG,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chỉnh sửa nhãn',
                  style: TextStyle(
                    fontSize: HeaderSizes.HEADER_20,
                    fontWeight: FontWeight.bold,
                    color: COLORS.PRIMARY_TEXT,
                  ),
                ),

                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(
                    Icons.close,
                    color: COLORS.ICON_PRIMARY,
                    size: IconSizes.ICON_20,
                  ),
                ),
              ],
            ),

            const SizedBox(height: HEIGHT_SIZED_BOX_8 * 2.5),

            Divider(color: COLORS.UNFOCUSED_BORDER_IP, height: 0.8),

            const SizedBox(height: HEIGHT_SIZED_BOX_8 * 2.5),

            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: COLORS.UNFOCUSED_BORDER_IP),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: label.color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: textController,
                      autofocus: true,
                      style: TextStyle(
                        fontSize: TextSizes.TITLE_14,
                        fontWeight: FontWeight.w500,
                        color: COLORS.PRIMARY_TEXT,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Nhập tên nhãn...',
                        hintStyle: TextStyle(color: COLORS.HINT_TEXT),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: HEIGTH_SIZED_BOX_12 * 2),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: COLORS.SECONDARY_BG,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Hủy',
                      style: TextStyle(
                        color: COLORS.PRIMARY_TEXT,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: WIDTH_SIZED_BOX_4 * 3),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (textController.text.isNotEmpty) {
                        onSave(textController.text);
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: COLORS.PRIMARY_BUTTON,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Lưu',
                      style: TextStyle(
                        color: COLORS.PRIMARY_TEXT,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}