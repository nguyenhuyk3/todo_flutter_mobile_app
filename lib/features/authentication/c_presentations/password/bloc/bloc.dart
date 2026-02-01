import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

part 'event.dart';
part 'state.dart';

class PasswordBloc extends Bloc<PasswordEvent, PasswordState> {
  PasswordBloc() : super(const PasswordInitial()) {
    on<PasswordToggleVisibility>(_onToggleVisibility);
  }

  FutureOr<void> _onToggleVisibility(
    PasswordToggleVisibility event,
    Emitter<PasswordState> emit,
  ) {
    emit(PasswordUpdatedVisibility(!state.obscureText));
  }
}
