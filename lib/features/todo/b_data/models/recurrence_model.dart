import '../../a_domain/entities/recurrence_entity.dart';
import '../../a_domain/entities/enums.dart';

class RecurrenceModel {
  final String? id;
  final String? todoId;
  final RecurrencePattern recurrencePattern;
  final String? reminderAt;
  final DateTime createdAt;

  const RecurrenceModel({
    this.id,
    this.todoId,
    required this.recurrencePattern,
    this.reminderAt,
    required this.createdAt,
  });

  factory RecurrenceModel.fromJson(Map<String, dynamic> json) {
    return RecurrenceModel(
      id: json['id'],
      todoId: json['todo_id'],
      recurrencePattern: RecurrencePatternX.fromDB(json['recurrence_pattern']),
      reminderAt: json['reminder_at'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // id tự sinh, todo_id lấy từ kết quả insert todo
      'recurrence_pattern': recurrencePattern.name,
      'reminder_at': reminderAt,
      // 'created_at': created_at tự sinh
    };
  }

  factory RecurrenceModel.fromEntity(RecurrenceEntity entity) {
    return RecurrenceModel(
      id: entity.id,
      todoId: entity.todoId,
      recurrencePattern: entity.recurrencePattern,
      reminderAt: entity.reminderAt,
      createdAt: entity.createdAt,
    );
  }

  RecurrenceEntity toEntity() {
    return RecurrenceEntity(
      id: id,
      todoId: todoId,
      recurrencePattern: recurrencePattern,
      reminderAt: reminderAt,
      createdAt: createdAt,
    );
  }
}
