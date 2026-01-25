import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/others.dart';
import '../../../../../core/constants/sizes.dart';
import '../../../../../core/widgets/error_displayer.dart';
import '../cubit/modify_todo_form_cubit.dart';

class ModifyTodoDescriptionInput extends StatelessWidget {
  const ModifyTodoDescriptionInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ModifyTodoFormCubit, ModifyTodoFormState>(
      builder: (context, state) {
        final borderColor =
            state.showDescriptionError
                ? COLORS.ERROR
                : COLORS.FOCUSED_BORDER_IP;
        final shadowColor =
            state.showDescriptionError ? COLORS.ERROR : COLORS.PRIMARY_SHADOW;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 200,
                maxHeight: MediaQuery.of(context).size.height * 0.3,
              ),
              child: AnimatedContainer(
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
                child: Column(
                  children: [
                    Expanded(
                      child: TextField(
                        maxLines: null,
                        onTapOutside: (event) {
                          // Dòng này sẽ tắt bàn phím và xóa focus khi bấm ra ngoài
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        onChanged:
                            (description) => context
                                .read<ModifyTodoFormCubit>()
                                .descriptionChanged(description: description),
                        decoration: InputDecoration(
                          hintText: 'Viết mô tả của công việc ...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: COLORS.HINT_TEXT,
                            fontWeight: FontWeight.normal,
                            fontSize: TextSizes.TITLE_14,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: TextSizes.TITLE_16,
                          fontWeight: FontWeight.w500,
                          color: COLORS.PRIMARY_TEXT,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            '(${state.description.length}/1000)',
                            style: TextStyle(
                              color: COLORS.PRIMARY_TEXT,
                              fontSize: TextSizes.TITLE_12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (state.showDescriptionError)
              ErrorDisplayer(message: state.error),
          ],
        );
      },
    );
  }
}
