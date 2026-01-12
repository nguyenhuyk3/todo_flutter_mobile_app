import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../core/constants/others.dart';
import '../../../../../../../core/constants/sizes.dart';
import '../../../../../../core/widgets/error_displayer.dart';
import '../../bloc/bloc.dart';

class FPEmailInput extends StatefulWidget {
  const FPEmailInput({super.key});

  @override
  State<FPEmailInput> createState() => _FPEmailInputState();
}

class _FPEmailInputState extends State<FPEmailInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();
    _focusNode = FocusNode();

    _controller.addListener(() {
      setState(() {});
    });
    // Lắng nghe thay đổi focus để rebuild UI (cập nhật màu icon/border)
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
    return BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
      builder: (context, state) {
        final String error = (state is ForgotPasswordError) ? state.error : '';
        // Kiểm tra xem bloc có đang load ở step 1 không
        final isLoading = context.select<ForgotPasswordBloc, bool>((bloc) {
          final state = bloc.state;

          return state is ForgotPasswordStepOne && state.isLoading;
        });
        final hasError = error.isNotEmpty;
        final isFocused = _focusNode.hasFocus;
        // Định nghĩa màu sắc UI theo trạng thái
        final borderColor = hasError ? COLORS.ERROR : Colors.black;
        final shadowColor = hasError ? COLORS.ERROR : Colors.black;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container bọc ngoài tạo hiệu ứng Hard Shadow
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
                    offset: const Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: TextField(
                key: const Key('registration_emailInput_stepOne_textField'),
                controller: _controller,
                focusNode: _focusNode,
                enabled: !isLoading,
                onChanged:
                    (email) => context.read<ForgotPasswordBloc>().add(
                      ForgotPasswordEmailChanged(email: email),
                    ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                style: TextStyle(
                  fontSize: TextSizes.TITLE_16,
                  fontWeight: FontWeight.w600,
                  color:
                      isLoading ? COLORS.SECONDARY_TEXT : COLORS.PRIMARY_TEXT,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  hintText: 'Nhập địa chỉ email',
                  hintStyle: TextStyle(
                    color: COLORS.HINT_TEXT,
                    fontSize: TextSizes.TITLE_14,
                  ),
                  prefixIcon: Icon(
                    Icons.mail_outline_rounded,
                    color:
                        hasError
                            ? COLORS.ERROR
                            : (isFocused
                                ? COLORS.ICON_DEFAULT_COLOR
                                : COLORS.ICON_PRIMARY),
                    size: IconSizes.ICON_20,
                  ),
                  suffixIcon:
                      isLoading
                          ? null
                          : (_controller.text.isNotEmpty
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

                                  context.read<ForgotPasswordBloc>().add(
                                    const ForgotPasswordEmailChanged(email: ''),
                                  );
                                },
                              )
                              : null),

                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
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
