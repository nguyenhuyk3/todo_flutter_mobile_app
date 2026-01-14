import 'package:flutter/material.dart';

class TodoTitleInput extends StatelessWidget {
  final TextEditingController controller;

  const TodoTitleInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1F222E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        decoration: const InputDecoration(
          hintText: 'Tiêu đề công việc...',
          hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
          border: InputBorder.none,
          icon: Icon(Icons.title, color: Colors.grey, size: 20),
        ),
      ),
    );
  }
}