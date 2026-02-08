import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/keys.dart';
import '../../../../core/constants/others.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/supabase_error_mapper.dart';
import '../../a_domain/repositories/tag.dart';
import '../data_sources/tag_remote_data_source.dart';
import '../models/tag_model.dart';

class TagService implements ITagRepository {
  final TagRemoteDataSource _tagRemoteDataSource;

  TagService({required TagRemoteDataSource tagRemoteDataSource})
    : _tagRemoteDataSource = tagRemoteDataSource;

  @override
  Future<Either<Failure, List<TagModel>>> getAllTags() async {
    try {
      final userId = await SECURE_STORAGE.read(key: SecureStorageKeys.USER_ID);
      final allTags = await _tagRemoteDataSource.getAllTags(userId!);

      return Right(allTags);
    } on AuthException catch (e) {
      return Left(Failure(error: mapAuthException(e), details: e.message));
    } on PostgrestException catch (e) {
      return Left(
        Failure(
          error: mapPostgrestException(e),
          details: 'Code: ${e.code}, Msg: ${e.message}',
        ),
      );
    } catch (e) {
      return Left(
        Failure(error: ErrorInformation.UNDEFINED_ERROR, details: e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, TagModel>> updateTag({
    required String id,
    required String name,
    String? color,
  }) async {
    try {
      final updated = await _tagRemoteDataSource.updateTag(
        id: id,
        name: name,
        color: color,
      );

      return Right(updated);
    } on AuthException catch (e) {
      return Left(Failure(error: mapAuthException(e), details: e.message));
    } on PostgrestException catch (e) {
      return Left(
        Failure(
          error: mapPostgrestException(e),
          details: 'Code: ${e.code}, Msg: ${e.message}',
        ),
      );
    } catch (e) {
      return Left(
        Failure(error: ErrorInformation.UNDEFINED_ERROR, details: e.toString()),
      );
    }
  }
}
