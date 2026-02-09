import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';

import 'package:todo_flutter_mobile_app/core/errors/failure.dart';
import 'package:todo_flutter_mobile_app/features/todo/a_domain/entities/enums.dart';
import 'package:todo_flutter_mobile_app/features/todo/a_domain/entities/recurrence_entity.dart';
import 'package:todo_flutter_mobile_app/features/todo/a_domain/entities/todo_entity.dart';
import 'package:todo_flutter_mobile_app/features/todo/b_data/models/todo_model.dart';
import 'package:todo_flutter_mobile_app/features/todo/c_presentations/modify_todo/cubit/todo/modify_todo_form_cubit.dart';

void mockSecureStorage(String userId) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),

        (MethodCall methodCall) async {
          if (methodCall.method == 'read') {
            return userId;
          }

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

    tearDown(() {
      cubit?.close();
    });

    // =======================================================
    // 1. STATE LOGIC TESTS
    // (Kiểm tra các getter/factory trong State class trước)
    // =======================================================
    group('1. ModifyTodoFormState Internal Logic', () {
      test('Initial factory creates default state', () {
        final state = ModifyTodoFormState.initial();

        expect(state.title, '');
        expect(state.recurrencePattern, RecurrencePattern.once);
        expect(state.showTitleError, false);
      });
      test('isRangeDateValid returns correct boolean', () {
        var state = ModifyTodoFormState.initial();
        // Empty
        expect(state.isRangeDateValid, false);
        // Valid
        state = state.copyWith(
          startedDate: '2026-01-01',
          dueDate: '2026-01-02',
        );
        expect(state.isRangeDateValid, true);
        // Invalid (End < Start)
        state = state.copyWith(
          startedDate: '2026-01-05',
          dueDate: '2026-01-01',
        );
        expect(state.isRangeDateValid, false);
        // Equal
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
        // 2. Ignore Value
        state = state.copyWith(title: 'Title');
        expect(state.reminderAt, '10:00');
        // 3. Clear Value
        state = state.copyWith(reminderAt: () => null);

        expect(state.reminderAt, null);
      });
    });

    // =======================================================
    // 2. INITIALIZATION TESTS
    // (Kiểm tra việc khởi tạo Cubit - bước đầu tiên của flow)
    // =======================================================
    group('2. Cubit Initialization', () {
      test(
        'Initializes with default state when initialTodo is null (New Mode)',
        () {
          cubit = ModifyTodoFormCubit();

          expect(cubit!.state.title, isEmpty);
          expect(cubit!.state.status, TodoStatus.pending);
        },
      );

      test(
        'Initializes with mapped values when initialTodo is provided (Edit Mode)',
        () {
          cubit = ModifyTodoFormCubit(initialTodo: tTodoEntity);

          expect(cubit!.state.title, 'Original Title');
          expect(cubit!.state.startedDate, '2025-01-01T00:00:00.000');
          expect(cubit!.state.recurrencePattern, RecurrencePattern.daily);
          expect(cubit!.state.reminderAt, '08:00');
        },
      );
    });

    // =======================================================
    // 3. BASIC INTERACTION TESTS
    // (Kiểm tra input các trường đơn giản)
    // =======================================================
    group('3. Simple Field Interactions', () {
      blocTest<ModifyTodoFormCubit, ModifyTodoFormState>(
        'titleChanged: updates Title and resets error flag',
        build: () => cubit = ModifyTodoFormCubit(),
        act: (c) => c.titleChanged(title: 'New Title'),
        expect:
            () => [
              isA<ModifyTodoFormState>()
                  .having((s) => s.title, 'title', 'New Title')
                  .having((s) => s.showTitleError, 'error hidden', false),
            ],
      );

      blocTest<ModifyTodoFormCubit, ModifyTodoFormState>(
        'descriptionChanged: updates Description and resets error flag',
        build: () => cubit = ModifyTodoFormCubit(),
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
        'priorityChanged: updates Priority',
        build: () => cubit = ModifyTodoFormCubit(),
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
        'tagIdsChanged: updates Tag IDs',
        build: () => cubit = ModifyTodoFormCubit(),
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

    // =======================================================
    // 4. COMPLEX LOGIC: DATE RANGE
    // (Kiểm tra tính toán ngày tháng và Weekdays)
    // =======================================================
    group('4. Date Range & Weekday Logic', () {
      // TEST BỔ SUNG: Kiểm tra input rỗng (từ screenshot)
      blocTest<ModifyTodoFormCubit, ModifyTodoFormState>(
        'dateRangeChanged: Handle Empty Inputs gracefully',
        build: () => cubit = ModifyTodoFormCubit(),
        act: (c) => c.dateRangeChanged(startedDate: '', dueDate: ''),
        expect:
            () => [
              isA<ModifyTodoFormState>()
                  .having(
                    (s) => s.availableWeekdays,
                    'should be empty list',
                    isEmpty,
                  )
                  .having((s) => s.startedDate, 'empty string', '')
                  .having((s) => s.showRangeDateError, 'error hidden', false),
            ],
      );

      blocTest<ModifyTodoFormCubit, ModifyTodoFormState>(
        'dateRangeChanged: Calculate Weekdays correctly (< 7 days)',
        build: () => cubit = ModifyTodoFormCubit(),
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
                  .having((s) => s.availableWeekdays, 'weekdays', [4, 5, 6]),
            ],
      );

      blocTest<ModifyTodoFormCubit, ModifyTodoFormState>(
        'dateRangeChanged: Allow all days when range >= 7 days',
        build: () => cubit = ModifyTodoFormCubit(),
        act:
            (c) => c.dateRangeChanged(
              startedDate: '2026-01-01',
              dueDate: '2026-01-08',
            ),
        expect:
            () => [
              isA<ModifyTodoFormState>().having(
                (s) => s.availableWeekdays,
                'all weekdays',
                [1, 2, 3, 4, 5, 6, 7],
              ),
            ],
      );

      blocTest<ModifyTodoFormCubit, ModifyTodoFormState>(
        'dateRangeChanged: Remove invalid Custom Weekdays when range shrinks',
        build: () => cubit = ModifyTodoFormCubit(),
        seed:
            () =>
                ModifyTodoFormState.initial().copyWith(customWeekdays: [4, 7]),
        act:
            (c) => c.dateRangeChanged(
              startedDate: '2026-01-01', // Thur (4)
              dueDate: '2026-01-03', // Sat (6) -> 7 invalid
            ),
        expect:
            () => [
              isA<ModifyTodoFormState>()
                  .having((s) => s.availableWeekdays, 'available', [4, 5, 6])
                  .having((s) => s.customWeekdays, 'removed 7, kept 4', [4]),
            ],
      );
    });

    // =======================================================
    // 5. COMPLEX LOGIC: RECURRENCE & REMINDER
    // (Kiểm tra logic chuyển đổi lặp lại và nhắc nhở)
    // =======================================================
    group('5. Recurrence & Reminder Logic', () {
      blocTest<ModifyTodoFormCubit, ModifyTodoFormState>(
        'reminderTimeChanged: updates format',
        build: () => cubit = ModifyTodoFormCubit(),
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
        'recurrenceChanged (to ONCE): Clears Reminder and Custom Days',
        build: () => cubit = ModifyTodoFormCubit(),
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
        'recurrenceChanged (to DAILY): Clears Custom Days but KEEPS Reminder',
        build: () => cubit = ModifyTodoFormCubit(),
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
        'recurrenceChanged (to CUSTOM): Preserves existing Custom Days',
        build: () => cubit = ModifyTodoFormCubit(),
        seed:
            () => ModifyTodoFormState.initial().copyWith(
              recurrencePattern: RecurrencePattern.daily,
              customWeekdays: [1, 2], // Có dữ liệu cũ
            ),
        act: (c) => c.recurrenceChanged(pattern: RecurrencePattern.custom),
        expect:
            () => [
              isA<ModifyTodoFormState>()
                  .having(
                    (s) => s.recurrencePattern,
                    'pattern',
                    RecurrencePattern.custom,
                  )
                  .having((s) => s.customWeekdays, 'DATA PRESERVED', [1, 2]),
            ],
      );

      blocTest<ModifyTodoFormCubit, ModifyTodoFormState>(
        'customWeekdaysChanged: Sets Custom Days and Auto-switches Pattern to CUSTOM',
        build: () => cubit = ModifyTodoFormCubit(),
        act: (c) => c.customWeekdaysChanged(days: [2, 4]),
        expect:
            () => [
              isA<ModifyTodoFormState>()
                  .having((s) => s.customWeekdays, 'days', [2, 4])
                  .having(
                    (s) => s.recurrencePattern,
                    'auto set pattern',
                    RecurrencePattern.custom,
                  ),
            ],
      );
    });

    // =======================================================
    // 6. SUBMIT VALIDATION TESTS
    // (Kiểm tra các trường hợp submit thất bại)
    // =======================================================
    group('6. Submit Validation (Failures)', () {
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
        // Enable recurrence
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

    // =======================================================
    // 7. SUBMIT SUCCESS TESTS
    // (Kiểm tra trường hợp submit thành công cuối cùng)
    // =======================================================
    group('7. Submit Success', () {
      test('Returns TodoModel successfully when all data is valid', () async {
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
        // 3. Verify
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
