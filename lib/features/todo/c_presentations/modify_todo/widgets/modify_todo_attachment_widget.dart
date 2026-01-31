import 'package:flutter/material.dart';

import '../../../../../core/constants/others.dart';
import '../../../../../core/constants/sizes.dart';
import '../../models/mock_file.dart';

class ModifyTodoAttachmentWidget extends StatefulWidget {
  // Đã bỏ hết các tham số truyền vào
  const ModifyTodoAttachmentWidget({super.key});

  @override
  State<ModifyTodoAttachmentWidget> createState() =>
      _ModifyTodoAttachmentWidgetState();
}

class _ModifyTodoAttachmentWidgetState
    extends State<ModifyTodoAttachmentWidget> {
  final List<MockFile> _files = [
    MockFile(name: "hinh_anh_loi.jpg", extension: "img", size: "2.5 MB"),
    MockFile(name: "yeu_cau_du_an.pdf", extension: "pdf", size: "1.2 MB"),
    MockFile(name: "ghi_chu_hop.docx", extension: "doc", size: "500 KB"),
  ];

  Widget _getFileIcon(String ext) {
    switch (ext) {
      case 'pdf':
        return const Icon(
          Icons.picture_as_pdf,
          color: Color(0xFFEF4444),
          size: IconSizes.ICON_28,
        );
      case 'doc':
      case 'docx':
        return const Icon(
          Icons.description,
          color: Color(0xFF3B82F6),
          size: IconSizes.ICON_28,
        );
      case 'img':
      case 'png':
      case 'jpg':
        return const Icon(
          Icons.image,
          color: Color(0xFF8B5CF6),
          size: IconSizes.ICON_28,
        );
      default:
        return const Icon(
          Icons.insert_drive_file,
          color: Colors.grey,
          size: IconSizes.ICON_28,
        );
    }
  }

  void _onAddTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng này sẽ phát triển sau!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _onDeleteTap(int index) {
    setState(() {
      _files.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
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
            offset: const Offset(0, 3), // Bóng cứng đổ xuống dưới
            blurRadius: 0, // Không làm mờ
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.attach_file,
                color: COLORS.ICON_PRIMARY,
                size: IconSizes.ICON_20,
              ),

              SizedBox(width: WIDTH_SIZED_BOX_4),

              Text(
                "Tệp đính kèm:",
                style: TextStyle(
                  color: COLORS.SECONDARY_TEXT,
                  fontWeight: FontWeight.bold,
                  fontSize: TextSizes.TITLE_14,
                ),
              ),
            ],
          ),

          const SizedBox(height: HEIGTH_SIZED_BOX_12),

          SizedBox(
            height: 70, // Chiều cao cố định cho list ngang
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              // Dùng _files nội bộ
              itemCount: _files.length + 1, // +1 cho nút Thêm
              separatorBuilder:
                  (context, index) =>
                      const SizedBox(width: WIDTH_SIZED_BOX_4 * 2),
              itemBuilder: (context, index) {
                // Item đầu tiên là nút Thêm
                if (index == 0) {
                  return GestureDetector(
                    onTap: _onAddTap, // Gọi hàm nội bộ
                    child: Container(
                      width: 70,
                      decoration: BoxDecoration(
                        color: COLORS.SECONDARY_BG,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: COLORS.UNFOCUSED_BORDER_IP,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Icon(Icons.add, color: COLORS.ICON_PRIMARY),
                    ),
                  );
                }

                // Các Item file (Index - 1 vì trừ đi nút thêm)
                final file = _files[index - 1];

                return Container(
                  width: 180,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: COLORS.SECONDARY_BG,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // Icon File
                      _getFileIcon(file.extension),

                      const SizedBox(width: WIDTH_SIZED_BOX_4 * 1.5),
                      // Thông tin tên + Size
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              file.name,
                              style: TextStyle(
                                color: COLORS.PRIMARY_TEXT,
                                fontSize: TextSizes.TITLE_14,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),

                            Text(
                              file.size,
                              style: TextStyle(
                                color: COLORS.SECONDARY_TEXT,
                                fontSize: TextSizes.TITLE_12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: WIDTH_SIZED_BOX_4),
                      // Nút Xóa
                      GestureDetector(
                        // Gọi hàm nội bộ xóa phần tử tương ứng
                        onTap: () => _onDeleteTap(index - 1),
                        child: Icon(
                          Icons.close,
                          size: IconSizes.ICON_16,
                          color: COLORS.ICON_PRIMARY,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
