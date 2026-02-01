import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/widgets/primary_button.dart';
import '../../bloc/bloc.dart';

class RegistrationOtpSubmitButton extends StatelessWidget {
  const RegistrationOtpSubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      buildWhen: (previous, current) {
        if (previous is RegistrationStepTwo && current is RegistrationStepTwo) {
          return previous.isLoading != current.isLoading;
        }

        return false;
      },
      builder: (context, state) {
        final isLoading = state is RegistrationStepTwo && state.isLoading;

        return PrimaryButton(
          title: 'Xác nhận',
          isLoading: isLoading,
          onPressed:
              isLoading
                  ? null
                  : () => context.read<RegistrationBloc>().add(
                    RegistrationOtpSubmitted(),
                  ),
        );
      },
    );
  }
}
