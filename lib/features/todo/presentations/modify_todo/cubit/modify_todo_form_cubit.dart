import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import 'package:todo_flutter_mobile_app/core/errors/failure.dart';
import 'package:todo_flutter_mobile_app/features/todo/domain/entities/app_recurrence.dart';

import '../../../../../core/constants/others.dart';
import '../../../domain/entities/app_todo.dart';
import '../../../domain/entities/enums.dart';

part 'modify_todo_form_state.dart';

class ModifyTodoFormCubit extends Cubit<ModifyTodoFormState> {
  ModifyTodoFormCubit({AppTodo? initialTodo})
    : super(
        initialTodo == null
            ? ModifyTodoFormState.initial()
            : ModifyTodoFormState.fromTodo(initialTodo),
      );

  // ===== Logic Tính toán thứ khả dụng =====
  List<int> _calculateAvailableWeekdays(String startStr, String endStr) {
    if (startStr.isEmpty || endStr.isEmpty) {
      return [];
    }

    final start = DateTime.parse(startStr);
    final end = DateTime.parse(endStr);

    // Nếu khoảng cách ngày >= 6 ngày (tức là trọn 1 tuần), thì TẤT CẢ các thứ đều khả dụng
    if (end.difference(start).inDays >= 6) {
      return [1, 2, 3, 4, 5, 6, 7];
    }
    // Nếu khoảng cách < 1 tuần, duyệt từng ngày để xem nó là thứ mấy
    final List<int> days = [];
    DateTime current = start;
    // convert end về date-only để so sánh (tránh lỗi giờ giấc)
    final dateEnd = DateTime(end.year, end.month, end.day);

    while (!DateTime(
      current.year,
      current.month,
      current.day,
    ).isAfter(dateEnd)) {
      if (!days.contains(current.weekday)) {
        days.add(current.weekday);
      }

      current = current.add(const Duration(days: 1));
    }

    days.sort(); // 1->7

    return days;
  }

  void titleChanged({required String title}) {
    emit(state.copyWith(title: title, showTitleError: false));
  }

  void descriptionChanged({required String description}) {
    emit(state.copyWith(description: description, showDescriptionError: false));
  }

  void projectChanged({String? projectId}) {
    if (projectId == null) {
      // TRƯỜNG HỢP: Chọn "Không" (Project = null)
      // UI: Ẩn "Công việc cha", Hiện "Lặp lại"
      // => Cần xóa dữ liệu: parentTodoId
      emit(
        state.copyWith(
          projectId: () => null,
          parentTodoId: () => null, // Reset việc cha về null
        ),
      );

      final availableWeekdays = _calculateAvailableWeekdays(
        state.startedDate,
        state.dueDate,
      );

      emit(state.copyWith(availableWeekdays: availableWeekdays));
    } else {
      // TRƯỜNG HỢP: Có chọn Dự án
      // UI: Hiện "Công việc cha", Ẩn "Lặp lại" & "Giờ"
      // => Cần xóa dữ liệu: recurrencePattern, reminderAt
      emit(
        state.copyWith(
          projectId: () => projectId,
          recurrencePattern: RecurrencePattern.once, // Reset lặp lại về none
          reminderAt: () => null, // Reset giờ nhắc
          availableWeekdays: [],
          customWeekdays: [],
        ),
      );
    }
  }

  void parentTodoChanged(String? parentTodoId) {
    emit(state.copyWith(parentTodoId: () => parentTodoId));
  }

  void recurrenceChanged({required RecurrencePattern pattern}) {
    if (pattern == RecurrencePattern.once) {
      // TRƯỜNG HỢP 1: Chọn "Một lần" (Không lặp lại)
      emit(
        state.copyWith(
          recurrencePattern: RecurrencePattern.once,
          reminderAt: () => null, // Reset giờ nhắc
          customWeekdays: const [], // Clear danh sách tùy chỉnh
        ),
      );
    } else if (pattern == RecurrencePattern.custom) {
      // TRƯỜNG HỢP 2: Chọn "Tùy chỉnh" (Logic mở dialog sẽ xử lý customWeekdays sau)
      // Ở đây chỉ cập nhật pattern, GIỮ NGUYÊN customWeekdays nếu đã có
      emit(state.copyWith(recurrencePattern: pattern));
    } else {
      // TRƯỜNG HỢP 3: Các mẫu khác (Hàng ngày, T2-T6...)
      // Giữ nguyên giờ nhắc (nếu có), Cập nhật pattern
      // Clear customWeekdays để tránh dữ liệu rác
      emit(
        state.copyWith(
          recurrencePattern: pattern,
          customWeekdays: const [], // Clear danh sách tùy chỉnh
        ),
      );
    }
  }

