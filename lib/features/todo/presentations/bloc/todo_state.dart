part of 'todo_bloc.dart';

class TodoState extends Equatable {
  final FormzSubmissionStatus status;
  final AppTodo? todo;
  final String? error;

  const TodoState({
    this.status = FormzSubmissionStatus.initial,
    this.todo,
    this.error,
  });

  TodoState copyWith({
    FormzSubmissionStatus? status,
    AppTodo? todo,
    String? error,
  }) {
    return TodoState(
      status: status ?? this.status,
      todo: todo ?? this.todo,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, todo, error];
}
