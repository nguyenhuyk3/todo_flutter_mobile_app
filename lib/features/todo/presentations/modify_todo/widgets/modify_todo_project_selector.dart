import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/others.dart';
import '../../../../../core/constants/sizes.dart';
import '../../models/project_option.dart';
import '../cubit/modify_todo_form_cubit.dart';

class ModifyTodoProjectSelector extends StatelessWidget {
  const ModifyTodoProjectSelector({super.key});

  static const List<ProjectOption> _projects = [
    ProjectOption(id: null, name: 'Không'),
    ProjectOption(id: 'project-id-001', name: 'Cá nhân'),
    ProjectOption(id: 'project-id-002', name: 'Công việc'),
    ProjectOption(id: 'project-id-003', name: 'Gia đình'),
    ProjectOption(id: 'project-id-004', name: 'Học tập'),
  ];

  void _showProjectPicker(BuildContext parentContext, String? currentId) {
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

              // Giới hạn chiều cao nếu danh sách quá dài (dùng Flexible/Expanded)
              Flexible(
                child: ListView(
                  shrinkWrap:
                      true, // Quan trọng để dùng trong Column minAxisSize
                  children:
                      _projects.map((project) {
                        final isSelected = project.id == currentId;

                        return InkWell(
                          onTap: () {
                            cubit.projectChanged(projectId: project.id);

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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  project.name,
                                  style: TextStyle(
                                    fontSize: TextSizes.TITLE_16,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        isSelected
                                            ? COLORS.PRIMARY_APP
                                            : COLORS.PRIMARY_TEXT,
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
                      }).toList(),
                ),
              ),

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
        final selectedId = state.projectId;
        // Logic an toàn để lấy tên hiển thị
        final projectObj = _projects.firstWhere(
          (e) => e.id == selectedId,
          orElse: () => _projects.first,
        );
        final displayName = projectObj.name;

        return GestureDetector(
          onTap: () => _showProjectPicker(context, selectedId),
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

                Text(
                  displayName,
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
