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

  // ===================== Recurrence options =====================
  // Danh sách các thứ (1=T2, ..., 7=CN) khả dụng trong DateRange
  final List<int> availableWeekdays;

  /// Danh sách các thứ người dùng đã chọn khi chọn Custom
  final List<int> customWeekdays;

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
    this.recurrencePattern = RecurrencePattern.once,
    this.parentTodoId,
    required this.position,

    this.availableWeekdays = const [],
    this.customWeekdays = const [],

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
      recurrencePattern: RecurrencePattern.once,
      parentTodoId: null,
      position: 0,

      availableWeekdays: const [],
      customWeekdays: const [],

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
      recurrencePattern: todo.recurrence!.recurrencePattern,
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

    List<int>? availableWeekdays,
    List<int>? customWeekdays,

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

      availableWeekdays: availableWeekdays ?? this.availableWeekdays,
      customWeekdays: customWeekdays ?? this.customWeekdays,

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

    availableWeekdays,
    customWeekdays,

    showTitleError,
    showDescriptionError,
    showRangeDateError,

    formzSubmissionStatus,
    error,
  ];

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'projectId': projectId,
      'priority': priority.name,
      'status': status.name,
      'startedDate': startedDate,
      'dueDate': dueDate,
      'reminderAt': reminderAt,
      'recurrencePattern': recurrencePattern.name,
      'parentTodoId': parentTodoId,
      'position': position,

      'availableWeekdays': availableWeekdays,
      'customWeekdays': customWeekdays,

      'showTitleError': showTitleError,
      'showDescriptionError': showDescriptionError,
      'showRangeDateError': showRangeDateError,
      'showReminderError': showReminderError,

      'formzSubmissionStatus': formzSubmissionStatus.name,
      'error': error,
    };
  }
}
