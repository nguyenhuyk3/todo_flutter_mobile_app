import 'package:flutter/material.dart';

import '../../../../../core/constants/others.dart';
import '../../../../../core/constants/sizes.dart';
import '../../models/label_item.dart';

import 'modify_todo_edit_label_dialog.dart';
import 'modify_todo_label_item.dart';

class ModifyTodoLabelsGrid extends StatefulWidget {
  const ModifyTodoLabelsGrid({super.key});

  @override
  State<ModifyTodoLabelsGrid> createState() => _ModifyTodoLabelsGridState();
}

class _ModifyTodoLabelsGridState extends State<ModifyTodoLabelsGrid> {
  final List<LabelItem> _labels = [
    LabelItem(name: "Chưa đặt tên", color: const Color(0xFF1FC389)),
    LabelItem(name: "Chưa đặt tên", color: const Color(0xFF8B5CF6)),
    LabelItem(name: "Chưa đặt tên", color: const Color(0xFFEF4444)),
    LabelItem(name: "Chưa đặt tên", color: const Color(0xFFF59E0B)),
    LabelItem(name: "Chưa đặt tên", color: const Color(0xFF3B82F6)),
    LabelItem(name: "Chưa đặt tên", color: const Color(0xFFEAB308)),
  ];

  void _onLabelTap(int index) {
    setState(() {
      _labels[index].isSelected = !_labels[index].isSelected;
    });
  }

  void _onLabelEdit(int index) {
    showDialog(
      context: context,
      builder:
          (ctx) => ModifyTodoEditLabelDialog(
            label: _labels[index],
            onSave: (newName) {
              setState(() {
                _labels[index].name = newName;
              });
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: COLORS.INPUT_BG,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: COLORS.FOCUSED_BORDER_IP, width: 1),
        boxShadow: [
          BoxShadow(
            color: COLORS.PRIMARY_SHADOW,
            offset: const Offset(0, 3),
            blurRadius: 0,
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
            itemCount: _labels.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              return ModifyTodoLabelItemWidget(
                item: _labels[index],
                // Gọi các hàm xử lý nội bộ
                onTap: () => _onLabelTap(index),
                onEditTap: () => _onLabelEdit(index),
              );
            },
          ),
        ],
      ),
    );
  }
}
