import 'package:flutter/material.dart';

class TodoRecurrenceSelector extends StatelessWidget {
  final String selectedRecurrence; // Giá trị: 'none', 'daily', ...
  final Function(String?) onChanged;

  const TodoRecurrenceSelector({
    super.key,
    required this.selectedRecurrence,
    required this.onChanged,
  });

  // Map hiển thị Tiếng Việt tương ứng với Enum database
  final Map<String, String> displayMap = const {
    'none': 'Không lặp lại',
    'daily': 'Hàng ngày',
    'weekly': 'Hàng tuần',
    'monthly': 'Hàng tháng',
    'yearly': 'Hàng năm',
  };

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
          // Icon Repeat
          const Icon(Icons.repeat, color: Color(0xFF22D3EE), size: 20),
          const SizedBox(width: 12),
          const Text(
            "Lặp lại:",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedRecurrence,
                dropdownColor: const Color(0xFF2B303F),
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                style: const TextStyle(color: Colors.white, fontSize: 15),
                isExpanded: true,
                onChanged: onChanged,
                items:
                    displayMap.entries.map<DropdownMenuItem<String>>((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key, // Giá trị trả về (Enum key)
                        child: Text(
                          entry.value, // Giá trị hiển thị (Tiếng Việt)
                          style: TextStyle(
                            color:
                                entry.key == selectedRecurrence
                                    ? Colors.white
                                    : Colors.white70,
                            fontWeight:
                                entry.key == selectedRecurrence
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
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
