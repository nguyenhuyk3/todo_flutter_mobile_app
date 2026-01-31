// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:todo_flutter_mobile_app/core/errors/failure.dart';
import 'package:todo_flutter_mobile_app/features/todo/a_domain/repositories/todo.dart';
import 'package:todo_flutter_mobile_app/features/todo/b_data/data_sources/todo_remote_data_source.dart';
import 'package:todo_flutter_mobile_app/features/todo/b_data/models/todo_model.dart';

import '../../../../core/errors/supabase_error_mapper.dart';
import '../../a_domain/entities/todo_entity.dart';

class TodoService implements ITodoRepository {
  final TodoRemoteDataSource _todoRemoteDataSource;

  TodoService({required TodoRemoteDataSource todoRemoteDataSource})
    : _todoRemoteDataSource = todoRemoteDataSource;

  @override
  Future<Either<Failure, TodoModel>> addTodo({required TodoEntity todo}) async {
    try {
      final resultModel = await _todoRemoteDataSource.addTodo(todo: todo);

      return Right(resultModel);
    } on AuthException catch (e) {
      return Left(Failure(error: mapAuthException(e), details: e.message));
    } on PostgrestException catch (e) {
      return Left(
        Failure(
          error: mapPostgrestException(e),
          details: "Code: ${e.code}, Msg: ${e.message}",
        ),
      );
    } catch (e) {
      return Left(
        Failure(error: ErrorInformation.UNDEFINED_ERROR, details: e.toString()),
      );
    }
  }
}
