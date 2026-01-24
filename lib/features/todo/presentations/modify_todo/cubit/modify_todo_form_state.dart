part of 'modify_todo_form_cubit.dart';

class ModifyTodoFormState extends Equatable {
  // ===================== Input values =====================
  final String title;
  final String description;
  final String? projectId;
  final TodoPriority priority;
  final TodoStatus status;
  final String startedDate; // yyyy-MM-dd
  final String dueDate; // yyyy-MM-dd
  final String? reminderAt; // HH:mm
  final RecurrencePattern recurrencePattern;
  final String? parentTodoId;
  final int position;

  // ===================== Validation flags =====================
  final bool showTitleError;
  final bool showDescriptionError;
  final bool showRangeDateError;
  final bool showReminderError;

  // ===================== Submission =====================
  final FormzSubmissionStatus formzSubmissionStatus;
  final String error;

  // ===================== Validations =====================
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

  const ModifyTodoFormState({
    // input
    required this.title,
    required this.description,
    this.projectId,
    this.priority = TodoPriority.low,
    required this.status,
    required this.startedDate,
    required this.dueDate,
    this.reminderAt,
    this.recurrencePattern = RecurrencePattern.none,
    this.parentTodoId,
    required this.position,

    // validation
    required this.showTitleError,
    required this.showDescriptionError,
    required this.showRangeDateError,
    required this.showReminderError,

    // submission
    required this.formzSubmissionStatus,
    this.error = '',
  });

  factory ModifyTodoFormState.initial() {
    return ModifyTodoFormState(
      title: '',
      description: '',
      projectId: null,
      priority: TodoPriority.low,
      status: TodoStatus.pending,
      startedDate: '',
      dueDate: '',
      reminderAt: null,
      recurrencePattern: RecurrencePattern.none,
      parentTodoId: null,
      position: 0,

      showTitleError: false,
      showDescriptionError: false,
      showRangeDateError: false,
      showReminderError: false,

      formzSubmissionStatus: FormzSubmissionStatus.initial,
    );
  }

  factory ModifyTodoFormState.fromTodo(AppTodo todo) {
    return ModifyTodoFormState(
      title: todo.title,
      description: todo.description,
      projectId: todo.projectId,
      priority: todo.priority,
      status: todo.status,
      startedDate: todo.startedDate.toIso8601String(),
      dueDate: todo.dueDate.toIso8601String(),
      reminderAt: todo.recurrence?.reminderAt,
      recurrencePattern: RecurrencePattern.daily,
      parentTodoId: todo.parentTodoId,
      position: todo.position,

      showTitleError: false,
      showDescriptionError: false,
      showRangeDateError: false,
      showReminderError: false,

      formzSubmissionStatus: FormzSubmissionStatus.initial,
    );
  }

  ModifyTodoFormState copyWith({
    String? title,
    String? description,
    String? Function()? projectId,
    TodoPriority? priority,
    TodoStatus? status,
    String? startedDate,
    String? dueDate,
    String? Function()? reminderAt,
    RecurrencePattern? recurrencePattern,
    String? Function()? parentTodoId,
    int? position,

    bool? showTitleError,
    bool? showDescriptionError,
    bool? showRangeDateError,
    bool? showReminderError,

    FormzSubmissionStatus? formzSubmissionStatus,
    String? error,
  }) {
    return ModifyTodoFormState(
      title: title ?? this.title,
      description: description ?? this.description,
      projectId: projectId != null ? projectId() : this.projectId,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      startedDate: startedDate ?? this.startedDate,
      dueDate: dueDate ?? this.dueDate,
      reminderAt: reminderAt != null ? reminderAt() : this.reminderAt,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      parentTodoId: parentTodoId != null ? parentTodoId() : this.parentTodoId,
      position: position ?? this.position,

      showTitleError: showTitleError ?? this.showTitleError,
      showDescriptionError: showDescriptionError ?? this.showDescriptionError,
      showRangeDateError: showRangeDateError ?? this.showRangeDateError,
      showReminderError: showReminderError ?? this.showReminderError,

      formzSubmissionStatus:
          formzSubmissionStatus ?? this.formzSubmissionStatus,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    title,
    description,
    projectId,
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
