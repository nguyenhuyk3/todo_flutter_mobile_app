import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:todo_flutter_mobile_app/core/constants/others.dart';
import 'package:todo_flutter_mobile_app/core/errors/failure.dart';
import 'package:todo_flutter_mobile_app/features/authentication/domain/entities/enums.dart';
import 'package:todo_flutter_mobile_app/features/authentication/domain/usecases/params/registration_param.dart';
import 'package:todo_flutter_mobile_app/features/authentication/domain/usecases/authentication_use_case.dart';
import 'package:todo_flutter_mobile_app/features/authentication/presentations/inputs/email.dart';
import 'package:todo_flutter_mobile_app/features/authentication/presentations/inputs/otp.dart';
import 'package:todo_flutter_mobile_app/features/authentication/presentations/inputs/password.dart';
import 'package:todo_flutter_mobile_app/features/authentication/presentations/registration/bloc/bloc.dart';

// 1. Tạo Mock cho các UseCases
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
  final tStepTwoInitialState = RegistrationStepTwo(otp: const Otp.pure());

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
    /*
      👉 Mục đích duy nhất:
        Đăng ký một “giá trị dự phòng” (fallback value) cho RegistrationParams để mocktail có thể dùng khi bạn gọi any()
    */
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
  // =================== STEP 1 ===================
  group('RegistrationBloc - Step 1 Logic', () {
    // Kiểm tra trạng thái ban đầu
    test('Initial state should be RegistrationStepOne.initial()', () {
      expect(registrationBloc.state, isA<RegistrationStepOne>());
      expect((registrationBloc.state as RegistrationStepOne).email.value, '');
      expect(
        (registrationBloc.state as RegistrationStepOne).password.value,
        '',
      );
      expect((registrationBloc.state as RegistrationStepOne).fullName, '');
      expect(
        (registrationBloc.state as RegistrationStepOne).birthDate,
        BIRTH_DATE_DEFAUL_VALUE,
      );
      expect((registrationBloc.state as RegistrationStepOne).sex, 'male');
      expect((registrationBloc.state as RegistrationStepOne).error, '');
      expect((registrationBloc.state as RegistrationStepOne).isLoading, false);
    });
    // 1. Kiểm tra ô input thay đổi (Email)
    blocTest<RegistrationBloc, RegistrationState>(
      'Emitting updated email when RegistrationEmailChanged is added',
      build: () => registrationBloc, // Trả về instance Bloc cần test
      act: (bloc) => bloc.add(const RegistrationEmailChanged(email: tEmail)),
      expect:
          () => [
            isA<RegistrationStepOne>().having(
              (s) => s.email.value,
              'email value',
              tEmail,
            ),
          ],
    );
    // 2. Kiểm tra ô input thay đổi (Password)
    blocTest<RegistrationBloc, RegistrationState>(
      'Emitting updated password and confirmedPassword when RegistrationPasswordChanged is added',
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
                .having(
                  (s) => s.confirmedPassword,
                  'confirmed password',
                  tPassword,
                ),
          ],
    );
    // 3. Kiểm tra thông tin cá nhân thay đổi (Full Name, BirthDate, Sex)
    blocTest<RegistrationBloc, RegistrationState>(
      'Emmits updated info (Full Name, BirthDate, Sex) and preserves existing Email',
      build: () => registrationBloc,
      // SEED: Giả sử người dùng đã nhập Email và Password trước đó
      seed:
          () => RegistrationStepOne.initial().copyWith(
            email: const Email.dirty(tEmail),
            password: const Password.dirty(tPassword),
          ),
      act:
          (bloc) => bloc.add(
            RegistrationInformationChanged(
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
                // QUAN TRỌNG: Kiểm tra xem email cũ có bị mất không (do dùng copyWith)
                .having((s) => s.email.value, 'preserved email', tEmail),
          ],
    );
    // 4. Kiểm tra Submit Thành Công (RegisterUseCase success)
    blocTest<RegistrationBloc, RegistrationState>(
      'Emitting [Loading, StepTwo] when param being valid and RegisterUseCase returns success',
      build: () {
        // Mock hành vi thành công của UseCase
        when(
          () => mockRegisterUseCase.execute(any<RegistrationParams>()),
        ).thenAnswer((_) async => const Right(true));

        return registrationBloc;
      },
      // Set sẵn state hợp lệ
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
      // Vì bloc có `Future.delayed(Duration(seconds: 2))`,
      // `wait` giúp bloc_test chờ thời gian này để assert chính xác.
      wait: const Duration(seconds: 2),
      expect:
          () => [
            // 1. Loading state (isList = true copyWith trong bloc của bạn)
            isA<RegistrationStepOne>().having(
              (s) => s.isLoading,
              'is loading',
              true,
            ),
            // 2. Chuyển sang Step Two
            isA<RegistrationStepTwo>(),
          ],
      verify: (_) {
        verify(
          () => mockRegisterUseCase.execute(any<RegistrationParams>()),
        ).called(1);
      },
    );
    // 5. Kiểm tra Submit Thất Bại (RegisterUseCase thất bại)
    blocTest<RegistrationBloc, RegistrationState>(
      'Emitting [Loading, StepOneWithError] when RegisterUseCase return failure',
      build: () {
        when(
          () => mockRegisterUseCase.execute(any<RegistrationParams>()),
        ).thenAnswer(
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
            birthDate: tBirthDate,
            sex: tSex,
          ),
      act: (bloc) => bloc.add(RegistrationStepOneSubmitted()),
      wait: const Duration(seconds: 2),
      expect:
          () => [
            isA<RegistrationStepOne>().having(
              (s) => s.isLoading,
              'is loading',
              true,
            ),
            isA<RegistrationStepOne>().having(
              (s) => s.error,
              'error message',
              ErrorInformation.UNDEFINED_ERROR.message,
            ),
          ],
    );
  });
  // =================== STEP 2 ===================
  group('RegistrationBloc - Step 2 (OTP) Logic', () {
    // 1. Kiểm tra nhập OTP
    blocTest<RegistrationBloc, RegistrationState>(
      'Emitting updated otp when RegistrationOtpChanged is added',
      build: () => registrationBloc,
      // seed: () => tStepTwoInitialState,
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
    // 2. Test Yêu cầu gửi lại OTP (Resend) - Thành công
    blocTest<RegistrationBloc, RegistrationState>(
      'Calls ResendOTPUseCase and verifies execution (No state change expected)',
      build: () {
        // Mock UseCase trả về thành công
        // Dùng any(named: 'email') vì biến _email đang là rỗng do seed state trực tiếp
        when(
          () => mockResendOTPUseCase.execute(
            email: any<String>(named: 'email'),
            type: any<OtpType>(named: 'type'),
          ),
        ).thenAnswer((_) async => const Right(true));

        return registrationBloc;
      },
      seed:
          () => tStepTwoInitialState.copyWith(otp: const Otp.dirty(tOtpValue)),
      act: (bloc) => bloc.add(RegistrationResendOTPRequested()),
      expect: () => [],
      verify: (_) {
        // ?? Có thể chưa đúng vì khi đăng kí có thể gửi nhiều lần
        verify(
          () => mockResendOTPUseCase.execute(
            email: any<String>(named: 'email'),
            type: any<OtpType>(named: 'type'),
          ),
        ).called(1);
      },
    );
    // 3. Test Yêu cầu gửi lại OTP (Resend) - Thất bại
    blocTest<RegistrationBloc, RegistrationState>(
      'Emitting error when ResendOTPUseCase returns failure',
      build: () {
        when(
          () => mockResendOTPUseCase.execute(
            email: any<String>(named: 'email'),
            type: any<OtpType>(named: 'type'),
          ),
        ).thenAnswer(
          (_) async =>
              const Left(Failure(error: ErrorInformation.UNDEFINED_ERROR)),
        );

        return registrationBloc;
      },
      seed: () => tStepTwoInitialState,
      act: (bloc) => bloc.add(RegistrationResendOTPRequested()),
      expect:
          () => [
            isA<RegistrationStepTwo>().having(
              (s) => s.error,
              'error message',
              ErrorInformation.UNDEFINED_ERROR.message,
            ),
          ],
    );
    // 4. Kiểm tra Submit OTP - Validate lỗi (OTP quá ngắn/rỗng)
    blocTest<RegistrationBloc, RegistrationState>(
      'Emitting error when OTP is invalid on Submit',
      build: () => registrationBloc,
      seed: () => tStepTwoInitialState.copyWith(otp: const Otp.dirty('12')),
      act: (bloc) => bloc.add(RegistrationOtpSubmitted()),
      expect:
          () => [
            isA<RegistrationStepTwo>().having(
              (s) => s.error,
              'error message',
              "Mã Otp phải có đúng $LENGTH_OF_OTP kí tự",
            ),
          ],
    );
    // 5. Kiểm tra Submit OTP - Thành công (Verify OK) -> Chuyển sang RegistrationSuccess
    blocTest<RegistrationBloc, RegistrationState>(
      'Emitting [Loading, RegistrationSuccess] when VerifyOTPUseCase succeeds',
      build: () {
        when(
          () => mockVerifyOTPUseCase.execute(
            email: any<String>(named: 'email'),
            otp: any<String>(named: 'otp'),
            type: any<OtpType>(named: 'type'),
          ),
        ).thenAnswer((_) async => const Right(true));

        return registrationBloc;
      },
      seed:
          () => tStepTwoInitialState.copyWith(otp: const Otp.dirty(tOtpValue)),
      act: (bloc) => bloc.add(RegistrationOtpSubmitted()),
      wait: const Duration(seconds: 2),
      expect:
          () => [
            // 1. Loading State
            isA<RegistrationStepTwo>().having(
              (s) => s.isLoading,
              'is loading',
              true,
            ),
            // 2. Success State
            isA<RegistrationSuccess>(),
          ],
      verify: (_) {
        verify(
          () => mockVerifyOTPUseCase.execute(
            email: any<String>(named: 'email'),
            otp: tOtpValue,
            type: OtpType.email,
          ),
        ).called(1);
      },
    );
    // 6. Test Submit OTP - Thất bại (Verify Error - VD: sai OTP)
    blocTest<RegistrationBloc, RegistrationState>(
      'Emits [Loading, StepTwoWithError] when VerifyOTPUseCase fails',
      build: () {
        when(
          () => mockVerifyOTPUseCase.execute(
            email: any<String>(named: 'email'),
            otp: any<String>(named: 'otp'),
            type: any<OtpType>(named: 'type'),
          ),
        ).thenAnswer(
          (_) async =>
              const Left(Failure(error: ErrorInformation.UNDEFINED_ERROR)),
        );

        return registrationBloc;
      },
      seed:
          () => tStepTwoInitialState.copyWith(otp: const Otp.dirty(tOtpValue)),
      act: (bloc) => bloc.add(RegistrationOtpSubmitted()),
      wait: const Duration(seconds: 2),
      expect:
          () => [
            isA<RegistrationStepTwo>().having(
              (s) => s.isLoading,
              'is loading',
              true,
            ),
            isA<RegistrationStepTwo>().having(
              (s) => s.error,
              'error message',
              ErrorInformation.UNDEFINED_ERROR.message,
            ),
          ],
    );
  });
  // =================== ADDITIONAL TESTS ===================
  group('RegistrationBloc - Additional Tests', () {
    // Kiểm tra mật khẩu không khớp
    // Lưu ý: Logic _validateStepOne được gọi khi submit.
    blocTest<RegistrationBloc, RegistrationState>(
      'Emitting error when confirmed password missmatches on Submit',
      build: () => registrationBloc,
      // Cần setup trước các state hợp lệ, rồi mới set password sai để test logic
      seed:
          () => RegistrationStepOne.initial().copyWith(
            email: const Email.dirty(tEmail),
            fullName: tFullName,
            password: const Password.dirty(tPassword),
            confirmedPassword: 'WrongPassword',
            birthDate: tBirthDate,
            sex: tSex,
          ),
      act: (bloc) => bloc.add(RegistrationStepOneSubmitted()),
      expect:
          () => [
            isA<RegistrationStepOne>().having(
              (s) => s.error,
              'error message',
              equals(ErrorInformation.CONFIRMED_PASSWORD_MISSMATCH.message),
            ),
          ],
    );
    blocTest<RegistrationBloc, RegistrationState>(
      'Emitting error when confirmed password is empty on Submit',
      build: () => registrationBloc,
      seed:
          () => RegistrationStepOne.initial().copyWith(
            email: const Email.dirty(tEmail),
            fullName: tFullName,
            password: const Password.dirty(tPassword),
            confirmedPassword: '',
            birthDate: tBirthDate,
            sex: tSex,
          ),
      act: (bloc) => bloc.add(RegistrationStepOneSubmitted()),
      expect:
          () => [
            isA<RegistrationStepOne>().having(
              (s) => s.error,
              'error message',
              equals(ErrorInformation.EMPTY_CONFIRMED_PASSWORD.message),
            ),
          ],
    );
    blocTest<RegistrationBloc, RegistrationState>(
      'Emitting error when full name is empty on Submit',
      build: () => registrationBloc,
      seed:
          () => RegistrationStepOne.initial().copyWith(
            email: const Email.dirty(tEmail),
            fullName: '',
            password: const Password.dirty(tPassword),
            confirmedPassword: tPassword,
            birthDate: tBirthDate,
            sex: tSex,
          ),
      act: (bloc) => bloc.add(RegistrationStepOneSubmitted()),
      expect:
          () => [
            isA<RegistrationStepOne>().having(
              (s) => s.error,
              'error message',
              equals(ErrorInformation.EMPTY_FULL_NAME.message),
            ),
          ],
    );
    // Kiểm ta RegistrationReset (Ví dụ: khi rời khỏi màn hình hoặc bấm nút Hủy)
    blocTest<RegistrationBloc, RegistrationState>(
      'Emits RegistrationInitial when RegistrationReset is added',
      build: () => registrationBloc,
      // SEED: Giả sử đang ở Step 2
      seed: () => const RegistrationStepTwo(otp: Otp.pure()),
      act: (bloc) => bloc.add(RegistrationReset()),
      expect:
          () => [
            // Kiểm tra state trở về Initial (hoặc state ban đầu tùy định nghĩa state của bạn)
            isA<RegistrationInitial>(),
          ],
    );
  });
}
