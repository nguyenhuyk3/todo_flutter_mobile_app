import 'package:flutter/material.dart';

import '../../../../../../core/constants/others.dart';
import '../../../../../../core/constants/sizes.dart';

class RegistrationOtpInfoSection extends StatelessWidget {
  final String email;

  const RegistrationOtpInfoSection({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Chúng tôi đã gửi mã OTP đến địa chỉ $email của bạn',
      style: TextStyle(
        fontSize: TextSizes.TITLE_14,
        color: COLORS.PRIMARY_TEXT,
        height: 1.5,
      ),
    );
  }
}
