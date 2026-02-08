import 'package:flutter/material.dart';

import '../../../../../../core/constants/others.dart';
import '../../../../../../core/constants/sizes.dart';
import '../../../models/label_item.dart';

/// Màu mặc định cho bộ chọn màu nhãn (hex từ seed tags trong DB).
const List<Color> _kLabelColorPresets = [
  Color(0xFFEF4444), // Red
  Color(0xFF3B82F6), // Blue
  Color(0xFF10B981), // Emerald
  Color(0xFFF59E0B), // Amber
  Color(0xFFEC4899), // Pink
  Color(0xFF8B5CF6), // Violet
  Color(0xFF14B8A6), // Teal
  Color(0xFF84CC16), // Lime
  Color(0xFFF97316), // Orange
  Color(0xFF06B6D4), // Cyan

  Color(0xFF6366F1), // Indigo
  Color(0xFF0EA5E9), // Sky
  Color(0xFF22C55E), // Green
  Color(0xFFA855F7), // Purple
  Color(0xFFFB7185), // Rose
  Color(0xFF64748B), // Slate (neutral)
  Color(0xFF334155), // Dark Slate
  Color(0xFFD946EF), // Fuchsia
  Color(0xFF2DD4BF), // Aqua Mint
  Color(0xFFEAB308), // Yellow
  Color(0xFF7C3AED), // Deep Violet
  Color(0xFF059669), // Deep Emerald
  Color(0xFFDC2626), // Strong Red
  Color(0xFF2563EB), // Royal Blue
];

class ModifyTodoEditLabelDialog extends StatefulWidget {
  final LabelItem label;
  final void Function(String name, Color color) onSave;

  const ModifyTodoEditLabelDialog({
    super.key,
    required this.label,
    required this.onSave,
  });

  @override
  State<ModifyTodoEditLabelDialog> createState() =>
      _ModifyTodoEditLabelDialogState();
}

class _ModifyTodoEditLabelDialogState extends State<ModifyTodoEditLabelDialog> {
  late final TextEditingController _textController;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController(text: widget.label.name);
    _selectedColor = widget.label.color;
  }

  @override
  void dispose() {
    _textController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: COLORS.PRIMARY_BG,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chỉnh sửa nhãn',
                  style: TextStyle(
                    fontSize: HeaderSizes.HEADER_20,
                    fontWeight: FontWeight.bold,
                    color: COLORS.PRIMARY_TEXT,
                  ),
                ),

                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(
                    Icons.close,
                    color: COLORS.ICON_PRIMARY,
                    size: IconSizes.ICON_28,
                  ),
                ),
              ],
            ),

            const SizedBox(height: HEIGTH_SIZED_BOX_12),

            // ignore: deprecated_member_use
            Divider(
              color: COLORS.UNFOCUSED_BORDER_IP.withOpacity(0.5),
              height: 0.8,
            ),

            const SizedBox(height: HEIGTH_SIZED_BOX_12 * 2),

            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                border: Border.all(
                  color: COLORS.UNFOCUSED_BORDER_IP.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      autofocus: true,
                      style: TextStyle(
                        fontSize: TextSizes.TITLE_14,
                        fontWeight: FontWeight.w500,
                        color: COLORS.PRIMARY_TEXT,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Nhập tên nhãn...',
                        hintStyle: TextStyle(color: COLORS.HINT_TEXT),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: HEIGTH_SIZED_BOX_12),

            Text(
              'Chọn màu',
              style: TextStyle(
                fontSize: TextSizes.TITLE_14,
                fontWeight: FontWeight.w600,
                color: COLORS.SECONDARY_TEXT,
              ),
            ),

            const SizedBox(height: HEIGTH_SIZED_BOX_12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  _kLabelColorPresets.map((color) {
                    final isSelected = _selectedColor.value == color.value;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isSelected
                                    ? _darkerShade(color)
                                    : Colors.transparent,
                            width: isSelected ? 3 : 0,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                          ],
                        ),
                        child:
                            isSelected
                                ? Icon(
                                  Icons.check,
                                  size: IconSizes.ICON_20,
                                  color: _contrastColor(color),
                                )
                                : null,
                      ),
                    );
                  }).toList(),
            ),

            const SizedBox(height: HEIGTH_SIZED_BOX_12 * 2),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: COLORS.SECONDARY_BG,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Hủy',
                      style: TextStyle(
                        color: COLORS.PRIMARY_TEXT,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: WIDTH_SIZED_BOX_4 * 3),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final text = _textController.text.trim();

                      if (text.isNotEmpty) {
                        widget.onSave(text, _selectedColor);
                      }

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: COLORS.PRIMARY_BUTTON,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Lưu',
                      style: TextStyle(
                        color: COLORS.PRIMARY_TEXT,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Màu chữ tương phản (trắng/đen) theo độ sáng nền.
Color _contrastColor(Color background) {
  final luminance = background.computeLuminance();
  return luminance > 0.5 ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
}

/// Phiên bản đậm hơn của màu để dùng cho border (dễ nhìn).
Color _darkerShade(Color color) {
  return Color.lerp(color, const Color(0xFF000000), 0.35) ?? color;
}
