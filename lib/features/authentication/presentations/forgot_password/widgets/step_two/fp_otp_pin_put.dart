import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';

import '../../../../../../core/constants/others.dart';
import '../../../../../../core/constants/sizes.dart';
import '../../../../../../core/widgets/error_displayer.dart';
import '../../bloc/bloc.dart';

class FPOtpPinInput extends StatelessWidget {
  const FPOtpPinInput({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Cấu hình cơ bản cho ô OTP bình thường
    final defaultPinTheme = PinTheme(
      width: 56, // Độ rộng mỗi ô
      height: 64, // Chiều cao mỗi ô
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
          // Hiệu ứng Hard Shadow (Bóng cứng)
          BoxShadow(
            color: COLORS.PRIMARY_SHADOW,
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
    );
    // 2. Cấu hình khi ô được Focus
    // Ở style này, ta có thể giữ nguyên giống default hoặc đậm viền hơn một chút
    // Nhưng để đồng bộ Neo-brutalism tĩnh, mình giữ shadow và chỉ nhấn mạnh nội dung
    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(
          color: COLORS.FOCUSED_BORDER_IP,
          width: 1.5,
        ), // Viền đậm hơn chút khi đang nhập
      ),
    );
    // 3. Cấu hình khi có Lỗi
    final errorPinTheme = defaultPinTheme.copyWith(
      textStyle: defaultPinTheme.textStyle!.copyWith(color: COLORS.ERROR),
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: COLORS.ERROR, width: 1),
        boxShadow: [
          // Bóng đổi sang màu đỏ
          BoxShadow(
            color: COLORS.ERROR,
            offset: const Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
    );

    return BlocSelector<ForgotPasswordBloc, ForgotPasswordState, String>(
      selector: (state) {
        return (state is ForgotPasswordError) ? state.error : '';
      },
      builder: (context, error) {
        final hasError = error.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Pinput(
                length: LENGTH_OF_OTP,
                // Áp dụng các Theme đã tạo
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                errorPinTheme: errorPinTheme,
                submittedPinTheme:
                    defaultPinTheme, // Khi nhập xong thì giữ nguyên style mặc định
                forceErrorState:
                    hasError, // Kích hoạt trạng thái lỗi cho Pinput
                keyboardType: TextInputType.number,
                // Cấu hình con trỏ nhấp nháy
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
                    (value) => context.read<ForgotPasswordBloc>().add(
                      ForgotPasswordOtpChanged(otp: value),
                    ),
                onCompleted:
                    (pin) => context.read<ForgotPasswordBloc>().add(
                      ForgotPasswordOtpSubmitted(),
                    ),
              ),
            ),

            if (hasError) ErrorDisplayer(message: error),
          ],
        );
      },
    );
  }
}
