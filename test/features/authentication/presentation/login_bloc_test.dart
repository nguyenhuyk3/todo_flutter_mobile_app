import 'package:bloc_test/bloc_test.dart'; // Cung cấp blocTest() để test Bloc theo Event → State
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart'; // Cung cấp test, expect, matcher (isA, having, …)
import 'package:formz/formz.dart';
import 'package:mocktail/mocktail.dart'; // Dùng để mock (giả lập)
import 'package:todo_flutter_mobile_app/core/errors/failure.dart';

import 'package:todo_flutter_mobile_app/features/authentication/a_domain/entities/authentication_session.dart';
import 'package:todo_flutter_mobile_app/features/authentication/a_domain/entities/enums.dart';
import 'package:todo_flutter_mobile_app/features/authentication/a_domain/usecases/authentication_use_case.dart';
import 'package:todo_flutter_mobile_app/features/authentication/a_domain/usecases/params/login_result_param.dart';
import 'package:todo_flutter_mobile_app/features/authentication/b_data/models/user_model.dart';
import 'package:todo_flutter_mobile_app/features/authentication/c_presentations/shared/inputs/email.dart';
import 'package:todo_flutter_mobile_app/features/authentication/c_presentations/shared/inputs/password.dart';
import 'package:todo_flutter_mobile_app/features/authentication/c_presentations/login/bloc/bloc.dart';

// 1. Tạo class Mock cho UseCase
// Vì Bloc gọi LoginUseCase, ta cần giả lập nó thay vì gọi API thật.
class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockTryAutoLoginUseCase extends Mock implements TryAutoLoginUseCase {}

