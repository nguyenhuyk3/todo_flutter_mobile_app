import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';

import '../../../../../../core/constants/others.dart';
import '../../../../../../core/constants/sizes.dart';
import '../../../../../../core/widgets/error_displayer.dart';
import '../../bloc/bloc.dart';

class RegistrationOtpPinInput extends StatelessWidget {
  const RegistrationOtpPinInput({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Cấu hình cơ bản cho ô OTP bình thường (Neo-brutalism Style)
    final defaultPinTheme = PinTheme(
      width: 56, // Độ rộng đồng bộ
      height: 64, // Chiều cao đồng bộ
      textStyle: TextStyle(
        fontSize: TextSizes.TITLE_22,
        fontWeight: FontWeight.w700,
        color: COLORS.PRIMARY_TEXT,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: COLORS.FOCUSED_BORDER_IP, width: 1),
        boxShadow: [
          BoxShadow(
            color: COLORS.PRIMARY_SHADOW,
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
    );
    // 2. Cấu hình khi ô được Focus (viền đậm hơn)
    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: COLORS.FOCUSED_BORDER_IP, width: 1.5),
      ),
    );
    // 3. Cấu hình khi có Lỗi (Viền đỏ, bóng đỏ)
    final errorPinTheme = defaultPinTheme.copyWith(
      textStyle: defaultPinTheme.textStyle!.copyWith(color: COLORS.ERROR),
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: COLORS.ERROR, width: 1),
        boxShadow: [
          BoxShadow(
            color: COLORS.ERROR,
            offset: const Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
    );

    return BlocSelector<RegistrationBloc, RegistrationState, String>(
      selector: (state) {
        return (state is RegistrationStepTwo) ? state.error : '';
      },
      builder: (context, error) {
        final hasError = error.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Pinput(
                length: LENGTH_OF_OTP,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                errorPinTheme: errorPinTheme,
                submittedPinTheme: defaultPinTheme,
                forceErrorState: hasError,
                keyboardType: TextInputType.number,
                cursor: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      width: 22,
                      height: 1.5,
                      color: Colors.black,
                    ),
                  ],
                ),
                onChanged:
                    (value) => context.read<RegistrationBloc>().add(
                      RegistrationOtpChanged(otp: value),
                    ),
                onCompleted: (pin) {
                  context.read<RegistrationBloc>().add(
                    RegistrationOtpSubmitted(),
                  );
                },
              ),
            ),

            if (hasError) ErrorDisplayer(message: error),
          ],
        );
      },
    );
  }
}
