import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:todo_flutter_mobile_app/core/constants/others.dart';
import 'package:todo_flutter_mobile_app/core/errors/failure.dart';
import 'package:todo_flutter_mobile_app/features/authentication/a_domain/entities/enums.dart';
import 'package:todo_flutter_mobile_app/features/authentication/a_domain/usecases/authentication_use_case.dart';
import 'package:todo_flutter_mobile_app/features/authentication/a_domain/usecases/params/registration_param.dart';
import 'package:todo_flutter_mobile_app/features/authentication/c_presentations/registration/bloc/bloc.dart';
import 'package:todo_flutter_mobile_app/features/authentication/c_presentations/shared/inputs/email.dart';
import 'package:todo_flutter_mobile_app/features/authentication/c_presentations/shared/inputs/otp.dart';
import 'package:todo_flutter_mobile_app/features/authentication/c_presentations/shared/inputs/password.dart';

// 1. Mocks
class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockResendOTPUseCase extends Mock implements ResendOTPUseCase {}

class MockVerifyOTPUseCase extends Mock implements VerifyOTPUseCase {}

void main() {
  late RegistrationBloc registrationBloc;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockResendOTPUseCase mockResendOTPUseCase;
  late MockVerifyOTPUseCase mockVerifyOTPUseCase;

  // Dữ liệu mẫu dùng chung
  const tEmail = 'test@example.com';
  const tPassword = 'Password123!';
  const tFullName = 'Nguyen Van A';
  const tBirthDate = BIRTH_DATE_DEFAUL_VALUE;
  const tSex = 'male';
  const tOtpValue = '123456';

  setUp(() {
    mockRegisterUseCase = MockRegisterUseCase();
    mockResendOTPUseCase = MockResendOTPUseCase();
    mockVerifyOTPUseCase = MockVerifyOTPUseCase();

    registrationBloc = RegistrationBloc(
      registerUseCase: mockRegisterUseCase,
      resendOTPUseCase: mockResendOTPUseCase,
      verifyOTPUseCase: mockVerifyOTPUseCase,
    );
  });

  setUpAll(() {
    registerFallbackValue(
      RegistrationParams(
        email: 'email',
        password: 'pass',
        fullName: 'name',
        dateOfBirth: DateTime.now(),
        sex: Sex.male,
      ),
    );
    registerFallbackValue(OtpType.email);
  });

  tearDown(() {
    registrationBloc.close();
  });

  // =================================================================
  // GROUP 0: INITIALIZATION
  // =================================================================
  group('Initialization', () {
    test('Initial state should be RegistrationStepOne.initial()', () {
      expect(registrationBloc.state, isA<RegistrationStepOne>());
      final state = registrationBloc.state as RegistrationStepOne;
      expect(state.email.value, '');
      expect(state.password.value, '');
      expect(state.fullName, '');
      expect(state.birthDate, BIRTH_DATE_DEFAUL_VALUE);
      expect(state.sex, 'male');
      expect(state.isLoading, false);
      expect(state.error, '');
    });
  });

  // =================================================================
  // GROUP 1: STEP 1 - INPUT HANDLERS
  // (Email, Password, Personal Info)
  // =================================================================
  group('Step 1: Input Handlers', () {
    blocTest<RegistrationBloc, RegistrationState>(
      'on RegistrationEmailChanged: emits state with updated email',
      build: () => registrationBloc,
      act: (bloc) => bloc.add(const RegistrationEmailChanged(email: tEmail)),
      expect:
          () => [
            isA<RegistrationStepOne>().having(
              (s) => s.email.value,
              'email',
              tEmail,
            ),
          ],
    );

    blocTest<RegistrationBloc, RegistrationState>(
      'on RegistrationPasswordChanged: emits state with updated password & confirm password',
      build: () => registrationBloc,
      act:
          (bloc) => bloc.add(
            const RegistrationPasswordChanged(
              password: tPassword,
              confirmedPassword: tPassword,
            ),
          ),
      expect:
          () => [
            isA<RegistrationStepOne>()
                .having((s) => s.password.value, 'password', tPassword)
                .having((s) => s.confirmedPassword, 'confirmed', tPassword),
          ],
    );

    blocTest<RegistrationBloc, RegistrationState>(
      'on RegistrationInformationChanged: emits state with updated personal info (preserves email)',
      build: () => registrationBloc,
      seed:
          () => RegistrationStepOne.initial().copyWith(
            email: const Email.dirty(tEmail),
            password: const Password.dirty(tPassword),
          ),
      act:
          (bloc) => bloc.add(
            const RegistrationInformationChanged(
              fullName: tFullName,
              birthDate: tBirthDate,
              sex: tSex,
            ),
          ),
      expect:
          () => [
            isA<RegistrationStepOne>()
                .having((s) => s.fullName, 'fullName', tFullName)
                .having((s) => s.birthDate, 'birthDate', '2000-01-01')
                .having((s) => s.sex, 'sex', tSex)
                .having((s) => s.email.value, 'preserved email', tEmail),
          ],
    );
  });

  // =================================================================
  // GROUP 2: STEP 1 - SUBMIT HANDLER (_onStepOneSubmitted)
  // (Validations -> Loading -> UseCase Execution)
  // =================================================================
  group('Step 1: Submit Handler', () {
    // --- 2.1 Validation Failures ---
    blocTest<RegistrationBloc, RegistrationState>(
      'fails validation when Confirmed Password is empty',
      build: () => registrationBloc,
      seed:
          () => RegistrationStepOne.initial().copyWith(
            email: const Email.dirty(tEmail),
            password: const Password.dirty(tPassword),
            confirmedPassword: '', // Rỗng
            fullName: tFullName,
          ),
      act: (bloc) => bloc.add(RegistrationStepOneSubmitted()),
      expect:
          () => [
            isA<RegistrationStepOne>().having(
              (s) => s.error,
              'error message',
              ErrorInformation.EMPTY_CONFIRMED_PASSWORD.message,
            ),
          ],
    );

    blocTest<RegistrationBloc, RegistrationState>(
      'fails validation when Passwords do not match',
      build: () => registrationBloc,
      seed:
          () => RegistrationStepOne.initial().copyWith(
            email: const Email.dirty(tEmail),
            password: const Password.dirty(tPassword),
            confirmedPassword: 'WrongPassword', // Không khớp
            fullName: tFullName,
          ),
      act: (bloc) => bloc.add(RegistrationStepOneSubmitted()),
      expect:
          () => [
            isA<RegistrationStepOne>().having(
              (s) => s.error,
              'error message',
              ErrorInformation.CONFIRMED_PASSWORD_MISSMATCH.message,
            ),
          ],
    );

    blocTest<RegistrationBloc, RegistrationState>(
      'fails validation when Full Name is empty',
      build: () => registrationBloc,
      seed:
          () => RegistrationStepOne.initial().copyWith(
            email: const Email.dirty(tEmail),
            password: const Password.dirty(tPassword),
            confirmedPassword: tPassword,
            fullName: '', // Rỗng
          ),
      act: (bloc) => bloc.add(RegistrationStepOneSubmitted()),
      expect:
          () => [
            isA<RegistrationStepOne>().having(
              (s) => s.error,
              'error message',
              ErrorInformation.EMPTY_FULL_NAME.message,
            ),
          ],
    );

    // --- 2.2 UseCase Failure ---
    blocTest<RegistrationBloc, RegistrationState>(
      'emits [Loading, StepOneWithError] when RegisterUseCase returns Failure',
      build: () {
        when(() => mockRegisterUseCase.execute(any())).thenAnswer(
          (_) async =>
              const Left(Failure(error: ErrorInformation.UNDEFINED_ERROR)),
        );
        return registrationBloc;
      },
      seed:
          () => RegistrationStepOne.initial().copyWith(
            email: const Email.dirty(tEmail),
            password: const Password.dirty(tPassword),
            confirmedPassword: tPassword,
            fullName: tFullName,
          ),
      act: (bloc) => bloc.add(RegistrationStepOneSubmitted()),
      wait: const Duration(seconds: 2),
      expect:
          () => [
            isA<RegistrationStepOne>().having(
              (s) => s.isLoading,
              'loading',
              true,
            ),
            isA<RegistrationStepOne>().having(
              (s) => s.error,
              'error',
              ErrorInformation.UNDEFINED_ERROR.message,
            ),
          ],
    );

    // --- 2.3 UseCase Success ---
    blocTest<RegistrationBloc, RegistrationState>(
      'emits [Loading, StepTwo] when RegisterUseCase returns Success',
      build: () {
        when(
          () => mockRegisterUseCase.execute(any()),
        ).thenAnswer((_) async => const Right(true));
        return registrationBloc;
      },
      seed:
          () => RegistrationStepOne.initial().copyWith(
            email: const Email.dirty(tEmail),
            password: const Password.dirty(tPassword),
            confirmedPassword: tPassword,
            fullName: tFullName,
            birthDate: tBirthDate,
            sex: tSex,
          ),
      act: (bloc) => bloc.add(RegistrationStepOneSubmitted()),
      wait: const Duration(seconds: 2),
      expect:
          () => [
            isA<RegistrationStepOne>().having(
              (s) => s.isLoading,
              'loading',
              true,
            ),
            isA<RegistrationStepTwo>(), // Chuyển sang Step 2
          ],
      verify: (_) {
        verify(() => mockRegisterUseCase.execute(any())).called(1);
      },
    );
  });

  // =================================================================
  // GROUP 3: STEP 2 - INPUT & RESEND HANDLERS
  // (OTP Input, Resend OTP)
  // =================================================================
  group('Step 2: Input & Resend Handlers', () {
    blocTest<RegistrationBloc, RegistrationState>(
      'on RegistrationOtpChanged: emits state with updated OTP',
      build: () => registrationBloc,
      seed: () => const RegistrationStepTwo(otp: Otp.pure()),
      act: (bloc) => bloc.add(const RegistrationOtpChanged(otp: tOtpValue)),
      expect:
          () => [
            isA<RegistrationStepTwo>().having(
              (s) => s.otp.value,
              'otp value',
              tOtpValue,
            ),
          ],
    );

    // --- Resend OTP Logic ---
    blocTest<RegistrationBloc, RegistrationState>(
      'on RegistrationResendOTPRequested: emits Error if ResendUseCase fails',
      build: () {
        when(
          () => mockResendOTPUseCase.execute(
            email: any(named: 'email'),
            type: any(named: 'type'),
          ),
        ).thenAnswer(
          (_) async =>
              const Left(Failure(error: ErrorInformation.UNDEFINED_ERROR)),
        );

        return registrationBloc;
      },
      seed: () => const RegistrationStepTwo(otp: Otp.dirty(tOtpValue)),
      act: (bloc) => bloc.add(RegistrationResendOTPRequested()),
      expect:
          () => [
            isA<RegistrationStepTwo>().having(
              (s) => s.error,
              'error',
              ErrorInformation.UNDEFINED_ERROR.message,
            ),
          ],
    );

    blocTest<RegistrationBloc, RegistrationState>(
      'on RegistrationResendOTPRequested: successful resend does NOT change state (duplicate state) but verifies UseCase execution',
      build: () {
        when(
          () => mockResendOTPUseCase.execute(
            email: any(named: 'email'),
            type: any(named: 'type'),
          ),
        ).thenAnswer((_) async => const Right(true));

        return registrationBloc;
      },
      // Seed trạng thái đang có OTP nhập sẵn
      seed: () => const RegistrationStepTwo(otp: Otp.dirty(tOtpValue)),
      act: (bloc) => bloc.add(RegistrationResendOTPRequested()),

      expect: () => [],

      // QUAN TRỌNG: Kiểm tra hàm execute vẫn được gọi 1 lần
      verify: (_) {
        verify(
          () => mockResendOTPUseCase.execute(
            email: any(
              named: 'email',
            ), // Lưu ý: trong bloc dùng biến _email local, cần đảm bảo biến này đã set (hoặc mock nhận bất kì String nào)
            type: OtpType.signup,
          ),
        ).called(1);
      },
    );
  });

  // =================================================================
  // GROUP 4: STEP 2 - SUBMIT HANDLER (_onOtpSubmitted)
  // (Validations -> Loading -> UseCase Execution -> Success)
  // =================================================================
  group('Step 2: Submit Handler', () {
    // --- 4.1 Validation Failure ---
    blocTest<RegistrationBloc, RegistrationState>(
      'fails validation if OTP length is invalid',
      build: () => registrationBloc,
      seed: () => const RegistrationStepTwo(otp: Otp.dirty('12')), // Quá ngắn
      act: (bloc) => bloc.add(RegistrationOtpSubmitted()),
      expect:
          () => [
            isA<RegistrationStepTwo>().having(
              (s) => s.error,
              'otp error',
              "Mã Otp phải có đúng $LENGTH_OF_OTP kí tự",
            ),
          ],
    );

    // --- 4.2 UseCase Failure ---
    blocTest<RegistrationBloc, RegistrationState>(
      'emits [Loading, StepTwoWithError] if VerifyOTPUseCase fails',
      build: () {
        when(
          () => mockVerifyOTPUseCase.execute(
            email: any(named: 'email'),
            otp: any(named: 'otp'),
            type: any(named: 'type'),
          ),
        ).thenAnswer(
          (_) async =>
              const Left(Failure(error: ErrorInformation.UNDEFINED_ERROR)),
        );

        return registrationBloc;
      },
      seed: () => const RegistrationStepTwo(otp: Otp.dirty(tOtpValue)),
      act: (bloc) => bloc.add(RegistrationOtpSubmitted()),
      wait: const Duration(seconds: 2),
      expect:
          () => [
            isA<RegistrationStepTwo>().having(
              (s) => s.isLoading,
              'loading',
              true,
            ),
            isA<RegistrationStepTwo>().having(
              (s) => s.error,
              'error',
              ErrorInformation.UNDEFINED_ERROR.message,
            ),
          ],
    );

    // --- 4.3 UseCase Success ---
    blocTest<RegistrationBloc, RegistrationState>(
      'emits [Loading, RegistrationSuccess] if VerifyOTPUseCase succeeds',
      build: () {
        when(
          () => mockVerifyOTPUseCase.execute(
            email: any(named: 'email'),
            otp: any(named: 'otp'),
            type: any(named: 'type'),
          ),
        ).thenAnswer((_) async => const Right(true));

        return registrationBloc;
      },
      seed: () => const RegistrationStepTwo(otp: Otp.dirty(tOtpValue)),
      act: (bloc) => bloc.add(RegistrationOtpSubmitted()),
      wait: const Duration(seconds: 2),
      expect:
          () => [
            isA<RegistrationStepTwo>().having(
              (s) => s.isLoading,
              'loading',
              true,
            ),
            isA<RegistrationSuccess>(), // Hoàn tất quy trình
          ],
      verify: (_) {
        verify(
          () => mockVerifyOTPUseCase.execute(
            email: any(named: 'email'),
            otp: tOtpValue,
            type: OtpType.email,
          ),
        ).called(1);
      },
    );
  });

  // =================================================================
  // GROUP 5: GLOBAL ACTIONS (Reset)
  // =================================================================
  group('Global Actions', () {
    blocTest<RegistrationBloc, RegistrationState>(
      'on RegistrationReset: returns to Initial state',
      build: () => registrationBloc,
      seed:
          () => const RegistrationStepTwo(
            otp: Otp.pure(),
          ), // Giả sử đang ở bước 2
      act: (bloc) => bloc.add(RegistrationReset()),
      expect: () => [isA<RegistrationInitial>()],
    );
  });
}
