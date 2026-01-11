import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../../core/utils/validator/validation_error_message.dart';
import '../../../domain/usecases/authentication_use_case.dart';
import '../../../inputs/email.dart';
import '../../../inputs/otp.dart';
import '../../../inputs/password.dart';

part 'event.dart';
part 'state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final CheckEmailExistsUseCase _checkEmailExistsUseCase;
  final SendForgotPasswordOTPUseCase _sendForgotPasswordOTPUseCase;
  final ResendOTPUseCase _resendOTPUseCase;
  final VerifyOTPUseCase _verifyOTPUseCase;
  final UpdatePasswordUseCase _updatePasswordUseCase;

  String _email = '';

  String get email => _email;

  ForgotPasswordBloc({
    required CheckEmailExistsUseCase checkEmailExistsUseCase,
    required SendForgotPasswordOTPUseCase sendForgotPasswordOTPUseCase,
    required ResendOTPUseCase resendOTPUseCase,
    required VerifyOTPUseCase verifyOTPUseCase,
    required UpdatePasswordUseCase updatePasswordUseCase,
  }) : _checkEmailExistsUseCase = checkEmailExistsUseCase,
       _sendForgotPasswordOTPUseCase = sendForgotPasswordOTPUseCase,
       _resendOTPUseCase = resendOTPUseCase,
       _verifyOTPUseCase = verifyOTPUseCase,
       _updatePasswordUseCase = updatePasswordUseCase,
       super(const ForgotPasswordInitial()) {
    on<ForgotPasswordEmailChanged>(_onEmailChanged);
    on<ForgotPasswordEmailSubmitted>(_onEmailSubmitted);

    on<ForgotPasswordOtpChanged>(_onOtpChanged);
    on<ForgotPasswordResendOTPRequested>(_onResendOTPRequested);
    on<ForgotPasswordOtpSubmitted>(_onOtpSubmitted);

    on<ForgotPasswordPasswordChanged>(_onPasswordChanged);
    on<ForgotPasswordSubmitted>(_onPasswordSubmmitted);
  }

  // Step 1
  FutureOr<void> _onEmailChanged(
    ForgotPasswordEmailChanged event,
    Emitter<ForgotPasswordState> emit,
  ) {
    emit(ForgotPasswordStepOne(email: Email.dirty(event.email)));
  }

  FutureOr<void> _onEmailSubmitted(
    ForgotPasswordEmailSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    final currentState = state;

    if (currentState is ForgotPasswordStepOne) {
      // 1. VALIDATION
      final error = ValidationErrorMessage.getEmailErrorMessage(
        error: currentState.email.error,
      );

      if (error != null) {
        emit(ForgotPasswordError(error: error));

        return;
      }
      // 2. LOADING
      emit(currentState.copyWith(isLoading: true));

      await Future.delayed(const Duration(seconds: 2));
      // 3. CHECK EMAIL EXISTS
      final checkEmailResult = await _checkEmailExistsUseCase.execute(
        email: currentState.email.value,
      );
      final checkResult = checkEmailResult.fold((l) => l, (r) => r);
      // 4. HANDLE RESULT
      // Tức là email đã tồn tại
      if (checkResult is bool) {
        final sendOTResult = await _sendForgotPasswordOTPUseCase.execute(
          email: currentState.email.value,
        );

        sendOTResult.fold(
          (failure) {
            emit(ForgotPasswordError(error: failure.message));
          },
          (_) {
            _email = currentState.email.value;

            emit(ForgotPasswordStepTwo(otp: const Otp.pure()));
          },
        );
      } else {
        emit(
          ForgotPasswordError(error: ErrorInformation.EMAIL_NOT_EXISTS.message),
        );
      }
    }
  }
  // ==========================  || ========================== //

  // Step 2
  FutureOr<void> _onOtpChanged(
    ForgotPasswordOtpChanged event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(ForgotPasswordStepTwo(otp: Otp.dirty(event.otp)));
  }

  FutureOr<void> _onResendOTPRequested(
    ForgotPasswordResendOTPRequested event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    final currentState = state;

    if (currentState is ForgotPasswordStepTwo) {
      final resendOTPResult = await _resendOTPUseCase.execute(
        email: _email,
        type: OtpType.recovery,
      );

      resendOTPResult.fold(
        (failure) {
          emit(ForgotPasswordError(error: failure.message));
        },
        (_) {
          emit(ForgotPasswordStepTwo(otp: Otp.dirty(currentState.otp.value)));
        },
      );
    }
  }

  FutureOr<void> _onOtpSubmitted(
    ForgotPasswordOtpSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    final currentState = state;

    if (currentState is ForgotPasswordStepTwo) {
      final error = ValidationErrorMessage.getOtpErrorMessage(
        error: currentState.otp.error,
      );

      if (error != null) {
        emit(ForgotPasswordError(error: error));

        return;
      }

      emit(const ForgotPasswordLoading());

      await Future.delayed(const Duration(seconds: 2));

      final verifyOTPResult = await _verifyOTPUseCase.execute(
        email: email,
        otp: currentState.otp.value,
        type: OtpType.recovery,
      );

      verifyOTPResult.fold(
        (failure) {
          emit(ForgotPasswordError(error: failure.message));
        },
        (_) {
          emit(
            ForgotPasswordStepThree(
              password: const Password.pure(),
              confirmedPassword: '',
              error: '',
            ),
          );
        },
      );
    }
  }
  // ========================== || ========================== //

  // Step 3
  FutureOr<void> _onPasswordChanged(
    ForgotPasswordPasswordChanged event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(
      ForgotPasswordStepThree(
        password: Password.dirty(event.password),
        confirmedPassword: event.confirmedPassword,
        error: '',
      ),
    );
  }

  FutureOr<void> _onPasswordSubmmitted(
    ForgotPasswordSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    final currentState = state;

    if (currentState is ForgotPasswordStepThree) {
      final password = currentState.password;
      final error = ValidationErrorMessage.getPasswordErrorMessage(
        error: password.error,
      );

      if (error != null) {
        emit(
          ForgotPasswordStepThree(
            password: password,
            confirmedPassword: currentState.confirmedPassword,
            error: error,
          ),
        );

        return;
      }

      if (currentState.confirmedPassword.isEmpty) {
        emit(
          ForgotPasswordStepThree(
            password: password,
            confirmedPassword: currentState.confirmedPassword,
            error: ErrorInformation.EMPTY_CONFIRMED_PASSWORD.message,
          ),
        );

        return;
      }

      if (currentState.password.value != currentState.confirmedPassword) {
        emit(
          ForgotPasswordStepThree(
            password: password,
            confirmedPassword: currentState.confirmedPassword,
            error: ErrorInformation.CONFIRMED_PASSWORD_MISSMATCH.message,
          ),
        );

        return;
      }

      emit(currentState.copyWith(isLoading: true));

      await Future.delayed(const Duration(seconds: 2));

      final updatePasswordResult = await _updatePasswordUseCase.execute(
        email: _email,
        newPassword: currentState.password.value,
      );

      updatePasswordResult.fold(
        (failure) {
          emit(
            ForgotPasswordStepThree(
              password: password,
              confirmedPassword: currentState.confirmedPassword,
              error: failure.message,
            ),
          );
        },
        (_) {
          emit(const ForgotPasswordSuccess());
        },
      );
    }
  }

  // ========================== || ========================== //
}