void main() {
  // late → khởi tạo trong setUp()
  // Mỗi test case dùng Bloc & UseCase mới
  late LoginBloc loginBloc;
  late MockLoginUseCase mockLoginUseCase;
  late MockTryAutoLoginUseCase mockTryAutoLoginUseCase;

  // Dữ liệu mẫu dùng chung
  final tValidEmail = 'validEmail@gmail.com';
  final tValidPassword = 'StrongPassword123!';
  final tUser =
      UserModel(
        id: 'test-uid',
        email: 'test@email.com',
        fullName: 'fullname',
        avatarUrl: 'avatar-url',
        dateOfBirth: DateTime.now(),
        sex: Sex.female,
      ).toEntity();
  final tSession = const AuthenticationSession(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
  );
  final tLoginResult = LoginResultParam(user: tUser, session: tSession);

  // Setup chạy trước mỗi test case
  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockTryAutoLoginUseCase = MockTryAutoLoginUseCase();
    loginBloc = LoginBloc(
      loginUseCase: mockLoginUseCase,
      tryAutoLoginUseCase: mockTryAutoLoginUseCase,
    );
  });
  // Clean up sau mỗi test case
  tearDown(() {
    loginBloc.close();
  });

  group('LoginBloc Tests', () {
    // ==============================================================
    // PHẦN 1: TEST TRẠNG THÁI KHỞI TẠO (Initial State)
    // ==============================================================
    test('Initialized state must be the default', () {
      expect(loginBloc.state, const LoginState());
    });

    // ==============================================================
    // PHẦN 2: TEST CÁC HANDLER INPUT (_onEmailChanged, _onPasswordChanged)
    // ==============================================================
    group('Input Handlers', () {
      blocTest<LoginBloc, LoginState>(
        'Emit the new state when the email changes',
        build: () => loginBloc, // Trả về instance Bloc cần test
        // 👉 Mô phỏng user nhập email vào form
        act:
            (bloc) =>
                bloc.add(const LoginEmailChanged(email: 'test@email.com')),
        expect:
            () => [
              // Lưu ý: Do dùng Equatable, hàm copyWith sẽ tạo object mới bằng với cái
              /*
                Giải thích chi tiết:
                  isA<LoginState>()
                    - Là matcher trong package test / flutter_test:
                      + 👉 Dùng để kiểm tra kiểu (type) của object
                      + Nghĩa tiếng Việt: “Object này có phải là LoginState hay không?”
                    - Chỉ cần chắc chắn:
                      + State được emit là LoginState
                    - expect: () => [isA<LoginState>()]:
                      + 👉 Có nghĩa:
                        ~ State được emit phải là LoginState
                        ~ Không cần biết chi tiết bên trong (sẽ kiểm tra bằng having)
                    - having(...) là gì?
                      + having() là matcher mở rộng
                      + Dùng để kiểm tra một thuộc tính cụ thể của object
                      + 👉 Thường dùng khi:
                        ~ Object phức tạp
                        ~ Không muốn so sánh toàn bộ object
              */
              isA<LoginState>()
                  .having(
                    (state) => state.email.value,
                    'email',
                    'test@email.com',
                  )
                  .having(
                    (state) => state.status,
                    'status',
                    FormzSubmissionStatus.initial,
                  ),
            ],
      );

      blocTest<LoginBloc, LoginState>(
        'Emit the new state when your password changes',
        build: () => loginBloc,
        act:
            (bloc) =>
                bloc.add(const LoginPasswordChanged(password: 'password123')),
        expect:
            () => [
              isA<LoginState>()
                  .having(
                    (state) => state.password.value,
                    'password',
                    'password123',
                  )
                  .having(
                    (state) => state.status,
                    'status',
                    FormzSubmissionStatus.initial,
                  ),
            ],
      );
    });

    // ==============================================================
    // PHẦN 3: TEST HANDLER SUBMIT (_onSubmitted)
    // ==============================================================
    group('Submission Handler (_onSubmitted)', () {
      // 3.1: Validation Email thất bại
      blocTest<LoginBloc, LoginState>(
        'Do not call the API and display an error if the submitted email is invalid',
        build: () => loginBloc,
        // Seed: Đặt trạng thái ban đầu với email sai format (ví dụ: không có @)
        // Lưu ý: Cần thay chuỗi 'invalid-email' bằng chuỗi nào mà class Email của mình coi là sai
        seed:
            () => const LoginState(
              email: Email.dirty('invalid-text-without-at-symbol'),
              password: Password.dirty('ValidPass123!'), // Pass đúng
              status: FormzSubmissionStatus.initial,
            ),
        act: (bloc) => bloc.add(const LoginSubmitted()),
        expect:
            () => [
              // Expectation: Bloc emit state mới chứa nội dung lỗi trong field 'error'
              isA<LoginState>()
                  .having(
                    (state) => state.error,
                    'error',
                    isNotEmpty,
                  ) // Error phải có chữ
                  .having(
                    (state) => state.status,
                    'status',
                    FormzSubmissionStatus.initial,
                  ), // Status vẫn giữ nguyên, KHÔNG được là inProgress
            ],
        verify: (_) {
          // QUAN TRỌNG: Kiểm tra API Login TUYỆT ĐỐI KHÔNG ĐƯỢC GỌI
          verifyNever(
            () => mockLoginUseCase.execute(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          );
        },
      );

      // 3.2: Validation Password thất bại
      blocTest<LoginBloc, LoginState>(
        'Do not call the API and display an error if the Submit password is invalid',
        build: () => loginBloc,
        // Seed: Email đúng, nhưng Password sai (ví dụ: rỗng hoặc quá ngắn)
        seed:
            () => LoginState(
              email: Email.dirty(tValidEmail),
              password: const Password.dirty(''), // Giả sử pass rỗng là lỗi
              status: FormzSubmissionStatus.initial,
            ),
        act: (bloc) => bloc.add(const LoginSubmitted()),
        expect:
            () => [
              isA<LoginState>()
                  .having(
                    (state) => state.error,
                    'error',
                    isNotEmpty,
                  ) // Phải có thông báo lỗi password
                  .having(
                    (state) => state.status,
                    'status',
                    FormzSubmissionStatus.initial,
                  ),
            ],
        verify: (_) {
          // Kiểm tra API Login không được gọi
          verifyNever(
            () => mockLoginUseCase.execute(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          );
        },
      );

      // 3.3: Submit thành công
      /*
        seed: 
          – set state ban đầu cho Bloc
          - Cho phép set state ban đầu của Bloc trước khi act chạy
      */
      blocTest<LoginBloc, LoginState>(
        'Emit [inProgress, success] upon successful login.',
        build: () {
          // Setup hành vi giả lập cho UseCase
          // Khi gọi execute thì trả về Right(true)
          /* 
            Đoạn when(...).thenAnswer(...) tồn tại để “dạy” cho mock LoginUseCase cách phản hồi khi Bloc gọi nó
            Nếu không có đoạn này:
              - Bloc sẽ gọi một hàm “rỗng”
              - Nhận về null
              - Và crash ngay khi chạy test
            GHI NHỚ 1 CÂU DUY NHÂT: Mock không tự biết phải trả về gì – bạn phải nói rõ cho nó
          */
          when(
            () => mockLoginUseCase.execute(
              email: tValidEmail,
              password: tValidPassword,
            ),
          ).thenAnswer((_) async => Right(tLoginResult));

          return loginBloc;
        },
        // Trước khi submit, cần set giá trị cho email và password trong state trước
        // bằng cách seed state hoặc gửi event change trước. Ở đây ta dùng seed.
        seed:
            () => LoginState(
              email: Email.dirty(tValidEmail),
              password: Password.dirty(tValidPassword),
              status: FormzSubmissionStatus.initial,
            ),
        act: (bloc) => bloc.add(const LoginSubmitted()),
        expect:
            () => [
              // State 1: Chuyển sang InProgress
              LoginState(
                email: Email.dirty(tValidEmail),
                password: Password.dirty(tValidPassword),
                status: FormzSubmissionStatus.inProgress,
                error: '',
              ),
              // State 2: Chuyển sang Success
              LoginState(
                email: Email.dirty(tValidEmail),
                password: Password.dirty(tValidPassword),
                status: FormzSubmissionStatus.success,
                error: '',
              ),
            ],
        verify: (_) {
          // Kiểm tra xem hàm execute có thực sự được gọi 1 lần không
          verify(
            () => mockLoginUseCase.execute(
              email: tValidEmail,
              password: tValidPassword,
            ),
          ).called(1);
        },
      );

      // 3.4: Submit thất bại
      blocTest<LoginBloc, LoginState>(
        'Emit [inProgress, failure] when login fails',
        build: () {
          // Mock trả về lỗi (Left)
          when(
            () => mockLoginUseCase.execute(
              email: tValidEmail,
              password: tValidPassword,
            ),
          ).thenAnswer(
            (_) async =>
                const Left(Failure(error: ErrorInformation.UNDEFINED_ERROR)),
          );

          return loginBloc;
        },
        seed:
            () => LoginState(
              email: Email.dirty(tValidEmail),
              password: Password.dirty(tValidPassword),
              status: FormzSubmissionStatus.initial,
            ),
        act: (bloc) => bloc.add(const LoginSubmitted()),
        expect:
            () => [
              // State 1: InProgress
              LoginState(
                email: Email.dirty(tValidEmail),
                password: Password.dirty(tValidPassword),
                status: FormzSubmissionStatus.inProgress,
                error: '',
              ),
              // State 2: Failure
              // Lưu ý: Logic code Bloc khi Failure đang KHÔNG cập nhật state.error
              // từ failure message (dòng res.fold), nó chỉ đổi status thành failure.
              LoginState(
                email: Email.dirty(tValidEmail),
                password: Password.dirty(tValidPassword),
                status: FormzSubmissionStatus.failure,
                error: '',
              ),
            ],
      );
    });

    // ==============================================================
    // PHẦN 4: TEST AUTO LOGIN HANDLER (_onAutoLoginStarted)
    // ==============================================================
    group('Auto Login Handler (_onAutoLoginStarted)', () {
      // 4.1: Auto Login thành công
      blocTest<LoginBloc, LoginState>(
        'Emit [inProgress, success] when AutoLogin succeeds',
        build: () {
          // Mock UseCase AutoLogin trả về thành công
          // Lưu ý: Trong logic mới bạn gửi, function execute() không nhận tham số
          when(
            () => mockTryAutoLoginUseCase.execute(),
          ).thenAnswer((_) async => Right(tLoginResult));

          return loginBloc;
        },
        act: (bloc) => bloc.add(LoginAutoLoginStarted()),
        expect:
            () => [
              // 1. Chuyển sang loading
              isA<LoginState>().having(
                (s) => s.status,
                'status',
                FormzSubmissionStatus.inProgress,
              ),
              // 2. Chuyển sang thành công
              isA<LoginState>().having(
                (s) => s.status,
                'status',
                FormzSubmissionStatus.success,
              ),
            ],
      );

      // 4.2: Auto Login thất bại
      blocTest<LoginBloc, LoginState>(
        'Emit [inProgress, failure] with specific error when AutoLogin fails',
        build: () {
          // Mock UseCase AutoLogin trả về lỗi
          when(() => mockTryAutoLoginUseCase.execute()).thenAnswer(
            (_) async => const Left(
              Failure(error: ErrorInformation.TRY_AUTO_LOGIN_FAILED),
            ),
          );

          return loginBloc;
        },
        act: (bloc) => bloc.add(LoginAutoLoginStarted()),
        expect:
            () => [
              // 1. Loading
              isA<LoginState>().having(
                (s) => s.status,
                'status',
                FormzSubmissionStatus.inProgress,
              ),
              // 2. Failure và Error message tương ứng
              isA<LoginState>()
                  .having(
                    (s) => s.status,
                    'status',
                    FormzSubmissionStatus.failure,
                  )
                  .having(
                    (s) => s.error,
                    'error',
                    ErrorInformation.TRY_AUTO_LOGIN_FAILED.message,
                  ),
            ],
      );
    });
  });
}
