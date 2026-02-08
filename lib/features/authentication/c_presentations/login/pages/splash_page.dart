import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../../core/constants/others.dart';
import '../../../../todo/c_presentations/modify_todo/pages/modify_todo_screen.dart';
import '../bloc/bloc.dart';

import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    context.read<LoginBloc>().add(const LoginAutoLoginStarted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status.isSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ModifyTodoPage()),
          );
        } else if (state.status.isFailure) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: COLORS.PRIMARY,
                backgroundColor: COLORS.PRIMARY_BG,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
