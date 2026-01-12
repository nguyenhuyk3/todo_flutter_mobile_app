import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/errors/failure.dart';
import '../../../../../../core/widgets/error_displayer.dart';
import '../../bloc/bloc.dart';

class RegistrationErrorMessageDisplayer extends StatelessWidget {
  const RegistrationErrorMessageDisplayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<RegistrationBloc, RegistrationState, String>(
      selector: (state) {
        if (state is! RegistrationStepOne || state.error.isEmpty) {
          return '';
        }

        final error = state.error;
        // Kiểm tra chính xác logic ErrorInformation class của bạn
        if (error == ErrorInformation.EMAIL_CAN_NOT_BE_BLANK.message ||
            error == ErrorInformation.INVALID_EMAIL.message ||
            error == ErrorInformation.EMPTY_PASSWORD.message ||
            error == ErrorInformation.PASSWORD_TOO_SHORT.message ||
            error == ErrorInformation.EMPTY_CONFIRMED_PASSWORD.message ||
            error == ErrorInformation.CONFIRMED_PASSWORD_MISSMATCH.message ||
            error == ErrorInformation.EMPTY_FULL_NAME.message) {
          return ''; // Không hiển thị lỗi validation ở đây
        }
        // Chỉ hiển thị các lỗi hệ thống, API (VD: "Email đã tồn tại", "Mất kết nối")
        return error;
      },
      builder: (context, error) {
        return error.isNotEmpty
            ? ErrorDisplayer(message: error)
            : const SizedBox.shrink();
      },
    );
  }
}
