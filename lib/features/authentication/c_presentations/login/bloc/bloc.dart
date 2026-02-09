import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../../core/constants/keys.dart';
import '../../../../../core/constants/others.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/utils/validator/validation_error_message.dart';
import '../../../a_domain/usecases/authentication_use_case.dart';
import '../../shared/inputs/email.dart';
import '../../shared/inputs/password.dart';

part 'event.dart';
part 'state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase _loginUseCase;
  final TryAutoLoginUseCase _tryAutoLoginUseCase;

  LoginBloc({
    required LoginUseCase loginUseCase,
    required TryAutoLoginUseCase tryAutoLoginUseCase,
  }) : _loginUseCase = loginUseCase,
       _tryAutoLoginUseCase = tryAutoLoginUseCase,
       super(const LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
    on<LoginAutoLoginStarted>(_onAutoLoginStarted);
  }

  FutureOr<void> _onEmailChanged(
    LoginEmailChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(
      state.copyWith(
        email: Email.dirty(event.email),
        status: FormzSubmissionStatus.initial,
        error: state.error,
      ),
    );
  }

  FutureOr<void> _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(
      state.copyWith(
        password: Password.dirty(event.password),
        status: FormzSubmissionStatus.initial,
        error: state.error,
      ),
    );
  }

  FutureOr<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    final emailError = ValidationErrorMessage.getEmailErrorMessage(
      error: state.email.error,
    );

    if (emailError != null) {
      emit(
        state.copyWith(
          email: state.email,
          password: state.password,
          error: emailError,
        ),
      );

      return;
    }

    final passwordError = ValidationErrorMessage.getPasswordErrorMessage(
      error: state.password.error,
    );

    if (passwordError != null) {
      emit(
        state.copyWith(
          email: state.email,
          password: state.password,
          error: passwordError,
        ),
      );

      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress, error: ''));

    final res = await _loginUseCase.execute(
      email: state.email.value,
      password: state.password.value,
    );

    res.fold(
      (failure) {
        emit(state.copyWith(status: FormzSubmissionStatus.failure));
      },
      (data) {
        emit(state.copyWith(status: FormzSubmissionStatus.success));
      },
    );
  }

  FutureOr<void> _onAutoLoginStarted(
    LoginAutoLoginStarted event,
    Emitter<LoginState> emit,
  ) async {
    final refreshToken = await SECURE_STORAGE.read(
      key: SecureStorageKeys.REFRESH_TOKEN,
    );
    final userId = await SECURE_STORAGE.read(key: SecureStorageKeys.USER_ID);

    if (refreshToken == null || userId == null) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          error: ErrorInformation.TRY_AUTO_LOGIN_FAILED.message,
        ),
      );

      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    final result = await _tryAutoLoginUseCase.execute(
      refreshToken: refreshToken,
      userId: userId,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: FormzSubmissionStatus.failure,
            error: ErrorInformation.TRY_AUTO_LOGIN_FAILED.message,
          ),
        );
      },
      (data) {
        emit(state.copyWith(status: FormzSubmissionStatus.success));
      },
    );
  }
}
