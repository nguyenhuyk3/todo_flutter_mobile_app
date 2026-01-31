import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:todo_flutter_mobile_app/core/errors/failure.dart';
import 'package:todo_flutter_mobile_app/features/authentication/domain/usecases/authentication_use_case.dart';
import 'package:todo_flutter_mobile_app/features/authentication/presentations/inputs/email.dart';
import 'package:todo_flutter_mobile_app/features/authentication/presentations/inputs/otp.dart';
import 'package:todo_flutter_mobile_app/features/authentication/presentations/inputs/password.dart';
import 'package:todo_flutter_mobile_app/features/authentication/presentations/forgot_password/bloc/bloc.dart';

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

  // ==================== STEP 1: NHẬP EMAIL ==================== //
  group('Step 1: Input Email', () {
    // Note: Kiểm tra trạng thái khởi tạo mặc định của Bloc là ForgotPasswordInitial
    test('Initial state should be ForgotPasswordInitial', () {
      expect(forgotPasswordBloc.state, const ForgotPasswordInitial());
    });
    // Note: Kiểm tra xem State có được cập nhật giá trị email mới khi người dùng nhập liệu không
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'Update state with new Email value when input changes',
      build: () => forgotPasswordBloc,
      act:
          (bloc) =>
              bloc.add(const ForgotPasswordEmailChanged(email: tEmailStr)),
      expect:
          () => [
            isA<ForgotPasswordStepOne>().having(
              (s) => s.email.value,
              'email value',
              tEmailStr,
            ),
          ],
    );
    // Note: Kiểm tra validate input (Validation Local). Nếu nhập sai định dạng email -> báo lỗi ngay, không gọi API.
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'Emit Error State immediately if Email format is invalid',
      build: () => forgotPasswordBloc,
      seed:
          () =>
              const ForgotPasswordStepOne(email: Email.dirty('invalid-email')),
      act: (bloc) => bloc.add(ForgotPasswordEmailSubmitted()),
      expect:
          () => [
            isA<ForgotPasswordError>().having(
              (s) => s.error,
              'validation error',
              ErrorInformation.INVALID_EMAIL.message,
            ),
          ],
    );
    // Note: Luồng logic: Email hợp lệ -> check Server -> Server trả về False (Không tồn tại) -> Bloc phải báo lỗi "Email not found"
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'Emit EMAIL_NOT_EXISTS Error when server returns "false" (email not found)',
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
            // 1. Loading bật lên khi bắt đầu gọi API
            isA<ForgotPasswordStepOne>().having(
              (s) => s.isLoading,
              'is loading',
              true,
            ),
            // 2. Loading tắt & Trả về lỗi
            isA<ForgotPasswordError>().having(
              (s) => s.error,
              'error message',
              ErrorInformation.EMAIL_NOT_EXISTS.message,
            ),
          ],
    );
    // Note: Luồng thành công Step 1: Check tồn tại = TRUE + Gửi OTP = TRUE -> Chuyển sang màn hình nhập OTP (Step 2)
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'Move to StepTwo when Email Exists AND Send OTP returns success',
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
              'is loading',
              true,
            ),
            isA<ForgotPasswordStepTwo>(),
          ],
    );
    // Note: Luồng lỗi Step 1: Check tồn tại = TRUE nhưng bước gửi OTP thất bại (Lỗi Server) -> Báo lỗi cho người dùng
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'Emit Server Error when CheckEmail is success BUT SendOTP fails',
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
              'is loading',
              true,
            ),
            // Error ở đây không phải validation, mà là lỗi server
            isA<ForgotPasswordError>().having((s) => s.error, 'msg', isNotNull),
          ],
    );
  });
  // ==================== STEP 2: XÁC THỰC OTP ==================== //
  group('Step 2: Verify OTP', () {
    test('Check Initial state logic for Step Two (Testing Seed)', () {
      expect(
        const ForgotPasswordStepTwo(otp: Otp.pure()),
        isA<ForgotPasswordStepTwo>(),
      );
    });
    // Note: Cập nhật giá trị OTP khi người dùng nhập từng ký tự
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'Update OTP value in state when input changes',
      build: () => forgotPasswordBloc,
      act: (bloc) => bloc.add(const ForgotPasswordOtpChanged(otp: tOtpStr)),
      expect:
          () => [
            isA<ForgotPasswordStepTwo>().having(
              (s) => s.otp.value,
              'otp value',
              tOtpStr,
            ),
          ],
    );
    // Note: Kiểm tra chức năng gửi lại OTP. Nếu thành công -> UI giữ nguyên để người dùng tiếp tục nhập, không reset.
    // State không đổi -> Expect list rỗng []
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'Do not change state (Expect []) when Resend OTP returns success',
      build: () {
        when(
          () => mockResendOTPUseCase.execute(
            email: any<String>(named: 'email'),
            type: any(named: 'type'),
          ),
        ).thenAnswer((_) async => const Right(true));

        return forgotPasswordBloc;
      },
      seed: () => const ForgotPasswordStepTwo(otp: Otp.dirty(tOtpStr)),
      act: (bloc) => bloc.add(ForgotPasswordResendOTPRequested()),
      expect: () => [],
    );
    // Note: Kiểm tra chức năng gửi lại OTP bị lỗi -> UI hiện thông báo lỗi.
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'Emit Error State when Resend OTP returns Failure',
      build: () {
        when(
          () => mockResendOTPUseCase.execute(
            email: any<String>(named: 'email'),
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
              'error message',
              ErrorInformation.UNDEFINED_ERROR.message,
            ),
          ],
    );
    // Note: Validate Local của OTP (VD: nhập OTP < 6 ký tự) -> Báo lỗi validation
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'Emit Validation Error immediately when submitting invalid OTP format',
      build: () => forgotPasswordBloc,
      seed: () => const ForgotPasswordStepTwo(otp: Otp.dirty('invalid-otp')),
      act: (bloc) => bloc.add(ForgotPasswordOtpSubmitted()),
      expect:
          () => [
            isA<ForgotPasswordError>().having(
              (s) => s.error,
              'validation error',
              isNotNull,
            ),
          ],
    );
    // Note: OTP đúng -> Server xác nhận thành công -> Chuyển sang màn hình Reset Pass (Step 3)
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'Move to StepThree when OTP Verify is success',
      build: () {
        when(
          () => mockVerifyOTPUseCase.execute(
            email: any<String>(named: 'email'),
            otp: tOtpStr,
            type: any(named: 'type'),
          ),
        ).thenAnswer((_) async => const Right(true));

        return forgotPasswordBloc;
      },
      seed: () => const ForgotPasswordStepTwo(otp: Otp.dirty(tOtpStr)),
      act: (bloc) => bloc.add(ForgotPasswordOtpSubmitted()),
      wait: const Duration(seconds: 2),
      expect:
          () => [
            // Bước 2 loading khác bước 1 (emit state mới)
            isA<ForgotPasswordLoading>(),
            isA<ForgotPasswordStepThree>(),
          ],
    );
    // Note: OTP đúng định dạng nhưng sai mã -> Server trả về lỗi -> UI báo lỗi
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'Emit Error State when OTP Verify returns Failure (Wrong OTP/Server Error)',
      build: () {
        when(
          () => mockVerifyOTPUseCase.execute(
            email: any<String>(named: 'email'),
            otp: any<String>(named: 'otp'),
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
              'error message',
              ErrorInformation.UNDEFINED_ERROR.message,
            ),
          ],
    );
  });
  // ==================== STEP 3: ĐẶT LẠI MẬT KHẨU ==================== //
  group('Step 3: New Password', () {
    final tStateStep3 = ForgotPasswordStepThree(
      password: const Password.dirty(tPasswordStr),
      confirmedPassword: tPasswordStr,
      error: '',
    );
    // Note: Khi nhập password mới/confirm pass, phải update State và quan trọng nhất là XÓA LỖI CŨ (error='') nếu có
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'Update Password inputs and CLEAR existing error',
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
                .having((s) => s.password.value, 'password value', tPasswordStr)
                .having(
                  (s) => s.confirmedPassword,
                  'confirm value',
                  tPasswordStr,
                )
                .having((s) => s.error, 'check clear error', isEmpty),
          ],
    );
    // Note: Local validation - Password yếu hoặc không đúng định dạng
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'Emit Validation Error if Password format is invalid',
      build: () => forgotPasswordBloc,
      seed:
          () => tStateStep3.copyWith(
            password: const Password.dirty('short'),
          ), // Pass quá ngắn
      act: (bloc) => bloc.add(ForgotPasswordSubmitted()),
      expect:
          () => [
            isA<ForgotPasswordStepThree>().having(
              (s) => s.error,
              'validation error',
              isNotNull,
            ),
          ],
    );
    // Note: Local validation - Chưa nhập xác nhận mật khẩu (Confirmed Password trống)
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'Emit Error if Confirmed Password is Empty',
      build: () => forgotPasswordBloc,
      seed:
          () => tStateStep3.copyWith(
            password: const Password.dirty(tPasswordStr),
            confirmedPassword: '', // Trống
            error: '',
            isLoading: false,
          ),
      act: (bloc) => bloc.add(ForgotPasswordSubmitted()),
      expect:
          () => [
            isA<ForgotPasswordStepThree>().having(
              (s) => s.error,
              'empty error',
              ErrorInformation.EMPTY_CONFIRMED_PASSWORD.message,
            ),
          ],
    );
    // Note: Local validation - Mật khẩu xác nhận KHÔNG KHỚP với mật khẩu chính
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'Emit Error if Confirmed Password does not match Password',
      build: () => forgotPasswordBloc,
      seed: () => tStateStep3.copyWith(confirmedPassword: 'DifferentPassword'),
      act: (bloc) => bloc.add(ForgotPasswordSubmitted()),
      expect:
          () => [
            isA<ForgotPasswordStepThree>().having(
              (s) => s.error,
              'mismatch error',
              ErrorInformation.CONFIRMED_PASSWORD_MISSMATCH.message,
            ),
          ],
    );
    // Note: Submit thành công -> Server update OK -> Chuyển sang màn hình Thành công hoàn tất
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'Emit ForgotPasswordSuccess when Update Password returns success',
      build: () {
        when(
          () => mockUpdatePasswordUseCase.execute(
            email: any(named: 'email'),
            newPassword: tPasswordStr,
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
    // Note: Submit lỗi Server -> Giữ nguyên ở Step 3 và hiện thông báo lỗi
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'Keep State at StepThree (with Error) when Update Password returns Failure',
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
              'error message',
              ErrorInformation.UNDEFINED_ERROR.message,
            ),
          ],
    );
  });
}
