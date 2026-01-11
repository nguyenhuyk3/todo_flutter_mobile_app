part of 'authentication_use_case.dart';

class RegisterUseCase extends AuthenticationUsecase {
  RegisterUseCase({required super.authenticationRepository});

  Future<Either<Failure, bool>> execute(RegistrationParams params) {
    return _authenticationRepository.register(params);
  }
}
