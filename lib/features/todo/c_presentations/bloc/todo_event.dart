part of 'todo_bloc.dart';

sealed class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object?> get props => [];
}

/// 1. Load danh sách
class TodoLoaded extends TodoEvent {
  final String? projectId;

  const TodoLoaded({this.projectId});

  @override
  List<Object?> get props => [projectId];
}

/// 2. Thêm mới Todo
class TodoAdded extends TodoEvent {
  final TodoModel todo;

  const TodoAdded({required this.todo});

  @override
  List<Object?> get props => [todo];
}

/// 3. Cập nhật Todo
class TodoUpdated extends TodoEvent {
  final TodoEntity todo;

  const TodoUpdated({required this.todo});

  @override
  List<Object?> get props => [todo];
}

/// 4. Đổi trạng thái
class TodoStatusChanged extends TodoEvent {
  final String id;
  final FormzSubmissionStatus status;

  const TodoStatusChanged({required this.id, required this.status});

  @override
  List<Object?> get props => [id, status];
}

/// 5. Xóa Todo
class TodoDeleted extends TodoEvent {
  final String id;

  const TodoDeleted({required this.id});

  @override
  List<Object?> get props => [id];
}
