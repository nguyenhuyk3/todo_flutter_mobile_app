import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/others.dart';
import '../../../../core/constants/sizes.dart';
import '../../domain/entities/enums.dart';
import '../cubit/todo_form_cubit.dart';

class TodoRecurrenceSelector extends StatelessWidget {
  const TodoRecurrenceSelector({super.key});

  // Map hiển thị: Enum -> Tiếng Việt
  // Giả sử enum của bạn có các giá trị tương ứng
  static const Map<RecurrencePattern, String> _displayMap = {
    RecurrencePattern.none: 'Không lặp lại',
    RecurrencePattern.daily: 'Hàng ngày',
    RecurrencePattern.weekly: 'Hàng tuần',
    RecurrencePattern.monthly: 'Hàng tháng',
    RecurrencePattern.yearly: 'Hàng năm',
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoFormCubit, TodoFormState>(
      builder: (context, state) {
        final currentPattern = state.recurrencePattern;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 14),
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
                "Lặp lại:",
                style: TextStyle(
                  color: COLORS.SECONDARY_TEXT,
                  fontWeight: FontWeight.bold,
                  fontSize: TextSizes.TITLE_14,
                ),
              ),

              const SizedBox(width: WIDTH_SIZED_BOX_4 * 15),

              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<RecurrencePattern>(
                    value: currentPattern,
                    dropdownColor: COLORS.PRIMARY_BG,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey,
                    ),
                    // style: const TextStyle(fontSize: 15),
                    isExpanded: true,
                    onChanged: (RecurrencePattern? newValue) {
                      if (newValue != null) {
                        context.read<TodoFormCubit>().recurrenceChanged(
                          pattern: newValue,
                        );
                      }
                    },
                    items:
                        _displayMap.entries
                            .map<DropdownMenuItem<RecurrencePattern>>((entry) {
                              final isSelected = entry.key == currentPattern;

                              return DropdownMenuItem<RecurrencePattern>(
                                value: entry.key,
                                child: Text(
                                  entry.value,
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? COLORS.PRIMARY_TEXT
                                            : COLORS.SECONDARY_TEXT,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              );
                            })
                            .toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
