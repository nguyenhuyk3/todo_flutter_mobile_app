import 'package:dartz/dartz.dart';
import 'package:todo_flutter_mobile_app/core/errors/failure.dart';
import 'package:todo_flutter_mobile_app/features/todo/a_domain/entities/todo_entity.dart';
import 'package:todo_flutter_mobile_app/features/todo/b_data/models/todo_model.dart';

abstract class ITodoRepository {
  Future<Either<Failure, TodoEntity>> addTodo({required TodoModel todo});
}
