import 'package:flutter/material.dart';
import 'todo_model.dart';
import 'todo_label_item.dart';

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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F222E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Nhãn",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.local_offer_outlined, color: Colors.grey, size: 18),
            ],
          ),
          const SizedBox(height: 12),
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
