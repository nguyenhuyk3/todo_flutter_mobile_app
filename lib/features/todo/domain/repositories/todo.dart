import 'package:dartz/dartz.dart';
import 'package:todo_flutter_mobile_app/core/errors/failure.dart';

abstract class ITodoRepository {
  Future<Either<Failure, bool>> addTodo({required String email});
}
