import 'enums.dart';

class AppTodo {
  final String? id; // Null khi tạo mới (Database tự gen UUID)
  final String userId;
  final String? projectId;
  final String title;
  final String description;
  final TodoPriority priority;
  final TodoStatus status;
  final DateTime startedDate;
  final DateTime dueDate;
  final DateTime? reminderAt;
  final DateTime? completedAt;
  final RecurrencePattern recurrencePattern;
  final String? parentTodoId;
  final int position;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppTodo({
    this.id,
    required this.userId,
    this.projectId,
    required this.title,
    required this.description,
    this.priority = TodoPriority.low,
    this.status = TodoStatus.pending,
    required this.startedDate,
    required this.dueDate,
    this.reminderAt,
    this.completedAt,
    this.recurrencePattern = RecurrencePattern.none,
    this.parentTodoId,
    this.position = 0,
    required this.createdAt,
    required this.updatedAt,
  });
}
