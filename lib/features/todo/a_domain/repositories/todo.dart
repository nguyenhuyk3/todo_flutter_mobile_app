import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../b_data/models/todo_model.dart';
import '../entities/todo_entity.dart';

abstract class ITodoRepository {
  Future<Either<Failure, TodoEntity>> addTodo({required TodoModel todo});
}
