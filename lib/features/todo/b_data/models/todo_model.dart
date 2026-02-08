import '../../a_domain/entities/enums.dart';
import '../../a_domain/entities/todo_entity.dart';

import 'recurrence_model.dart';

class TodoModel {
  final String? id;

  final String userId;

  final String title;
  final String description;

  final RecurrenceModel? recurrence;

  final DateTime startedDate;
  final DateTime dueDate;

  final TodoPriority priority;
  final TodoStatus status;

  final DateTime? completedAt;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Id các tag đã chọn (ghi vào bảng todo_tags trong transaction).
  final List<String>? tagIds;

  const TodoModel({
    this.id,

    required this.userId,

    required this.title,
    required this.description,

    this.recurrence,

    required this.startedDate,
    required this.dueDate,

    this.priority = TodoPriority.low,
    this.status = TodoStatus.pending,

    this.completedAt,

    required this.createdAt,
    required this.updatedAt,
    this.tagIds,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'],

      userId: json['user_id'],

      title: json['title'] ?? '',
      description: json['description'] ?? '',

      priority: TodoPriorityX.fromDB(json['priority']),
      status: TodoStatusX.fromDB(json['status']),

      completedAt:
          json['completed_at'] != null
              ? DateTime.parse(json['completed_at'])
              : null,

      startedDate: DateTime.parse(json['started_date'] as String),
      dueDate: DateTime.parse(json['due_date'] as String),

      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      tagIds: null,
    );
  }

  factory TodoModel.fromEntity(TodoEntity entity) {
    return TodoModel(
      id: entity.id,

      userId: entity.userId,

      title: entity.title,
      description: entity.description,

      recurrence:
          entity.recurrence == null
              ? null
              : RecurrenceModel.fromEntity(entity.recurrence!),

      priority: entity.priority,
      status: entity.status,

      completedAt: entity.completedAt,

      startedDate: entity.startedDate,
      dueDate: entity.dueDate,

      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      tagIds: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,

      'title': title,
      'description': description,

      // 'recurrence': recurrence?.toJson(),
      'priority': priority.toDB(),
      'status': status.toDB(),

      'started_date': startedDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
    };
  }

  TodoEntity toEntity() {
    return TodoEntity(
      id: id,

      userId: userId,

      title: title,
      description: description,

      recurrence: recurrence?.toEntity(),

      startedDate: startedDate,
      dueDate: dueDate,

      priority: priority,
      status: status,

      completedAt: completedAt,

      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
