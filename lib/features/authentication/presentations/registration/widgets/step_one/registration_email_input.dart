import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/constants/others.dart';
import '../../../../../../core/constants/sizes.dart';
import '../../../../../../core/errors/failure.dart';
import '../../../../../../core/widgets/error_displayer.dart';
import '../../bloc/bloc.dart';

/*
    FocusNode trong Flutter là đối tượng dùng để quản lý trạng thái focus (đang được chọn / đang nhập) 
  của một widget có thể nhận input (TextField, TextFormField, Button, v.v.).
    Hiểu ngắn gọn 👇
      FocusNode = “con trỏ biết widget nào đang được focus”

    TextEditingController là bộ điều khiển nội dung của TextField.
    Controller quản lý "View State" (vị trí con trỏ, vùng chọn), Bloc quản lý "Data State" (giá trị email).
*/
class RegistrationEmailInput extends StatefulWidget {
  const RegistrationEmailInput({super.key});

  @override
  State<RegistrationEmailInput> createState() => _RegistrationEmailInputState();
}

class _RegistrationEmailInputState extends State<RegistrationEmailInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();
    _focusNode = FocusNode();

    // Rebuild khi text thay đổi để update nút xoá (suffixIcon)
    _controller.addListener(() {
      setState(() {});
    });
    // Rebuild khi focus thay đổi để update style border/icon
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
    // ---- LOGIC BẮT LỖI & LOADING TỪ BLOC ----
    final String errorDisplay = context.select<RegistrationBloc, String>((
      bloc,
    ) {
      final state = bloc.state;

      if (state is! RegistrationStepOne) {
        return '';
      }
      if (state.error == ErrorInformation.EMAIL_CAN_NOT_BE_BLANK.message ||
          state.error == ErrorInformation.INVALID_EMAIL.message) {
        return state.error;
      }

      return '';
    });
    // ------------------------------------------
    final bool hasError = errorDisplay.isNotEmpty;
    final bool isLoading = context.select<RegistrationBloc, bool>((bloc) {
      final state = bloc.state;

      return state is RegistrationStepOne && state.isLoading;
    });
    final borderColor =
        hasError ? COLORS.ERROR_COLOR : COLORS.FOCUSED_BORDER_IP_COLOR;
    final shadowColor =
        hasError ? COLORS.ERROR_COLOR : COLORS.PRIMARY_SHADOW_COLOR;
    final isFocused = _focusNode.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            onChanged: (email) {
              context.read<RegistrationBloc>().add(
                RegistrationEmailChanged(email: email),
              );
            },
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            style: TextStyle(
              fontSize: TextSizes.TITLE_SMALL,
              fontWeight: FontWeight.w600,
              color:
                  isLoading
                      ? COLORS.SECONDARY_TEXT_COLOR
                      : COLORS.PRIMARY_TEXT_COLOR,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.transparent,
              hintText: 'Nhập địa chỉ email',
              hintStyle: TextStyle(
                color: COLORS.HINT_TEXT_COLOR,
                fontSize: TextSizes.TITLE_X_SMALL,
              ),
              prefixIcon: Icon(
                Icons.mail_outline_rounded,
                color:
                    hasError
                        ? COLORS.ERROR_COLOR
                        : (isFocused
                            ? COLORS.ICON_DEFAULT_COLOR
                            : COLORS.ICON_PRIMARY_COLOR),
                size: IconSizes.ICON_INPUT_SIZE,
              ),
              /*
                LOGIC MỚI CHO SUFFIX ICON:
                1. isLoading = true -> Ẩn icon (null)
                2. isLoading = false & có text -> Hiện nút X
                3. isLoading = false & không có text -> Ẩn (null)
              */
              suffixIcon:
                  isLoading
                      ? null
                      : (_controller.text.isNotEmpty
                          ? IconButton(
                            icon: Icon(
                              Icons.cancel,
                              size: IconSizes.ICON_MEDIUM_SIZE,
                              color:
                                  hasError
                                      ? COLORS.ERROR_COLOR
                                      : COLORS.ICON_PRIMARY_COLOR,
                            ),
                            onPressed: () {
                              _controller.clear();

                              context.read<RegistrationBloc>().add(
                                const RegistrationEmailChanged(email: ''),
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

        if (hasError) ErrorDisplayer(message: errorDisplay),
      ],
    );
  }
}
