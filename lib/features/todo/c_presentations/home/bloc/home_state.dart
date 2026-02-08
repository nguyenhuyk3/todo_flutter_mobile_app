part of 'home_bloc.dart';

class HomeState extends Equatable {
  final FormzSubmissionStatus status;
  final TodoEntity? todo;
  final String? error;

  const HomeState({
    this.status = FormzSubmissionStatus.initial,
    this.todo,
    this.error,
  });

  HomeState copyWith({
    FormzSubmissionStatus? status,
    TodoEntity? todo,
    String? error,
  }) {
    return HomeState(
      status: status ?? this.status,
      todo: todo ?? this.todo,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, todo, error];
}
