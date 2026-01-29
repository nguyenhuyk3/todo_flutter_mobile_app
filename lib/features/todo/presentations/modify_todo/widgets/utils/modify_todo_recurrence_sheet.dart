import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/constants/others.dart';
import '../../../../../../core/constants/sizes.dart';
import '../../../../domain/entities/enums.dart';
import '../../cubit/modify_todo_form_cubit.dart';

import 'modify_todo_custom_weekdays_dialog.dart';
import 'modify_todo_recurrence_info_dialog.dart';

class ModifyTodoRecurrenceSheet extends StatelessWidget {
  const ModifyTodoRecurrenceSheet({super.key});

  static const Map<RecurrencePattern, String> _displayMap = {
    RecurrencePattern.once: 'Một lần',
    RecurrencePattern.daily: 'Hàng ngày',
    RecurrencePattern.weekdays: 'Thứ hai đến Thứ sáu',
    RecurrencePattern.custom: 'Tùy chỉnh',
  };

  static const Map<RecurrencePattern, String> _descriptionMap = {
    RecurrencePattern.once:
        'Nếu ngày bắt đầu không phải là ngày hôm nay thì thông báo sẽ nhắc bạn vào ngày bắt đầu mà bạn đã chọn',
    RecurrencePattern.daily:
        'Công việc sẽ tự động xuất hiện lại vào tất cả các ngày trong tuần',
    RecurrencePattern.weekdays:
        'Công việc chỉ lặp lại vào các ngày làm việc (Thứ Hai đến Thứ Sáu), nghỉ Thứ 7 và CN',
    RecurrencePattern.custom:
        'Bạn có thể tự chọn các ngày cụ thể trong tuần mà công việc này sẽ diễn ra (chỉ chọn được các thứ có thể có trong thời gian diễn ra công việc)',
  };

  static void show(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      backgroundColor: COLORS.PRIMARY_BG,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (ctx) => BlocProvider.value(
            value: parentContext.read<ModifyTodoFormCubit>(),
            child: const ModifyTodoRecurrenceSheet(),
          ),
    );
  }

  void _handlePatternSelection(
    BuildContext context,
    ModifyTodoFormCubit cubit,
    RecurrencePattern pattern,
  ) {
    if (pattern == RecurrencePattern.custom) {
      Navigator.pop(context);

      ModifyTodoCustomWeekdaysDialog.show(
        context,
        availableWeekdays: cubit.state.availableWeekdays,
        currentCustomWeekdays: cubit.state.customWeekdays,
        onConfirm: (days) {
          cubit.customWeekdaysChanged(days: days);
        },
      );
    } else {
      cubit.recurrenceChanged(pattern: pattern);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ModifyTodoFormCubit>();

    return BlocBuilder<ModifyTodoFormCubit, ModifyTodoFormState>(
      buildWhen:
          (previous, current) =>
              previous.recurrencePattern != current.recurrencePattern,
      builder: (context, state) {
        final currentPattern = state.recurrencePattern;

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: COLORS.PRIMARY,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ..._displayMap.entries.map((entry) {
                final isSelected = entry.key == currentPattern;

                return InkWell(
                  onTap:
                      () => _handlePatternSelection(context, cubit, entry.key),
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
                      children: [
                        Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: TextSizes.TITLE_16,
                            fontWeight: FontWeight.w500,
                            color:
                                isSelected
                                    ? COLORS.PRIMARY
                                    : COLORS.PRIMARY_TEXT,
                          ),
                        ),

                        const SizedBox(width: WIDTH_SIZED_BOX_4 * 2),

                        GestureDetector(
                          onTap:
                              () => ModifyTodoRecurrenceInfoDialog.show(
                                context,
                                title: entry.value,
                                description: _descriptionMap[entry.key] ?? '',
                              ),
                          child: Container(
                            color: Colors.transparent,
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.info_outline,
                              // ignore: deprecated_member_use
                              color: COLORS.SECONDARY_TEXT.withOpacity(0.6),
                              size: IconSizes.ICON_20,
                            ),
                          ),
                        ),

                        const Spacer(),

                        if (isSelected)
                          Icon(
                            Icons.check,
                            color: COLORS.PRIMARY,
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
}
