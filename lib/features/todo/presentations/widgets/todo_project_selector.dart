import 'package:flutter/material.dart';

class TodoProjectSelector extends StatelessWidget {
  final String selectedProject;
  final List<String> projects;
  final Function(String?) onChanged;

  const TodoProjectSelector({
    super.key,
    required this.selectedProject,
    required this.projects,
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
          const Icon(Icons.folder_open_outlined, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          const Text(
            "Dự án:",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedProject,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                dropdownColor: const Color(0xFF2B303F),
                style: const TextStyle(color: Colors.white, fontSize: 15),
                isExpanded: true,
                onChanged: onChanged,
                items:
                    projects.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            color:
                                value == selectedProject
                                    ? Colors.white
                                    : Colors.white70,
                            fontWeight:
                                value == selectedProject
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
