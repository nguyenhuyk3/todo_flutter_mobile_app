part of 'bloc.dart';

sealed class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();

  @override
  List<Object?> get props => [];
}

// Step 1
class ForgotPasswordEmailChanged extends ForgotPasswordEvent {
  final String email;

  const ForgotPasswordEmailChanged({required this.email});

  @override
  List<Object?> get props => [email];
}

class ForgotPasswordEmailSubmitted extends ForgotPasswordEvent {}

// Step 2
class ForgotPasswordOtpChanged extends ForgotPasswordEvent {
  final String otp;

  const ForgotPasswordOtpChanged({required this.otp});

  @override
  List<Object?> get props => [otp];
}

class ForgotPasswordResendOTPRequested extends ForgotPasswordEvent {}

class ForgotPasswordOtpSubmitted extends ForgotPasswordEvent {}

// Step 3
class ForgotPasswordPasswordChanged extends ForgotPasswordEvent {
  final String password;
  final String confirmedPassword;

  const ForgotPasswordPasswordChanged({
    required this.password,
    required this.confirmedPassword,
  });

  @override
  List<Object?> get props => [password, confirmedPassword];
}

class ForgotPasswordSubmitted extends ForgotPasswordEvent {}
