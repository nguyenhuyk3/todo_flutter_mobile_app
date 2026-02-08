import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/constants/keys.dart';
import '../../../../../../core/utils/storage/secure_storage_service.dart';
import '../../../../a_domain/usecases/tag_use_case.dart';
import '../../../../b_data/models/tag_model.dart';
import '../../../models/label_item.dart';
import 'modify_labels_state.dart';

/// Chuyển hex string (vd: #EF4444) sang [Color].
Color _colorFromHex(String hex) {
  final h = hex.replaceFirst('#', '');
  return Color(
    0xFF000000 | int.parse(h.length == 6 ? h : h.padRight(6, '0'), radix: 16),
  );
}

/// Chuyển [Color] sang hex string (#rrggbb) để lưu DB.
String _colorToHex(Color color) {
  return '#${color.red.toRadixString(16).padLeft(2, '0')}'
      '${color.green.toRadixString(16).padLeft(2, '0')}'
      '${color.blue.toRadixString(16).padLeft(2, '0')}';
}

/// Cubit quản lý danh sách nhãn: fetch theo user_id và chỉnh sửa tên.
class ModifyLabelCubit extends Cubit<ModifyLabelState> {
  final GetTagsByUserIdUseCase _getTagsByUserIdUseCase;
  final UpdateTagUseCase _updateTagUseCase;
  final SecureStorageService SECURE_STORAGE;

  ModifyLabelCubit({
    required GetTagsByUserIdUseCase getTagsByUserIdUseCase,
    required UpdateTagUseCase updateTagUseCase,
    SecureStorageService? secureStorage,
  }) : _getTagsByUserIdUseCase = getTagsByUserIdUseCase,
       _updateTagUseCase = updateTagUseCase,
       SECURE_STORAGE = secureStorage ?? const SecureStorageService(),
       super(const ModifyLabelState());

  /// Gọi khi vào ModifyTodoPage: đọc user_id từ storage và fetch tags.
  Future<void> loadTags() async {
    emit(state.copyWith(isLoading: true, error: null));
    final userId = await SECURE_STORAGE.read(key: SecureStorageKeys.USER_ID);
    if (userId == null || userId.isEmpty) {
      emit(
        state.copyWith(isLoading: false, error: 'Chưa đăng nhập', labels: []),
      );
      return;
    }
    final result = await _getTagsByUserIdUseCase.execute(userId: userId);
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
                    color: _colorFromHex(t.color),
                    isSelected: false,
                  ),
                )
                .toList();
        emit(state.copyWith(isLoading: false, labels: labels, error: null));
      },
    );
  }

  /// Cập nhật tên và/hoặc màu nhãn trên Supabase và cập nhật state.
  Future<void> updateTag({
    required String tagId,
    required String newName,
    Color? newColor,
  }) async {
    final name = newName;
    final colorHex = newColor != null ? _colorToHex(newColor) : null;
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
                  color: newColor ?? _colorFromHex(updated.color),
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
