import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:todo_flutter_mobile_app/core/widgets/error_displayer.dart';

import '../../../../core/constants/others.dart';
import '../../../../core/constants/sizes.dart';
import '../cubit/todo_form_cubit.dart';

class TodoDateRangeSelector extends StatelessWidget {
  const TodoDateRangeSelector({super.key});

  /// Hàm helper để lấy Text hiển thị từ State
  String _getDateText(String startedDateStr, String dueDateStr) {
    // Dành cho trường hợp thêm todo (Khi đó mới vào màn hình thì chưa có giá trị)
    if (startedDateStr.isEmpty || dueDateStr.isEmpty) {
      return "Chọn thời gian";
    }

    final start = DateTime.parse(startedDateStr);
    final end = DateTime.parse(dueDateStr);
    final startFmt = DateFormat('dd/MM/yyyy').format(start);
    final endFmt = DateFormat('dd/MM/yyyy').format(end);

    if (startFmt == endFmt) {
      return startFmt;
    }

    return "$startFmt - $endFmt";
  }

  /// Hàm helper để convert state về DateTimeRange cho DatePicker khởi tạo
  DateTimeRange? _getInitialRange(String startedDateStr, String dueDateStr) {
    // Dành cho trường hợp thêm todo (Khi đó mới vào màn hình thì chưa có giá trị)
    if (startedDateStr.isEmpty || dueDateStr.isEmpty) {
      return null;
    }
    // Dành cho trường hợp chỉnh sửa todo
    return DateTimeRange(
      start: DateTime.parse(startedDateStr),
      end: DateTime.parse(dueDateStr),
    );
  }

  /// Hàm xử lý hiển thị DatePicker
  Future<void> _pickDateRange(
    BuildContext context,
    // Nếu là thêm mới thì không cho chọn ngày trước hiện tại
    bool isAdd,
    DateTimeRange? initialRange,
  ) async {
    final DateTime now = DateTime.now();
    final firstDate = now;
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate:
          isAdd
              ? firstDate
              : now.subtract(
                const Duration(days: 365),
              ), // Cho phép xem lại lịch sử 1 chút nếu cần chỉnh sửa todo
      lastDate: DateTime(now.year + 5),
      initialDateRange: initialRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: COLORS.PRIMARY_APP,
              onPrimary: COLORS.PRIMARY_TEXT,
              secondary: COLORS.PRIMARY_APP,
              onSecondary: COLORS.SECONDARY_TEXT,
              surface: COLORS.PRIMARY_BG,
              onSurface: COLORS.PRIMARY_TEXT,
            ),
          ),
          child: child!,
        );
      },
    );
    // Update Cubit nếu user bấm "Lưu"
    if (picked != null && context.mounted) {
      context.read<TodoFormCubit>().dateRangeChanged(
        startedDate: picked.start.toIso8601String(),
        dueDate: picked.end.toIso8601String(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoFormCubit, TodoFormState>(
      builder: (context, state) {
        final dateText = _getDateText(state.startedDate, state.dueDate);
        final initialRange = _getInitialRange(state.startedDate, state.dueDate);
        final bool hasValue =
            state.startedDate.isNotEmpty && state.dueDate.isNotEmpty;
        final borderColor =
            state.showRangeDateError ? COLORS.ERROR : COLORS.FOCUSED_BORDER_IP;
        final shadowColor =
            state.showRangeDateError ? COLORS.ERROR : COLORS.PRIMARY_SHADOW;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _pickDateRange(context, true, initialRange),
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
                      Icons.calendar_month_outlined,
                      color:
                          !hasValue ? COLORS.ICON_PRIMARY : COLORS.ICON_DEFAULT,
                      size: IconSizes.ICON_20,
                    ),

                    SizedBox(width: WIDTH_SIZED_BOX_4),

                    Text(
                      "Thời gian:",
                      style: TextStyle(
                        color: COLORS.SECONDARY_TEXT,
                        fontWeight: FontWeight.bold,
                        fontSize: TextSizes.TITLE_14,
                      ),
                    ),

                    SizedBox(width: WIDTH_SIZED_BOX_4 * 10),

                    Expanded(
                      child: Text(
                        dateText,
                        style: TextStyle(
                          color:
                              !hasValue
                                  ? COLORS.SECONDARY_TEXT
                                  : COLORS.PRIMARY_TEXT,
                          fontWeight:
                              !hasValue ? FontWeight.normal : FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (state.showRangeDateError) ErrorDisplayer(message: state.error),
          ],
        );
      },
    );
  }
}
