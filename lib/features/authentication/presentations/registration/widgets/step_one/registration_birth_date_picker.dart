import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/constants/others.dart';
import '../../../../../../core/constants/sizes.dart';
import '../../bloc/bloc.dart';

class RegistrationBirthDatePicker extends StatelessWidget {
  const RegistrationBirthDatePicker({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Lấy dữ liệu ngày sinh
    final birthDateStr = context.select<RegistrationBloc, String>((bloc) {
      final state = bloc.state;

      return state is RegistrationStepOne ? state.birthDate : '';
    });
    // 2. Lấy trạng thái Loading
    final bool isLoading = context.select<RegistrationBloc, bool>((bloc) {
      final state = bloc.state;

      return state is RegistrationStepOne && state.isLoading;
    });
    // 3. Logic xử lý hiển thị ngày
    final effectiveDate =
        birthDateStr.isNotEmpty
            ? DateTime.parse(birthDateStr)
            : DateTime(2000, 1, 1);
    final formattedDate =
        "${effectiveDate.day.toString().padLeft(2, '0')}/"
        "${effectiveDate.month.toString().padLeft(2, '0')}/"
        "${effectiveDate.year}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Widget bấm để chọn ngày
        InkWell(
          onTap:
              isLoading
                  ? null
                  : () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: effectiveDate,
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                    );

                    if (picked != null) {
                      if (!context.mounted) {
                        return;
                      }

                      final currentState =
                          context.read<RegistrationBloc>().state;

                      if (currentState is RegistrationStepOne) {
                        context.read<RegistrationBloc>().add(
                          RegistrationInformationChanged(
                            fullName: currentState.fullName,
                            birthDate: picked.toIso8601String(),
                            sex: currentState.sex,
                          ),
                        );
                      }
                    }
                  },
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              // Viền đen cứng
              border: Border.all(color: COLORS.FOCUSED_BORDER_IP, width: 1),
              boxShadow: [
                BoxShadow(
                  color: COLORS.PRIMARY_SHADOW,
                  offset: Offset(0, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  color: isLoading ? Colors.grey.shade400 : Colors.black,
                ),

                const SizedBox(width: WIDTH_SIZED_BOX_4 * 3),

                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: TextSizes.TITLE_16,
                    fontWeight: FontWeight.w700,
                    // Màu chữ: Nếu loading -> mờ, chưa chọn -> hint, đã chọn -> đen đậm
                    color:
                        isLoading ? COLORS.SECONDARY_TEXT : COLORS.PRIMARY_TEXT,
                  ),
                ),

                const Spacer(),

                // Logic Icon:
                // isLoading -> Ẩn (trả về Empty Widget hoặc null)
                // !isLoading -> Icon Dropdown
                if (!isLoading)
                  Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
