import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

import '../../domain/entities/app_todo.dart';
import '../../domain/repositories/todo.dart';

part 'event.dart';
part 'state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final ITodoRepository _todoRepository;

  TodoBloc({required ITodoRepository todoRepository})
    : _todoRepository = todoRepository,
      super(const TodoState()) {
    on<TodoLoaded>(_onLoaded);
    on<TodoAdded>(_onAdded);
    on<TodoUpdated>(_onUpdated);
    on<TodoStatusChanged>(_onStatusChanged);
    on<TodoDeleted>(_onDeleted);
  }

  // --- HANDLERS ---

  Future<void> _onLoaded(TodoLoaded event, Emitter<TodoState> emit) async {
    emit(state.copyWith(status: TodoStatusLoading.loading));
    try {
      final todos = await _todoRepository.getTodos(projectId: event.projectId);
      emit(state.copyWith(status: TodoStatusLoading.success, todos: todos));
    } catch (e) {
      emit(
        state.copyWith(
          status: TodoStatusLoading.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAdded(TodoAdded event, Emitter<TodoState> emit) async {
    // 1. Gọi API tạo
    try {
      // Optimistic Update: Thêm vào UI trước khi server trả về?
      // Ở đây mình làm cách an toàn: Gọi server -> thành công -> update list

      final newTodo = await _todoRepository.createTodo(event.todo);

      // Update State: Thêm todo mới vào danh sách hiện có
      final updatedList = List<Todo>.from(state.todos)..insert(0, newTodo);

      emit(
        state.copyWith(status: TodoStatusLoading.success, todos: updatedList),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TodoStatusLoading.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdated(TodoUpdated event, Emitter<TodoState> emit) async {
    try {
      await _todoRepository.updateTodo(event.todo);

      // Update List trong bộ nhớ cục bộ thay vì fetch lại API (tối ưu performance)
      final updatedList =
          state.todos.map((t) {
            return t.id == event.todo.id ? event.todo : t;
          }).toList();

      emit(
        state.copyWith(status: TodoStatusLoading.success, todos: updatedList),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TodoStatusLoading.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onStatusChanged(
    TodoStatusChanged event,
    Emitter<TodoState> emit,
  ) async {
    try {
      // Tìm todo hiện tại
      final index = state.todos.indexWhere((t) => t.id == event.id);
      if (index == -1) return;

      final currentTodo = state.todos[index];
      final updatedTodo = currentTodo.copyWith(
        status: event.status,
        completedAt:
            event.status == TodoStatus.completed
                ? DateTime.now()
                : null, // Logic set completed_at
      );

      await _todoRepository.updateTodo(updatedTodo);

      // Update State
      final updatedList = List<Todo>.from(state.todos);
      updatedList[index] = updatedTodo;

      emit(
        state.copyWith(status: TodoStatusLoading.success, todos: updatedList),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TodoStatusLoading.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleted(TodoDeleted event, Emitter<TodoState> emit) async {
    try {
      await _todoRepository.deleteTodo(event.id);

      // Xóa khỏi list hiện tại
      final updatedList = state.todos.where((t) => t.id != event.id).toList();

      emit(
        state.copyWith(status: TodoStatusLoading.success, todos: updatedList),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TodoStatusLoading.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
