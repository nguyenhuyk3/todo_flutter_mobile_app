import 'package:flutter/material.dart';
import 'package:todo_flutter_mobile_app/features/todo/presentations/widgets/odo_title_input.dart';
import 'package:todo_flutter_mobile_app/features/todo/presentations/widgets/todo_bottom_actions.dart';
import 'package:todo_flutter_mobile_app/features/todo/presentations/widgets/todo_date_selector.dart';
import 'package:todo_flutter_mobile_app/features/todo/presentations/widgets/todo_labels_grid.dart';
import 'package:todo_flutter_mobile_app/features/todo/presentations/widgets/todo_model.dart';
import 'package:todo_flutter_mobile_app/features/todo/presentations/widgets/todo_note_input.dart';
import 'package:todo_flutter_mobile_app/features/todo/presentations/widgets/todo_parent_task_selector.dart';
import 'package:todo_flutter_mobile_app/features/todo/presentations/widgets/todo_priority_selector.dart';
import 'package:todo_flutter_mobile_app/features/todo/presentations/widgets/todo_project_selector.dart';
import 'package:todo_flutter_mobile_app/features/todo/presentations/widgets/todo_recurrence_selector.dart';

// Dialog chỉnh sửa Label giữ nguyên như cũ hoặc tách file riêng
class TodoEditLabelDialog extends StatelessWidget {
  final TodoLabelItem label;
  final Function(String) onSave;

  const TodoEditLabelDialog({
    super.key,
    required this.label,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController textController = TextEditingController();
    return Dialog(
      backgroundColor: const Color(0xFF242936),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Chỉnh sửa nhãn',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, color: Colors.grey, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF5B718F)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: label.color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: textController,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Nhập tên nhãn...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF353A47),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Hủy',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (textController.text.isNotEmpty) {
                        onSave(textController.text);
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22D3EE),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Lưu',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  // --- STATES ---
  final TextEditingController _titleController = TextEditingController();

  // Dữ liệu Nhãn
  List<TodoLabelItem> labels = [
    TodoLabelItem(name: "Chưa đặt tên", color: const Color(0xFF1FC389)),
    TodoLabelItem(name: "Chưa đặt tên", color: const Color(0xFF8B5CF6)),
    TodoLabelItem(name: "Chưa đặt tên", color: const Color(0xFFEF4444)),
    TodoLabelItem(name: "Chưa đặt tên", color: const Color(0xFFF59E0B)),
    TodoLabelItem(name: "Chưa đặt tên", color: const Color(0xFF3B82F6)),
    TodoLabelItem(name: "Chưa đặt tên", color: const Color(0xFFEAB308)),
  ];

  // Dự án
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
        // Tùy chỉnh màu sắc lịch cho hợp Dark Mode
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF22D3EE), // Màu chủ đạo (Xanh Cyan)
              onPrimary: Colors.black,
              surface: Color(0xFF242936),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF242936),
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
      backgroundColor: const Color(0xFF13151C),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: const Color(0xFF13151C),
        elevation: 0,
        title: const Text(
          'Thêm Todo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
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
                  // 1. Tiêu đề
                  TodoTitleInput(controller: _titleController),
                  const SizedBox(height: 16),

                  // 2. Nội dung chi tiết
                  const TodoNoteInput(),
                  const SizedBox(height: 16),

                  // 3. Hàng ngang: Độ ưu tiên & Dự án (Để chung 1 dòng cho tiết kiệm diện tích nếu muốn, hoặc tách dòng)
                  // Ở đây mình tách dòng như UI gốc cho thoáng
                  TodoPrioritySelector(
                    selectedPriority: selectedPriority,
                    onChanged: (val) {
                      if (val != null) setState(() => selectedPriority = val);
                    },
                  ),
                  const SizedBox(height: 16),

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
                  const SizedBox(height: 16),

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
                    const SizedBox(height: 16),
                  ] else ...[
                    // TRƯỜNG HỢP: Dự án = Không (Việc cá nhân) -> Chọn Lặp lại
                    TodoRecurrenceSelector(
                      selectedRecurrence: selectedRecurrence,
                      onChanged: (val) {
                        if (val != null)
                          setState(() {
                            selectedRecurrence = val;
                          });
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 4. Lịch (Start & End)
                  TodoDateSelector(
                    selectedDateRange: selectedDateRange,
                    onTap: _pickDateRange,
                  ),
                  const SizedBox(height: 16),

                  // 5. Grid Nhãn
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
            onSave: () {
              print("Title: ${_titleController.text}");
              print("Project: $selectedProject");
              print("Priority: $selectedPriority");
              print("Dates: $selectedDateRange");
            },
            onClose: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
