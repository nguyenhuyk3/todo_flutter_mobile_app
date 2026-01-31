import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:todo_flutter_mobile_app/core/constants/sizes.dart';
import 'package:todo_flutter_mobile_app/features/todo/c_presentations/bloc/todo_bloc.dart';
import 'package:todo_flutter_mobile_app/features/todo/c_presentations/modify_todo/cubit/modify_todo_form_cubit.dart';

import '../../../../../core/constants/others.dart';

class ModifyTodoBottomActions extends StatelessWidget {
  const ModifyTodoBottomActions({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ModifyTodoFormCubit, ModifyTodoFormState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          color: COLORS.PRIMARY_BG,
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () async {
                    final todoModel =
                        await context.read<ModifyTodoFormCubit>().submitForm();
                    // ignore: use_build_context_synchronously
                    context.read<TodoBloc>().add(TodoAdded(todo: todoModel!));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: COLORS.PRIMARY,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Lưu',
                    style: TextStyle(
                      color: COLORS.PRIMARY_TEXT,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: WIDTH_SIZED_BOX_4 * 3),

              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: COLORS.SECONDARY_BG,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Trở về',
                    style: TextStyle(
                      color: COLORS.PRIMARY_TEXT,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
