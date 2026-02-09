import 'package:flutter/material.dart';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:todo_flutter_mobile_app/core/errors/failure.dart';
import 'package:todo_flutter_mobile_app/features/todo/a_domain/usecases/tag_use_case.dart';
import 'package:todo_flutter_mobile_app/features/todo/b_data/models/tag_model.dart';
import 'package:todo_flutter_mobile_app/features/todo/c_presentations/modify_todo/cubit/tag/modify_tag_cubit.dart';
import 'package:todo_flutter_mobile_app/features/todo/c_presentations/modify_todo/cubit/tag/modify_tag_state.dart';
import 'package:todo_flutter_mobile_app/features/todo/c_presentations/shared/models/label_item.dart';

// =============================================================================
// MOCKS
// =============================================================================

class MockGetAllTagsUseCase extends Mock implements GetAllTagsUseCase {}

class MockUpdateTagUseCase extends Mock implements UpdateTagUseCase {}

// =============================================================================
// MAIN TEST
// =============================================================================

void main() {
  late ModifyTagCubit cubit;
  late MockGetAllTagsUseCase mockGetAllTagsUseCase;
  late MockUpdateTagUseCase mockUpdateTagUseCase;

  // ---------------------------------------------------------------------------
  // TEST DATA & CONSTANTS
  // ---------------------------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // SETUP
  // ---------------------------------------------------------------------------

  setUpAll(() {
    registerFallbackValue(const Color(0xFF000000));
  });

  setUp(() {
    mockGetAllTagsUseCase = MockGetAllTagsUseCase();
    mockUpdateTagUseCase = MockUpdateTagUseCase();

    cubit = ModifyTagCubit(
      getAllTagsUseCase: mockGetAllTagsUseCase,
      updateTagUseCase: mockUpdateTagUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  // ---------------------------------------------------------------------------
  // TEST GROUPS
  // ---------------------------------------------------------------------------

  group('ModifyTagCubit', () {
    // --- Initial Check ---
    test('Initial state is correct (default constructor)', () {
      expect(cubit.state, const ModifyTagState());
    });

    // =========================================================================
    // GROUP 1: FETCH DATA (loadTags)
    // =========================================================================
    group('loadTags', () {
      blocTest<ModifyTagCubit, ModifyTagState>(
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
              // State 1: Loading
              isA<ModifyTagState>()
                  .having((s) => s.isLoading, 'isLoading', true)
                  .having((s) => s.error, 'error', null),
              // State 2: Success
              isA<ModifyTagState>()
                  .having((s) => s.isLoading, 'isLoading', false)
                  .having((s) => s.labels.length, 'labels length', 1)
                  .having((s) => s.labels.first.name, 'label name', tTagName)
                  .having((s) => s.error, 'error', null),
            ],
      );

      blocTest<ModifyTagCubit, ModifyTagState>(
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
              // State 1: Loading
              isA<ModifyTagState>().having(
                (s) => s.isLoading,
                'isLoading',
                true,
              ),
              // State 2: Failure
              isA<ModifyTagState>()
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

    // =========================================================================
    // GROUP 2: UPDATE TAG (updateTag)
    // =========================================================================
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

      blocTest<ModifyTagCubit, ModifyTagState>(
        'Emits state with updated labels list when UpdateTag success',
        build: () {
          when(
            () => mockUpdateTagUseCase.execute(
              id: tTagId,
              name: newName,
              color: any(named: 'color'), // Verify Color Object
            ),
          ).thenAnswer((_) async => Right(updatedTagModel));

          return cubit;
        },
        seed: () => ModifyTagState(labels: [tLabelItem]),
        act:
            (cubit) => cubit.updateTag(
              tagId: tTagId,
              newName: newName,
              newColor: newColor,
            ),
        expect:
            () => [
              isA<ModifyTagState>()
                  .having((s) => s.labels.first.name, 'updated name', newName)
                  .having(
                    // ignore: deprecated_member_use
                    (s) => s.labels.first.color.value,
                    'updated color',
                    // ignore: deprecated_member_use
                    newColor.value,
                  )
                  .having((s) => s.error, 'error', null),
            ],
      );

      blocTest<ModifyTagCubit, ModifyTagState>(
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
        seed: () => ModifyTagState(labels: [tLabelItem]),
        act:
            (cubit) => cubit.updateTag(
              tagId: tTagId,
              newName: newName,
              newColor: null,
            ),
        expect:
            () => [
              isA<ModifyTagState>().having(
                (s) => s.labels.first.name,
                'updated name',
                newName,
              ),
            ],
      );

      blocTest<ModifyTagCubit, ModifyTagState>(
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
        seed: () => ModifyTagState(labels: [tLabelItem]),
        act: (cubit) => cubit.updateTag(tagId: tTagId, newName: 'Fail Name'),
        expect:
            () => [
              isA<ModifyTagState>().having(
                (s) => s.error,
                'error message match',
                ErrorInformation.DB_PERMISSION_DENIED.message,
              ),
            ],
      );
    });
  });
}