  void dateRangeChanged({
    required String startedDate,
    required String dueDate,
  }) {
    final availableWeekdays = _calculateAvailableWeekdays(startedDate, dueDate);
    final currentCustom = List<int>.from(state.customWeekdays);

    currentCustom.removeWhere((day) => !availableWeekdays.contains(day));

    emit(
      state.copyWith(
        startedDate: startedDate,
        dueDate: dueDate,
        availableWeekdays: availableWeekdays, // Cập nhật availableWeekdays
        customWeekdays: currentCustom, // Cập nhập lại list chọn nếu bị conflict
        showRangeDateError: false,
      ),
    );
  }

  void reminderTimeChanged({required TimeOfDay time}) {
    // Logic: TimeOfDay(10, 5) -> "10:05"
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final timeString = '$hour:$minute';

    emit(state.copyWith(reminderAt: () => timeString));
  }

  void priorityChanged(TodoPriority priority) {
    emit(state.copyWith(priority: priority));
  }

  void customWeekdaysChanged({required List<int> days}) {
    emit(
      state.copyWith(
        customWeekdays: days,
        // Nếu user chọn custom days -> Pattern tự động set là custom
        recurrencePattern: RecurrencePattern.custom,
      ),
    );
  }

  AppTodo? submitForm({required String userId}) {
    // Reset trạng thái submit
    emit(
      state.copyWith(
        formzSubmissionStatus: FormzSubmissionStatus.inProgress,
        showTitleError: false,
        showDescriptionError: false,
        showRangeDateError: false,
      ),
    );
    // 1. Validate Title
    if (state.title.trim().isEmpty) {
      emit(
        state.copyWith(
          showTitleError: true,
          formzSubmissionStatus: FormzSubmissionStatus.failure,
          error: ErrorInformation.EMPTY_TITLE.message,
        ),
      );

      return null;
    }
    // 2. Validate Description
    if (state.description.trim().isEmpty) {
      emit(
        state.copyWith(
          showDescriptionError: true,
          formzSubmissionStatus: FormzSubmissionStatus.failure,
          error: ErrorInformation.EMPTY_DESCRIPTION.message,
        ),
      );

      return null;
    }
    // 3. Validate Date range
    if (!state.isRangeDateValid) {
      emit(
        state.copyWith(
          showRangeDateError: true,
          formzSubmissionStatus: FormzSubmissionStatus.failure,
          error: ErrorInformation.EMPTY_DATE_RANGE.message,
        ),
      );

      return null;
    }
    // 4. Validate Reminder time (nếu có chọn lặp lại)
    if (state.recurrencePattern != RecurrencePattern.once) {
      if (state.reminderAt == null || state.reminderAt!.isEmpty) {
        emit(
          state.copyWith(
            showReminderError: true,
            formzSubmissionStatus: FormzSubmissionStatus.failure,
            error: ErrorInformation.EMPTY_REMINDER_TIME.message,
          ),
        );

        return null;
      }
    }
    // 5. Thành công → build AppTodo
    emit(state.copyWith(formzSubmissionStatus: FormzSubmissionStatus.success));

    final todo = AppTodo(
      userId: userId,
      title: state.title.trim(),
      description: state.description.trim(),
      projectId: state.projectId,
      parentTodoId: state.parentTodoId,
      recurrence:
          state.recurrencePattern != RecurrencePattern.once
              ? AppRecurrence(
                recurrencePattern: state.recurrencePattern,
                startedDate: DateTime.parse(state.startedDate),
                dueDate: DateTime.parse(state.dueDate),
                reminderAt: state.reminderAt,
                createdAt: DateTime.now(),
              )
              : null,
      startedDate: DateTime.parse(state.startedDate),
      dueDate: DateTime.parse(state.dueDate),
      priority: state.priority,
      status: state.status,
      position: state.position,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    LOGGER.i(state.toJson());

    return todo;
  }
}
