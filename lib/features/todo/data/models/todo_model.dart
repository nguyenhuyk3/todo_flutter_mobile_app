import '../../a_domain/entities/enums.dart';
import '../../a_domain/entities/todo_entity.dart';

class TodoModel extends TodoEntity {
  TodoModel({
    super.id,

    required super.userId,

    required super.title,
    required super.description,

    super.projectId,
    super.parentTodoId,

    super.recurrence,

    super.priority,
    super.status,

    super.completedAt,

    super.position,

    required super.startedDate,
    required super.dueDate,

    required super.createdAt,
    required super.updatedAt,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,

      'title': title,
      'description': description,

      'project_id': projectId,
      'parent_todo_id': parentTodoId,

      'priority': priority.toDB(),
      'status': status.toDB(),

      'position': position,

      'started_date': startedDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
    };
  }

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'],

      userId: json['user_id'],

      title: json['title'] ?? '',
      description: json['description'] ?? '',

      projectId: json['project_id'],
      parentTodoId: json['parent_todo_id'],

      priority: TodoPriority.values.firstWhere(
        (e) => e.toDB() == json['priority'],
        orElse: () => TodoPriority.low,
      ),
      status: TodoStatus.values.firstWhere(
        (e) => e.toDB() == json['status'],
        orElse: () => TodoStatus.pending,
      ),

      completedAt:
          json['completed_at'] != null
              ? DateTime.parse(json['completed_at'])
              : null,
      position: json['position'],

      startedDate: json['started_date'],
      dueDate: json['due_date'],

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

      recurrence: entity.recurrence,

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
}
