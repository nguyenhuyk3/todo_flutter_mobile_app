import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/others.dart';
import '../../../../../core/constants/sizes.dart';
import '../../../domain/entities/enums.dart';
import '../cubit/modify_todo_form_cubit.dart';

class ModifyTodoRecurrenceSelector extends StatelessWidget {
  const ModifyTodoRecurrenceSelector({super.key});

  static const Map<RecurrencePattern, String> _displayMap = {
    RecurrencePattern.once: 'Một lần',
    RecurrencePattern.daily: 'Hàng ngày',
    RecurrencePattern.weekdays: 'Thứ hai đến Thứ sáu',
    RecurrencePattern.custom: 'Tùy chỉnh',
  };

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

  void _showCustomWeekdaysDialog(BuildContext context) {
    final cubit = context.read<ModifyTodoFormCubit>();
    final originalAvailable = cubit.state.availableWeekdays;
    final availableWeekdays =
        originalAvailable.isEmpty ? [1, 2, 3, 4, 5, 6, 7] : originalAvailable;
    List<int> tempSelected = List.from(cubit.state.customWeekdays);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: COLORS.PRIMARY_BG,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 24.0,
              ), // Padding bên ngoài dialog
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
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
                            final day = index + 1; // 1 -> 7
                            final isAvailable = availableWeekdays.contains(day);
                            final isSelected = tempSelected.contains(day);

                            return ListTile(
                              enabled: isAvailable,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              title: Text(
                                _getWeekdayName(day),
                                style: TextStyle(
                                  color:
                                      isAvailable
                                          ? COLORS.PRIMARY_TEXT
                                          : COLORS.SECONDARY_TEXT,
                                  fontSize: TextSizes.TITLE_16,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                ),
                              ),
                              trailing:
                                  isAvailable
                                      ? Transform.scale(
                                        scale: 1.1,
                                        child: Checkbox(
                                          activeColor: COLORS.PRIMARY_APP,
                                          checkColor: COLORS.PRIMARY_TEXT,
                                          side: BorderSide(
                                            color: COLORS.UNFOCUSED_BORDER_IP,
                                            width: 2,
                                          ),
                                          shape: const CircleBorder(),
                                          value: isSelected,
                                          onChanged: (val) {
                                            setState(() {
                                              if (val == true) {
                                                tempSelected.add(day);
                                              } else {
                                                tempSelected.remove(day);
                                              }
                                            });
                                          },
                                        ),
                                      )
                                      : null,
                              onTap:
                                  isAvailable
                                      ? () {
                                        setState(() {
                                          if (isSelected) {
                                            tempSelected.remove(day);
                                          } else {
                                            tempSelected.add(day);
                                          }
                                        });
                                      }
                                      : null,
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

                        const SizedBox(
                          width: WIDTH_SIZED_BOX_4 * 4,
                        ), // Khoảng cách giữa 2 nút

                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: COLORS.PRIMARY_APP,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              cubit.customWeekdaysChanged(days: tempSelected);

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
          },
        );
      },
    );
  }

  void _showRecurrencePicker(
    BuildContext parentContext,
    RecurrencePattern currentPattern,
  ) {
    final cubit = parentContext.read<ModifyTodoFormCubit>();

    showModalBottomSheet(
      context: parentContext,
      backgroundColor: COLORS.PRIMARY_BG,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: COLORS.PRIMARY_APP,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ..._displayMap.entries.map((entry) {
                final isSelected = entry.key == currentPattern;

                return InkWell(
                  onTap: () {
                    if (entry.key == RecurrencePattern.custom) {
                      Navigator.pop(context);

                      _showCustomWeekdaysDialog(parentContext);
                    } else {
                      cubit.recurrenceChanged(pattern: entry.key);

                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: COLORS.UNFOCUSED_BORDER_IP,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: TextSizes.TITLE_16,
                            fontWeight: FontWeight.w500,
                            color:
                                isSelected
                                    ? COLORS.PRIMARY_APP
                                    : COLORS.PRIMARY_TEXT,
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check,
                            color: COLORS.PRIMARY_APP,
                            size: IconSizes.ICON_20,
                          ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: HEIGTH_SIZED_BOX_12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ModifyTodoFormCubit, ModifyTodoFormState>(
      builder: (context, state) {
        final currentPattern = state.recurrencePattern;
        String displayValue = _displayMap[currentPattern] ?? 'Một lần';
        // Nếu đang chọn custom -> hiển thị chi tiết (vd: T2, T4)
        if (currentPattern == RecurrencePattern.custom &&
            state.customWeekdays.isNotEmpty) {
          final selected = List<int>.from(state.customWeekdays)..sort();
          // Logic hiển thị thông minh: Nếu chọn cả tuần thì hiện "Hàng ngày"
          if (selected.length == 7) {
            displayValue = 'Từ T2 đến CN';
          } else {
            final names = selected
                .map((day) {
                  return day == 7 ? "CN" : "T${day + 1}";
                })
                .join(', ');
            displayValue = names;
          }
        }

        return GestureDetector(
          onTap: () => _showRecurrencePicker(context, currentPattern),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: COLORS.INPUT_BG,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: COLORS.FOCUSED_BORDER_IP, width: 1),
              boxShadow: [
                BoxShadow(
                  color: COLORS.PRIMARY_SHADOW,
                  offset: const Offset(0, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.repeat,
                  color: COLORS.ICON_PRIMARY,
                  size: IconSizes.ICON_20,
                ),

                SizedBox(width: WIDTH_SIZED_BOX_4),

                Text(
                  "Lặp lại: ",
                  style: TextStyle(
                    color: COLORS.SECONDARY_TEXT,
                    fontWeight: FontWeight.bold,
                    fontSize: TextSizes.TITLE_14,
                  ),
                ),

                SizedBox(width: WIDTH_SIZED_BOX_4 * 14),

                ConstrainedBox(
                  // Giới hạn width text
                  constraints: const BoxConstraints(maxWidth: 150),
                  child: Text(
                    displayValue,
                    style: TextStyle(
                      color: COLORS.PRIMARY_TEXT,
                      fontWeight: FontWeight.bold,
                      fontSize: TextSizes.TITLE_14,
                    ),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const Spacer(),

                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: IconSizes.ICON_16,
                  color: COLORS.ICON_PRIMARY,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
