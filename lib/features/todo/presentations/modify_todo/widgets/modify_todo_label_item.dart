import 'package:flutter/material.dart';

import 'package:todo_flutter_mobile_app/core/constants/sizes.dart';

import '../../../../../core/constants/others.dart';
import '../../models/label_item.dart';

class ModifyTodoLabelItemWidget extends StatelessWidget {
  final LabelItem item;
  final VoidCallback onTap;
  final VoidCallback onEditTap;

  const ModifyTodoLabelItemWidget({
    super.key,
    required this.item,
    required this.onTap,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: COLORS.SECONDARY_BG,
          borderRadius: BorderRadius.circular(8),
          border:
              item.isSelected
                  ? Border.all(color: item.color, width: 1)
                  : Border.all(color: COLORS.UNFOCUSED_BORDER_IP, width: 1),
        ),
        padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: item.color,
                borderRadius: BorderRadius.circular(6),
              ),
              child:
                  item.isSelected
                      ? Icon(
                        Icons.check,
                        size: IconSizes.ICON_16,
                        color: COLORS.ICON_DEFAULT,
                      )
                      : null,
            ),

            const SizedBox(width: WIDTH_SIZED_BOX_4 * 2),

            Expanded(
              child: Text(
                item.name,
                style: TextStyle(
                  fontSize: TextSizes.TITLE_14,
                  color:
                      item.isSelected
                          ? COLORS.PRIMARY_TEXT
                          : COLORS.SECONDARY_TEXT,
                  fontWeight: FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            IconButton(
              icon: Icon(
                Icons.edit_note,
                color: item.isSelected ? item.color : COLORS.ICON_PRIMARY,
                size: IconSizes.ICON_20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: onEditTap,
            ),

            const SizedBox(width: WIDTH_SIZED_BOX_4 * 2),
          ],
        ),
      ),
    );
  }
}
