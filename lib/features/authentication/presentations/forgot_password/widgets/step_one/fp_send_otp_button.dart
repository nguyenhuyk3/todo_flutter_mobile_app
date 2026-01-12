import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../core/widgets/primary_button.dart';
import '../../bloc/bloc.dart';

class FPSendOTPButton extends StatelessWidget {
  const FPSendOTPButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return BlocSelector<ForgotPasswordBloc, ForgotPasswordState, bool>(
          selector:
              (state) => state is ForgotPasswordStepOne && state.isLoading,
          builder: (context, isLoading) {
            return PrimaryButton(
              title: 'Gửi mã xác thực OTP',
              isLoading: isLoading,
              onPressed:
                  isLoading
                      ? null
                      : () {
                        context.read<ForgotPasswordBloc>().add(
                          ForgotPasswordEmailSubmitted(),
                        );
                      },
            );
          },
        );
      },
    );
  }
}
