import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/constants/others.dart';
import '../../../../../../core/constants/sizes.dart';
import '../../../../../../core/errors/failure.dart';
import '../../../../../../core/widgets/error_displayer.dart';
import '../../../password/bloc/bloc.dart';
import '../../bloc/bloc.dart';

class FPPasswordInput extends StatefulWidget {
  final String label;
  final String hintText;
  final bool isConfirmedPassword;

  const FPPasswordInput({
    super.key,
    required this.label,
    required this.hintText,
    this.isConfirmedPassword = false,
  });

  @override
  State<FPPasswordInput> createState() => _FPPasswordInputState();
}

class _FPPasswordInputState extends State<FPPasswordInput> {
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
    // 1. Logic bắt lỗi phức tạp (Giữ nguyên)
    final displayError = context.select<ForgotPasswordBloc, String>((bloc) {
      final state = bloc.state;

      if (state is! ForgotPasswordStepThree) {
        return '';
      }

      final errorMsg = state.error;

      if (widget.isConfirmedPassword) {
        if (errorMsg == ErrorInformation.EMPTY_CONFIRMED_PASSWORD.message ||
            errorMsg == ErrorInformation.CONFIRMED_PASSWORD_MISSMATCH.message) {
          return errorMsg;
        }
      } else {
        if (errorMsg == ErrorInformation.EMPTY_PASSWORD.message ||
            errorMsg == ErrorInformation.PASSWORD_TOO_SHORT.message ||
            errorMsg == ErrorInformation.PASSWORD_MISSING_LOWERCASE.message ||
            errorMsg == ErrorInformation.PASSWORD_MISSING_UPPERCASE.message ||
            errorMsg == ErrorInformation.PASSWORD_MISSING_NUMBER.message ||
            errorMsg ==
                ErrorInformation.PASSWORD_MISSING_SPECIAL_CHAR.message) {
          return errorMsg;
        }
      }

      return '';
    });

    final hasError = displayError.isNotEmpty;
    // 2. Logic Loading
    final bool isLoading = context.select<ForgotPasswordBloc, bool>((bloc) {
      final state = bloc.state;

      return state is ForgotPasswordStepThree && state.isLoading;
    });
    // 3. Logic Style (Color/Shadow)
    final borderColor = hasError ? COLORS.ERROR : Colors.black;
    final shadowColor = hasError ? COLORS.ERROR : Colors.black;
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
                  onChanged: (value) {
                    final currentState =
                        context.read<ForgotPasswordBloc>().state;

                    if (currentState is ForgotPasswordStepThree) {
                      context.read<ForgotPasswordBloc>().add(
                        ForgotPasswordPasswordChanged(
                          password:
                              widget.isConfirmedPassword
                                  ? currentState.password.value
                                  : value,
                          confirmedPassword:
                              widget.isConfirmedPassword
                                  ? value
                                  : currentState.confirmedPassword,
                        ),
                      );
                    }
                  },
                  textInputAction:
                      widget.isConfirmedPassword
                          ? TextInputAction.done
                          : TextInputAction.next,
                  style: TextStyle(
                    fontSize: TextSizes.TITLE_16,
                    fontWeight: FontWeight.w600,
                    color:
                        isLoading ? COLORS.SECONDARY_TEXT : COLORS.PRIMARY_TEXT,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.transparent,
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      color: COLORS.HINT_TEXT,
                      fontSize: TextSizes.TITLE_14,
                    ),
                    prefixIcon: Icon(
                      widget.isConfirmedPassword
                          ? Icons.lock_reset_rounded
                          : Icons.lock_outline_rounded,
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
