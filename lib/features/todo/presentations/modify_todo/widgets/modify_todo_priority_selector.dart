import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/others.dart';
import '../../../../../core/constants/sizes.dart';
import '../../../domain/entities/enums.dart'; // Import Enum TodoPriority
import '../cubit/modify_todo_form_cubit.dart';

/// Helper class để quản lý thông tin hiển thị của từng độ ưu tiên
class _PriorityProps {
  final String label;
  final Color color;

  const _PriorityProps(this.label, this.color);
}

class TodoPrioritySelector extends StatelessWidget {
  const TodoPrioritySelector({super.key});

  /// Map cấu hình: Enum -> {Label, Color}
  static const Map<TodoPriority, _PriorityProps> _priorityConfig = {
    TodoPriority.low: _PriorityProps('Thấp', Colors.grey),
    TodoPriority.medium: _PriorityProps('Trung bình', Colors.yellowAccent),
    TodoPriority.high: _PriorityProps('Cao', Colors.redAccent),
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ModifyTodoFormCubit, ModifyTodoFormState>(
      builder: (context, state) {
        final currentPriority = state.priority;

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
                offset: const Offset(0, 3), // Bóng cứng đổ xuống dưới
                blurRadius: 0, // Không làm mờ
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.flag_outlined,
                color: COLORS.ICON_PRIMARY,
                size: IconSizes.ICON_20,
              ),

              SizedBox(width: WIDTH_SIZED_BOX_4),

              Text(
                "Độ ưu tiên:",
                style: TextStyle(
                  color: COLORS.SECONDARY_TEXT,
                  fontWeight: FontWeight.bold,
                  fontSize: TextSizes.TITLE_14,
                ),
              ),

              // Khoảng cách này giữ nguyên như code cũ của bạn
              SizedBox(width: WIDTH_SIZED_BOX_4 * 9),

              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<TodoPriority>(
                    value: currentPriority,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: COLORS.ICON_PRIMARY,
                    ),
                    dropdownColor: COLORS.PRIMARY_BG,
                    isExpanded: true,
                    // Gọi Cubit khi thay đổi
                    onChanged: (TodoPriority? newPriority) {
                      if (newPriority != null) {
                        context.read<ModifyTodoFormCubit>().priorityChanged(
                          newPriority,
                        );
                      }
                    },
                    // Generate danh sách Item từ Enum.values
                    items:
                        TodoPriority.values.map<DropdownMenuItem<TodoPriority>>(
                          (priority) {
                            final props =
                                _priorityConfig[priority] ??
                                const _PriorityProps(
                                  'Không xác định',
                                  Colors.black,
                                );
                            final isSelected = priority == currentPriority;

                            return DropdownMenuItem<TodoPriority>(
                              value: priority,
                              child: Row(
                                children: [
                                  // Chấm tròn màu sắc
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: props.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),

                                  const SizedBox(width: WIDTH_SIZED_BOX_4 * 3),

                                  Text(
                                    props.label,
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
                                  ),
                                ],
                              ),
                            );
                          },
                        ).toList(),
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
