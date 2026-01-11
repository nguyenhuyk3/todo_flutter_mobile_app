import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/constants/others.dart';
import '../../../../../../core/constants/sizes.dart';
import '../../bloc/bloc.dart';

class RegistrationSexSelection extends StatelessWidget {
  const RegistrationSexSelection({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Lấy giới tính hiện tại từ State
    final currentSex = context.select<RegistrationBloc, String>((bloc) {
      return bloc.state is RegistrationStepOne
          ? (bloc.state as RegistrationStepOne).sex
          : 'male';
    });
    // 2. Lấy trạng thái Loading
    final bool isLoading = context.select<RegistrationBloc, bool>((bloc) {
      final state = bloc.state;

      return state is RegistrationStepOne && state.isLoading;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSexOption(
              context: context,
              title: 'Nam',
              value: 'male',
              isSelected: currentSex == 'male',
              isLoading: isLoading,
            ),

            const SizedBox(width: X_MIN_WIDTH_SIZED_BOX * 4),

            _buildSexOption(
              context: context,
              title: 'Nữ',
              value: 'female',
              isSelected: currentSex == 'female',
              isLoading: isLoading,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSexOption({
    required BuildContext context,
    required String title,
    required String value,
    required bool isSelected,
    required bool isLoading,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap:
            isLoading
                ? null
                : () {
                  final state = context.read<RegistrationBloc>().state;

                  if (state is RegistrationStepOne) {
                    context.read<RegistrationBloc>().add(
                      RegistrationInformationChanged(
                        fullName: state.fullName,
                        birthDate: state.birthDate,
                        sex: value,
                      ),
                    );
                  }
                },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? COLORS.PRIMARY_APP_COLOR : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: COLORS.FOCUSED_BORDER_IP_COLOR,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: COLORS.PRIMARY_SHADOW_COLOR,
                offset: const Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isLoading ? Colors.white : COLORS.PRIMARY_TEXT_COLOR,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: TextSizes.TITLE_SMALL,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
