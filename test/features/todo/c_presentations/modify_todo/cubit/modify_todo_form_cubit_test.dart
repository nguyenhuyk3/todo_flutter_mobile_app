import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';

// --- Imports đúng đường dẫn project của bạn ---
import 'package:todo_flutter_mobile_app/core/errors/failure.dart';
import 'package:todo_flutter_mobile_app/features/todo/a_domain/entities/enums.dart';
import 'package:todo_flutter_mobile_app/features/todo/a_domain/entities/recurrence_entity.dart';
import 'package:todo_flutter_mobile_app/features/todo/a_domain/entities/todo_entity.dart';
import 'package:todo_flutter_mobile_app/features/todo/b_data/models/todo_model.dart';
import 'package:todo_flutter_mobile_app/features/todo/c_presentations/modify_todo/cubit/todo/modify_todo_form_cubit.dart';
// (Đừng quên import State file)

// --- Helpers ---
void mockSecureStorage(String userId) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'read') return userId;
          return null;
        },
      );
}

void clearMockSecureStorage() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
        null,
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ModifyTodoFormCubit', () {
    // 1. SỬA TẠI ĐÂY: Đổi từ late -> Nullable
    ModifyTodoFormCubit? cubit;
    const tUserId = 'user-123';

    final tTodoEntity = TodoEntity(
      id: 'todo-1',
      userId: tUserId,
      title: 'Original Title',
      description: 'Original Description',
      startedDate: DateTime(2025, 1, 1),
      dueDate: DateTime(2025, 1, 5),
      priority: TodoPriority.high,
      status: TodoStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      recurrence: const RecurrenceEntity(
        recurrencePattern: RecurrencePattern.daily,
        reminderAt: '08:00',
      ),
    );

    setUpAll(() {
      mockSecureStorage(tUserId);
    });

    tearDownAll(() {
      clearMockSecureStorage();
    });

    // 2. SỬA TẠI ĐÂY: Check null trước khi close
    tearDown(() {
      cubit?.close();
    });

    // =======================================================
    // 1. STATE LOGIC TESTS
    // (Các test này không init cubit nên sẽ gây lỗi nếu dùng late cubit)
    // =======================================================
    group('ModifyTodoFormState Logic', () {
      test('Initial factory creates default state', () {
        final state = ModifyTodoFormState.initial();
        expect(state.title, '');
        expect(state.recurrencePattern, RecurrencePattern.once);
        expect(state.showTitleError, false);
      });

      test('isRangeDateValid returns correct boolean', () {
        // Case: Empty dates
        var state = ModifyTodoFormState.initial();
        expect(state.isRangeDateValid, false);

        // Case: Valid range
        state = state.copyWith(
          startedDate: '2026-01-01',
          dueDate: '2026-01-02',
        );
        expect(state.isRangeDateValid, true);

        // Case: Invalid range (End < Start)
        state = state.copyWith(
          startedDate: '2026-01-05',
          dueDate: '2026-01-01',
        );
        expect(state.isRangeDateValid, false);

        // Case: Equal dates (One day task) -> Valid
        state = state.copyWith(
          startedDate: '2026-01-05',
          dueDate: '2026-01-05',
        );
        expect(state.isRangeDateValid, true);
      });

      test('copyWith handles nullable reminderAt correctly', () {
        var state = ModifyTodoFormState.initial();

        // 1. Set Value
        state = state.copyWith(reminderAt: () => '10:00');
        expect(state.reminderAt, '10:00');

        // 2. Ignore Value (keep previous)
        state = state.copyWith(title: 'Change Title Only');
        expect(state.reminderAt, '10:00');

        // 3. Clear Value (set to null)
        state = state.copyWith(reminderAt: () => null);
        expect(state.reminderAt, null);
      });
    });

    // =======================================================
    // 2. CUBIT TESTS
    // =======================================================
    group('Initialization', () {
      test('Initializes with default state when initialTodo is null', () {
        cubit = ModifyTodoFormCubit(); // Gán cubit ở đây
        expect(cubit!.state.title, isEmpty); // Dùng cubit! hoặc cubit?.
        expect(cubit!.state.status, TodoStatus.pending);
      });

      test('Initializes with mapped values when initialTodo is provided', () {
        cubit = ModifyTodoFormCubit(initialTodo: tTodoEntity);

        expect(cubit!.state.title, 'Original Title');
        expect(cubit!.state.startedDate, '2025-01-01T00:00:00.000');
        expect(cubit!.state.recurrencePattern, RecurrencePattern.daily);
        expect(cubit!.state.reminderAt, '08:00');
      });
    });

    group('Field Updates', () {
      blocTest<ModifyTodoFormCubit, ModifyTodoFormState>(
        'Emits new Title and resets error flag',
        // Luôn trả về cubit instance trong build
        build: () {
          cubit = ModifyTodoFormCubit();
          return cubit!;
        },
        act: (c) => c.titleChanged(title: 'New Title'),
        expect:
            () => [
              isA<ModifyTodoFormState>()
                  .having((s) => s.title, 'title', 'New Title')
                  .having((s) => s.showTitleError, 'error hidden', false),
            ],
      );

      blocTest<ModifyTodoFormCubit, ModifyTodoFormState>(
        'Emits new Description and resets error flag',
        build: () {
          cubit = ModifyTodoFormCubit();
          return cubit!;
        },
        act: (c) => c.descriptionChanged(description: 'New Desc'),
        expect:
            () => [
              isA<ModifyTodoFormState>().having(
                (s) => s.description,
                'description',
                'New Desc',
              ),
            ],
      );

      blocTest<ModifyTodoFormCubit, ModifyTodoFormState>(
        'Emits new Priority',
        build: () {
          cubit = ModifyTodoFormCubit();
          return cubit!;
        },
        act: (c) => c.priorityChanged(TodoPriority.medium),
        expect:
            () => [
              isA<ModifyTodoFormState>().having(
                (s) => s.priority,
                'priority',
                TodoPriority.medium,
              ),
            ],
      );

      blocTest<ModifyTodoFormCubit, ModifyTodoFormState>(
        'Emits new Tag IDs',
        build: () {
          cubit = ModifyTodoFormCubit();
          return cubit!;
        },
        act: (c) => c.tagIdsChanged(['id1', 'id2']),
        expect:
            () => [
              isA<ModifyTodoFormState>().having(
                (s) => s.selectedTagIds,
                'tags',
                ['id1', 'id2'],
              ),
            ],
      );
    });

    group('Date Range & Logic', () {
      blocTest<ModifyTodoFormCubit, ModifyTodoFormState>(
        'Emits updated Dates and Calculated Weekdays (< 7 days)',
        build: () {
          cubit = ModifyTodoFormCubit();
          return cubit!;
        },
        act:
            (c) => c.dateRangeChanged(
              startedDate: '2026-01-01',
              dueDate: '2026-01-03',
            ),
        expect:
            () => [
              isA<ModifyTodoFormState>()
                  .having((s) => s.startedDate, 'started', '2026-01-01')
                  .having((s) => s.dueDate, 'due', '2026-01-03')
                  .having((s) => s.availableWeekdays, 'weekdays', [4, 5, 6])
                  .having((s) => s.showRangeDateError, 'error hidden', false),
            ],
      );

      blocTest<ModifyTodoFormCubit, ModifyTodoFormState>(
        'Emits full week days when range >= 7 days',
        build: () {
          cubit = ModifyTodoFormCubit();
          return cubit!;
        },
        act:
            (c) => c.dateRangeChanged(
              startedDate: '2026-01-01',
              dueDate: '2026-01-08',
            ),
        expect:
            () => [
              isA<ModifyTodoFormState>().having(
                (s) => s.availableWeekdays,
                'weekdays',
                [1, 2, 3, 4, 5, 6, 7],
              ),
            ],
      );

      blocTest<ModifyTodoFormCubit, ModifyTodoFormState>(
        'Removes invalid Custom Weekdays when range shrinks',
        build: () {
          cubit = ModifyTodoFormCubit();
          return cubit!;
        },
        seed:
            () => const ModifyTodoFormState(
              title: '',
              description: '',
              status: TodoStatus.pending,
              startedDate: '',
              dueDate: '',
              showTitleError: false,
              showDescriptionError: false,
              showRangeDateError: false,
              showReminderError: false,
              formzSubmissionStatus: FormzSubmissionStatus.initial,
              customWeekdays: [4, 7],
            ),
        act:
            (c) => c.dateRangeChanged(
              startedDate: '2026-01-01',
              dueDate: '2026-01-03',
            ),
        expect:
            () => [
              isA<ModifyTodoFormState>()
                  .having((s) => s.availableWeekdays, 'available', [4, 5, 6])
                  .having((s) => s.customWeekdays, 'filtered custom', [4]),
            ],
      );
    });

    group('Recurrence & Reminder Logic', () {
      blocTest<ModifyTodoFormCubit, ModifyTodoFormState>(
        'Clears Reminder and Custom Days when pattern is ONCE',
        build: () {
          cubit = ModifyTodoFormCubit();
          return cubit!;
        },
        seed:
            () => ModifyTodoFormState.initial().copyWith(
              reminderAt: () => '10:00',
              customWeekdays: [1],
            ),
        act: (c) => c.recurrenceChanged(pattern: RecurrencePattern.once),
        expect:
            () => [
              isA<ModifyTodoFormState>()
                  .having(
                    (s) => s.recurrencePattern,
                    'pattern',
                    RecurrencePattern.once,
                  )
                  .having((s) => s.reminderAt, 'reminder null', isNull)
                  .having((s) => s.customWeekdays, 'custom empty', isEmpty),
            ],
      );

      blocTest<ModifyTodoFormCubit, ModifyTodoFormState>(
        'Clears Custom Days but KEEPS Reminder when pattern is DAILY',
        build: () {
          cubit = ModifyTodoFormCubit();
          return cubit!;
        },
        seed:
            () => ModifyTodoFormState.initial().copyWith(
              reminderAt: () => '10:00',
              customWeekdays: [1],
            ),
        act: (c) => c.recurrenceChanged(pattern: RecurrencePattern.daily),
        expect:
            () => [
              isA<ModifyTodoFormState>()
                  .having(
                    (s) => s.recurrencePattern,
                    'pattern',
                    RecurrencePattern.daily,
                  )
                  .having((s) => s.customWeekdays, 'custom empty', isEmpty)
                  .having((s) => s.reminderAt, 'reminder preserved', '10:00'),
            ],
      );

      blocTest<ModifyTodoFormCubit, ModifyTodoFormState>(
        'Updates Time Format correctly',
        build: () {
          cubit = ModifyTodoFormCubit();
          return cubit!;
        },
        act:
            (c) => c.reminderTimeChanged(
              time: const TimeOfDay(hour: 9, minute: 5),
            ),
        expect:
            () => [
              isA<ModifyTodoFormState>().having(
                (s) => s.reminderAt,
                'formatted',
                '09:05',
              ),
            ],
      );

      blocTest<ModifyTodoFormCubit, ModifyTodoFormState>(
        'Sets Custom Days and auto switches to Custom Pattern',
        build: () {
          cubit = ModifyTodoFormCubit();
          return cubit!;
        },
        act: (c) => c.customWeekdaysChanged(days: [2, 4]),
        expect:
            () => [
              isA<ModifyTodoFormState>()
                  .having((s) => s.customWeekdays, 'days', [2, 4])
                  .having(
                    (s) => s.recurrencePattern,
                    'pattern',
                    RecurrencePattern.custom,
                  ),
            ],
      );
    });

    group('Submit Form Validation', () {
      test('Fails on Empty Title', () async {
        cubit = ModifyTodoFormCubit();
        cubit!.descriptionChanged(description: 'Desc');
        cubit!.dateRangeChanged(
          startedDate: '2026-01-01',
          dueDate: '2026-01-02',
        );

        final result = await cubit!.submitForm();

        expect(result, isNull);
        expect(cubit!.state.showTitleError, true);
        expect(cubit!.state.error, ErrorInformation.EMPTY_TITLE.message);
      });

      test('Fails on Empty Description', () async {
        cubit = ModifyTodoFormCubit();
        cubit!.titleChanged(title: 'Title');
        cubit!.dateRangeChanged(
          startedDate: '2026-01-01',
          dueDate: '2026-01-02',
        );

        final result = await cubit!.submitForm();

        expect(result, isNull);
        expect(cubit!.state.showDescriptionError, true);
        expect(cubit!.state.error, ErrorInformation.EMPTY_DESCRIPTION.message);
      });

      test('Fails on Invalid Date Range', () async {
        cubit = ModifyTodoFormCubit();
        cubit!.titleChanged(title: 'Title');
        cubit!.descriptionChanged(description: 'Desc');
        cubit!.dateRangeChanged(
          startedDate: '2026-01-05',
          dueDate: '2026-01-01',
        );

        final result = await cubit!.submitForm();

        expect(result, isNull);
        expect(cubit!.state.showRangeDateError, true);
      });

      test('Fails if Recurrence is ON but Reminder is Missing', () async {
        cubit = ModifyTodoFormCubit();
        cubit!.titleChanged(title: 'Title');
        cubit!.descriptionChanged(description: 'Desc');
        cubit!.dateRangeChanged(
          startedDate: '2026-01-01',
          dueDate: '2026-01-02',
        );

        cubit!.recurrenceChanged(pattern: RecurrencePattern.daily);

        final result = await cubit!.submitForm();

        expect(result, isNull);
        expect(cubit!.state.showReminderError, true);
        expect(
          cubit!.state.error,
          ErrorInformation.EMPTY_REMINDER_TIME.message,
        );
      });
    });

    group('Submit Form Success', () {
      test('Returns TodoModel successfully when valid', () async {
        cubit = ModifyTodoFormCubit();

        // 1. Fill Valid Data
        cubit!.titleChanged(title: 'Final Task');
        cubit!.descriptionChanged(description: 'Full Desc');
        cubit!.priorityChanged(TodoPriority.low);
        cubit!.dateRangeChanged(
          startedDate: '2026-01-01',
          dueDate: '2026-01-05',
        );
        cubit!.tagIdsChanged(['tag-a']);

        cubit!.recurrenceChanged(pattern: RecurrencePattern.daily);
        cubit!.reminderTimeChanged(time: const TimeOfDay(hour: 10, minute: 0));

        // 2. Submit
        final result = await cubit!.submitForm();

        expect(
          cubit!.state.formzSubmissionStatus,
          FormzSubmissionStatus.success,
        );
        expect(result, isNotNull);
        expect(result, isA<TodoModel>());

        expect(result?.title, 'Final Task');
        expect(result?.recurrence?.recurrencePattern, RecurrencePattern.daily);
        expect(result?.recurrence?.reminderAt, '10:00');
      });
    });
  });
}
