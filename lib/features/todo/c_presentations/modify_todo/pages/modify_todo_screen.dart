import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../../core/constants/others.dart';
import '../../../../../core/constants/sizes.dart';
import '../../../../../core/utils/toats.dart';
import '../../../../home/presentations/home_page.dart';
import '../../../a_domain/entities/enums.dart';
import '../../../a_domain/repositories/tag.dart';
import '../../../a_domain/usecases/tag_use_case.dart';
import '../../home/bloc/home_bloc.dart';
import '../cubit/label/modify_labels_cubit.dart';
import '../cubit/todo/modify_todo_form_cubit.dart';
import '../widgets/modify_todo_bottom_actions.dart';
import '../widgets/modify_todo_date_range_selector.dart';
import '../widgets/modify_todo_description_input.dart';
import '../widgets/modify_todo_labels_grid.dart';
import '../widgets/modify_todo_priority_selector.dart';
import '../widgets/modify_todo_recurrence_selector.dart';
import '../widgets/modify_todo_time_selector.dart';
import '../widgets/modify_todo_title_input.dart';

class ModifyTodoPage extends StatefulWidget {
  const ModifyTodoPage({super.key});

  @override
  State<ModifyTodoPage> createState() => _ModifyTodoPageState();
}

class _ModifyTodoPageState extends State<ModifyTodoPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final repo = context.read<ITagRepository>();

        return ModifyLabelCubit(
          getTagsByUserIdUseCase: GetTagsByUserIdUseCase(tagRepository: repo),
          updateTagUseCase: UpdateTagUseCase(tagRepository: repo),
        )..loadTags();
      },
      child: BlocBuilder<ModifyTodoFormCubit, ModifyTodoFormState>(
        builder: (context, state) {
          // final bool hasProject = state.projectId != null;
          final bool isRecurring =
              state.recurrencePattern != RecurrencePattern.once;
          // Kiểm tra xem khoảng thời gian đã được chọn hợp lệ chưa
          final bool isDateRangeValid = state.isRangeDateValid;

          return BlocConsumer<HomeBloc, HomeState>(
            listener: (context, state) {
              if (state.status == FormzSubmissionStatus.success) {
                ToastUtils.showSuccess(
                  context: context,
                  message: "Thêm việc thành công",
                );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => HomePage()),
                );
              } else if (state.status == FormzSubmissionStatus.failure) {
                ToastUtils.showError(
                  context: context,
                  message: "Thêm việc thất bại",
                );
              }
            },
            buildWhen: (previous, current) => previous.status != current.status,
            builder: (context, homeState) {
              final isLoading =
                  homeState.status == FormzSubmissionStatus.inProgress;
              
              return Stack(
                children: [
                  Scaffold(
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
                    body: GestureDetector(
                      behavior:
                          HitTestBehavior
                              .opaque, // Đảm bảo bắt được sự kiện tap ở cả chỗ trống
                      onTap: () {
                        FocusScope.of(
                          context,
                        ).unfocus(); // Tắt bàn phím khi bấm vào vùng trống
                      },
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Column(
                                children: [
                                  ModifyTodoTitleInput(),

                                  const SizedBox(
                                    height: HEIGHT_SIZED_BOX_4 * 4,
                                  ),

                                  const ModifyTodoDescriptionInput(),

                                  const SizedBox(
                                    height: HEIGHT_SIZED_BOX_4 * 4,
                                  ),

                                  // ModifyTodoProjectSelector(),
                                  const SizedBox(
                                    height: HEIGHT_SIZED_BOX_4 * 4,
                                  ),

                                  // Nếu có Project -> Chỉ hiển thị Task cha, KHÔNG hiển thị Lặp lại
                                  // if (hasProject) ...[
                                  //   ModifyTodoParentTaskSelector(),

                                  //   const SizedBox(height: HEIGHT_SIZED_BOX_4 * 4),
                                  // ],

                                  // Hiển thị chọn Ngày TRƯỚC
                                  ModifyTodoDateRangeSelector(),

                                  const SizedBox(
                                    height: HEIGHT_SIZED_BOX_4 * 4,
                                  ),

                                  // YÊU CẦU: Chỉ hiển thị Lặp lại KHI đã chọn khoảng ngày hợp lệ
                                  if (isDateRangeValid) ...[
                                    ModifyTodoRecurrenceSelector(),

                                    const SizedBox(
                                      height: HEIGHT_SIZED_BOX_4 * 4,
                                    ),
                                  ],

                                  // Hiển thị chọn Giờ nếu đang bật chế độ Lặp lại
                                  if (isRecurring) ...[
                                    ModifyTodoTimeSelector(),

                                    const SizedBox(
                                      height: HEIGHT_SIZED_BOX_4 * 4,
                                    ),
                                  ],

                                  ModifyTodoPrioritySelector(),

                                  const SizedBox(
                                    height: HEIGHT_SIZED_BOX_4 * 4,
                                  ),

                                  // ModifyTodoAttachmentWidget(),

                                  // const SizedBox(height: HEIGHT_SIZED_BOX_4 * 4),
                                  //
                                  ModifyTodoLabelsGrid(),

                                  SizedBox(
                                    height:
                                        MediaQuery.of(
                                                  context,
                                                ).viewInsets.bottom >
                                                0
                                            ? 300
                                            : 20,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          ModifyTodoBottomActions(),
                        ],
                      ),
                    ),
                  ),

                  if (isLoading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black54,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: COLORS.PRIMARY,
                            backgroundColor: COLORS.PRIMARY_BG,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
