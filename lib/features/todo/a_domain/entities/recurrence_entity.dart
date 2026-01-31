import 'enums.dart';

class RecurrenceEntity {
  final String? id;
  final String? todoId;
  final RecurrencePattern recurrencePattern;
  final String? reminderAt;
  final DateTime createdAt;

  const RecurrenceEntity({
    this.id,
    this.todoId,
    required this.recurrencePattern,
    this.reminderAt,
    required this.createdAt,
  });
  // Dùng để in thông tin ra log để debug
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'todo_id': todoId,
      'recurrence_pattern': recurrencePattern.name,
      'reminder_at': reminderAt,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
