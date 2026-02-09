import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/others.dart';
import '../../../../../core/constants/sizes.dart';
import '../../models/label_item.dart';
import '../cubit/tag/modify_tag_cubit.dart';
import '../cubit/tag/modify_tag_state.dart';
import '../cubit/todo/modify_todo_form_cubit.dart';

import 'dialog/modify_todo_edit_label_dialog.dart';
import 'modify_todo_label_item.dart';

class ModifyTodoLabelsGrid extends StatelessWidget {
  const ModifyTodoLabelsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ModifyTagCubit, ModifyTagState>(
      builder: (context, labelState) {
        // Các attributes trong state
        final labels = labelState.labels;
        final isLoading = labelState.isLoading;
        final error = labelState.error;

        return BlocBuilder<ModifyTodoFormCubit, ModifyTodoFormState>(
          buildWhen: (prev, curr) => prev.selectedTagIds != curr.selectedTagIds,
          builder: (context, todoFormState) {
            // Lấy ra các tag ids đã chọn
            final selectedTagIds = todoFormState.selectedTagIds;
            final labelsWithSelection =
                labels
                    .map(
                      (l) => LabelItem(
                        id: l.id,
                        name: l.name,
                        color: l.color,
                        isSelected:
                            l.id != null && selectedTagIds.contains(l.id),
                      ),
                    )
                    .toList();

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
                    offset: const Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.local_offer_outlined,
                        color: COLORS.ICON_PRIMARY,
                        size: IconSizes.ICON_20,
                      ),

                      SizedBox(width: WIDTH_SIZED_BOX_4),

                      Text(
                        "Nhãn",
                        style: TextStyle(
                          color: COLORS.SECONDARY_TEXT,
                          fontWeight: FontWeight.bold,
                          fontSize: TextSizes.TITLE_14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: HEIGTH_SIZED_BOX_12),

                  if (isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: COLORS.PRIMARY,
                          backgroundColor: COLORS.PRIMARY_BG,
                        ),
                      ),
                    )
                  else if (error != null && error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          error,
                          style: TextStyle(
                            color: COLORS.ERROR,
                            fontSize: TextSizes.TITLE_18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  else if (labelsWithSelection.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Chưa có nhãn. Nhãn được tạo khi bạn đăng ký',
                        style: TextStyle(
                          color: COLORS.ERROR,
                          fontSize: TextSizes.TITLE_18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: labelsWithSelection.length,
                      // Quy định cách chia layout dạng lưới
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        // Số cột cố định trên trục ngang
                        // = 2 → mỗi hàng có 2 item
                        // Tăng số này → item nhỏ lại
                        crossAxisCount: 2,
                        // Tỉ lệ rộng : cao của mỗi item
                        // = width / height
                        // 3.5 → item rộng gấp 3.5 lần chiều cao (dạng chip/tag)
                        // < 1 → item cao hơn rộng
                        childAspectRatio: 3.5,
                        // Khoảng cách giữa các cột (theo chiều ngang)
                        // Tác động trực tiếp đến khoảng trống trái/phải giữa item
                        crossAxisSpacing: 10,
                        // Khoảng cách giữa các hàng (theo chiều dọc)
                        // Tạo khoảng cách trên/dưới giữa các item
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        final item = labelsWithSelection[index];

                        return ModifyTodoLabelItemWidget(
                          item: item,
                          onTap: () {
                            if (item.id == null) {
                              return;
                            }
                            // Thêm id vừa nhấn vào vào list
                            final next =
                                selectedTagIds.contains(item.id)
                                    ? selectedTagIds
                                        .where((id) => id != item.id)
                                        .toList()
                                    : [...selectedTagIds, item.id!];
                            context.read<ModifyTodoFormCubit>().tagIdsChanged(
                              next,
                            );
                          },
                          onEditTap: () {
                            if (item.id == null) {
                              return;
                            }

                            showDialog(
                              context: context,
                              builder:
                                  (ctx) => ModifyTodoEditLabelDialog(
                                    label: item,
                                    onSave: (newName, newColor) {
                                      context.read<ModifyTagCubit>().updateTag(
                                        tagId: item.id!,
                                        newName: newName,
                                        newColor: newColor,
                                      );
                                    },
                                  ),
                            );
                          },
                        );
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
