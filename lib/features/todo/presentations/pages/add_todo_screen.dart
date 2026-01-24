import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_flutter_mobile_app/features/todo/domain/entities/enums.dart'; // Import để dùng RecurrencePattern
import 'package:todo_flutter_mobile_app/features/todo/presentations/cubit/todo_form_cubit.dart';
import 'package:todo_flutter_mobile_app/features/todo/presentations/widgets/todo_hour_selector.dart';

import '../../../../core/constants/others.dart';
import '../../../../core/constants/sizes.dart';
import '../widgets/todo_attachment_widget.dart';
import '../widgets/todo_bottom_actions.dart';
import '../widgets/todo_date_range_selector.dart';
import '../widgets/todo_edit_label_dialog.dart';
import '../widgets/todo_labels_grid.dart';
import '../widgets/todo_model.dart';
import '../widgets/todo_description_input.dart';
import '../widgets/todo_parent_task_selector.dart';
import '../widgets/todo_priority_selector.dart';
import '../widgets/todo_project_selector.dart';
import '../widgets/todo_recurrence_selector.dart';
import '../widgets/todo_title_input.dart';

class AddTodoPage extends StatefulWidget {
  const AddTodoPage({super.key});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  // Các state vẫn tạm giữ lại ở UI (Attachment, Label, Time, ParentTask, Priority)
  // Vì chưa có yêu cầu refactor các phần này
  List<MockFile> mockAttachments = [
    MockFile(name: "hinh_anh_loi.jpg", extension: "img", size: "2.5 MB"),
    MockFile(name: "yeu_cau_du_an.pdf", extension: "pdf", size: "1.2 MB"),
    MockFile(name: "ghi_chu_hop.docx", extension: "doc", size: "500 KB"),
  ];

  List<TodoLabelItem> labels = [
    TodoLabelItem(name: "Chưa đặt tên", color: const Color(0xFF1FC389)),
    TodoLabelItem(name: "Chưa đặt tên", color: const Color(0xFF8B5CF6)),
    TodoLabelItem(name: "Chưa đặt tên", color: const Color(0xFFEF4444)),
    TodoLabelItem(name: "Chưa đặt tên", color: const Color(0xFFF59E0B)),
    TodoLabelItem(name: "Chưa đặt tên", color: const Color(0xFF3B82F6)),
    TodoLabelItem(name: "Chưa đặt tên", color: const Color(0xFFEAB308)),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoFormCubit, TodoFormState>(
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
                      TodoTitleInput(),

                      const SizedBox(height: HEIGHT_SIZED_BOX_4 * 4),

                      const TodoDescriptionInput(),

                      const SizedBox(height: HEIGHT_SIZED_BOX_4 * 4),

                      TodoProjectSelector(),

                      const SizedBox(height: HEIGHT_SIZED_BOX_4 * 4),

                      if (hasProject) ...[
                        TodoParentTaskSelector(),

                        const SizedBox(height: HEIGHT_SIZED_BOX_4 * 4),
                      ] else ...[
                        TodoRecurrenceSelector(),

                        const SizedBox(height: HEIGHT_SIZED_BOX_4 * 4),
                      ],

                      TodoDateRangeSelector(),

                      const SizedBox(height: HEIGHT_SIZED_BOX_4 * 4),

                      if (isRecurring) ...[
                        TodoTimeSelector(),

                        const SizedBox(height: HEIGHT_SIZED_BOX_4 * 4),
                      ],

                      TodoPrioritySelector(),

                      const SizedBox(height: HEIGHT_SIZED_BOX_4 * 4),

                      // File đính kèm
                      TodoAttachmentWidget(
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
                      TodoLabelsGrid(
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
                                (ctx) => TodoEditLabelDialog(
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

              TodoBottomActions(
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
