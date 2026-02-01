import 'package:flutter/material.dart';

import '../../../../../core/constants/others.dart';
import '../../../../../core/constants/sizes.dart';
import '../../forgot_password/pages/step_one.dart';

class LoginRedirectToForgotPasswordPage extends StatelessWidget {
  const LoginRedirectToForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ForgotPasswordStepOnePage(),
            ),
          );
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'Quên mật khẩu?',
          style: TextStyle(
            color: COLORS.PRIMARY_TEXT,
            fontSize: TextSizes.TITLE_12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
