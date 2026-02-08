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

class MockGetAllTagsUseCase extends Mock implements GetAllTagsUseCase {}

class MockUpdateTagUseCase extends Mock implements UpdateTagUseCase {}

void main() {
  late ModifyLabelCubit cubit;
  late MockGetAllTagsUseCase mockGetAllTagsUseCase;
  late MockUpdateTagUseCase mockUpdateTagUseCase;

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

  setUpAll(() {
    registerFallbackValue(const Color(0xFF000000));
  });

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
    test('Initial state is correct', () {
      expect(cubit.state, const ModifyLabelState());
    });

    group('LoadTags', () {
      blocTest<ModifyLabelCubit, ModifyLabelState>(
        'Emits [isLoading=true, labels=List, isLoading=false] when success',
        build: () {
          when(
            () => mockGetAllTagsUseCase.execute(),
          ).thenAnswer((_) async => Right([tTagModel]));

          return cubit;
        },
        act: (cubit) => cubit.loadTags(),
        expect:
            () => [
              // 1. Loading
              isA<ModifyLabelState>()
                  .having((s) => s.isLoading, 'isLoading', true)
                  .having((s) => s.error, 'error', null),
              // 2. Success
              isA<ModifyLabelState>()
                  .having((s) => s.isLoading, 'isLoading', false)
                  .having((s) => s.labels.length, 'labels length', 1)
                  .having((s) => s.labels.first.name, 'label name', tTagName)
                  .having((s) => s.error, 'error', null),
            ],
      );

      blocTest<ModifyLabelCubit, ModifyLabelState>(
        'Emits error message when usecase returns Failure',
        build: () {
          when(() => mockGetAllTagsUseCase.execute()).thenAnswer(
            (_) async => Left(Failure(error: ErrorInformation.UNDEFINED_ERROR)),
          );

          return cubit;
        },
        act: (cubit) => cubit.loadTags(),
        expect:
            () => [
              // 1. Loading
              isA<ModifyLabelState>().having(
                (s) => s.isLoading,
                'isLoading',
                true,
              ),
              // 2. Failure
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

    group('UpdateTag', () {
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
        'Emits state with updated list when success (With New Color)',
        build: () {
          when(
            () => mockUpdateTagUseCase.execute(
              id: tTagId,
              name: newName,
              color: any(named: 'color'),
            ),
          ).thenAnswer((_) async => Right(updatedTagModel));

          return cubit;
        },
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
                    (s) => s.labels.first.color.value,
                    'Updated color',
                    newColor.value,
                  )
                  .having((s) => s.error, 'error', null),
            ],
      );

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
        'Emits error message when update fails',
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
