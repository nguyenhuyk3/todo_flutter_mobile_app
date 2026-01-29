import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/others.dart';
import '../../../../../core/constants/sizes.dart';
import '../../../domain/entities/enums.dart';
import '../cubit/modify_todo_form_cubit.dart';
import 'utils/modify_todo_recurrence_sheet.dart';

class ModifyTodoRecurrenceSelector extends StatelessWidget {
  const ModifyTodoRecurrenceSelector({super.key});

  String _getDisplayText(ModifyTodoFormState state) {
    const displayMap = {
      RecurrencePattern.once: 'Một lần',
      RecurrencePattern.daily: 'Hàng ngày',
      RecurrencePattern.weekdays: 'Thứ hai đến Thứ sáu',
      RecurrencePattern.custom: 'Tùy chỉnh',
    };

    final currentPattern = state.recurrencePattern;
    String displayValue = displayMap[currentPattern] ?? 'Một lần';

    if (currentPattern == RecurrencePattern.custom &&
        state.customWeekdays.isNotEmpty) {
      final selected = List<int>.from(state.customWeekdays)..sort();
      if (selected.length == 7) {
        displayValue = 'Từ T2 đến CN';
      } else {
        final names = selected
            .map((day) => day == 7 ? "CN" : "T${day + 1}")
            .join(', ');
        displayValue = names;
      }
    }
    return displayValue;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ModifyTodoFormCubit, ModifyTodoFormState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () => ModifyTodoRecurrenceSheet.show(context),
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
                  constraints: const BoxConstraints(maxWidth: 150),
                  child: Text(
                    _getDisplayText(state),
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
