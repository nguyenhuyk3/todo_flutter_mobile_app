import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/constants/others.dart';
import '../../../../../../core/constants/sizes.dart';
import '../../bloc/bloc.dart';

class FPOtpInfoSection extends StatelessWidget {
  const FPOtpInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final email = context.read<ForgotPasswordBloc>().email;

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
