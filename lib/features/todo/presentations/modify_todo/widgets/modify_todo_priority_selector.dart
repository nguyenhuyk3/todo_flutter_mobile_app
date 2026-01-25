import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/others.dart';
import '../../../../../core/constants/sizes.dart';
import '../../../domain/entities/enums.dart';
import '../../models/priority_prop.dart';
import '../cubit/modify_todo_form_cubit.dart';

class ModifyTodoPrioritySelector extends StatelessWidget {
  const ModifyTodoPrioritySelector({super.key});

  static const Map<TodoPriority, PriorityProp> _priorityConfig = {
    TodoPriority.undefined: PriorityProp('Không xác định', Colors.grey),
    TodoPriority.low: PriorityProp(
      'Thấp',
      Color(0xFF69F0AE),
    ), // Xanh lá nhạt (GreenAccent)
    TodoPriority.medium: PriorityProp('Trung bình', Colors.yellowAccent),
    TodoPriority.high: PriorityProp('Cao', Colors.orangeAccent),
    TodoPriority.urgent: PriorityProp('Khẩn cấp', Colors.redAccent),
  };

  void _showPriorityPicker(
    BuildContext parentContext,
    TodoPriority currentPriority,
  ) {
    final cubit = parentContext.read<ModifyTodoFormCubit>();

    showModalBottomSheet(
      context: parentContext,
      backgroundColor: COLORS.PRIMARY_BG,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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

              ...TodoPriority.values.map((priority) {
                final isSelected = priority == currentPriority;
                final props =
                    _priorityConfig[priority] ??
                    PriorityProp('?', COLORS.SECONDARY_TEXT);

                return InkWell(
                  onTap: () {
                    cubit.priorityChanged(priority);
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
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: props.color,
                            shape: BoxShape.circle,
                          ),
                        ),

                        const SizedBox(width: WIDTH_SIZED_BOX_4 * 3),

                        Expanded(
                          child: Text(
                            props.label,
                            style: TextStyle(
                              fontSize: TextSizes.TITLE_16,
                              fontWeight: FontWeight.w500,
                              color:
                                  isSelected
                                      ? COLORS.PRIMARY_APP
                                      : COLORS.PRIMARY_TEXT,
                            ),
                          ),
                        ),

                        if (isSelected)
                          Icon(
                            Icons.check,
                            color: COLORS.PRIMARY_APP,
                            size: IconSizes.ICON_20,
                          ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: HEIGTH_SIZED_BOX_12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ModifyTodoFormCubit, ModifyTodoFormState>(
      builder: (context, state) {
        final currentPriority = state.priority;
        final props =
            _priorityConfig[currentPriority] ??
            const PriorityProp('Thấp', Colors.grey);

        return GestureDetector(
          onTap: () => _showPriorityPicker(context, currentPriority),
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

                const SizedBox(width: WIDTH_SIZED_BOX_4 * 9),

                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: props.color,
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: WIDTH_SIZED_BOX_4 * 2),

                Text(
                  props.label,
                  style: TextStyle(
                    color: COLORS.PRIMARY_TEXT,
                    fontWeight: FontWeight.bold,
                    fontSize: TextSizes.TITLE_14,
                  ),
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
