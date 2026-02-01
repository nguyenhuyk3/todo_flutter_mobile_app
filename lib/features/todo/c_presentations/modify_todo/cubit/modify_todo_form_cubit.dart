import 'package:flutter/material.dart';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import 'package:todo_flutter_mobile_app/core/errors/failure.dart';
import 'package:todo_flutter_mobile_app/features/todo/b_data/models/recurrence_model.dart';
import 'package:todo_flutter_mobile_app/features/todo/b_data/models/todo_model.dart';

import '../../../../../core/constants/keys.dart';
import '../../../../../core/constants/others.dart';
import '../../../a_domain/entities/enums.dart';
import '../../../a_domain/entities/todo_entity.dart';

part 'modify_todo_form_state.dart';

class ModifyTodoFormCubit extends Cubit<ModifyTodoFormState> {
  ModifyTodoFormCubit({TodoEntity? initialTodo})
    : super(
        initialTodo == null
            ? ModifyTodoFormState.initial()
            : ModifyTodoFormState.fromTodo(initialTodo),
      );

  /// Tính danh sách các thứ trong tuần (1–7) xuất hiện trong khoảng thời gian
  /// từ [startStr] đến [endStr] (bao gồm cả hai đầu mút).
  ///
  /// Tham số:
  /// - [startStr], [endStr]: chuỗi ngày ở định dạng ISO-8601 (yyyy-MM-dd hoặc full datetime).
  ///
  /// Quy tắc xử lý:
  /// 1. Nếu một trong hai chuỗi rỗng → trả về danh sách rỗng.
  /// 2. Nếu khoảng cách ngày >= 6 (tức bao phủ tối thiểu 7 ngày liên tiếp)
  ///    → mặc định trả về toàn bộ các thứ [1,2,3,4,5,6,7].
  /// 3. Nếu < 7 ngày:
  ///    → duyệt từng ngày trong khoảng, thu thập `DateTime.weekday`
  ///      và loại bỏ trùng lặp.
  ///
  /// Lưu ý kỹ thuật:
  /// - Kết quả sử dụng chuẩn `DateTime.weekday` của Dart:
  ///     1 = Monday, ..., 7 = Sunday.
  /// - So sánh theo "date-only" (bỏ giờ/phút/giây) để tránh sai lệch do time component.
  /// - Khoảng thời gian là inclusive (bao gồm cả start và end).
  ///
  /// Ví dụ:
  /// start = 2026-01-01 (Thu)
  /// end   = 2026-01-03 (Sat)
  /// → [4,5,6]
  ///
  /// start = 2026-01-01
  /// end   = 2026-01-08
  /// → [1,2,3,4,5,6,7]
  ///
  /// Trả về:
  /// - Các weekday đã sắp xếp tăng dần.
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
          parentTodoId: () => null, // Reset parentTodo về null
        ),
      );

      // !! Hiện tại chưa biết là có cần 2 đoạn code phía dưới hay không
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
          recurrencePattern:
              RecurrencePattern
                  .once, // Reset lặp lại về none (mặc định sẽ là once)
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
          reminderAt: () => null, // Reset giờ nhắc (Sẽ không hiển thị lên UI)
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

  Future<TodoModel?> submitForm() async {
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

    final userId = await SECURE_STORAGE.read(key: SecureStorageKeys.USER_ID);
    final todo = TodoModel(
      userId: userId!,
      title: state.title.trim(),
      description: state.description.trim(),
      recurrence:
          state.recurrencePattern != RecurrencePattern.once
              ? RecurrenceModel(
                recurrencePattern: state.recurrencePattern,
                reminderAt: state.reminderAt,
              )
              : null,
      startedDate: DateTime.parse(state.startedDate),
      dueDate: DateTime.parse(state.dueDate),
      priority: state.priority,
      status: state.status,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return todo;
  }
}
