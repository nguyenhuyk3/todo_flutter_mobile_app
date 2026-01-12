// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/sizes.dart';
import '../../../../../core/widgets/authentication_form.dart';
import '../bloc/bloc.dart';
import '../widgets/step_one/fp_email_input.dart';
import '../widgets/step_one/fp_send_otp_button.dart';
import 'step_two.dart';

class ForgotPasswordStepOnePage extends StatelessWidget {
  const ForgotPasswordStepOnePage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<ForgotPasswordBloc>().state is ForgotPasswordInitial) {
        context.read<ForgotPasswordBloc>().add(
          const ForgotPasswordEmailChanged(email: ''),
        );
      }
    });

    return AuthenticationForm(
      title: 'Quên mật khẩu',
      allowBack: true,
      resizeToAvoidBottomInset: true,
      child: BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ForgotPasswordStepTwo) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (_) => BlocProvider.value(
                      value: context.read<ForgotPasswordBloc>(),
                      child: const ForgotPasswordStepTwoPage(),
                    ),
              ),
            );
          }
        },
        child: Column(
          children: [
            const SizedBox(height: HEIGTH_SIZED_BOX_12),

            const FPEmailInput(),

            const Spacer(),

            const FPSendOTPButton(),
          ],
        ),
      ),
    );
  }
}
