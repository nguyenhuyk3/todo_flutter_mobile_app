import '../../a_domain/entities/recurrence_entity.dart';
import '../../a_domain/entities/enums.dart';

class RecurrenceModel extends RecurrenceEntity {
  const RecurrenceModel({
    super.id,
    super.todoId,
    required super.recurrencePattern,
    super.reminderAt,
    required super.createdAt,
  });

  factory RecurrenceModel.fromJson(Map<String, dynamic> json) {
    return RecurrenceModel(
      id: json['id'],
      todoId: json['todo_id'],
      recurrencePattern: RecurrencePattern.values.firstWhere(
        (e) => e.name == json['recurrence_pattern'],
        orElse: () => RecurrencePattern.daily,
      ),
      reminderAt: json['reminder_at'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  @override
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
}
