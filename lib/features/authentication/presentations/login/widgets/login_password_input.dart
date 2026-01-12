import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../../../core/constants/others.dart';
import '../../../../../../core/constants/sizes.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/widgets/error_displayer.dart';
import '../../password/bloc/bloc.dart';
import '../bloc/bloc.dart';

class LoginPasswordInput extends StatefulWidget {
  const LoginPasswordInput({super.key});

  @override
  State<LoginPasswordInput> createState() => _LoginPasswordInputState();
}

class _LoginPasswordInputState extends State<LoginPasswordInput> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Bắt lỗi: lọc các lỗi của email để không hiển thị nhầm bên password
    final displayError = context.select<LoginBloc, String>((bloc) {
      final state = bloc.state;
      final errorMsg = state.error;

      if (errorMsg == ErrorInformation.EMAIL_CAN_NOT_BE_BLANK.message ||
          errorMsg == ErrorInformation.INVALID_EMAIL.message) {
        return '';
      }

      return errorMsg;
    });
    final hasError = displayError.isNotEmpty;
    final isLoading =
        context.watch<LoginBloc>().state.status ==
        FormzSubmissionStatus.inProgress;
    // Màu sắc và trạng thái UI
    final borderColor = hasError ? COLORS.ERROR : COLORS.FOCUSED_BORDER_IP;
    final shadowColor = hasError ? COLORS.ERROR : COLORS.PRIMARY_SHADOW;
    final isFocused = _focusNode.hasFocus;

    return BlocProvider(
      create: (context) => PasswordBloc(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<PasswordBloc, PasswordState>(
            builder: (context, passwordState) {
              return AnimatedContainer(
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
                  focusNode: _focusNode,
                  enabled: !isLoading,
                  obscureText: passwordState.obscureText,
                  onChanged: (password) {
                    context.read<LoginBloc>().add(
                      LoginPasswordChanged(password: password),
                    );
                  },
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
                    hintText: 'Nhập mật khẩu',
                    hintStyle: TextStyle(
                      color: COLORS.HINT_TEXT,
                      fontSize: TextSizes.TITLE_14,
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline_rounded,
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
                            : IconButton(
                              icon: Icon(
                                passwordState.obscureText
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: IconSizes.ICON_20,
                                color:
                                    hasError
                                        ? COLORS.ERROR
                                        : (isFocused
                                            ? COLORS.ICON_DEFAULT_COLOR
                                            : COLORS.ICON_PRIMARY),
                              ),
                              onPressed: () {
                                context.read<PasswordBloc>().add(
                                  PasswordToggleVisibility(),
                                );
                              },
                            ),
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
                  ),
                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                ),
              );
            },
          ),

          if (hasError) ErrorDisplayer(message: displayError),
        ],
      ),
    );
  }
}
