import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/others.dart';
import '../../../../core/constants/sizes.dart';
import '../cubit/todo_form_cubit.dart';

class _ProjectOption {
  final String? id;
  final String name;

  const _ProjectOption({required this.id, required this.name});
}

class TodoProjectSelector extends StatelessWidget {
  const TodoProjectSelector({super.key});

  static const List<_ProjectOption> _projects = [
    _ProjectOption(id: null, name: 'Không'),
    _ProjectOption(id: 'project-id-001', name: 'Cá nhân'),
    _ProjectOption(id: 'project-id-002', name: 'Công việc'),
    _ProjectOption(id: 'project-id-003', name: 'Gia đình'),
    _ProjectOption(id: 'project-id-004', name: 'Học tập'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoFormCubit, TodoFormState>(
      builder: (context, state) {
        final selectedId = state.projectId;
        // Logic hiển thị an toàn: Đảm bảo ID đang chọn thực sự có trong List
        // (đề phòng trường hợp ID từ DB load lên không khớp với mock list)
        final bool isValidId = _projects.any((e) => e.id == selectedId);
        // Nếu ID không khớp list (hoặc null), fallback về option đầu tiên ('Không')
        final currentValue = isValidId ? selectedId : _projects.first.id;

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
                Icons.folder_open_outlined,
                color: COLORS.ICON_PRIMARY,
                size: IconSizes.ICON_20,
              ),

              SizedBox(width: WIDTH_SIZED_BOX_4),

              Text(
                "Dự án:",
                style: TextStyle(
                  color: COLORS.SECONDARY_TEXT,
                  fontWeight: FontWeight.bold,
                  fontSize: TextSizes.TITLE_14,
                ),
              ),

              const SizedBox(width: WIDTH_SIZED_BOX_4 * 16),

              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: currentValue,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: COLORS.ICON_PRIMARY,
                    ),
                    dropdownColor: COLORS.PRIMARY_BG,
                    // style: const TextStyle(color: Colors.red, fontSize: 15),
                    isExpanded: true,
                    onChanged: (String? newId) {
                      context.read<TodoFormCubit>().projectChanged(
                        projectId: newId,
                      );
                    },
                    items:
                        _projects.map<DropdownMenuItem<String?>>((
                          _ProjectOption project,
                        ) {
                          final bool isSelected = project.id == currentValue;

                          return DropdownMenuItem<String?>(
                            value: project.id,
                            child: Text(
                              project.name,
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
