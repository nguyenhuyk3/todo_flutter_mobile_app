import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/others.dart';
import '../../../../../core/constants/sizes.dart';
import '../../models/parent_task_option.dart';
import '../cubit/modify_todo_form_cubit.dart';

class ModifyTodoParentTaskSelector extends StatelessWidget {
  const ModifyTodoParentTaskSelector({super.key});

  static const List<ParentTaskOption> _availableTasks = [
    ParentTaskOption(id: null, name: 'Không'),
    ParentTaskOption(id: 'task-001', name: 'Thiết kế giao diện Mobile'),
    ParentTaskOption(id: 'task-002', name: 'Phân tích cơ sở dữ liệu'),
    ParentTaskOption(id: 'task-003', name: 'Họp Client giai đoạn 1'),
    ParentTaskOption(id: 'task-004', name: 'Viết API đăng nhập'),
    ParentTaskOption(id: 'task-005', name: 'Mua sắm thiết bị'),
  ];

  void _showParentTaskPicker(BuildContext parentContext, String? currentId) {
    final cubit = parentContext.read<ModifyTodoFormCubit>();

    showModalBottomSheet(
      context: parentContext,
      backgroundColor: COLORS.PRIMARY_BG,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      // Cho phép BottomSheet co giãn khi bàn phím mở hoặc list dài
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return SafeArea(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: COLORS.PRIMARY_APP,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.only(bottom: 20),
                      children:
                          _availableTasks.map((task) {
                            final isSelected = task.id == currentId;

                            return InkWell(
                              onTap: () {
                                cubit.parentTodoChanged(task.id);

                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: COLORS.UNFOCUSED_BORDER_IP,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Dùng Expanded để text dài tự xuống dòng hoặc cắt bớt trong popup
                                    Expanded(
                                      child: Text(
                                        task.name,
                                        style: TextStyle(
                                          fontSize: TextSizes.TITLE_16,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              isSelected
                                                  ? COLORS.PRIMARY_APP
                                                  : COLORS.PRIMARY_TEXT,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                    if (isSelected) ...[
                                      const SizedBox(
                                        width: WIDTH_SIZED_BOX_4 * 2,
                                      ),

                                      Icon(
                                        Icons.check,
                                        color: COLORS.PRIMARY_APP,
                                        size: IconSizes.ICON_20,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ModifyTodoFormCubit, ModifyTodoFormState>(
      builder: (context, state) {
        final currentParentId = state.parentTodoId;
        // Logic an toàn lấy tên hiển thị
        final taskObj = _availableTasks.firstWhere(
          (e) => e.id == currentParentId,
          orElse: () => _availableTasks.first,
        );

        return GestureDetector(
          onTap: () => _showParentTaskPicker(context, currentParentId),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: COLORS.INPUT_BG,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: COLORS.FOCUSED_BORDER_IP, width: 1),
              boxShadow: [
                BoxShadow(
                  color: COLORS.PRIMARY_SHADOW,
                  offset: const Offset(0, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.subdirectory_arrow_right,
                  color: COLORS.ICON_PRIMARY,
                  size: IconSizes.ICON_20,
                ),

                SizedBox(width: WIDTH_SIZED_BOX_4),

                Text(
                  "Công việc cha:",
                  style: TextStyle(
                    color: COLORS.SECONDARY_TEXT,
                    fontWeight: FontWeight.bold,
                    fontSize: TextSizes.TITLE_14,
                  ),
                ),

                const SizedBox(width: WIDTH_SIZED_BOX_4 * 2),

                Text(
                  taskObj.name,
                  style: TextStyle(
                    color: COLORS.PRIMARY_TEXT,
                    fontWeight: FontWeight.bold,
                    fontSize: TextSizes.TITLE_14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

                const Spacer(),

                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: IconSizes.ICON_16,
                  color: COLORS.ICON_PRIMARY,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
