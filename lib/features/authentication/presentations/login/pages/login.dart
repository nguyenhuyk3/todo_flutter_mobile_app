import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../../core/constants/sizes.dart';
import '../../../../../core/utils/toats.dart';
import '../../../../../core/widgets/authentication_form.dart';
import '../../../../home/presentations/home_page.dart';
import '../bloc/bloc.dart';
import '../widgets/login_email_input.dart';
import '../widgets/login_password_input.dart';
import '../widgets/login_redirect_to_forgot_password_page.dart';
import '../widgets/login_redirect_to_registration_page.dart';
import '../widgets/login_social_login_button.dart';
import '../widgets/login_social_login_divider.dart';
import '../widgets/login_submit_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) async {
        if (state.status.isFailure) {
          ToastUtils.showError(
            context: context,
            message: 'Vui lòng kiểm tra thông tin đăng nhập',
          );
        } else if (state.status.isSuccess) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => HomePage()),
            (Route<dynamic> route) => false,
          );

          ToastUtils.showSuccess(
            context: context,
            message: 'Đăng nhập thành công',
          );
        }
      },
      child: AuthenticationForm(
        title: 'Đăng nhập',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: HEIGTH_SIZED_BOX_12),

            const LoginEmailInput(),

            const SizedBox(height: HEIGTH_SIZED_BOX_12 * 1.5),

            const LoginPasswordInput(),

            const SizedBox(height: HEIGTH_SIZED_BOX_12 * 2),

            LoginRedirectToForgotPasswordPage(),

            LoginSocialLoginDivider(),

            LoginSocialLoginButton(),

            const SizedBox(height: HEIGTH_SIZED_BOX_12 * 2),

            LoginRedirectToRegistrationPage(),

            const Spacer(),

            const LoginSubmitButton(),
          ],
        ),
      ),
    );
  }
}
