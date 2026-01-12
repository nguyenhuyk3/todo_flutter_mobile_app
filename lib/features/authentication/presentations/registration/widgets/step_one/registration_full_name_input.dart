import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/constants/others.dart';
import '../../../../../../core/constants/sizes.dart';
import '../../../../../../core/errors/failure.dart';
import '../../../../../../core/widgets/error_displayer.dart';
import '../../bloc/bloc.dart';

class RegistrationFullNameInput extends StatefulWidget {
  const RegistrationFullNameInput({super.key});

  @override
  State<RegistrationFullNameInput> createState() =>
      RegistrationFullNameInputState();
}

class RegistrationFullNameInputState extends State<RegistrationFullNameInput> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Rebuild UI khi focus thay đổi (cập nhật màu icon/border)
    _focusNode.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. LOGIC LỌC LỖI TỪ BLOC
    final String errorDisplay = context.select<RegistrationBloc, String>((
      bloc,
    ) {
      final state = bloc.state;
      // Chỉ bắt lỗi EMPTY_FULL_NAME tại RegistrationStepOne
      if (state is RegistrationStepOne &&
          state.error == ErrorInformation.EMPTY_FULL_NAME.message) {
        return state.error;
      }

      return '';
    });

    final bool hasError = errorDisplay.isNotEmpty;
    // 2. LOGIC LOADING
    final bool isLoading = context.select<RegistrationBloc, bool>((bloc) {
      final state = bloc.state;

      return state is RegistrationStepOne && state.isLoading;
    });
    // 3. COLOR & STYLE
    final borderColor =
        hasError ? COLORS.ERROR : COLORS.FOCUSED_BORDER_IP;
    final shadowColor =
        hasError ? COLORS.ERROR : COLORS.PRIMARY_SHADOW;
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
            focusNode: _focusNode,
            enabled: !isLoading,
            onChanged: (fullName) {
              final currentState = context.read<RegistrationBloc>().state;

              if (currentState is RegistrationStepOne) {
                context.read<RegistrationBloc>().add(
                  RegistrationInformationChanged(
                    fullName: fullName,
                    birthDate: currentState.birthDate,
                    sex: currentState.sex,
                  ),
                );
              }
            },
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
              fillColor: Colors.transparent,
              hintText: 'Nhập họ và tên',
              hintStyle: TextStyle(
                color: COLORS.HINT_TEXT,
                fontSize: TextSizes.TITLE_14
              ),
              prefixIcon: Icon(
                Icons.person_outline_rounded,
                color:
                    hasError
                        ? COLORS.ERROR
                        : (isFocused
                            ? COLORS.ICON_DEFAULT_COLOR
                            : COLORS.ICON_PRIMARY),
                size: IconSizes.ICON_20,
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
              errorText: null,
            ),
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
          ),
        ),

        if (hasError) ErrorDisplayer(message: errorDisplay),
      ],
    );
  }
}
