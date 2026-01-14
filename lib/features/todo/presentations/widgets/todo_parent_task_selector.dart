import 'package:flutter/material.dart';

class TodoParentTaskSelector extends StatelessWidget {
  final String? selectedParentTask; // Có thể null nếu chưa chọn
  final List<String> availableTasks; // Danh sách công việc cha khả dụng
  final Function(String?) onChanged;

  const TodoParentTaskSelector({
    super.key,
    required this.selectedParentTask,
    required this.availableTasks,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1F222E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // Icon thể hiện sự phân cấp
          const Icon(
            Icons.subdirectory_arrow_right,
            color: Color(0xFF22D3EE),
            size: 20,
          ),
          const SizedBox(width: 12),
          const Text(
            "Công việc cha:",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedParentTask,
                hint: const Text(
                  "Chọn công việc...",
                  style: TextStyle(color: Colors.grey),
                ),
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                dropdownColor: const Color(0xFF2B303F),
                style: const TextStyle(color: Colors.white, fontSize: 15),
                isExpanded: true,
                onChanged: onChanged,
                items:
                    availableTasks.map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            color:
                                value == selectedParentTask
                                    ? Colors.white
                                    : Colors.white70,
                            fontWeight:
                                value == selectedParentTask
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                          overflow:
                              TextOverflow
                                  .ellipsis, // Cắt bớt nếu tên việc quá dài
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
