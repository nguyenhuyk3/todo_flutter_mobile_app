import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:todo_flutter_mobile_app/features/todo/presentations/modify_todo/cubit/modify_todo_form_cubit.dart';

import '../../../../../core/constants/others.dart';
import '../../../../../core/constants/sizes.dart';
import '../../../../../core/widgets/error_displayer.dart';

class ModifyTodoTitleInput extends StatelessWidget {
  const ModifyTodoTitleInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ModifyTodoFormCubit, ModifyTodoFormState>(
      builder: (context, state) {
        final borderColor =
            state.showTitleError ? COLORS.ERROR : COLORS.FOCUSED_BORDER_IP;
        final shadowColor =
            state.showTitleError ? COLORS.ERROR : COLORS.PRIMARY_SHADOW;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: COLORS.INPUT_BG,
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
                onChanged:
                    (title) => context.read<ModifyTodoFormCubit>().titleChanged(
                      title: title,
                    ),
                onTapOutside: (event) {
                  // Dòng này sẽ tắt bàn phím và xóa focus khi bấm ra ngoài
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                textInputAction: TextInputAction.next,
                style: TextStyle(
                  fontSize: TextSizes.TITLE_16,
                  fontWeight: FontWeight.w500,
                  color: COLORS.PRIMARY_TEXT,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  hintText: 'Tiêu đề công việc...',
                  hintStyle: TextStyle(
                    color: COLORS.HINT_TEXT,
                    fontWeight: FontWeight.normal,
                    fontSize: TextSizes.TITLE_14,
                  ),
                  icon: Icon(
                    Icons.title,
                    color:
                        state.showTitleError
                            ? COLORS.ERROR
                            : COLORS.ICON_PRIMARY,
                    size: IconSizes.ICON_20,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),

            if (state.showTitleError) ErrorDisplayer(message: state.error),
          ],
        );
      },
    );
  }
}
