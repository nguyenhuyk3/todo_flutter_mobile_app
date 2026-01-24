import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/others.dart';
import '../../../../core/constants/sizes.dart';
import '../cubit/todo_form_cubit.dart';

/// Model nội bộ dùng để giả lập ID + Tên Task
class _ParentTaskOption {
  final String? id;
  final String name;

  const _ParentTaskOption({this.id, required this.name});
}

class TodoParentTaskSelector extends StatelessWidget {
  const TodoParentTaskSelector({super.key});

  // Giả lập danh sách công việc có ID (Sau này có thể fetch từ API/DB)
  static const List<_ParentTaskOption> _availableTasks = [
    _ParentTaskOption(id: null, name: 'Không'),
    _ParentTaskOption(id: 'task-001', name: 'Thiết kế giao diện Mobile'),
    _ParentTaskOption(id: 'task-002', name: 'Phân tích cơ sở dữ liệu'),
    _ParentTaskOption(id: 'task-003', name: 'Họp Client giai đoạn 1'),
    _ParentTaskOption(id: 'task-004', name: 'Viết API đăng nhập'),
    _ParentTaskOption(id: 'task-005', name: 'Mua sắm thiết bị'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoFormCubit, TodoFormState>(
      builder: (context, state) {
        final currentParentId = state.parentTodoId;
        // Kiểm tra an toàn: Nếu ID đang chọn không nằm trong list (do filter hoặc delete)
        // thì reset hiển thị về null để tránh crash Dropdown
        final bool isValidId =
            currentParentId == null ||
            _availableTasks.any((task) => task.id == currentParentId);
        final dropdownValue = isValidId ? currentParentId : null;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 14),
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

              SizedBox(width: WIDTH_SIZED_BOX_4 * 1.5),

              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    hint: Text(
                      "Chọn công việc...",
                      style: TextStyle(
                        color: COLORS.HINT_TEXT,
                        fontWeight: FontWeight.normal,
                        fontSize: TextSizes.TITLE_14,
                      ),
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: COLORS.ICON_PRIMARY,
                    ),
                    dropdownColor: COLORS.PRIMARY_BG,
                    style: const TextStyle(color: Colors.red, fontSize: 15),
                    isExpanded: true,
                    onChanged: (String? newId) {
                      context.read<TodoFormCubit>().parentTodoChanged(newId);
                    },

                    items:
                        _availableTasks.map<DropdownMenuItem<String>>((
                          _ParentTaskOption task,
                        ) {
                          final isSelected = task.id == currentParentId;

                          return DropdownMenuItem<String>(
                            value: task.id,
                            child: Text(
                              task.name,
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? COLORS.PRIMARY_TEXT
                                        : COLORS.SECONDARY_TEXT,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
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
