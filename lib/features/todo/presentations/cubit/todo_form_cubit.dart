import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

import '../../domain/entities/app_todo.dart';
import '../../domain/entities/enums.dart';

part 'todo_form_state.dart';

class TodoFormCubit extends Cubit<TodoFormState> {
  TodoFormCubit({AppTodo? initialTodo})
    : super(
        initialTodo == null
            ? TodoFormState.initial()
            : TodoFormState.fromTodo(initialTodo),
      );

  void titleChanged(String value) {
    emit(state.copyWith(title: value, showTitleError: false));
  }

  void descriptionChanged(String value) {
    emit(state.copyWith(description: value, showDescriptionError: false));
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

  AppTodo? submitForm(String userId) {
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
    if (!state.isTitleValid) {
      emit(
        state.copyWith(
          showTitleError: true,
          formzSubmissionStatus: FormzSubmissionStatus.failure,
          error: '',
        ),
      );

      return null;
    }
    // 2. Validate Description
    if (!state.isDescriptionValid) {
      emit(
        state.copyWith(
          showDescriptionError: true,
          formzSubmissionStatus: FormzSubmissionStatus.failure,
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
        ),
      );
      return null;
    }

    // 4. Thành công → build AppTodo
    emit(state.copyWith(formzSubmissionStatus: FormzSubmissionStatus.success));

    return AppTodo(
      userId: userId,
      title: state.title.trim(),
      description: state.description.trim(),
      priority: state.priority,
      status: state.status,
      startedDate: DateTime.parse(state.startedDate),
      dueDate: DateTime.parse(state.dueDate),
      reminderAt:
          state.reminderAt != null ? DateTime.parse(state.reminderAt!) : null,
      recurrencePattern: state.recurrencePattern,
      parentTodoId: state.parentTodoId,
      position: state.position,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
