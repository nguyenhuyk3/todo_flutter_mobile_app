import 'package:todo_flutter_mobile_app/features/todo/domain/entities/app_recurrence.dart';

import 'enums.dart';

class AppTodo {
  // Null khi tạo mới (Database tự gen UUID)
  final String? id;
  // Chủ sở hữu todo
  final String userId;
  final String title;
  final String description;
  // Todo thuộc project nào (có thể null)
  final String? projectId;
  // Todo cha (dùng cho sub-task)
  final String? parentTodoId;
  final AppRecurrence? recurrence;
  final DateTime startedDate;
  final DateTime dueDate;
  final TodoPriority priority;
  final TodoStatus status;
  final DateTime? completedAt;

  /// Thứ tự hiển thị trong list
  final int position;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppTodo({
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'project_id': projectId,
      'parent_todo_id': parentTodoId,
      'recurrence': recurrence?.toJson(),
      'started_date': startedDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'priority': priority.name,
      'status': status.name,
      'completed_at': completedAt?.toIso8601String(),
      'position': position,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
