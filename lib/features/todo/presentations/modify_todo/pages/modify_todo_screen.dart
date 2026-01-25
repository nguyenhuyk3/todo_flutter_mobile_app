import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:todo_flutter_mobile_app/features/todo/presentations/modify_todo/cubit/modify_todo_form_cubit.dart';
import 'package:todo_flutter_mobile_app/features/todo/presentations/modify_todo/widgets/modify_todo_time_selector.dart';

import '../../../../../core/constants/others.dart';
import '../../../../../core/constants/sizes.dart';
import '../../../domain/entities/enums.dart';
import '../widgets/modify_todo_bottom_actions.dart';
import '../widgets/modify_todo_date_range_selector.dart';
import '../widgets/modify_todo_description_input.dart';
import '../widgets/modify_todo_labels_grid.dart';
import '../widgets/modify_todo_parent_task_selector.dart';
import '../widgets/modify_todo_priority_selector.dart';
import '../widgets/modify_todo_project_selector.dart';
import '../widgets/modify_todo_recurrence_selector.dart';
import '../widgets/modify_todo_title_input.dart';

class ModifyTodoPage extends StatefulWidget {
  const ModifyTodoPage({super.key});

  @override
  State<ModifyTodoPage> createState() => _ModifyTodoPageState();
}

class _ModifyTodoPageState extends State<ModifyTodoPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ModifyTodoFormCubit, ModifyTodoFormState>(
      builder: (context, state) {
        final bool hasProject = state.projectId != null;
        final bool isRecurring =
            state.recurrencePattern != RecurrencePattern.once;

        // Kiểm tra xem khoảng thời gian đã được chọn hợp lệ chưa
        final bool isDateRangeValid = state.isRangeDateValid;

        return Scaffold(
          backgroundColor: COLORS.PRIMARY_BG,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: COLORS.PRIMARY_BG,
            elevation: 0,
            title: Text(
              'Thêm công việc cần làm',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: HeaderSizes.HEADER_18,
                color: COLORS.PRIMARY_TEXT,
              ),
            ),
          ),
          body: GestureDetector(
            behavior:
                HitTestBehavior
                    .opaque, // Đảm bảo bắt được sự kiện tap ở cả chỗ trống
            onTap: () {
              FocusScope.of(
                context,
              ).unfocus(); // Tắt bàn phím khi bấm vào vùng trống
            },
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        ModifyTodoTitleInput(),

                        const SizedBox(height: HEIGHT_SIZED_BOX_4 * 4),

                        const ModifyTodoDescriptionInput(),

                        const SizedBox(height: HEIGHT_SIZED_BOX_4 * 4),

                        ModifyTodoProjectSelector(),

                        const SizedBox(height: HEIGHT_SIZED_BOX_4 * 4),

                        // Nếu có Project -> Chỉ hiển thị Task cha, KHÔNG hiển thị Lặp lại
                        if (hasProject) ...[
                          ModifyTodoParentTaskSelector(),

                          const SizedBox(height: HEIGHT_SIZED_BOX_4 * 4),
                        ],

                        // Hiển thị chọn Ngày TRƯỚC
                        ModifyTodoDateRangeSelector(),

                        const SizedBox(height: HEIGHT_SIZED_BOX_4 * 4),

                        // YÊU CẦU: Chỉ hiển thị Lặp lại KHI (Không có Project VÀ Ngày đã chọn hợp lệ)
                        if (!hasProject && isDateRangeValid) ...[
                          ModifyTodoRecurrenceSelector(),

                          const SizedBox(height: HEIGHT_SIZED_BOX_4 * 4),
                        ],

                        // Hiển thị chọn Giờ nếu đang bật chế độ Lặp lại
                        if (isRecurring) ...[
                          ModifyTodoTimeSelector(),

                          const SizedBox(height: HEIGHT_SIZED_BOX_4 * 4),
                        ],

                        ModifyTodoPrioritySelector(),

                        const SizedBox(height: HEIGHT_SIZED_BOX_4 * 4),

                        // ModifyTodoAttachmentWidget(),

                        // const SizedBox(height: HEIGHT_SIZED_BOX_4 * 4),
                        //
                        ModifyTodoLabelsGrid(),

                        SizedBox(
                          height:
                              MediaQuery.of(context).viewInsets.bottom > 0
                                  ? 300
                                  : 20,
                        ),
                      ],
                    ),
                  ),
                ),

                ModifyTodoBottomActions(
                  onClose: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
