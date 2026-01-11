part of 'bloc.dart';

sealed class PasswordState {
  const PasswordState(this.obscureText);

  final bool obscureText;
}

class PasswordInitial extends PasswordState {
  const PasswordInitial() : super(true);
}

class PasswordUpdatedVisibility extends PasswordState {
  const PasswordUpdatedVisibility(super.obscureText);
}
