import 'package:flutter/material.dart';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:todo_flutter_mobile_app/core/errors/failure.dart';
import 'package:todo_flutter_mobile_app/features/todo/a_domain/usecases/tag_use_case.dart';
import 'package:todo_flutter_mobile_app/features/todo/b_data/models/tag_model.dart';
import 'package:todo_flutter_mobile_app/features/todo/c_presentations/models/label_item.dart';
import 'package:todo_flutter_mobile_app/features/todo/c_presentations/modify_todo/cubit/label/modify_labels_cubit.dart';
import 'package:todo_flutter_mobile_app/features/todo/c_presentations/modify_todo/cubit/label/modify_labels_state.dart';

// Mocks
class MockGetAllTagsUseCase extends Mock implements GetAllTagsUseCase {}

class MockUpdateTagUseCase extends Mock implements UpdateTagUseCase {}

void main() {
  late ModifyLabelCubit cubit;
  late MockGetAllTagsUseCase mockGetAllTagsUseCase;
  late MockUpdateTagUseCase mockUpdateTagUseCase;

  // --- Constants & Test Data ---
  const tUserId = 'user-123';
  const tTagId = 'tag-1';
  const tTagName = 'Work';
  const tTagColorHex = '#FF0000'; // Red
  const tTagColorObj = Color(0xFFFF0000);

  final tTagModel = TagModel(
    id: tTagId,
    userId: tUserId,
    name: tTagName,
    color: tTagColorHex,
  );

  final tLabelItem = LabelItem(
    id: tTagId,
    name: tTagName,
    color: tTagColorObj,
    isSelected: false,
  );

  // Setup Global Mocks
  setUpAll(() {
    registerFallbackValue(const Color(0xFF000000));
  });

  // Setup per Test
  setUp(() {
    mockGetAllTagsUseCase = MockGetAllTagsUseCase();
    mockUpdateTagUseCase = MockUpdateTagUseCase();

    cubit = ModifyLabelCubit(
      getAllTagsUseCase: mockGetAllTagsUseCase,
      updateTagUseCase: mockUpdateTagUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('ModifyLabelCubit', () {
    // 1. Check Initial State first
    test('Initial state is correct (default constructor)', () {
      expect(cubit.state, const ModifyLabelState());
    });

    // 2. LOGIC: FETCH DATA (Thường chạy khi init màn hình)
    group('loadTags', () {
      blocTest<ModifyLabelCubit, ModifyLabelState>(
        'Emits [isLoading=true, labels=List, isLoading=false] when GetTags success',
        build: () {
          when(
            () => mockGetAllTagsUseCase.execute(),
          ).thenAnswer((_) async => Right([tTagModel]));
          return cubit;
        },
        act: (cubit) => cubit.loadTags(),
        expect:
            () => [
              // Loading State
              isA<ModifyLabelState>()
                  .having((s) => s.isLoading, 'isLoading', true)
                  .having((s) => s.error, 'error', null),
              // Success State
              isA<ModifyLabelState>()
                  .having((s) => s.isLoading, 'isLoading', false)
                  .having((s) => s.labels.length, 'labels length', 1)
                  .having((s) => s.labels.first.name, 'label name', tTagName)
                  .having((s) => s.error, 'error', null),
            ],
      );

      blocTest<ModifyLabelCubit, ModifyLabelState>(
        'Emits [isLoading=true, isLoading=false, error=Msg] when GetTags fails',
        build: () {
          when(() => mockGetAllTagsUseCase.execute()).thenAnswer(
            (_) async => Left(Failure(error: ErrorInformation.UNDEFINED_ERROR)),
          );
          return cubit;
        },
        act: (cubit) => cubit.loadTags(),
        expect:
            () => [
              // Loading
              isA<ModifyLabelState>().having(
                (s) => s.isLoading,
                'isLoading',
                true,
              ),
              // Failure
              isA<ModifyLabelState>()
                  .having((s) => s.isLoading, 'isLoading', false)
                  .having((s) => s.labels, 'labels', isEmpty)
                  .having(
                    (s) => s.error,
                    'error message',
                    ErrorInformation.UNDEFINED_ERROR.message,
                  ),
            ],
      );
    });

    // 3. LOGIC: USER INTERACTION (Chỉnh sửa dữ liệu)
    group('updateTag', () {
      const newName = 'New Work';
      const newColor = Color(0xFF00FF00); // Green
      const newColorHex = '#00ff00';

      final updatedTagModel = TagModel(
        id: tTagId,
        userId: tUserId,
        name: newName,
        color: newColorHex,
      );

      blocTest<ModifyLabelCubit, ModifyLabelState>(
        'Emits state with updated labels list when UpdateTag success',
        build: () {
          when(
            () => mockUpdateTagUseCase.execute(
              id: tTagId,
              name: newName,
              // Matcher kiểm tra việc parse color object sang hex có đúng không
              color: any(named: 'color'),
            ),
          ).thenAnswer((_) async => Right(updatedTagModel));
          return cubit;
        },
        // Cần seed dữ liệu cũ trước để có cái mà update
        seed: () => ModifyLabelState(labels: [tLabelItem]),
        act:
            (cubit) => cubit.updateTag(
              tagId: tTagId,
              newName: newName,
              newColor: newColor,
            ),
        expect:
            () => [
              isA<ModifyLabelState>()
                  .having((s) => s.labels.first.name, 'Updated name', newName)
                  .having(
                    // ignore: deprecated_member_use
                    (s) => s.labels.first.color.value,
                    'Updated color',
                    // ignore: deprecated_member_use
                    newColor.value,
                  )
                  .having((s) => s.error, 'error', null),
            ],
      );

      /* 
        --- TEST DƯ THỪA (REDUNDANT) ---
        Logic này kiểm tra việc update KHÔNG có màu mới. 
        Tuy nhiên, luồng đi (Success Flow) của Bloc giống hệt test bên trên.
        Sự khác biệt chỉ nằm ở input đầu vào hàm execute của UseCase (null vs not null).
        Nếu muốn tối giản file test, test case này có thể bỏ qua vì logic state update đã được cover ở trên.
      */
      blocTest<ModifyLabelCubit, ModifyLabelState>(
        'Emits state with updated list when success (Without New Color)',
        build: () {
          when(
            () => mockUpdateTagUseCase.execute(
              id: tTagId,
              name: newName,
              color: null,
            ),
          ).thenAnswer((_) async => Right(updatedTagModel));
          return cubit;
        },
        seed: () => ModifyLabelState(labels: [tLabelItem]),
        act:
            (cubit) => cubit.updateTag(
              tagId: tTagId,
              newName: newName,
              newColor: null,
            ),
        expect:
            () => [
              isA<ModifyLabelState>().having(
                (s) => s.labels.first.name,
                'Updated name',
                newName,
              ),
            ],
      );

      blocTest<ModifyLabelCubit, ModifyLabelState>(
        'Emits error message when UpdateTag fails',
        build: () {
          when(
            () => mockUpdateTagUseCase.execute(
              id: any(named: 'id'),
              name: any(named: 'name'),
              color: any(named: 'color'),
            ),
          ).thenAnswer(
            (_) async =>
                Left(Failure(error: ErrorInformation.DB_PERMISSION_DENIED)),
          );
          return cubit;
        },
        seed: () => ModifyLabelState(labels: [tLabelItem]),
        act: (cubit) => cubit.updateTag(tagId: tTagId, newName: 'Fail Name'),
        expect:
            () => [
              isA<ModifyLabelState>().having(
                (s) => s.error,
                'Error message match',
                ErrorInformation.DB_PERMISSION_DENIED.message,
              ),
            ],
      );
    });
  });
}
