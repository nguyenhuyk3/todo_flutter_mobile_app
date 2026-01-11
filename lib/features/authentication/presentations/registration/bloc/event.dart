part of 'bloc.dart';

sealed class RegistrationEvent extends Equatable {
  const RegistrationEvent();

  @override
  List<Object?> get props => [];
}

// Step 1
class RegistrationEmailChanged extends RegistrationEvent {
  final String email;

  const RegistrationEmailChanged({required this.email});

  @override
  List<Object?> get props => [email];
}

class RegistrationPasswordChanged extends RegistrationEvent {
  final String password;
  final String confirmedPassword;

  const RegistrationPasswordChanged({
    required this.password,
    required this.confirmedPassword,
  });

  @override
  List<Object?> get props => [password];
}

class RegistrationInformationChanged extends RegistrationEvent {
  final String fullName;
  final String birthDate;
  final String sex;

  const RegistrationInformationChanged({
    required this.fullName,
    required this.birthDate,
    required this.sex,
  });

  String get formattedBirthDate {
    return birthDate.split('T').first;
  }

  @override
  List<Object?> get props => [fullName, birthDate, sex];
}

class RegistrationStepOneSubmitted extends RegistrationEvent {}
// ========================== || ========================== //

// Step 2
class RegistrationOtpChanged extends RegistrationEvent {
  final String otp;

  const RegistrationOtpChanged({required this.otp});

  @override
  List<Object?> get props => [otp];
}

class RegistrationResendOTPRequested extends RegistrationEvent {}

class RegistrationOtpSubmitted extends RegistrationEvent {}
// ========================== || ========================== //

class RegistrationReset extends RegistrationEvent {}
