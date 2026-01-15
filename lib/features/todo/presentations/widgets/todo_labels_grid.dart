import 'package:flutter/material.dart';

import '../../../../core/constants/others.dart';

import '../../../../core/constants/sizes.dart';
import 'todo_label_item.dart';
import 'todo_model.dart';

class TodoLabelsGrid extends StatelessWidget {
  final List<TodoLabelItem> labels;
  final Function(int index) onLabelTap;
  final Function(int index) onLabelEdit;

  const TodoLabelsGrid({
    super.key,
    required this.labels,
    required this.onLabelTap,
    required this.onLabelEdit,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.local_offer_outlined,
                color: COLORS.ICON_PRIMARY,
                size: IconSizes.ICON_20,
              ),

              SizedBox(width: WIDTH_SIZED_BOX_4),

              Text(
                "Nhãn",
                style: TextStyle(
                  color: COLORS.SECONDARY_TEXT,
                  fontWeight: FontWeight.bold,
                  fontSize: TextSizes.TITLE_14,
                ),
              ),
            ],
          ),

          const SizedBox(height: HEIGTH_SIZED_BOX_12),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: labels.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              return TodoLabelItemWidget(
                item: labels[index],
                onTap: () => onLabelTap(index),
                onEditTap: () => onLabelEdit(index),
              );
            },
          ),
        ],
      ),
    );
  }
}
