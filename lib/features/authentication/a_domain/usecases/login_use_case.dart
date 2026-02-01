part of 'authentication_use_case.dart';

class LoginUseCase extends AuthenticationUsecase {
  LoginUseCase({required super.authenticationRepository});

  Future<Either<Failure, LoginResultParam>> execute({
    required String email,
    required String password,
  }) {
    return _authenticationRepository.login(email: email, password: password);
  }
}

class TryAutoLoginUseCase extends AuthenticationUsecase {
  TryAutoLoginUseCase({required super.authenticationRepository});

  Future<Either<Failure, LoginResultParam>> execute({
    required String refreshToken,
    required String userId,
  }) {
    return _authenticationRepository.tryAutoLogin(refreshToken: refreshToken, userId: userId);
  }
}
