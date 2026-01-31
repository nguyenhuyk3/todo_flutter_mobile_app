import 'package:flutter/material.dart';

class LabelItem {
  String name;
  final Color color;
  bool isSelected;

  LabelItem({required this.name, required this.color, this.isSelected = false});
}
