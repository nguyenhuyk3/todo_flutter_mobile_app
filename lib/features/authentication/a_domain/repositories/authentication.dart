import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../usecases/params/login_result_param.dart';
import '../usecases/params/registration_param.dart';

/*
  dartz là functional programming library cho Dart
  Nó cung cấp các kiểu dữ liệu giúp: 
    - Tránh try-catch lộn xộn
    - Xử lý lỗi rõ ràng, an toàn
    - Code dễ test, dễ đọc
  Các kiểu hay dùng trong Flutter:
    - Either<L, R>
    - Option<T>
    - Unit
  Either là gì?
    - Either là kiểu dữ liệu chỉ có 1 trong 2 giá trị:
      + Left (L) → ❌ lỗi
      + Right (R) → ✅ thành công
    - 👉 Quy ước:
      + Left = Failure / Error
      + Right = Data / Success
*/
abstract class IAuthenticationRepository {
  Future<Either<Failure, bool>> checkEmailExists({required String email});

  Future<Either<Failure, bool>> resendOTP({
    required String email,
    required OtpType type,
  });

  Future<Either<Failure, Object>> verifyOTP({
    required String email,
    required String otp,
    required OtpType type,
  });

  Future<Either<Failure, bool>> register(RegistrationParams params);

  Future<Either<Failure, bool>> sendForgotPasswordOTP({required String email});
  Future<Either<Failure, bool>> updatePassword({
    required String email,
    required String newPassword,
  });

  Future<Either<Failure, LoginResultParam>> login({
    required String email,
    required String password,
  });
  Future<Either<Failure, LoginResultParam>> tryAutoLogin();
}
