import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../../../../core/constants/others.dart';
import '../../../../../../../core/constants/sizes.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/widgets/error_displayer.dart';
import '../bloc/bloc.dart';

/* 
  AnimatedContainer là gì?
    AnimatedContainer là Container có khả năng animate tự động khi các thuộc tính của nó thay đổi.
    📌 Khi bất kỳ thuộc tính nào sau đây thay đổi:\
      - decoration
      - padding
      - margin
      - width, height
      - alignment
      - color, borderRadius, boxShadow, … 
    👉 Flutter tự động tạo animation mượt từ trạng thái cũ → trạng thái mới.
    boxShadow:
      - offset: Offset(0, 3):
        + Shadow chỉ đổ xuống dưới
        + Trục X = 0 (không lệch ngang)
        + Trục Y = 3 (đổ xuống)
      ➡️ Tạo cảm giác nút nổi lên khỏi mặt phẳng
*/
class LoginEmailInput extends StatefulWidget {
  const LoginEmailInput({super.key});

  @override
  State<LoginEmailInput> createState() => _LoginEmailInputState();
}

class _LoginEmailInputState extends State<LoginEmailInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();
    _controller = TextEditingController();
    _controller.addListener(() {
      setState(() {});
    });
    // Lắng nghe thay đổi focus để rebuild UI hiệu ứng nhấn
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<LoginBloc, LoginState, String>(
      selector: (state) {
        return state.error;
      },
      builder: (context, error) {
        final displayError = context.select<LoginBloc, String>((bloc) {
          final state = bloc.state;
          final errorMsg = state.error;

          if (errorMsg == ErrorInformation.EMPTY_PASSWORD.message ||
              errorMsg == ErrorInformation.PASSWORD_TOO_SHORT.message ||
              errorMsg == ErrorInformation.PASSWORD_MISSING_LOWERCASE.message ||
              errorMsg == ErrorInformation.PASSWORD_MISSING_UPPERCASE.message ||
              errorMsg == ErrorInformation.PASSWORD_MISSING_NUMBER.message ||
              errorMsg ==
                  ErrorInformation.PASSWORD_MISSING_SPECIAL_CHAR.message) {
            return '';
          }

          return errorMsg;
        });
        final hasError = displayError.isNotEmpty;
        final isLoading =
            context.watch<LoginBloc>().state.status ==
            FormzSubmissionStatus.inProgress;
        // Xử lý hiệu ứng focus
        final isFocused = _focusNode.hasFocus;
        // Màu sắc dựa trên trạng thái
        final borderColor =
            hasError ? COLORS.ERROR : COLORS.FOCUSED_BORDER_IP;
        // Shadow cứng luôn là màu đen, trừ khi lỗi
        final shadowColor =
            hasError ? COLORS.ERROR : COLORS.PRIMARY_SHADOW;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container chịu trách nhiệm vẽ Border và Shadow style "Neo-brutalism"
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    offset: const Offset(0, 3), // Bóng cứng đổ xuống dưới
                    blurRadius: 0, // Không làm mờ
                  ),
                ],
              ),
              child: TextField(
                key: const Key('login_emailInput_textField'),
                controller: _controller,
                focusNode: _focusNode,
                enabled: !isLoading, // Vô hiệu hóa input khi đang loading
                onChanged:
                    (email) => context.read<LoginBloc>().add(
                      LoginEmailChanged(email: email),
                    ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                style: TextStyle(
                  fontSize: TextSizes.TITLE_16,
                  fontWeight: FontWeight.w600,
                  color:
                      isLoading
                          ? COLORS.SECONDARY_TEXT
                          : COLORS.PRIMARY_TEXT,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor:
                      Colors.transparent, // Trong suốt để thấy nền Container
                  hintText: 'Nhập địa chỉ email',
                  hintStyle: TextStyle(
                    color: COLORS.HINT_TEXT,
                    fontSize: TextSizes.TITLE_14,
                  ),
                  // PREFIX ICON
                  prefixIcon: Icon(
                    Icons.mail_outline_rounded,
                    color:
                        hasError
                            ? COLORS.ERROR
                            : (isFocused
                                // Giả định COLORS.ICON_DEFAULT_COLOR tồn tại như trong code cũ của bạn
                                // nếu không có thể thay bằng Colors.black
                                ? COLORS.ICON_DEFAULT_COLOR
                                : COLORS.ICON_PRIMARY),
                    size: IconSizes.ICON_20,
                  ),
                  suffixIcon:
                      (!isLoading && _controller.text.isNotEmpty)
                          ? IconButton(
                            icon: Icon(
                              Icons.cancel,
                              size: IconSizes.ICON_20,
                              color:
                                  hasError
                                      ? COLORS.ERROR
                                      : COLORS.ICON_PRIMARY,
                            ),
                            onPressed: () {
                              _controller.clear();

                              context.read<LoginBloc>().add(
                                const LoginEmailChanged(email: ''),
                              );
                            },
                          )
                          : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  // Tắt hết border mặc định của InputDecorator
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  errorText: null,
                ),
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
              ),
            ),

            if (hasError) ErrorDisplayer(message: error),
          ],
        );
      },
    );
  }
}
