import 'package:dartz/dartz.dart';
import 'package:todo_flutter_mobile_app/core/errors/failure.dart';
import 'package:todo_flutter_mobile_app/features/todo/a_domain/entities/todo_entity.dart';

abstract class ITodoRepository {
  Future<Either<Failure, TodoEntity>> addTodo({required TodoEntity todo});
}
