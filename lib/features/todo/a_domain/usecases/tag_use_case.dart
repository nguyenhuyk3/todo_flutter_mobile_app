import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../b_data/models/tag_model.dart';
import '../repositories/tag.dart';

abstract class TagUseCase {
  final ITagRepository _tagRepository;

  TagUseCase({required ITagRepository tagRepository})
    : _tagRepository = tagRepository;
}

class GetTagsByUserIdUseCase extends TagUseCase {
  GetTagsByUserIdUseCase({required super.tagRepository});

  Future<Either<Failure, List<TagModel>>> execute({required String userId}) {
    return _tagRepository.getTagsByUserId(userId);
  }
}

class UpdateTagUseCase extends TagUseCase {
  UpdateTagUseCase({required super.tagRepository});

  Future<Either<Failure, TagModel>> execute({
    required String id,
    required String name,
    String? color,
  }) {
    return _tagRepository.updateTag(id: id, name: name, color: color);
  }
}
