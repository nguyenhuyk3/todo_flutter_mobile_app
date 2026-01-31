import 'package:dartz/dartz.dart';

import 'package:todo_flutter_mobile_app/features/todo/b_data/models/todo_model.dart';
import 'package:todo_flutter_mobile_app/features/todo/a_domain/repositories/todo.dart';

import '../../../../core/errors/failure.dart';
import '../entities/todo_entity.dart';

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
