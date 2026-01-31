import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/constants/others.dart';
import '../../../../../../core/constants/sizes.dart';
import '../../../../a_domain/entities/enums.dart';
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
        'Công việc sẽ tự động xuất hiện lại vào tất cả các ngày trong tuần trong khoảng thời gian diễn ra công việc (Từ T2 -> CN)',
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

  /// Hàm kiểm tra logic: Liệu pattern này có khả dụng với các ngày availableWeekdays không?
  bool _isPatternEnabled({
    required RecurrencePattern pattern,
    required List<int> availableWeekdays,
  }) {
    // Nếu availableWeekdays rỗng (nghĩa là chưa chọn ngày hoặc logic lỗi),
    // ta mặc định cho phép hoặc chặn tùy ý.
    // Ở đây tôi giả sử nếu rỗng thì coi như là [1..7] (thoải mái)
    // hoặc xử lý tùy theo logic cubit của bạn khởi tạo.
    // Tuy nhiên, theo logic dateRangeChanged, nó thường sẽ có dữ liệu.
    if (availableWeekdays.isEmpty) return true;

    switch (pattern) {
      case RecurrencePattern.once:
      case RecurrencePattern.daily:
      case RecurrencePattern.custom:
        return true;
      case RecurrencePattern.weekdays:
        // "Thứ 2 - Thứ 6" yêu cầu PHẢI CÓ ĐỦ [1, 2, 3, 4, 5]
        const requiredDays = [1, 2, 3, 4, 5];

        return requiredDays.every((day) => availableWeekdays.contains(day));
    }
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
      // Rebuild khi thay đổi pattern hoặc thay đổi availableWeekdays (để update trạng thái enable/disable)
      buildWhen:
          (previous, current) =>
              previous.recurrencePattern != current.recurrencePattern ||
              previous.availableWeekdays != current.availableWeekdays,
      builder: (context, state) {
        final currentPattern = state.recurrencePattern;
        // Lấy danh sách ngày khả dụng từ State (đã tính ở Cubit)
        final availableWeekdays = state.availableWeekdays;

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
                final pattern = entry.key;
                final isSelected = pattern == currentPattern;

                // 1. Kiểm tra xem pattern này có được phép enable không
                final isEnabled = _isPatternEnabled(
                  pattern: pattern,
                  availableWeekdays: availableWeekdays,
                );

                // 2. Xác định màu sắc text và icon
                final Color contentColor;
                if (!isEnabled) {
                  // Màu khi disabled (ví dụ màu xám nhạt)
                  // ignore: deprecated_member_use
                  contentColor = COLORS.SECONDARY_TEXT.withOpacity(0.3);
                } else if (isSelected) {
                  contentColor = COLORS.PRIMARY;
                } else {
                  contentColor = COLORS.PRIMARY_TEXT;
                }

                return InkWell(
                  // 3. Nếu disabled thì onTap = null -> Không bấm được
                  onTap:
                      isEnabled
                          ? () =>
                              _handlePatternSelection(context, cubit, pattern)
                          : null,
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
                            color: contentColor, // Áp dụng màu sắc đã tính
                            decoration:
                                isEnabled
                                    ? null
                                    : TextDecoration
                                        .lineThrough, // (Tuỳ chọn) Gạch ngang nếu disable
                          ),
                        ),

                        const SizedBox(width: WIDTH_SIZED_BOX_4 * 2),

                        // Info Icon (vẫn cho bấm để đọc info kể cả khi disable,
                        // hoặc disable luôn tuỳ logic của bạn. Ở đây mình để bấm được để hiểu why)
                        GestureDetector(
                          onTap:
                              () => ModifyTodoRecurrenceInfoDialog.show(
                                context,
                                title: entry.value,
                                description: _descriptionMap[pattern] ?? '',
                              ),
                          child: Container(
                            color: Colors.transparent,
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.info_outline,
                              // ignore: deprecated_member_use
                              color:
                                  isEnabled
                                      ? COLORS.SECONDARY_TEXT.withOpacity(0.6)
                                      : COLORS.SECONDARY_TEXT.withOpacity(0.2),
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
