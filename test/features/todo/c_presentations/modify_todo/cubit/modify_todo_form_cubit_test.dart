import 'package:flutter/material.dart';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';

import 'package:todo_flutter_mobile_app/core/errors/failure.dart';
import 'package:todo_flutter_mobile_app/features/todo/a_domain/entities/enums.dart';
import 'package:todo_flutter_mobile_app/features/todo/c_presentations/modify_todo/cubit/todo/modify_todo_form_cubit.dart';

void main() {
  group('ModifyTodoFormCubit', () {
    late ModifyTodoFormCubit cubit;

    tearDown(() {
      cubit.close();
    });

    group('Initial state', () {
      test(
        'Initializes with default state when initialTodo is not provided',
        () {
          cubit = ModifyTodoFormCubit();

          expect(cubit.state.title, '');
          expect(cubit.state.description, '');
          expect(cubit.state.priority, TodoPriority.low);
          expect(cubit.state.status, TodoStatus.pending);
          expect(cubit.state.startedDate, '');
          expect(cubit.state.dueDate, '');
          expect(cubit.state.recurrencePattern, RecurrencePattern.once);
          expect(
            cubit.state.formzSubmissionStatus,
            FormzSubmissionStatus.initial,
          );
          expect(cubit.state.showTitleError, false);
          expect(cubit.state.showDescriptionError, false);
          expect(cubit.state.showRangeDateError, false);
        },
      );
    });

    group('titleChanged', () {
      blocTest<ModifyTodoFormCubit, ModifyTodoFormState>(
        'Emits state with new title and showTitleError = false',
        build: () => ModifyTodoFormCubit(),
        act: (c) => c.titleChanged(title: 'New todo'),
        expect:
            () => [
              isA<ModifyTodoFormState>()
                  .having((s) => s.title, 'title', 'New todo')
                  .having((s) => s.showTitleError, 'showTitleError', false),
            ],
      );
    });

    group('descriptionChanged', () {
      blocTest<ModifyTodoFormCubit, ModifyTodoFormState>(
        'Emits state with new description and showDescriptionError = false',
        build: () => ModifyTodoFormCubit(),
        act: (c) => c.descriptionChanged(description: 'Detailed description'),
        expect:
            () => [
              isA<ModifyTodoFormState>()
                  .having(
                    (s) => s.description,
                    'description',
                    'Detailed description',
                  )
                  .having(
                    (s) => s.showDescriptionError,
                    'showDescriptionError',
                    false,
                  ),
            ],
      );
    });

    group('dateRangeChanged', () {
      blocTest<ModifyTodoFormCubit, ModifyTodoFormState>(
        'Emits state with startedDate, dueDate and availableWeekdays',
        build: () => ModifyTodoFormCubit(),
        act:
            (c) => c.dateRangeChanged(
              startedDate: '2026-01-01',
              dueDate: '2026-01-05',
            ),
        expect:
            () => [
              isA<ModifyTodoFormState>()
                  .having((s) => s.startedDate, 'startedDate', '2026-01-01')
                  .having((s) => s.dueDate, 'dueDate', '2026-01-05')
                  .having(
                    (s) => s.showRangeDateError,
                    'showRangeDateError',
                    false,
                  ),
            ],
      );

      test(
        'AvailableWeekdays contains correct weekdays for range < 7 days',
        () {
          cubit = ModifyTodoFormCubit();
          cubit.dateRangeChanged(
            startedDate: '2026-01-01', // Thu
            dueDate: '2026-01-03', // Sat
          );
          // 2026-01-01 Thu=4, 01-02 Fri=5, 01-03 Sat=6
          expect(cubit.state.availableWeekdays, [4, 5, 6]);
        },
      );

      test('AvailableWeekdays equals [1..7] when range >= 7 days', () {
        cubit = ModifyTodoFormCubit();
        cubit.dateRangeChanged(
          startedDate: '2026-01-01',
          dueDate: '2026-01-08',
        );
        expect(cubit.state.availableWeekdays, [1, 2, 3, 4, 5, 6, 7]);
      });
    });

    group('recurrenceChanged', () {
      blocTest<ModifyTodoFormCubit, ModifyTodoFormState>(
        'Emits state with recurrencePattern = once and clears reminder and customWeekdays',
        build: () => ModifyTodoFormCubit(),
        act: (c) => c.recurrenceChanged(pattern: RecurrencePattern.once),
        expect:
            () => [
              isA<ModifyTodoFormState>()
                  .having(
                    (s) => s.recurrencePattern,
                    'recurrencePattern',
                    RecurrencePattern.once,
                  )
                  .having((s) => s.reminderAt, 'reminderAt', null)
                  .having((s) => s.customWeekdays, 'customWeekdays', []),
            ],
      );

      blocTest<ModifyTodoFormCubit, ModifyTodoFormState>(
        'Emits state with recurrencePattern = custom',
        build: () => ModifyTodoFormCubit(),
        act: (c) => c.recurrenceChanged(pattern: RecurrencePattern.custom),
        expect:
            () => [
              isA<ModifyTodoFormState>().having(
                (s) => s.recurrencePattern,
                'recurrencePattern',
                RecurrencePattern.custom,
              ),
            ],
      );

      blocTest<ModifyTodoFormCubit, ModifyTodoFormState>(
        'Emits state with recurrencePattern = daily and clears customWeekdays',
        build: () => ModifyTodoFormCubit(),
        act: (c) => c.recurrenceChanged(pattern: RecurrencePattern.daily),
        expect:
            () => [
              isA<ModifyTodoFormState>()
                  .having(
                    (s) => s.recurrencePattern,
                    'recurrencePattern',
                    RecurrencePattern.daily,
                  )
                  .having((s) => s.customWeekdays, 'customWeekdays', []),
            ],
      );
    });

    group('reminderTimeChanged', () {
      blocTest<ModifyTodoFormCubit, ModifyTodoFormState>(
        'Emits state with reminderAt in HH:mm format',
        build: () => ModifyTodoFormCubit(),
        act:
            (c) => c.reminderTimeChanged(
              time: const TimeOfDay(hour: 10, minute: 5),
            ),
        expect:
            () => [
              isA<ModifyTodoFormState>().having(
                (s) => s.reminderAt,
                'reminderAt',
                '10:05',
              ),
            ],
      );
    });

    group('priorityChanged', () {
      blocTest<ModifyTodoFormCubit, ModifyTodoFormState>(
        'Emits state with new priority',
        build: () => ModifyTodoFormCubit(),
        act: (c) => c.priorityChanged(TodoPriority.high),
        expect:
            () => [
              isA<ModifyTodoFormState>().having(
                (s) => s.priority,
                'priority',
                TodoPriority.high,
              ),
            ],
      );
    });

    group('customWeekdaysChanged', () {
      blocTest<ModifyTodoFormCubit, ModifyTodoFormState>(
        'Emits state with customWeekdays and recurrencePattern = custom',
        build: () => ModifyTodoFormCubit(),
        act: (c) => c.customWeekdaysChanged(days: [1, 3, 5]),
        expect:
            () => [
              isA<ModifyTodoFormState>()
                  .having((s) => s.customWeekdays, 'customWeekdays', [1, 3, 5])
                  .having(
                    (s) => s.recurrencePattern,
                    'recurrencePattern',
                    RecurrencePattern.custom,
                  ),
            ],
      );
    });

    group('tagIdsChanged', () {
      blocTest<ModifyTodoFormCubit, ModifyTodoFormState>(
        'Emits state with selectedTagIds',
        build: () => ModifyTodoFormCubit(),
        act: (c) => c.tagIdsChanged(['id1', 'id2']),
        expect:
            () => [
              isA<ModifyTodoFormState>().having(
                (s) => s.selectedTagIds,
                'selectedTagIds',
                ['id1', 'id2'],
              ),
            ],
      );
    });

    // group('projectChanged', () {
    //   blocTest<ModifyTodoFormCubit, ModifyTodoFormState>(
    //     'Emits state with projectId = null and resets parentTodoId when projectChanged(null)',
    //     build: () => ModifyTodoFormCubit(),
    //     seed: () => ModifyTodoFormState.initial(),
    //     act: (c) => c.projectChanged(projectId: null),
    //     expect: () => [isA<ModifyTodoFormState>(), isA<ModifyTodoFormState>()],
    //   );

    //   blocTest<ModifyTodoFormCubit, ModifyTodoFormState>(
    //     'Emits state with projectId and resets recurrence when projectChanged(projectId)',
    //     build: () => ModifyTodoFormCubit(),
    //     act: (c) => c.projectChanged(projectId: 'project-1'),
    //     expect:
    //         () => [
    //           isA<ModifyTodoFormState>()
    //               .having(
    //                 (s) => s.recurrencePattern,
    //                 'recurrencePattern',
    //                 RecurrencePattern.once,
    //               )
    //               .having((s) => s.reminderAt, 'reminderAt', null)
    //               .having((s) => s.availableWeekdays, 'availableWeekdays', [])
    //               .having((s) => s.customWeekdays, 'customWeekdays', []),
    //         ],
    //   );
    // });

    // group('ParentTodoChanged', () {
    //   blocTest<ModifyTodoFormCubit, ModifyTodoFormState>(
    //     'Rmits state with parentTodoId',
    //     build: () => ModifyTodoFormCubit(),
    //     act: (c) => c.parentTodoChanged('parent-id'),
    //     expect: () => [isA<ModifyTodoFormState>()],
    //   );
    // });

    group('SubmitForm validation', () {
      test(
        'Returns null and emits showTitleError when title is empty',
        () async {
          cubit = ModifyTodoFormCubit();
          cubit.dateRangeChanged(
            startedDate: '2026-01-01',
            dueDate: '2026-01-02',
          );
          cubit.descriptionChanged(description: 'Description');
          cubit.titleChanged(title: '   ');

          final result = await cubit.submitForm();

          expect(result, isNull);
          expect(cubit.state.showTitleError, true);
          expect(
            cubit.state.formzSubmissionStatus,
            FormzSubmissionStatus.failure,
          );
          expect(cubit.state.error, ErrorInformation.EMPTY_TITLE.message);
        },
      );

      test(
        'Returns null and emits showDescriptionError when description is empty',
        () async {
          cubit = ModifyTodoFormCubit();
          cubit.dateRangeChanged(
            startedDate: '2026-01-01',
            dueDate: '2026-01-02',
          );
          cubit.titleChanged(title: 'Title');
          cubit.descriptionChanged(description: '   ');

          final result = await cubit.submitForm();

          expect(result, isNull);
          expect(cubit.state.showDescriptionError, true);
          expect(
            cubit.state.formzSubmissionStatus,
            FormzSubmissionStatus.failure,
          );
          expect(cubit.state.error, ErrorInformation.EMPTY_DESCRIPTION.message);
        },
      );

      test(
        'Returns null and emits showRangeDateError when date range is invalid',
        () async {
          cubit = ModifyTodoFormCubit();
          cubit.titleChanged(title: 'Title');
          cubit.descriptionChanged(description: 'Description');
          // startedDate, dueDate still empty or invalid

          final result = await cubit.submitForm();

          expect(result, isNull);
          expect(cubit.state.showRangeDateError, true);
          expect(
            cubit.state.formzSubmissionStatus,
            FormzSubmissionStatus.failure,
          );
          expect(cubit.state.error, ErrorInformation.EMPTY_DATE_RANGE.message);
        },
      );

      test(
        'Returns null and emits showRangeDateError when dueDate is before startedDate',
        () async {
          cubit = ModifyTodoFormCubit();
          cubit.titleChanged(title: 'Title');
          cubit.descriptionChanged(description: 'Description');
          cubit.dateRangeChanged(
            startedDate: '2026-01-10',
            dueDate: '2026-01-01',
          );

          final result = await cubit.submitForm();

          expect(result, isNull);
          expect(cubit.state.showRangeDateError, true);
          expect(
            cubit.state.formzSubmissionStatus,
            FormzSubmissionStatus.failure,
          );
        },
      );

      test(
        'Returns null and emits showReminderError when recurring but reminder time not set',
        () async {
          cubit = ModifyTodoFormCubit();
          cubit.titleChanged(title: 'Title');
          cubit.descriptionChanged(description: 'Description');
          cubit.dateRangeChanged(
            startedDate: '2026-01-01',
            dueDate: '2026-01-02',
          );
          cubit.recurrenceChanged(pattern: RecurrencePattern.daily);
          // reminderAt still null

          final result = await cubit.submitForm();

          expect(result, isNull);
          expect(cubit.state.showReminderError, true);
          expect(
            cubit.state.formzSubmissionStatus,
            FormzSubmissionStatus.failure,
          );
          expect(
            cubit.state.error,
            ErrorInformation.EMPTY_REMINDER_TIME.message,
          );
        },
      );

      test('Emits inProgress before validation', () async {
        cubit = ModifyTodoFormCubit();
        cubit.titleChanged(title: 'Title');
        cubit.descriptionChanged(description: 'Description');
        cubit.dateRangeChanged(
          startedDate: '2026-01-01',
          dueDate: '2026-01-02',
        );

        final states = <ModifyTodoFormState>[];
        final subscription = cubit.stream.listen(states.add);

        try {
          await cubit.submitForm();
        } catch (_) {
          // In test env SECURE_STORAGE.read may return null so userId! throws
        }

        await subscription.cancel();
        final inProgressStates = states.where(
          (s) => s.formzSubmissionStatus == FormzSubmissionStatus.inProgress,
        );
        expect(inProgressStates.isNotEmpty, true);
      });
    });
  });
}
