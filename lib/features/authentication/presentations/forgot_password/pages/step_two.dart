import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/sizes.dart';
import '../../../../../core/widgets/authentication_form.dart';
import '../bloc/bloc.dart';
import '../widgets/step_two/fp_otp_info_section.dart';
import '../widgets/step_two/fp_otp_pin_put.dart';
import '../widgets/step_two/fp_otp_submit_button.dart';
import '../widgets/step_two/fp_otp_timer_resent.dart';
import 'step_three.dart';

class ForgotPasswordStepTwoPage extends StatelessWidget {
  const ForgotPasswordStepTwoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final email = context.read<ForgotPasswordBloc>().email;

    return AuthenticationForm(
      title: 'Nhập mã OTP',
      child: BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ForgotPasswordStepThree) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (_) => BlocProvider.value(
                      value: context.read<ForgotPasswordBloc>(),
                      child: const ForgotPasswordStepThreePage(),
                    ),
              ),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FPOtpInfoSection(email: email),

            const SizedBox(height: MAX_HEIGTH_SIZED_BOX),

            const FPOtpPinInput(),

            const SizedBox(height: MAX_HEIGTH_SIZED_BOX),

            const FPOtpTimerResend(),

            const Spacer(),

            const FPOtpSubmitButton(),
          ],
        ),
      ),
    );
  }
}
