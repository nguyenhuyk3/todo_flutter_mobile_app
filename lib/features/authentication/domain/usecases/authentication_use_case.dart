import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import 'params/registration_param.dart';
import '../repositories/authentication.dart';

part 'registration_use_case.dart';
part 'forgot_password_use_case.dart';
part 'login_use_case.dart';

abstract class AuthenticationUsecase {
  final IAuthenticationRepository _authenticationRepository;

  // AuthenticationRepository get authenticationRepository =>
  //     _authenticationRepository;

  AuthenticationUsecase({
    required IAuthenticationRepository authenticationRepository,
  }) : _authenticationRepository = authenticationRepository;
}

class CheckEmailExistsUseCase extends AuthenticationUsecase {
  CheckEmailExistsUseCase({required super.authenticationRepository});

  Future<Either<Failure, bool>> execute({required String email}) {
    return _authenticationRepository.checkEmailExists(email: email);
  }
}

class ResendOTPUseCase extends AuthenticationUsecase {
  ResendOTPUseCase({required super.authenticationRepository});

  Future<Either<Failure, bool>> execute({
    required String email,
    required OtpType type,
  }) {
    return _authenticationRepository.resendOTP(email: email, type: type);
  }
}

class VerifyOTPUseCase extends AuthenticationUsecase {
  VerifyOTPUseCase({required super.authenticationRepository});

  Future<Either<Failure, Object>> execute({
    required String email,
    required String otp,
    required OtpType type,
  }) {
    return _authenticationRepository.verifyOTP(
      email: email,
      otp: otp,
      type: type,
    );
  }
}
