import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../b_data/models/todo_model.dart';
import '../entities/todo_entity.dart';
import '../repositories/todo.dart';

abstract class TodoUseCase {
  final ITodoRepository _todoRepository;

  TodoUseCase({required ITodoRepository todoRepository})
    : _todoRepository = todoRepository;
}

class AddTodoUseCase extends TodoUseCase {
  AddTodoUseCase({required super.todoRepository});

  Future<Either<Failure, TodoEntity>> execute({required TodoModel todo}) {
    return _todoRepository.addTodo(todo: todo);
  }
}
