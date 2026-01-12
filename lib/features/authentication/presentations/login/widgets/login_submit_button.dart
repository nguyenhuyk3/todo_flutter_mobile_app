import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../../../core/widgets/primary_button.dart';
import '../bloc/bloc.dart';

class LoginSubmitButton extends StatelessWidget {
  const LoginSubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen:
          (prev, curr) =>
              curr.status == FormzSubmissionStatus.inProgress ||
              prev.status == FormzSubmissionStatus.inProgress,
      builder: (context, state) {
        return PrimaryButton(
          title: 'Đăng nhập',
          isLoading: state.status == FormzSubmissionStatus.inProgress,
          onPressed: () {
            context.read<LoginBloc>().add(const LoginSubmitted());
          },
        );
      },
    );
  }
}
