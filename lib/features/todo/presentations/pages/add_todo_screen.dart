import 'package:flutter/material.dart';

import '../../../../core/constants/others.dart';
import '../../../../core/constants/sizes.dart';
import '../widgets/todo_attachment_widget.dart';
import '../widgets/todo_bottom_actions.dart';
import '../widgets/todo_date_selector.dart';
import '../widgets/todo_edit_label_dialog.dart';
import '../widgets/todo_labels_grid.dart';
import '../widgets/todo_model.dart';
import '../widgets/todo_note_input.dart';
import '../widgets/todo_parent_task_selector.dart';
import '../widgets/todo_priority_selector.dart';
import '../widgets/todo_project_selector.dart';
import '../widgets/todo_recurrence_selector.dart';
import '../widgets/todo_title_input.dart';

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final TextEditingController _titleController = TextEditingController();
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
  final List<String> projects = [
    'Không',
    'Cá nhân',
    'Công việc',
    'Gia đình',
    'Học tập',
  ];
  String selectedProject = 'Không';
  String? selectedParentTask; // Null nghĩa là không chọn
  // Giả lập danh sách công việc có sẵn trong hệ thống để chọn làm cha
  final List<String> existingTasks = [
    'Thiết kế giao diện Mobile',
    'Phân tích cơ sở dữ liệu',
    'Họp Client giai đoạn 1',
    'Viết API đăng nhập',
    'Mua sắm thiết bị',
  ];

  // Độ ưu tiên
  String selectedPriority = 'Thấp'; // Mặc định thấp
  String selectedRecurrence = 'none';
  // Lịch (Start - End)
  DateTimeRange? selectedDateRange;

  // --- HÀM XỬ LÝ LỊCH ---
  Future<void> _pickDateRange() async {
    final DateTime now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      initialDateRange: selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              /*
              👉 Dùng cho:
                - Ngày được chọn
                - Thanh highlight
                - Range selection background
                - Action buttons (OK, CANCEL)
              */
              primary: COLORS.PRIMARY_APP,
              // 👉 Màu chữ/icon nằm trên nền primary
              onPrimary: COLORS.PRIMARY_TEXT,
              // 👉 Màu của khoảng range
              secondary: COLORS.PRIMARY_APP,
              onSecondary: COLORS.SECONDARY_TEXT,
              surface: COLORS.PRIMARY_BG,
              onSurface: COLORS.PRIMARY_TEXT,
            ),
            // dialogTheme: DialogThemeData(backgroundColor: Colors.red),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  // Tiêu đề
                  TodoTitleInput(controller: _titleController),

                  const SizedBox(height: HEIGHT_SIZED_BOX_4 * 4),

                  // Nội dung chi tiết
                  const TodoNoteInput(),

                  const SizedBox(height: HEIGHT_SIZED_BOX_4 * 4),

                  // Độ ưu tiên & Dự án (Để chung 1 dòng cho tiết kiệm diện tích nếu muốn, hoặc tách dòng)
                  TodoPrioritySelector(
                    selectedPriority: selectedPriority,
                    onChanged: (val) {
                      if (val != null) setState(() => selectedPriority = val);
                    },
                  ),

                  const SizedBox(height: HEIGHT_SIZED_BOX_4 * 4),

                  TodoProjectSelector(
                    selectedProject: selectedProject,
                    projects: projects,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          selectedProject = val;
                          // Nếu chọn lại "Không" -> Reset việc cha về null
                          if (val == 'Không') {
                            selectedParentTask = null;
                          }
                        });
                      }
                    },
                  ),

                  const SizedBox(height: HEIGHT_SIZED_BOX_4 * 4),

                  if (selectedProject != 'Không') ...[
                    // TRƯỜNG HỢP: Có dự án -> Chọn Parent Task
                    TodoParentTaskSelector(
                      selectedParentTask: selectedParentTask,
                      availableTasks: existingTasks,
                      onChanged: (val) {
                        setState(() {
                          selectedParentTask = val;
                        });
                      },
                    ),

                    const SizedBox(height: HEIGHT_SIZED_BOX_4 * 4),
                  ] else ...[
                    // TRƯỜNG HỢP: Dự án = Không (Việc cá nhân) -> Chọn Lặp lại
                    TodoRecurrenceSelector(
                      selectedRecurrence: selectedRecurrence,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            selectedRecurrence = val;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: HEIGHT_SIZED_BOX_4 * 4),
                  ],

                  // Lịch (Start & End)
                  TodoDateSelector(
                    selectedDateRange: selectedDateRange,
                    onTap: _pickDateRange,
                  ),

                  const SizedBox(height: HEIGHT_SIZED_BOX_4 * 4),

                  TodoAttachmentWidget(
                    files: mockAttachments,
                    onAddTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Tính năng chọn file sẽ phát triển sau!',
                          ),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    onDeleteTap: (index) {
                      // Xóa file khỏi list giả lập để tạo cảm giác thật
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
                        labels[index].isSelected = !labels[index].isSelected;
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

                  // Spacer
                  SizedBox(
                    height:
                        MediaQuery.of(context).viewInsets.bottom > 0 ? 300 : 20,
                  ),
                ],
              ),
            ),
          ),

          TodoBottomActions(
            onSave: () {},
            onClose: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
