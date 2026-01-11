part of 'bloc.dart';

final class LoginState extends Equatable {
  const LoginState({
    this.status = FormzSubmissionStatus.initial,
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.error = '',
  });

  final FormzSubmissionStatus status;
  final Email email;
  final Password password;
  final String error;

  LoginState copyWith({
    FormzSubmissionStatus? status,
    Email? email,
    Password? password,
    String? error,
  }) {
    return LoginState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      error: error ?? this.error,
    );
  }

  @override
  List<Object> get props => [status, email, password, error];
}
