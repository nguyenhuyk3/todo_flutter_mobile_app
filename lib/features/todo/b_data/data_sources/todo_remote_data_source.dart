import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:todo_flutter_mobile_app/features/todo/b_data/models/todo_model.dart';
import 'package:todo_flutter_mobile_app/features/todo/a_domain/entities/todo_entity.dart';

import '../../../../core/constants/others.dart';
import '../models/recurrence_model.dart';

class TodoRemoteDataSource {
  final SupabaseClient _supabaseClient;

  TodoRemoteDataSource({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  Future<TodoModel> addTodo({required TodoEntity todo}) async {
    LOGGER.e(todo.toJson());

    final todoResponse =
        await _supabaseClient
            .from('todos')
            .insert(todo.toJson())
            .select() // Yêu cầu trả về dữ liệu vừa tạo
            .single();
    var createdTodo = TodoModel.fromJson(todoResponse);
    // Nếu có cấu hình Recurrence -> Insert vào bảng recurrences
    if (todo.recurrence != null) {
      // Tạo Model từ Entity recurrence và gán ID của Todo vừa tạo vào
      final recurrenceData =
          RecurrenceModel.fromEntity(todo.recurrence!).toJson();

      recurrenceData['todo_id'] = createdTodo.id; // FK quan trọng

      final recurrenceResponse =
          await _supabaseClient
              .from('recurrences')
              .insert(recurrenceData)
              .select()
              .single();

      // Cập nhật lại createdTodo để trả về đủ data cho UI
      createdTodo = TodoModel(
        // ... copy lại hết thuộc tính từ createdTodo cũ ...
        // Mình demo cách copy ngắn gọn, bạn nên dùng copyWith ở Entity/Model
        id: createdTodo.id,
        userId: createdTodo.userId,
        title: createdTodo.title,
        description: createdTodo.description,
        startedDate: createdTodo.startedDate,
        dueDate: createdTodo.dueDate,
        createdAt: createdTodo.createdAt,
        updatedAt: createdTodo.updatedAt,
        recurrence: RecurrenceModel.fromJson(
          recurrenceResponse,
        ), // Gắn cái vừa insert xong vào
        // ... copy tiếp các field còn thiếu ...
        priority: createdTodo.priority,
        status: createdTodo.status,
      );
    }

    return createdTodo;
  }
}
