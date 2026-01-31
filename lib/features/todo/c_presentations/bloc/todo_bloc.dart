import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import 'package:todo_flutter_mobile_app/features/todo/b_data/models/todo_model.dart';

import '../../a_domain/entities/todo_entity.dart';
import '../../a_domain/usecases/todo_use_case.dart';

part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final AddTodoUseCase _addTodoUseCase;

  TodoBloc({required AddTodoUseCase addTodoUseCase})
    : _addTodoUseCase = addTodoUseCase,
      super(const TodoState()) {
    on<TodoLoaded>(_onLoaded);
    on<TodoAdded>(_onAdded);
    on<TodoUpdated>(_onUpdated);
    on<TodoStatusChanged>(_onStatusChanged);
    on<TodoDeleted>(_onDeleted);
  }

  // --- HANDLERS ---

  Future<void> _onLoaded(TodoLoaded event, Emitter<TodoState> emit) async {
    // emit(state.copyWith(status: TodoStatusLoading.loading));
    // try {
    //   final todos = await _todoRepository.getTodos(projectId: event.projectId);
    //   emit(state.copyWith(status: TodoStatusLoading.success, todos: todos));
    // } catch (e) {
    //   emit(
    //     state.copyWith(
    //       status: TodoStatusLoading.failure,
    //       errorMessage: e.toString(),
    //     ),
    //   );
    // }
  }

  Future<void> _onAdded(TodoAdded event, Emitter<TodoState> emit) async {
    final addTodoResult = await _addTodoUseCase.execute(todo: event.todo);

    addTodoResult.fold(
      (failure) {
        emit(state.copyWith(status: FormzSubmissionStatus.failure));
      },
      (_) {
        emit(state.copyWith(status: FormzSubmissionStatus.success));
      },
    );
  }

  Future<void> _onUpdated(TodoUpdated event, Emitter<TodoState> emit) async {
    // try {
    //   await _todoRepository.updateTodo(event.todo);

    //   // Update List trong bộ nhớ cục bộ thay vì fetch lại API (tối ưu performance)
    //   final updatedList =
    //       state.todos.map((t) {
    //         return t.id == event.todo.id ? event.todo : t;
    //       }).toList();

    //   emit(
    //     state.copyWith(status: TodoStatusLoading.success, todos: updatedList),
    //   );
    // } catch (e) {
    //   emit(
    //     state.copyWith(
    //       status: TodoStatusLoading.failure,
    //       errorMessage: e.toString(),
    //     ),
    //   );
    // }
  }

  Future<void> _onStatusChanged(
    TodoStatusChanged event,
    Emitter<TodoState> emit,
  ) async {
    // try {
    //   // Tìm todo hiện tại
    //   final index = state.todos.indexWhere((t) => t.id == event.id);
    //   if (index == -1) return;

    //   final currentTodo = state.todos[index];
    //   final updatedTodo = currentTodo.copyWith(
    //     status: event.status,
    //     completedAt:
    //         event.status == TodoStatus.completed
    //             ? DateTime.now()
    //             : null, // Logic set completed_at
    //   );

    //   await _todoRepository.updateTodo(updatedTodo);

    //   // Update State
    //   final updatedList = List<Todo>.from(state.todos);
    //   updatedList[index] = updatedTodo;

    //   emit(
    //     state.copyWith(status: TodoStatusLoading.success, todos: updatedList),
    //   );
    // } catch (e) {
    //   emit(
    //     state.copyWith(
    //       status: TodoStatusLoading.failure,
    //       errorMessage: e.toString(),
    //     ),
    //   );
    // }
  }

  Future<void> _onDeleted(TodoDeleted event, Emitter<TodoState> emit) async {
    // try {
    //   await _todoRepository.deleteTodo(event.id);

    //   // Xóa khỏi list hiện tại
    //   final updatedList = state.todos.where((t) => t.id != event.id).toList();

    //   emit(
    //     state.copyWith(status: TodoStatusLoading.success, todos: updatedList),
    //   );
    // } catch (e) {
    //   emit(
    //     state.copyWith(
    //       status: TodoStatusLoading.failure,
    //       errorMessage: e.toString(),
    //     ),
    //   );
    // }
  }
}
