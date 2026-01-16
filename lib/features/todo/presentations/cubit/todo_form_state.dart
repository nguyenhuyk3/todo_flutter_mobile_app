part of 'todo_form_cubit.dart';

class TodoFormState extends Equatable {
  // ===================== Input values =====================
  final String title;
  final String description;
  final TodoPriority priority;
  final TodoStatus status;
  final String startedDate; // yyyy-MM-dd
  final String dueDate; // yyyy-MM-dd
  final String? reminderAt;
  final RecurrencePattern recurrencePattern;
  final String? parentTodoId;
  final int position;
  // ===================== Validation flags =====================
  final bool showTitleError;
  final bool showDescriptionError;
  final bool showRangeDateError;
  // ===================== Submission =====================
  final FormzSubmissionStatus formzSubmissionStatus;
  final String error;
  // ===================== Validators =====================
  bool get isTitleValid => title.trim().isNotEmpty;
  bool get isDescriptionValid => description.trim().isNotEmpty;
  bool get isRangeDateValid {
    if (startedDate.isEmpty || dueDate.isEmpty) {
      return false;
    }

    final start = DateTime.tryParse(startedDate);
    final end = DateTime.tryParse(dueDate);

    if (start == null || end == null) {
      return false;
    }

    return !end.isBefore(start);
  }
  bool get isFormValid =>
      isTitleValid && isDescriptionValid && isRangeDateValid;

  const TodoFormState({
    // input
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.startedDate,
    required this.dueDate,
    this.reminderAt,
    required this.recurrencePattern,
    this.parentTodoId,
    required this.position,
    // validation
    required this.showTitleError,
    required this.showDescriptionError,
    required this.showRangeDateError,
    // submission
    required this.formzSubmissionStatus,
    this.error = '',
  });

  factory TodoFormState.initial() {
    return TodoFormState(
      title: '',
      description: '',
      priority: TodoPriority.low,
      status: TodoStatus.pending,
      startedDate: '',
      dueDate: '',
      recurrencePattern: RecurrencePattern.none,
      position: 0,
      showTitleError: false,
      showDescriptionError: false,
      showRangeDateError: false,
      formzSubmissionStatus: FormzSubmissionStatus.initial,
    );
  }

  factory TodoFormState.fromTodo(AppTodo todo) {
    return TodoFormState(
      title: todo.title,
      description: todo.description,
      priority: todo.priority,
      status: todo.status,
      startedDate: todo.startedDate.toIso8601String(),
      dueDate: todo.dueDate.toIso8601String(),
      reminderAt: todo.reminderAt?.toIso8601String(),
      recurrencePattern: todo.recurrencePattern,
      parentTodoId: todo.parentTodoId,
      position: todo.position,
      showTitleError: false,
      showDescriptionError: false,
      showRangeDateError: false,
      formzSubmissionStatus: FormzSubmissionStatus.initial,
    );
  }

  TodoFormState copyWith({
    String? title,
    String? description,
    TodoPriority? priority,
    TodoStatus? status,
    String? startedDate,
    String? dueDate,
    String? reminderAt,
    RecurrencePattern? recurrencePattern,
    String? parentTodoId,
    int? position,
    bool? showTitleError,
    bool? showDescriptionError,
    bool? showRangeDateError,
    FormzSubmissionStatus? formzSubmissionStatus,
    String? error,
  }) {
    return TodoFormState(
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      startedDate: startedDate ?? this.startedDate,
      dueDate: dueDate ?? this.dueDate,
      reminderAt: reminderAt ?? this.reminderAt,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      parentTodoId: parentTodoId ?? this.parentTodoId,
      position: position ?? this.position,
      showTitleError: showTitleError ?? this.showTitleError,
      showDescriptionError: showDescriptionError ?? this.showDescriptionError,
      showRangeDateError: showRangeDateError ?? this.showRangeDateError,
      formzSubmissionStatus:
          formzSubmissionStatus ?? this.formzSubmissionStatus,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    title,
    description,
    priority,
    status,
    startedDate,
    dueDate,
    reminderAt,
    recurrencePattern,
    parentTodoId,
    position,
    showTitleError,
    showDescriptionError,
    showRangeDateError,
    formzSubmissionStatus,
    error,
  ];
}
