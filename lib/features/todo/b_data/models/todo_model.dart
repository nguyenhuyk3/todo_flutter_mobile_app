import '../../a_domain/entities/enums.dart';
import '../../a_domain/entities/todo_entity.dart';

import 'recurrence_model.dart';

class TodoModel {
  final String? id;

  final String userId;

  final String title;
  final String description;

  final String? projectId;
  final String? parentTodoId;

  final RecurrenceModel? recurrence;

  final DateTime startedDate;
  final DateTime dueDate;

  final TodoPriority priority;
  final TodoStatus status;

  final DateTime? completedAt;

  final int position;

  final DateTime createdAt;
  final DateTime updatedAt;

  const TodoModel({
    this.id,

    required this.userId,

    required this.title,
    required this.description,

    this.projectId,
    this.parentTodoId,

    this.recurrence,

    required this.startedDate,
    required this.dueDate,

    this.priority = TodoPriority.low,
    this.status = TodoStatus.pending,

    this.completedAt,

    this.position = 0,

    required this.createdAt,
    required this.updatedAt,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'],

      userId: json['user_id'],

      title: json['title'] ?? '',
      description: json['description'] ?? '',

      projectId: json['project_id'],
      parentTodoId: json['parent_todo_id'],

      priority: TodoPriorityX.fromDB(json['priority']),
      status: TodoStatusX.fromDB(json['status']),

      completedAt:
          json['completed_at'] != null
              ? DateTime.parse(json['completed_at'])
              : null,
      position: json['position'] ?? 0,

      startedDate: DateTime.parse(json['started_date'] as String),
      dueDate: DateTime.parse(json['due_date'] as String),

      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  factory TodoModel.fromEntity(TodoEntity entity) {
    return TodoModel(
      id: entity.id,

      userId: entity.userId,

      title: entity.title,
      description: entity.description,

      projectId: entity.projectId,
      parentTodoId: entity.parentTodoId,

      recurrence:
          entity.recurrence == null
              ? null
              : RecurrenceModel.fromEntity(entity.recurrence!),

      priority: entity.priority,
      status: entity.status,

      completedAt: entity.completedAt,
      position: entity.position,

      startedDate: entity.startedDate,
      dueDate: entity.dueDate,

      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,

      'title': title,
      'description': description,

      'project_id': projectId,
      'parent_todo_id': parentTodoId,

      // 'recurrence': recurrence?.toJson(),

      'priority': priority.toDB(),
      'status': status.toDB(),

      'position': position,

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

      projectId: projectId,
      parentTodoId: parentTodoId,

      recurrence: recurrence?.toEntity(),

      startedDate: startedDate,
      dueDate: dueDate,

      priority: priority,
      status: status,

      completedAt: completedAt,

      position: position,

      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
