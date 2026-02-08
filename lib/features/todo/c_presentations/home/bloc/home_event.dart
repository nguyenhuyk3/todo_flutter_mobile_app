part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// 1. Load danh sách todo theo project (nếu có)
/// Trigger khi:
/// - mở màn hình
/// - refresh
/// - đổi project
class HomeLoaded extends HomeEvent {
  final String? projectId;

  const HomeLoaded({this.projectId});

  @override
  List<Object?> get props => [projectId];
}

/// 2. Thêm mới item
/// Truyền full model để Bloc xử lý insert
class HomeTodoAdded extends HomeEvent {
  final TodoModel todo;

  const HomeTodoAdded({required this.todo});

  @override
  List<Object?> get props => [todo];
}

/// 3. Cập nhật item
/// Sử dụng entity (domain layer) thay vì model (data layer)
/// → giảm coupling với datasource
class HomeTodoUpdated extends HomeEvent {
  final TodoEntity todo;

  const HomeTodoUpdated({required this.todo});

  @override
  List<Object?> get props => [todo];
}

/// 4. Đổi trạng thái (complete / processing / failed)
/// Chỉ truyền id + status để tránh gửi cả object lớn
class HomeItemStatusChanged extends HomeEvent {
  final String id;
  final FormzSubmissionStatus status;

  const HomeItemStatusChanged({required this.id, required this.status});

  @override
  List<Object?> get props => [id, status];
}

/// 5. Xóa item
class HomeTodoDeleted extends HomeEvent {
  final String id;

  const HomeTodoDeleted({required this.id});

  @override
  List<Object?> get props => [id];
}
