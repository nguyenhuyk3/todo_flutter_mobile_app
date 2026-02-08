import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../b_data/models/tag_model.dart';

abstract class ITagRepository {
  Future<Either<Failure, List<TagModel>>> getAllTags();
  Future<Either<Failure, TagModel>> updateTag({
    required String id,
    required String name,
    String? color,
  });
}
