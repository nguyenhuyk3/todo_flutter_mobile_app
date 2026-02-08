import 'package:supabase_flutter/supabase_flutter.dart';

import '../../a_domain/entities/todo_entity.dart';
import '../../a_domain/entities/enums.dart';
import '../models/recurrence_model.dart';
import '../models/todo_model.dart';

class TodoRemoteDataSource {
  final SupabaseClient _supabaseClient;

  TodoRemoteDataSource({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  /// Thêm todo. Nếu [todo.tagIds] không rỗng thì gọi RPC add_todo_with_tags (transaction).
  Future<TodoEntity> addTodo({required TodoModel todo}) async {
    final hasTagIds =
        todo.tagIds != null && todo.tagIds!.isNotEmpty;

    if (hasTagIds) {
      return _addTodoWithTagsViaRpc(todo);
    }

    return _addTodoWithRecurrenceOnly(todo);
  }

  /// Gọi RPC add_todo_with_tags: insert todo + recurrences + todo_tags trong một transaction.
  Future<TodoEntity> _addTodoWithTagsViaRpc(TodoModel todo) async {
    final params = <String, dynamic>{
      'p_user_id': todo.userId,
      'p_title': todo.title,
      'p_description': todo.description,
      'p_priority': todo.priority.toDB(),
      'p_status': todo.status.toDB(),
      'p_started_date': _toDateStr(todo.startedDate),
      'p_due_date': _toDateStr(todo.dueDate),
      'p_recurrence_pattern': todo.recurrence?.recurrencePattern.toDB() ?? RecurrencePattern.once.toDB(),
      'p_reminder_at': todo.recurrence?.reminderAt,
      'p_tag_ids': todo.tagIds,
    };

    final response = await _supabaseClient.rpc(
      'add_todo_with_tags',
      params: params,
    );

    if (response == null) {
      throw Exception('add_todo_with_tags returned null');
    }

    if (response is! Map) {
      throw Exception('add_todo_with_tags did not return a row');
    }
    final Map<String, dynamic> row = Map<String, dynamic>.from(response);

    final createdTodo = TodoModel.fromJson(row);
    return createdTodo.toEntity();
  }

  static String _toDateStr(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  /// Luồng cũ: insert todo rồi insert recurrences (không có todo_tags).
  Future<TodoEntity> _addTodoWithRecurrenceOnly(TodoModel todo) async {
    final todoResponse = await _supabaseClient
        .from('todos')
        .insert(todo.toJson())
        .select()
        .single();
    var createdTodo = TodoModel.fromJson(todoResponse);

    if (todo.recurrence != null) {
      final recurrenceData = todo.recurrence!.toJson();
      recurrenceData['todo_id'] = createdTodo.id;

      final recurrenceResponse = await _supabaseClient
          .from('recurrences')
          .insert(recurrenceData)
          .select()
          .single();

      createdTodo = TodoModel(
        id: createdTodo.id,
        userId: createdTodo.userId,
        title: createdTodo.title,
        description: createdTodo.description,
        startedDate: createdTodo.startedDate,
        dueDate: createdTodo.dueDate,
        createdAt: createdTodo.createdAt,
        updatedAt: createdTodo.updatedAt,
        recurrence: RecurrenceModel.fromJson(recurrenceResponse),
        priority: createdTodo.priority,
        status: createdTodo.status,
      );
    }

    return createdTodo.toEntity();
  }
}
