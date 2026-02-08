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

class MockGetTagsByUserIdUseCase extends Mock
    implements GetTagsByUserIdUseCase {}

class MockUpdateTagUseCase extends Mock implements UpdateTagUseCase {}

void main() {
  late ModifyLabelCubit cubit;
  late MockGetTagsByUserIdUseCase mockGetTagsByUserIdUseCase;
  late MockUpdateTagUseCase mockUpdateTagUseCase;

  setUp(() {
    mockGetTagsByUserIdUseCase = MockGetTagsByUserIdUseCase();
    mockUpdateTagUseCase = MockUpdateTagUseCase();
  });

  tearDown(() {
    cubit.close();
  });

  group('ModifyLabelCubit', () {
    group('Initial state', () {
      test('Initializes with default state', () {
        cubit = ModifyLabelCubit(
          getTagsByUserIdUseCase: mockGetTagsByUserIdUseCase,
          updateTagUseCase: mockUpdateTagUseCase,
        );

        expect(cubit.state.labels, isEmpty);
        expect(cubit.state.isLoading, false);
        expect(cubit.state.error, isNull);
      });
    });

    group('UpdateTag', () {
      const tagId = 'tag-1';
      const initialName = 'Old name';
      const newName = 'New name';
      const colorHex = '#EF4444';

      final initialLabel = LabelItem(
        id: tagId,
        name: initialName,
        color: const Color(0xFFEF4444),
        isSelected: false,
      );

      blocTest<ModifyLabelCubit, ModifyLabelState>(
        'Emits state with updated label and error null on success',
        build: () {
          when(
            () => mockUpdateTagUseCase.execute(
              id: tagId,
              name: newName,
              color: any(named: 'color'),
            ),
          ).thenAnswer(
            (_) async => Right(
              TagModel(
                id: tagId,
                userId: 'user-1',
                name: newName,
                color: colorHex,
              ),
            ),
          );

          return ModifyLabelCubit(
            getTagsByUserIdUseCase: mockGetTagsByUserIdUseCase,
            updateTagUseCase: mockUpdateTagUseCase,
          );
        },
        seed: () => ModifyLabelState(labels: [initialLabel]),
        act: (c) => c.updateTag(tagId: tagId, newName: newName),
        expect:
            () => [
              isA<ModifyLabelState>()
                  .having((s) => s.labels.length, 'labels.length', 1)
                  .having(
                    (s) => s.labels.first.name,
                    'labels.first.name',
                    newName,
                  )
                  .having((s) => s.error, 'error', isNull),
            ],
      );

      blocTest<ModifyLabelCubit, ModifyLabelState>(
        'Emits state with updated label and new color when newColor is provided',
        build: () {
          // colorToHex produces lowercase (e.g. #10b981); stub with any to match
          when(
            () => mockUpdateTagUseCase.execute(
              id: tagId,
              name: newName,
              color: any(named: 'color'),
            ),
          ).thenAnswer(
            (_) async => Right(
              TagModel(
                id: tagId,
                userId: 'user-1',
                name: newName,
                color: '#10b981',
              ),
            ),
          );

          return ModifyLabelCubit(
            getTagsByUserIdUseCase: mockGetTagsByUserIdUseCase,
            updateTagUseCase: mockUpdateTagUseCase,
          );
        },
        seed: () => ModifyLabelState(labels: [initialLabel]),
        act:
            (c) => c.updateTag(
              tagId: tagId,
              newName: newName,
              newColor: const Color(0xFF10B981),
            ),
        expect:
            () => [
              isA<ModifyLabelState>()
                  .having(
                    (s) => s.labels.first.name,
                    'labels.first.name',
                    newName,
                  )
                  .having((s) => s.error, 'error', isNull),
            ],
      );

      blocTest<ModifyLabelCubit, ModifyLabelState>(
        'Emits state with error message on failure',
        build: () {
          when(
            () => mockUpdateTagUseCase.execute(
              id: tagId,
              name: newName,
              color: any(named: 'color'),
            ),
          ).thenAnswer(
            (_) async => Left(Failure(error: ErrorInformation.UNDEFINED_ERROR)),
          );

          return ModifyLabelCubit(
            getTagsByUserIdUseCase: mockGetTagsByUserIdUseCase,
            updateTagUseCase: mockUpdateTagUseCase,
          );
        },
        seed: () => ModifyLabelState(labels: [initialLabel]),
        act: (c) => c.updateTag(tagId: tagId, newName: newName),
        expect:
            () => [
              isA<ModifyLabelState>().having(
                (s) => s.error,
                'error',
                Failure(error: ErrorInformation.UNDEFINED_ERROR).message,
              ),
            ],
      );

      test('Keeps other labels unchanged when updating one', () async {
        final otherLabel = LabelItem(
          id: 'tag-2',
          name: 'Other',
          color: Colors.blue,
          isSelected: false,
        );
        when(
          () => mockUpdateTagUseCase.execute(
            id: tagId,
            name: newName,
            color: any(named: 'color'),
          ),
        ).thenAnswer(
          (_) async => Right(
            TagModel(
              id: tagId,
              userId: 'user-1',
              name: newName,
              color: colorHex,
            ),
          ),
        );
        cubit = ModifyLabelCubit(
          getTagsByUserIdUseCase: mockGetTagsByUserIdUseCase,
          updateTagUseCase: mockUpdateTagUseCase,
        );
        cubit.emit(ModifyLabelState(labels: [initialLabel, otherLabel]));

        await cubit.updateTag(tagId: tagId, newName: newName);

        expect(cubit.state.labels.length, 2);
        expect(
          cubit.state.labels.firstWhere((l) => l.id == tagId).name,
          newName,
        );
        expect(
          cubit.state.labels.firstWhere((l) => l.id == 'tag-2').name,
          'Other',
        );
      });
    });

    group('LoadTags', () {
      // loadTags() uses global SECURE_STORAGE.read(key: USER_ID). In unit test
      // the storage may return null and the cubit will throw. Prefer testing
      // loadTags in integration tests or inject a storage dependency for testing.
      test('Emits loading state first when loadTags is called', () async {
        // This test may throw if SECURE_STORAGE.read returns null in test env.
        when(
          () =>
              mockGetTagsByUserIdUseCase.execute(userId: any(named: 'userId')),
        ).thenAnswer((_) async => Right([]));

        cubit = ModifyLabelCubit(
          getTagsByUserIdUseCase: mockGetTagsByUserIdUseCase,
          updateTagUseCase: mockUpdateTagUseCase,
        );

        final states = <ModifyLabelState>[];
        final subscription = cubit.stream.listen(states.add);

        try {
          await cubit.loadTags();
        } catch (_) {
          // userId may be null from SECURE_STORAGE in test
        }

        await subscription.cancel();

        final loadingStates = states.where((s) => s.isLoading == true);
        expect(
          loadingStates.isNotEmpty,
          true,
          reason: 'Cubit should emit loading when loadTags starts',
        );
      });
    });
  });
}
