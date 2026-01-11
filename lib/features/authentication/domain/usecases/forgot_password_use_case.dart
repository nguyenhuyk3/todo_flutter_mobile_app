part of 'authentication_use_case.dart';

class SendForgotPasswordOTPUseCase extends AuthenticationUsecase {
  SendForgotPasswordOTPUseCase({required super.authenticationRepository});

  Future<Either<Failure, bool>> execute({required String email}) {
    return _authenticationRepository.sendForgotPasswordOTP(email: email);
  }
}

class UpdatePasswordUseCase extends AuthenticationUsecase {
  UpdatePasswordUseCase({required super.authenticationRepository});

  Future<Either<Failure, bool>> execute({
    required String email,
    required String newPassword,
  }) {
    return _authenticationRepository.updatePassword(
      email: email,
      newPassword: newPassword,
    );
  }
}
