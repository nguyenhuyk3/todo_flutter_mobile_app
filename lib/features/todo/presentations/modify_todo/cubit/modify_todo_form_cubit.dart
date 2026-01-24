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
    } else {
      // TRƯỜNG HỢP: Có chọn Dự án
      // UI: Hiện "Công việc cha", Ẩn "Lặp lại" & "Giờ"
      // => Cần xóa dữ liệu: recurrencePattern, reminderAt
      emit(
        state.copyWith(
          projectId: () => projectId,
          recurrencePattern: RecurrencePattern.none, // Reset lặp lại về none
          reminderAt: () => null, // Reset giờ nhắc
        ),
      );
    }
  }

  void parentTodoChanged(String? parentTodoId) {
    emit(state.copyWith(parentTodoId: () => parentTodoId));
  }

  void recurrenceChanged({required RecurrencePattern pattern}) {
    if (pattern == RecurrencePattern.none) {
      // TRƯỜNG HỢP: Chọn "Không lặp lại"
      // UI: Sẽ ẩn widget chọn Giờ (TimeSelector)
      // Logic: Reset biến thời gian nhắc (reminderAt) về null
      emit(
        state.copyWith(
          recurrencePattern: RecurrencePattern.none,
          reminderAt: () => null, // Quan trọng: Xóa dữ liệu giờ
        ),
      );
    } else {
      // TRƯỜNG HỢP: Chọn Lặp lại (Ngày/Tuần/Tháng...)
      // Giữ nguyên logic cũ, cập nhật pattern mới.
      // reminderAt giữ nguyên (nếu đã chọn trước đó) hoặc null
      emit(state.copyWith(recurrencePattern: pattern));
    }
  }

  void dateRangeChanged({
    required String startedDate,
    required String dueDate,
  }) {
    emit(
      state.copyWith(
        startedDate: startedDate,
        dueDate: dueDate,
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
    if (state.recurrencePattern != RecurrencePattern.none) {
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

    final appTodo = AppTodo(
      userId: userId,
      title: state.title.trim(),
      description: state.description.trim(),
      projectId: state.projectId,
      parentTodoId: state.parentTodoId,
      recurrence:
          state.recurrencePattern != RecurrencePattern.none
              ? AppRecurrence(
                recurrencePattern: RecurrencePattern.daily,
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

    LOGGER.i(appTodo.toJson());

    return AppTodo(
      userId: userId,
      title: state.title.trim(),
      description: state.description.trim(),
      parentTodoId: state.parentTodoId,
      recurrence: AppRecurrence(
        recurrencePattern: RecurrencePattern.daily,
        startedDate: DateTime.parse(state.startedDate),
        dueDate: DateTime.parse(state.dueDate),
        createdAt: DateTime.now(),
      ),
      startedDate: DateTime.parse(state.startedDate),
      dueDate: DateTime.parse(state.dueDate),
      priority: state.priority,
      status: state.status,
      position: state.position,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
