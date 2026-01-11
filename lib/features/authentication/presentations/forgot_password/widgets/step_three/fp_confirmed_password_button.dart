import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/widgets/primary_button.dart';
import '../../bloc/bloc.dart';

class FPConfirmedPasswordButton extends StatelessWidget {
  const FPConfirmedPasswordButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ForgotPasswordBloc, ForgotPasswordState, bool>(
      selector: (state) => state is ForgotPasswordStepThree && state.isLoading,
      builder: (context, isLoading) {
        return PrimaryButton(
          title: 'Xác nhận',
          isLoading: isLoading,
          onPressed:
              isLoading
                  ? null
                  : () {
                    context.read<ForgotPasswordBloc>().add(
                      ForgotPasswordSubmitted(),
                    );
                  },
        );
      },
    );
  }
}
