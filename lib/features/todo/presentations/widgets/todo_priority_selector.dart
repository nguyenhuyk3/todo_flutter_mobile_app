import 'package:flutter/material.dart';

class TodoPrioritySelector extends StatelessWidget {
  final String selectedPriority;
  final Function(String?) onChanged;

  // Dữ liệu fix cứng trong widget hoặc truyền từ ngoài vào
  final Map<String, Color> priorities = const {
    'Thấp': Colors.grey,
    'Trung bình': Color(0xFFEAB308), // Vàng
    'Cao': Color(0xFFEF4444), // Đỏ
  };

  const TodoPrioritySelector({
    super.key,
    required this.selectedPriority,
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
          const Icon(Icons.flag_outlined, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          const Text(
            "Độ ưu tiên:",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedPriority,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                dropdownColor: const Color(0xFF2B303F),
                style: const TextStyle(color: Colors.white, fontSize: 15),
                isExpanded: true,
                onChanged: onChanged,
                items:
                    priorities.keys.map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            // Chấm tròn màu sắc thể hiện mức độ
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: priorities[value],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              value,
                              style: TextStyle(
                                color:
                                    value == selectedPriority
                                        ? Colors.white
                                        : Colors.white70,
                                fontWeight:
                                    value == selectedPriority
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ],
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
