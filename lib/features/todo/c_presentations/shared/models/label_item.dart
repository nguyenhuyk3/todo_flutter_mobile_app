import 'package:flutter/material.dart';

class LabelItem {
  /// Id từ Supabase (bảng tags). Null nếu là dữ liệu mock/local.
  final String? id;
  String name;
  final Color color;
  bool isSelected;

  LabelItem({
    this.id,
    required this.name,
    required this.color,
    this.isSelected = false,
  });
}
