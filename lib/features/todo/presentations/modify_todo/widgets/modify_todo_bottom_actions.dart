import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:todo_flutter_mobile_app/core/constants/sizes.dart';
import 'package:todo_flutter_mobile_app/features/todo/presentations/modify_todo/cubit/modify_todo_form_cubit.dart';

import '../../../../../core/constants/others.dart';

class TodoBottomActions extends StatelessWidget {
  final VoidCallback onClose;

  const TodoBottomActions({super.key, required this.onClose});

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
                    // final userId = await SECURE_STORAGE.read(
                    //   key: SecureStorageKeys.USER_ID,
                    // );

                    context.read<ModifyTodoFormCubit>().submitForm(
                      userId: 'lsjflksjdlkfsjldkfjlkds',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: COLORS.PRIMARY_APP,
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
                  onPressed: onClose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: COLORS.SECONDARY_BG,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Đóng',
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
