import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/constants/keys.dart';
import '../../../../../../core/constants/others.dart';
import '../../../../../../core/utils/color.dart';
import '../../../../a_domain/usecases/tag_use_case.dart';
import '../../../../b_data/models/tag_model.dart';
import '../../../models/label_item.dart';

import 'modify_labels_state.dart';

class ModifyLabelCubit extends Cubit<ModifyLabelState> {
  final GetTagsByUserIdUseCase _getTagsByUserIdUseCase;
  final UpdateTagUseCase _updateTagUseCase;

  ModifyLabelCubit({
    required GetTagsByUserIdUseCase getTagsByUserIdUseCase,
    required UpdateTagUseCase updateTagUseCase,
  }) : _getTagsByUserIdUseCase = getTagsByUserIdUseCase,
       _updateTagUseCase = updateTagUseCase,
       super(const ModifyLabelState());

  Future<void> loadTags() async {
    emit(state.copyWith(isLoading: true, error: null));

    final userId = await SECURE_STORAGE.read(key: SecureStorageKeys.USER_ID);
    final result = await _getTagsByUserIdUseCase.execute(userId: userId!);

    result.fold(
      (failure) {
        emit(
          state.copyWith(isLoading: false, error: failure.message, labels: []),
        );
      },
      (list) {
        final labels =
            list
                .map(
                  (t) => LabelItem(
                    id: t.id,
                    name: t.name,
                    color: colorFromHex(t.color),
                    isSelected: false,
                  ),
                )
                .toList();

        emit(state.copyWith(isLoading: false, labels: labels, error: null));
      },
    );
  }

  Future<void> updateTag({
    required String tagId,
    required String newName,
    Color? newColor,
  }) async {
    final name = newName;
    final colorHex = newColor != null ? colorToHex(newColor) : null;
    final result = await _updateTagUseCase.execute(
      id: tagId,
      name: name,
      color: colorHex,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(error: failure.message));
      },
      (TagModel updated) {
        final updatedLabels =
            state.labels.map((l) {
              if (l.id == tagId) {
                return LabelItem(
                  id: l.id,
                  name: updated.name,
                  color: newColor ?? colorFromHex(updated.color),
                  isSelected: l.isSelected,
                );
              }

              return l;
            }).toList();

        emit(state.copyWith(labels: updatedLabels, error: null));
      },
    );
  }
}
