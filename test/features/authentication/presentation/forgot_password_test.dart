import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:todo_flutter_mobile_app/core/errors/failure.dart';
import 'package:todo_flutter_mobile_app/features/authentication/a_domain/usecases/authentication_use_case.dart';
import 'package:todo_flutter_mobile_app/features/authentication/c_presentations/forgot_password/bloc/bloc.dart';
import 'package:todo_flutter_mobile_app/features/authentication/c_presentations/shared/inputs/email.dart';
import 'package:todo_flutter_mobile_app/features/authentication/c_presentations/shared/inputs/otp.dart';
import 'package:todo_flutter_mobile_app/features/authentication/c_presentations/shared/inputs/password.dart';

class MockCheckEmailExistsUseCase extends Mock
    implements CheckEmailExistsUseCase {}

class MockSendForgotPasswordOTPUseCase extends Mock
    implements SendForgotPasswordOTPUseCase {}

class MockResendOTPUseCase extends Mock implements ResendOTPUseCase {}

class MockVerifyOTPUseCase extends Mock implements VerifyOTPUseCase {}

class MockUpdatePasswordUseCase extends Mock implements UpdatePasswordUseCase {}

void main() {
  late ForgotPasswordBloc forgotPasswordBloc;
  late MockCheckEmailExistsUseCase mockCheckEmailExistsUseCase;
  late MockSendForgotPasswordOTPUseCase mockSendForgotPasswordOTPUseCase;
  late MockResendOTPUseCase mockResendOTPUseCase;
  late MockVerifyOTPUseCase mockVerifyOTPUseCase;
  late MockUpdatePasswordUseCase mockUpdatePasswordUseCase;

  const tEmailStr = 'test@example.com';
  const tOtpStr = '123456';
  const tPasswordStr = 'Password123!';

  setUpAll(() {
    registerFallbackValue(OtpType.recovery);
  });
  setUp(() {
    mockCheckEmailExistsUseCase = MockCheckEmailExistsUseCase();
    mockSendForgotPasswordOTPUseCase = MockSendForgotPasswordOTPUseCase();
    mockResendOTPUseCase = MockResendOTPUseCase();
    mockVerifyOTPUseCase = MockVerifyOTPUseCase();
    mockUpdatePasswordUseCase = MockUpdatePasswordUseCase();

    forgotPasswordBloc = ForgotPasswordBloc(
      checkEmailExistsUseCase: mockCheckEmailExistsUseCase,
      sendForgotPasswordOTPUseCase: mockSendForgotPasswordOTPUseCase,
      resendOTPUseCase: mockResendOTPUseCase,
      verifyOTPUseCase: mockVerifyOTPUseCase,
      updatePasswordUseCase: mockUpdatePasswordUseCase,
    );
  });
  tearDown(() {
    forgotPasswordBloc.close();
  });

  // ==================== KHỞI TẠO ==================== //
  test('Initial state should be ForgotPasswordInitial', () {
    expect(forgotPasswordBloc.state, const ForgotPasswordInitial());
  });

  // ==================== STEP 1: EMAIL HANDLERS ==================== //

  // Handler: _onEmailChanged
  group('_onEmailChanged', () {
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'updates email state when user types',
      build: () => forgotPasswordBloc,
      act:
          (bloc) =>
              bloc.add(const ForgotPasswordEmailChanged(email: tEmailStr)),
      expect:
          () => [
            isA<ForgotPasswordStepOne>().having(
              (s) => s.email.value,
              'email',
              tEmailStr,
            ),
          ],
    );
  });

  // Handler: _onEmailSubmitted
  group('_onEmailSubmitted', () {
    // 1. Validate Formz
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'emits Error immediately if email format is invalid (local validation)',
      build: () => forgotPasswordBloc,
      seed:
          () =>
              const ForgotPasswordStepOne(email: Email.dirty('invalid-email')),
      act: (bloc) => bloc.add(ForgotPasswordEmailSubmitted()),
      expect:
          () => [
            isA<ForgotPasswordError>().having(
              (s) => s.error,
              'error',
              ErrorInformation.INVALID_EMAIL.message,
            ),
          ],
    );

    // 2. Logic: Email not found in DB
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'emits Error when CheckEmailExists returns false',
      build: () {
        when(
          () => mockCheckEmailExistsUseCase.execute(email: tEmailStr),
        ).thenAnswer((_) async => const Right(false));

        return forgotPasswordBloc;
      },
      seed: () => const ForgotPasswordStepOne(email: Email.dirty(tEmailStr)),
      act: (bloc) => bloc.add(ForgotPasswordEmailSubmitted()),
      wait: const Duration(seconds: 2),
      expect:
          () => [
            isA<ForgotPasswordStepOne>().having(
              (s) => s.isLoading,
              'loading',
              true,
            ),
            isA<ForgotPasswordError>().having(
              (s) => s.error,
              'error',
              ErrorInformation.EMAIL_NOT_EXISTS.message,
            ),
          ],
    );

    // 3. Logic: Email found but Sending OTP fails
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'emits Error when SendOTP fails (server error)',
      build: () {
        when(
          () => mockCheckEmailExistsUseCase.execute(email: tEmailStr),
        ).thenAnswer((_) async => const Right(true));
        when(
          () => mockSendForgotPasswordOTPUseCase.execute(email: tEmailStr),
        ).thenAnswer(
          (_) async =>
              const Left(Failure(error: ErrorInformation.UNDEFINED_ERROR)),
        );

        return forgotPasswordBloc;
      },
      seed: () => const ForgotPasswordStepOne(email: Email.dirty(tEmailStr)),
      act: (bloc) => bloc.add(ForgotPasswordEmailSubmitted()),
      wait: const Duration(seconds: 2),
      expect:
          () => [
            isA<ForgotPasswordStepOne>().having(
              (s) => s.isLoading,
              'loading',
              true,
            ),
            isA<ForgotPasswordError>().having((s) => s.error, 'msg', isNotNull),
          ],
    );

    // 4. Logic: SUCCESS -> Move to Step 2
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'emits StepTwo when Email exists AND OTP sent successfully',
      build: () {
        when(
          () => mockCheckEmailExistsUseCase.execute(email: tEmailStr),
        ).thenAnswer((_) async => const Right(true));
        when(
          () => mockSendForgotPasswordOTPUseCase.execute(email: tEmailStr),
        ).thenAnswer((_) async => const Right(true));
        return forgotPasswordBloc;
      },
      seed: () => const ForgotPasswordStepOne(email: Email.dirty(tEmailStr)),
      act: (bloc) => bloc.add(ForgotPasswordEmailSubmitted()),
      wait: const Duration(seconds: 2),
      expect:
          () => [
            isA<ForgotPasswordStepOne>().having(
              (s) => s.isLoading,
              'loading',
              true,
            ),
            isA<ForgotPasswordStepTwo>(),
          ],
    );
  });

  // ==================== STEP 2: OTP HANDLERS ==================== //

  // Handler: _onOtpChanged
  group('_onOtpChanged', () {
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'updates otp state when user types',
      build: () => forgotPasswordBloc,
      act: (bloc) => bloc.add(const ForgotPasswordOtpChanged(otp: tOtpStr)),
      expect:
          () => [
            isA<ForgotPasswordStepTwo>().having(
              (s) => s.otp.value,
              'otp',
              tOtpStr,
            ),
          ],
    );
  });

  // Handler: _onResendOTPRequested
  group('_onResendOTPRequested', () {
    // 1. Logic: Fail
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'emits Error when Resend OTP fails',
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

        return forgotPasswordBloc;
      },
      seed: () => const ForgotPasswordStepTwo(otp: Otp.dirty(tOtpStr)),
      act: (bloc) => bloc.add(ForgotPasswordResendOTPRequested()),
      expect:
          () => [
            isA<ForgotPasswordError>().having(
              (s) => s.error,
              'msg',
              ErrorInformation.UNDEFINED_ERROR.message,
            ),
          ],
    );

    // 2. Logic: Success
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'does nothing (empty list) if Resend OTP succeeds (keeps user on step 2)',
      build: () {
        when(
          () => mockResendOTPUseCase.execute(
            email: any(named: 'email'),
            type: any(named: 'type'),
          ),
        ).thenAnswer((_) async => const Right(true));

        return forgotPasswordBloc;
      },
      seed: () => const ForgotPasswordStepTwo(otp: Otp.dirty(tOtpStr)),
      act: (bloc) => bloc.add(ForgotPasswordResendOTPRequested()),
      expect:
          () => [
            // Nếu nhìn vào Bloc: `emit(ForgotPasswordStepTwo(otp: ...))` với giá trị cũ.
            // Equatable có thể coi là không đổi nếu object giống hệt.
            // Nhưng code trong bloc tạo instance mới: ForgotPasswordStepTwo(otp: Otp.dirty(currentState.otp.value))
            // Nếu test trả về list rỗng thì có nghĩa Equatable đã xử lý trùng state.
          ],
    );
  });

  // Handler: _onOtpSubmitted
  group('_onOtpSubmitted', () {
    // 1. Validate Formz
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'emits Error immediately if OTP format is invalid',
      build: () => forgotPasswordBloc,
      seed: () => const ForgotPasswordStepTwo(otp: Otp.dirty('short')),
      act: (bloc) => bloc.add(ForgotPasswordOtpSubmitted()),
      expect:
          () => [
            isA<ForgotPasswordError>().having(
              (s) => s.error,
              'validation',
              isNotNull,
            ),
          ],
    );

    // 2. Logic: Fail
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'emits Loading then Error when VerifyOTP fails',
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

        return forgotPasswordBloc;
      },
      seed: () => const ForgotPasswordStepTwo(otp: Otp.dirty(tOtpStr)),
      act: (bloc) => bloc.add(ForgotPasswordOtpSubmitted()),
      wait: const Duration(seconds: 2),
      expect:
          () => [
            isA<ForgotPasswordLoading>(),
            isA<ForgotPasswordError>().having(
              (s) => s.error,
              'msg',
              ErrorInformation.UNDEFINED_ERROR.message,
            ),
          ],
    );

    // 3. Logic: Success -> Move to Step 3
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'emits Loading then StepThree when VerifyOTP succeeds',
      build: () {
        when(
          () => mockVerifyOTPUseCase.execute(
            email: any(named: 'email'),
            otp: any(named: 'otp'),
            type: any(named: 'type'),
          ),
        ).thenAnswer((_) async => const Right(true));

        return forgotPasswordBloc;
      },
      seed: () => const ForgotPasswordStepTwo(otp: Otp.dirty(tOtpStr)),
      act: (bloc) => bloc.add(ForgotPasswordOtpSubmitted()),
      wait: const Duration(seconds: 2),
      expect:
          () => [isA<ForgotPasswordLoading>(), isA<ForgotPasswordStepThree>()],
    );
  });

  // ==================== STEP 3: PASSWORD HANDLERS ==================== //

  // Handler: _onPasswordChanged
  group('_onPasswordChanged', () {
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'updates password inputs and clears existing error',
      build: () => forgotPasswordBloc,
      act:
          (bloc) => bloc.add(
            const ForgotPasswordPasswordChanged(
              password: tPasswordStr,
              confirmedPassword: tPasswordStr,
            ),
          ),
      expect:
          () => [
            isA<ForgotPasswordStepThree>()
                .having((s) => s.password.value, 'pass', tPasswordStr)
                .having((s) => s.confirmedPassword, 'confirm', tPasswordStr)
                .having((s) => s.error, 'error cleared', isEmpty),
          ],
    );
  });

  // Handler: _onPasswordSubmitted
  group('_onPasswordSubmmitted', () {
    final tStateStep3 = ForgotPasswordStepThree(
      password: const Password.dirty(tPasswordStr),
      confirmedPassword: tPasswordStr,
      error: '',
    );

    // 1. Validate Formz
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'emits StepThree with Error if password format is invalid',
      build: () => forgotPasswordBloc,
      seed: () => tStateStep3.copyWith(password: const Password.dirty('bad')),
      act: (bloc) => bloc.add(ForgotPasswordSubmitted()),
      expect:
          () => [
            isA<ForgotPasswordStepThree>().having(
              (s) => s.error,
              'msg',
              isNotNull,
            ),
          ],
    );

    // 2. Validate Empty Confirm
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'emits StepThree with Error if confirmed password is empty',
      build: () => forgotPasswordBloc,
      seed: () => tStateStep3.copyWith(confirmedPassword: ''),
      act: (bloc) => bloc.add(ForgotPasswordSubmitted()),
      expect:
          () => [
            isA<ForgotPasswordStepThree>().having(
              (s) => s.error,
              'msg',
              ErrorInformation.EMPTY_CONFIRMED_PASSWORD.message,
            ),
          ],
    );

    // 3. Validate Mismatch
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'emits StepThree with Error if passwords do not match',
      build: () => forgotPasswordBloc,
      seed: () => tStateStep3.copyWith(confirmedPassword: 'DifferentPassword'),
      act: (bloc) => bloc.add(ForgotPasswordSubmitted()),
      expect:
          () => [
            isA<ForgotPasswordStepThree>().having(
              (s) => s.error,
              'msg',
              ErrorInformation.CONFIRMED_PASSWORD_MISSMATCH.message,
            ),
          ],
    );

    // 4. Logic: Update Failure
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'emits Loading then StepThree with Error if UpdatePassword fails',
      build: () {
        when(
          () => mockUpdatePasswordUseCase.execute(
            email: any(named: 'email'),
            newPassword: any(named: 'newPassword'),
          ),
        ).thenAnswer(
          (_) async =>
              const Left(Failure(error: ErrorInformation.UNDEFINED_ERROR)),
        );

        return forgotPasswordBloc;
      },
      seed: () => tStateStep3,
      act: (bloc) => bloc.add(ForgotPasswordSubmitted()),
      wait: const Duration(seconds: 2),
      expect:
          () => [
            isA<ForgotPasswordStepThree>().having(
              (s) => s.isLoading,
              'loading',
              true,
            ),
            isA<ForgotPasswordStepThree>().having(
              (s) => s.error,
              'msg',
              ErrorInformation.UNDEFINED_ERROR.message,
            ),
          ],
    );

    // 5. Logic: SUCCESS -> Finish
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'emits Loading then ForgotPasswordSuccess when UpdatePassword succeeds',
      build: () {
        when(
          () => mockUpdatePasswordUseCase.execute(
            email: any(named: 'email'),
            newPassword: any(named: 'newPassword'),
          ),
        ).thenAnswer((_) async => const Right(true));

        return forgotPasswordBloc;
      },
      seed: () => tStateStep3,
      act: (bloc) => bloc.add(ForgotPasswordSubmitted()),
      wait: const Duration(seconds: 2),
      expect:
          () => [
            isA<ForgotPasswordStepThree>().having(
              (s) => s.isLoading,
              'loading',
              true,
            ),
            isA<ForgotPasswordSuccess>(),
          ],
    );
  });
}
