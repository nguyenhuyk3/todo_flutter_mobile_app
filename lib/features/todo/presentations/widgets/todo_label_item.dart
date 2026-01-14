import 'package:flutter/material.dart';
import 'todo_model.dart'; // Import model của bạn

class TodoLabelItemWidget extends StatelessWidget {
  final TodoLabelItem item;
  final VoidCallback onTap;
  final VoidCallback onEditTap;

  const TodoLabelItemWidget({
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
          color: const Color(0xFF2B303F),
          borderRadius: BorderRadius.circular(8),
          border:
              item.isSelected
                  ? Border.all(color: item.color, width: 2)
                  : Border.all(color: Colors.transparent, width: 2),
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
                      ? const Icon(Icons.check, size: 16, color: Colors.black45)
                      : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.name,
                style: TextStyle(
                  fontSize: 13,
                  color: item.isSelected ? Colors.white : Colors.white70,
                  fontWeight:
                      item.isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.edit_note,
                color: item.isSelected ? item.color : Colors.grey,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: onEditTap,
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
