import 'enums.dart';

class AppRecurrence {
  final String? id;
  final String? todoId;
  final RecurrencePattern recurrencePattern;
  final DateTime startedDate;
  final DateTime dueDate;
  final String? reminderAt;
  final DateTime createdAt;

  const AppRecurrence({
    this.id,
    this.todoId,
    required this.recurrencePattern,
    required this.startedDate,
    required this.dueDate,
    this.reminderAt,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'todo_id': todoId,
      'recurrence_pattern': recurrencePattern.name,
      'started_date': startedDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'reminder_at': reminderAt,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
