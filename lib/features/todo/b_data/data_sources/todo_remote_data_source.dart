import 'package:supabase_flutter/supabase_flutter.dart';

import '../../a_domain/entities/todo_entity.dart';
import '../models/recurrence_model.dart';
import '../models/todo_model.dart';

class TodoRemoteDataSource {
  final SupabaseClient _supabaseClient;

  TodoRemoteDataSource({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  Future<TodoEntity> addTodo({required TodoModel todo}) async {
    final todoResponse =
        await _supabaseClient
            .from('todos')
            .insert(todo.toJson())
            .select() // Yêu cầu trả về dữ liệu vừa tạo
            .single();
    var createdTodo = TodoModel.fromJson(todoResponse);
    // Nếu có cấu hình Recurrence -> Insert vào bảng recurrences
    if (todo.recurrence != null) {
      final recurrenceData = todo.recurrence!.toJson();

      recurrenceData['todo_id'] = createdTodo.id; // FK

      final recurrenceResponse =
          await _supabaseClient
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
