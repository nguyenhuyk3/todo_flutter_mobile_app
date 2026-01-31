import 'package:flutter/material.dart';

import '../../../../../../core/constants/others.dart';
import '../../../../../../core/constants/sizes.dart';

class ModifyTodoCustomWeekdaysDialog extends StatefulWidget {
  final List<int> availableWeekdays;
  final List<int> initialSelectedWeekdays;
  final Function(List<int>) onConfirm;

  const ModifyTodoCustomWeekdaysDialog({
    super.key,
    required this.availableWeekdays,
    required this.initialSelectedWeekdays,
    required this.onConfirm,
  });

  static void show(
    BuildContext context, {
    required List<int> availableWeekdays,
    required List<int> currentCustomWeekdays,
    required Function(List<int>) onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) {
        return ModifyTodoCustomWeekdaysDialog(
          availableWeekdays:
              availableWeekdays.isEmpty
                  ? [1, 2, 3, 4, 5, 6, 7]
                  : availableWeekdays,
          initialSelectedWeekdays: currentCustomWeekdays,
          onConfirm: onConfirm,
        );
      },
    );
  }

  @override
  State<ModifyTodoCustomWeekdaysDialog> createState() =>
      _ModifyTodoCustomWeekdaysDialogState();
}

class _ModifyTodoCustomWeekdaysDialogState
    extends State<ModifyTodoCustomWeekdaysDialog> {
  late List<int> _tempSelected;

  @override
  void initState() {
    super.initState();

    _tempSelected = List.from(widget.initialSelectedWeekdays);
  }

  String _getWeekdayName(int weekday) {
    const map = {
      1: 'Thứ Hai',
      2: 'Thứ Ba',
      3: 'Thứ Tư',
      4: 'Thứ Năm',
      5: 'Thứ Sáu',
      6: 'Thứ Bảy',
      7: 'Chủ Nhật',
    };

    return map[weekday] ?? '';
  }

  void _toggleDay(int day) {
    setState(() {
      if (_tempSelected.contains(day)) {
        _tempSelected.remove(day);
      } else {
        _tempSelected.add(day);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: COLORS.PRIMARY_BG,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                'Lặp lại',
                style: TextStyle(
                  color: COLORS.PRIMARY_TEXT,
                  fontWeight: FontWeight.bold,
                  fontSize: TextSizes.TITLE_18,
                ),
              ),
            ),

            const SizedBox(height: HEIGTH_SIZED_BOX_12),

            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(7, (index) {
                    final day = index + 1;
                    final isAvailable = widget.availableWeekdays.contains(day);
                    final isSelected = _tempSelected.contains(day);

                    return ListTile(
                      enabled: isAvailable,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      title: Text(
                        _getWeekdayName(day),

                        style: TextStyle(
                          color:
                              isAvailable
                                  ? COLORS.PRIMARY_TEXT
                                  : COLORS.SECONDARY_TEXT,
                          fontSize: TextSizes.TITLE_16,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      trailing:
                          isAvailable
                              ? Transform.scale(
                                scale: 1.1,
                                child: Checkbox(
                                  activeColor: COLORS.PRIMARY,
                                  checkColor: COLORS.PRIMARY_TEXT,
                                  side: BorderSide(
                                    color: COLORS.UNFOCUSED_BORDER_IP,
                                    width: 2,
                                  ),
                                  shape: const CircleBorder(),
                                  value: isSelected,
                                  onChanged: (val) => _toggleDay(day),
                                ),
                              )
                              : null,
                      onTap: isAvailable ? () => _toggleDay(day) : null,
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: HEIGTH_SIZED_BOX_12 * 2),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: COLORS.SECONDARY_BG,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Hủy',
                      style: TextStyle(
                        color: COLORS.PRIMARY_TEXT,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: WIDTH_SIZED_BOX_4 * 4),

                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: COLORS.PRIMARY,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      widget.onConfirm(_tempSelected);
                      Navigator.pop(context);
                    },
                    child: Text(
                      'OK',
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
