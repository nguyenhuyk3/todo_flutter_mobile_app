part of 'bloc.dart';

sealed class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object> get props => [];
}

// 1. Load danh sách (có thể load theo projectId hoặc filters)
class TodoLoaded extends TodoEvent {
  final String? projectId;

  const TodoLoaded({this.projectId});
}

// 2. Thêm mới Todo
class TodoAdded extends TodoEvent {
  final AppTodo todo;
  const TodoAdded(this.todo);
}

// 3. Cập nhật nội dung (Edit, Change Priority...)
class TodoUpdated extends TodoEvent {
  final AppTodo todo;
  const TodoUpdated(this.todo);
}

// 4. Đánh dấu hoàn thành / Chuyển trạng thái nhanh
class TodoStatusChanged extends TodoEvent {
  final String id;
  final FormzSubmissionStatus status;

  const TodoStatusChanged({required this.id, required this.status});
}

// 5. Xóa Todo
class TodoDeleted extends TodoEvent {
  final String id;

  const TodoDeleted(this.id);
}
