import 'package:flutter/material.dart';

class TodoLabelItem {
  String name;
  final Color color;
  bool isSelected;

  TodoLabelItem({
    required this.name,
    required this.color,
    this.isSelected = false,
  });
}
