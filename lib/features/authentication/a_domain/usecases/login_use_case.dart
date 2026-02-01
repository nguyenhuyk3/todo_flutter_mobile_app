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
