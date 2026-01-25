import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/others.dart';
import '../../../../../core/constants/sizes.dart';
import '../../../../../core/widgets/error_displayer.dart';
import '../cubit/modify_todo_form_cubit.dart';

class ModifyTodoTimeSelector extends StatelessWidget {
  const ModifyTodoTimeSelector({super.key});

  /// 1. Hiển thị Text
  /// Vì state đã lưu dạng "HH:mm" rồi nên ta hiển thị trực tiếp
  String _getTimeText(String? reminderAt) {
    if (reminderAt == null || reminderAt.isEmpty) {
      return "Chọn giờ";
    }

    return reminderAt; // Trả về "09:05"
  }

  /// 2. Helper để chuyển "HH:mm" thành TimeOfDay cho TimePicker
  TimeOfDay _parseTime(String timeString) {
    try {
      final parts = timeString.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return TimeOfDay.now();
    }
  }

  /// 3. Hiển thị TimePicker
  Future<void> _pickTime(
    BuildContext context,
    String? currentReminderAt, // Nhận vào String thay vì DateTime
  ) async {
    // Convert String "HH:mm" -> TimeOfDay để hiển thị đồng hồ đúng vị trí cũ
    final initialTime =
        currentReminderAt != null
            ? _parseTime(currentReminderAt)
            : TimeOfDay.now();

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: 'CHỌN GIỜ NHẮC NHỞ',
      cancelText: 'ĐÓNG',
      confirmText: 'XONG',
      errorInvalidText: 'Giờ không hợp lệ',
      hourLabelText: 'Giờ',
      minuteLabelText: 'Phút',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: COLORS.PRIMARY_APP,
                onPrimary: COLORS.PRIMARY_TEXT,
                secondary: COLORS.PRIMARY_APP,
                onSecondary: COLORS.SECONDARY_TEXT,
                surface: COLORS.PRIMARY_BG,
                onSurface: COLORS.PRIMARY_TEXT,
              ),
              timePickerTheme: TimePickerThemeData(
                backgroundColor: COLORS.PRIMARY_BG,
                dialHandColor: COLORS.PRIMARY_APP,
                dialBackgroundColor: COLORS.SECONDARY_BG,
                hourMinuteTextColor: COLORS.PRIMARY_TEXT,
                dayPeriodTextColor: COLORS.PRIMARY_TEXT,
                helpTextStyle: TextStyle(
                  color: COLORS.PRIMARY_TEXT,
                  fontWeight: FontWeight.bold,
                  fontSize: TextSizes.TITLE_14,
                ),
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null && context.mounted) {
      context.read<ModifyTodoFormCubit>().reminderTimeChanged(time: picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ModifyTodoFormCubit, ModifyTodoFormState>(
      builder: (context, state) {
        final reminderAt = state.reminderAt;
        final borderColor =
            state.showReminderError ? COLORS.ERROR : COLORS.FOCUSED_BORDER_IP;
        final shadowColor =
            state.showReminderError ? COLORS.ERROR : COLORS.PRIMARY_SHADOW;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              // Gọi hàm pickTime nội bộ
              onTap: () => _pickTime(context, reminderAt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: COLORS.INPUT_BG,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      offset: const Offset(0, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time_filled,
                      color:
                          reminderAt == null
                              ? COLORS.ICON_PRIMARY
                              : COLORS.ICON_DEFAULT,
                      size: IconSizes.ICON_20,
                    ),

                    SizedBox(width: WIDTH_SIZED_BOX_4),

                    Text(
                      "Giờ:",
                      style: TextStyle(
                        color: COLORS.SECONDARY_TEXT,
                        fontWeight: FontWeight.bold,
                        fontSize: TextSizes.TITLE_14,
                      ),
                    ),

                    SizedBox(width: WIDTH_SIZED_BOX_4 * 21),

                    Expanded(
                      child: Text(
                        _getTimeText(reminderAt),
                        style: TextStyle(
                          color:
                              reminderAt == null
                                  ? COLORS.SECONDARY_TEXT
                                  : COLORS.PRIMARY_TEXT,
                          fontWeight:
                              reminderAt == null
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (state.showReminderError) ErrorDisplayer(message: state.error),
          ],
        );
      },
    );
  }
}
