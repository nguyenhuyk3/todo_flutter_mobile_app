import 'enums.dart';

class RecurrenceEntity {
  final String? id;
  final String? todoId;
  final RecurrencePattern recurrencePattern;
  final String? reminderAt;

  const RecurrenceEntity({
    this.id,
    this.todoId,
    required this.recurrencePattern,
    this.reminderAt,
  });
  // Dùng để in thông tin ra log để debug
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'todo_id': todoId,
      'recurrence_pattern': recurrencePattern.name,
      'reminder_at': reminderAt,
    };
  }
}
