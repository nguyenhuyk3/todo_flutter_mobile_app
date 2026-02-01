part of 'bloc.dart';

/*
    Mai sau nếu có thiết kế lại state thì nên mỗi statet nên có 1 trường isLoading riêng 
  hơn là sử dụng 1 sate loading chung cho tất cả các state
*/
sealed class ForgotPasswordState extends Equatable {
  final FormzSubmissionStatus status;

  const ForgotPasswordState({required this.status});

  @override
  List<Object?> get props => [status];
}

class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial() : super(status: FormzSubmissionStatus.initial);
}

class ForgotPasswordLoading extends ForgotPasswordState {
  const ForgotPasswordLoading()
    : super(status: FormzSubmissionStatus.inProgress);

  @override
  List<Object?> get props => [];
}

class ForgotPasswordError extends ForgotPasswordState {
  final String error;

  const ForgotPasswordError({required this.error})
    : super(status: FormzSubmissionStatus.inProgress);

  @override
  List<Object?> get props => [error];
}

class ForgotPasswordStepOne extends ForgotPasswordState {
  final Email email;
  final bool isLoading;

  const ForgotPasswordStepOne({required this.email, this.isLoading = false})
    : super(status: FormzSubmissionStatus.inProgress);

  ForgotPasswordStepOne copyWith({Email? email, bool? isLoading}) {
    return ForgotPasswordStepOne(
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [email, isLoading];
}

class ForgotPasswordStepTwo extends ForgotPasswordState {
  final Otp otp;

  const ForgotPasswordStepTwo({required this.otp})
    : super(status: FormzSubmissionStatus.inProgress);

  @override
  List<Object?> get props => [otp];
}

class ForgotPasswordStepThree extends ForgotPasswordState {
  final Password password;
  final String confirmedPassword;
  final String error;
  final bool isLoading;

  const ForgotPasswordStepThree({
    required this.password,
    required this.confirmedPassword,
    required this.error,
    this.isLoading = false,
  }) : super(status: FormzSubmissionStatus.inProgress);

  ForgotPasswordStepThree copyWith({
    Password? password,
    String? confirmedPassword,
    String? error,
    bool? isLoading,
  }) {
    return ForgotPasswordStepThree(
      password: password ?? this.password,
      confirmedPassword: confirmedPassword ?? this.confirmedPassword,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [password, confirmedPassword, error, isLoading];
}

class ForgotPasswordSuccess extends ForgotPasswordState {
  const ForgotPasswordSuccess() : super(status: FormzSubmissionStatus.success);
}
