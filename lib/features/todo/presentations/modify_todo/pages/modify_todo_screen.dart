import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:todo_flutter_mobile_app/features/todo/presentations/modify_todo/cubit/modify_todo_form_cubit.dart';
import 'package:todo_flutter_mobile_app/features/todo/presentations/modify_todo/widgets/modify_todo_time_selector.dart';

import '../../../../../core/constants/others.dart';
import '../../../../../core/constants/sizes.dart';
import '../../../domain/entities/enums.dart';
import '../../models/label_item.dart';
import '../../models/mock_file.dart';
import '../widgets/modify_todo_attachment_widget.dart';
import '../widgets/modify_todo_bottom_actions.dart';
import '../widgets/modify_todo_date_range_selector.dart';
import '../widgets/modify_todo_description_input.dart';
import '../widgets/modify_todo_edit_label_dialog.dart';
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
  // Các state vẫn tạm giữ lại ở UI (Attachment, Label, Time, ParentTask, Priority)
  // Vì chưa có yêu cầu refactor các phần này
  List<MockFile> mockAttachments = [
    MockFile(name: "hinh_anh_loi.jpg", extension: "img", size: "2.5 MB"),
    MockFile(name: "yeu_cau_du_an.pdf", extension: "pdf", size: "1.2 MB"),
    MockFile(name: "ghi_chu_hop.docx", extension: "doc", size: "500 KB"),
  ];

  List<LabelItem> labels = [
    LabelItem(name: "Chưa đặt tên", color: const Color(0xFF1FC389)),
    LabelItem(name: "Chưa đặt tên", color: const Color(0xFF8B5CF6)),
    LabelItem(name: "Chưa đặt tên", color: const Color(0xFFEF4444)),
    LabelItem(name: "Chưa đặt tên", color: const Color(0xFFF59E0B)),
    LabelItem(name: "Chưa đặt tên", color: const Color(0xFF3B82F6)),
    LabelItem(name: "Chưa đặt tên", color: const Color(0xFFEAB308)),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ModifyTodoFormCubit, ModifyTodoFormState>(
      builder: (context, state) {
        final bool hasProject = state.projectId != null;
        final bool isRecurring =
            state.recurrencePattern != RecurrencePattern.none;

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
          body: Column(
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

                      if (hasProject) ...[
                        ModifyTodoParentTaskSelector(),

                        const SizedBox(height: HEIGHT_SIZED_BOX_4 * 4),
                      ] else ...[
                        ModifyTodoRecurrenceSelector(),

                        const SizedBox(height: HEIGHT_SIZED_BOX_4 * 4),
                      ],

                      ModifyTodoDateRangeSelector(),

                      const SizedBox(height: HEIGHT_SIZED_BOX_4 * 4),

                      if (isRecurring) ...[
                        ModifyTodoTimeSelector(),

                        const SizedBox(height: HEIGHT_SIZED_BOX_4 * 4),
                      ],

                      ModifyTodoPrioritySelector(),

                      const SizedBox(height: HEIGHT_SIZED_BOX_4 * 4),

                      // File đính kèm
                      ModifyTodoAttachmentWidget(
                        files: mockAttachments,
                        onAddTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tính năng này sẽ phát triển sau!'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        onDeleteTap: (index) {
                          setState(() {
                            mockAttachments.removeAt(index);
                          });
                        },
                      ),

                      const SizedBox(height: HEIGHT_SIZED_BOX_4 * 4),

                      // Grid Nhãn
                      ModifyTodoLabelsGrid(
                        labels: labels,
                        onLabelTap: (index) {
                          setState(() {
                            labels[index].isSelected =
                                !labels[index].isSelected;
                          });
                        },
                        onLabelEdit: (index) {
                          showDialog(
                            context: context,
                            builder:
                                (ctx) => ModifyTodoEditLabelDialog(
                                  label: labels[index],
                                  onSave: (newName) {
                                    setState(() {
                                      labels[index].name = newName;
                                    });
                                  },
                                ),
                          );
                        },
                      ),

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
        );
      },
    );
  }
}
