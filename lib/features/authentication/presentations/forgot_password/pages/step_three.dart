import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/sizes.dart';
import '../../../../../core/utils/toats.dart';
import '../../../../../core/widgets/authentication_form.dart';
import '../../login/pages/login.dart';
import '../bloc/bloc.dart';
import '../widgets/step_three/fp_confirmed_password_button.dart';
import '../widgets/step_three/fp_error_message_displayer.dart';
import '../widgets/step_three/fp_password_input.dart';

class ForgotPasswordStepThreePage extends StatelessWidget {
  const ForgotPasswordStepThreePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthenticationForm(
      title: 'Thiết lập mật khẩu',
      child: BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ForgotPasswordSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (_) => BlocProvider.value(
                      value: context.read<ForgotPasswordBloc>(),
                      child: LoginPage(),
                    ),
              ),
            );

            ToastUtils.showSuccess(
              context: context,
              message: 'Cập nhập mật khẩu thành công',
            );
          }
        },
        child: Column(
          children: [
            const SizedBox(height: MAX_HEIGTH_SIZED_BOX),

            FPPasswordInput(label: 'Mật khẩu', hintText: 'Hãy nhập mật khẩu'),

            const SizedBox(height: MAX_HEIGTH_SIZED_BOX * 1.5),

            FPPasswordInput(
              label: 'Mật khẩu xác nhận',
              hintText: 'Hãy nhập mật khẩu xác nhận',
              isConfirmedPassword: true,
            ),

            const SizedBox(height: MAX_HEIGTH_SIZED_BOX * 4),

            FPErrorMessageDisplayer(),

            const Spacer(),

            FPConfirmedPasswordButton(),
          ],
        ),
      ),
    );
  }
}
