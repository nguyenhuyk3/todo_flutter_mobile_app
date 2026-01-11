import 'package:flutter/material.dart';

import '../../../../../core/constants/others.dart';
import '../../../../../core/constants/sizes.dart';
import '../../registration/pages/step_one.dart';

class LoginRedirectToRegistrationPage extends StatelessWidget {
  const LoginRedirectToRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Bạn chưa là thành viên?',
            style: TextStyle(
              color: COLORS.SECONDARY_TEXT_COLOR,
              fontSize: TextSizes.TITLE_X_SMALL,
            ),
          ),

          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RegistrationStepOnePage(),
                ),
              );
            },
            child: Text(
              'Đăng ký ngay',
              style: TextStyle(
                color: COLORS.PRIMARY_TEXT_COLOR,
                fontSize: TextSizes.TITLE_X_SMALL,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
