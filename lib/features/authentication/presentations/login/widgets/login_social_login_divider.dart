import 'package:flutter/material.dart';

import '../../../../../core/constants/others.dart';
import '../../../../../core/constants/sizes.dart';

class LoginSocialLoginDivider extends StatelessWidget {
  const LoginSocialLoginDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: COLORS.UNFOCUSED_BORDER_IP_COLOR,
              thickness: 0.8,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "HOẶC",
              style: TextStyle(
                color: COLORS.LABEL_COLOR,
                fontSize: TextSizes.TITLE_XX_SMALL,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),

          Expanded(
            child: Divider(
              color: COLORS.UNFOCUSED_BORDER_IP_COLOR,
              thickness: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
