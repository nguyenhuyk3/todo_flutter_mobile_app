import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/constants/others.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/utils/validator/validation_error_message.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/registration_params.dart';
import '../../../domain/usecases/authentication_use_case.dart';
import '../../../inputs/email.dart';
import '../../../inputs/otp.dart';
import '../../../inputs/password.dart';

part 'event.dart';
part 'state.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final RegisterUseCase _registerUseCase;
  final ResendOTPUseCase _resendOTPUseCase;
  final VerifyOTPUseCase _verifyOTPUseCase;

  String _email = '';

  String get email => _email;

  RegistrationBloc({
    required RegisterUseCase registerUseCase,
    required ResendOTPUseCase resendOTPUseCase,
    required VerifyOTPUseCase verifyOTPUseCase,
  }) : _registerUseCase = registerUseCase,
       _resendOTPUseCase = resendOTPUseCase,
       _verifyOTPUseCase = verifyOTPUseCase,

       super(RegistrationStepOne.initial()) {
    on<RegistrationEmailChanged>(_onEmailChanged);
    on<RegistrationPasswordChanged>(_onPasswordChanged);
    on<RegistrationInformationChanged>(_onInformationChanged);
    on<RegistrationStepOneSubmitted>(_onStepOneSubmitted);

    on<RegistrationOtpChanged>(_onOtpChanged);
    on<RegistrationResendOTPRequested>(_onResendOTPRequested);
    on<RegistrationOtpSubmitted>(_onOtpSubmitted);

    on<RegistrationReset>(_onRegistrationReset);
  }

  // Step 1
  Future<void> _onEmailChanged(
    RegistrationEmailChanged event,
    Emitter<RegistrationState> emit,
  ) async {
    final currentState = state;

    if (currentState is RegistrationStepOne) {
      emit(currentState.copyWith(email: Email.dirty(event.email)));
    }
  }

  Future<void> _onPasswordChanged(
    RegistrationPasswordChanged event,
    Emitter<RegistrationState> emit,
  ) async {
    final currentState = state;

    if (currentState is RegistrationStepOne) {
      emit(
        currentState.copyWith(
          password: Password.dirty(event.password),
          confirmedPassword: event.confirmedPassword,
        ),
      );
    }
  }

  Future<void> _onInformationChanged(
    RegistrationInformationChanged event,
    Emitter<RegistrationState> emit,
  ) async {
    final currentState = state;

    if (currentState is RegistrationStepOne) {
      emit(
        currentState.copyWith(
          fullName: event.fullName,
          birthDate: event.formattedBirthDate,
          sex: event.sex,
        ),
      );
    }
  }

  String? _validateStepOne(RegistrationStepOne state) {
    final emailError = ValidationErrorMessage.getEmailErrorMessage(
      error: state.email.error,
    );

    if (emailError != null) {
      return emailError;
    }

    final passwordError = ValidationErrorMessage.getPasswordErrorMessage(
      error: state.password.error,
    );

    if (passwordError != null) {
      return passwordError;
    }

    if (state.confirmedPassword.isEmpty) {
      return ErrorInformation.EMPTY_CONFIRMED_PASSWORD.message;
    }

    if (state.password.value != state.confirmedPassword) {
      return ErrorInformation.CONFIRMED_PASSWORD_MISSMATCH.message;
    }

    if (state.fullName.isEmpty) {
      return ErrorInformation.EMPTY_FULL_NAME.message;
    }

    return null;
  }

  FutureOr<void> _onStepOneSubmitted(
    RegistrationStepOneSubmitted event,
    Emitter<RegistrationState> emit,
  ) async {
    final currentState = state;

    if (currentState is! RegistrationStepOne) {
      return;
    }
    // ===== 1. VALIDATION =====
    final errorMessage = _validateStepOne(currentState);

    if (errorMessage != null) {
      emit(currentState.copyWith(error: errorMessage));

      return;
    }
    // ===== 2. CHUẨN BỊ DỮ LIỆU =====
    _email = currentState.email.value;
    // ===== 3. BẬT TRẠNG THÁI LOADING =====
    emit(currentState.copyWith(isLoading: true));
    // Giả lập thời gian chờ (Có thể xóa khi dùng thật)
    await Future.delayed(const Duration(seconds: 2));

    final registrationResult = await _registerUseCase.execute(
      RegistrationParams(
        email: _email,
        password: currentState.password.value,
        fullName: currentState.fullName,
        dateOfBirth: DateTime.parse(
          currentState.birthDate,
        ), // Convert String ISO -> DateTime
        sex: Sex.fromString(currentState.sex),
      ),
    );

    registrationResult.fold(
      (failure) {
        emit(currentState.copyWith(error: failure.message));
      },
      (_) {
        emit(RegistrationStepTwo(otp: const Otp.pure()));
      },
    );
  }
  // ========================== || ========================== //

  // Step 2
  Future<void> _onOtpChanged(
    RegistrationOtpChanged event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(RegistrationStepTwo(otp: Otp.dirty(event.otp)));
  }

  FutureOr<void> _onResendOTPRequested(
    RegistrationResendOTPRequested event,
    Emitter<RegistrationState> emit,
  ) async {
    final currentState = state;

    if (currentState is RegistrationStepTwo) {
      final resendOTPResult = await _resendOTPUseCase.execute(
        email: _email,
        type: OtpType.signup,
      );

      resendOTPResult.fold(
        (failure) {
          emit(currentState.copyWith(error: failure.message));
        },
        (_) {
          emit(currentState.copyWith(otp: Otp.dirty(currentState.otp.value)));
        },
      );
    }
  }

  FutureOr<void> _onOtpSubmitted(
    RegistrationOtpSubmitted event,
    Emitter<RegistrationState> emit,
  ) async {
    final currentState = state;

    if (currentState is RegistrationStepTwo) {
      final error = ValidationErrorMessage.getOtpErrorMessage(
        error: currentState.otp.error,
      );

      if (error != null) {
        emit(currentState.copyWith(error: error));

        return;
      }

      emit(currentState.copyWith(isLoading: true));

      await Future.delayed(const Duration(seconds: 2));

      final verifyOTPResult = await _verifyOTPUseCase.execute(
        email: email,
        otp: currentState.otp.value,
        type: OtpType.email,
      );

      verifyOTPResult.fold(
        (failure) {
          emit(currentState.copyWith(error: error));
        },
        (_) {
          emit(RegistrationSuccess());
        },
      );
    }
  }
  // ========================== || ========================== //

  FutureOr<void> _onRegistrationReset(
    RegistrationReset event,
    Emitter<RegistrationState> emit,
  ) {
    emit(RegistrationInitial());
  }
}
