import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../a_domain/entities/todo_entity.dart';
import '../../../a_domain/usecases/todo_use_case.dart';
import '../../../b_data/models/todo_model.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AddTodoUseCase _addTodoUseCase;

  HomeBloc({required AddTodoUseCase addTodoUseCase})
    : _addTodoUseCase = addTodoUseCase,
      super(const HomeState()) {
    // on<HomeLoaded>(_onLoaded);
    on<HomeTodoAdded>(_onTodoAdded);
    // on<HomeTodoUpdated>(_onTodoUpdated);
    // on<HomeItemStatusChanged>(_onStatusChanged);
    // on<HomeTodoDeleted>(_onTodoDeleted);
  }

  // Future<void> _onLoaded(HomeLoaded event, Emitter<HomeState> emit) async {
  //   // emit(state.copyWith(status: HomeStatusLoading.loading));
  //   // try {
  //   //   final Homes = await _HomeRepository.getHomes(projectId: event.projectId);
  //   //   emit(state.copyWith(status: HomeStatusLoading.success, Homes: Homes));
  //   // } catch (e) {
  //   //   emit(
  //   //     state.copyWith(
  //   //       status: HomeStatusLoading.failure,
  //   //       errorMessage: e.toString(),
  //   //     ),
  //   //   );
  //   // }
  // }

  Future<void> _onTodoAdded(
    HomeTodoAdded event,
    Emitter<HomeState> emit,
  ) async {
    final addHomeResult = await _addTodoUseCase.execute(todo: event.todo);

    addHomeResult.fold(
      (failure) {
        emit(state.copyWith(status: FormzSubmissionStatus.failure));
      },
      (_) {
        emit(state.copyWith(status: FormzSubmissionStatus.success));
      },
    );
  }

  // Future<void> _onTodoUpdated(HomeTodoUpdated event, Emitter<HomeState> emit) async {
  //   // try {
  //   //   await _HomeRepository.updateHome(event.Home);

  //   //   // Update List trong bộ nhớ cục bộ thay vì fetch lại API (tối ưu performance)
  //   //   final updatedList =
  //   //       state.Homes.map((t) {
  //   //         return t.id == event.Home.id ? event.Home : t;
  //   //       }).toList();

  //   //   emit(
  //   //     state.copyWith(status: HomeStatusLoading.success, Homes: updatedList),
  //   //   );
  //   // } catch (e) {
  //   //   emit(
  //   //     state.copyWith(
  //   //       status: HomeStatusLoading.failure,
  //   //       errorMessage: e.toString(),
  //   //     ),
  //   //   );
  //   // }
  // }

  // Future<void> _onStatusChanged(
  //   HomeStatusChanged event,
  //   Emitter<HomeState> emit,
  // ) async {
  //   // try {
  //   //   // Tìm Home hiện tại
  //   //   final index = state.Homes.indexWhere((t) => t.id == event.id);
  //   //   if (index == -1) return;

  //   //   final currentHome = state.Homes[index];
  //   //   final updatedHome = currentHome.copyWith(
  //   //     status: event.status,
  //   //     completedAt:
  //   //         event.status == HomeStatus.completed
  //   //             ? DateTime.now()
  //   //             : null, // Logic set completed_at
  //   //   );

  //   //   await _HomeRepository.updateHome(updatedHome);

  //   //   // Update State
  //   //   final updatedList = List<Home>.from(state.Homes);
  //   //   updatedList[index] = updatedHome;

  //   //   emit(
  //   //     state.copyWith(status: HomeStatusLoading.success, Homes: updatedList),
  //   //   );
  //   // } catch (e) {
  //   //   emit(
  //   //     state.copyWith(
  //   //       status: HomeStatusLoading.failure,
  //   //       errorMessage: e.toString(),
  //   //     ),
  //   //   );
  //   // }
  // }

  // Future<void> _onDeleted(HomeDeleted event, Emitter<HomeState> emit) async {
  //   // try {
  //   //   await _HomeRepository.deleteHome(event.id);

  //   //   // Xóa khỏi list hiện tại
  //   //   final updatedList = state.Homes.where((t) => t.id != event.id).toList();

  //   //   emit(
  //   //     state.copyWith(status: HomeStatusLoading.success, Homes: updatedList),
  //   //   );
  //   // } catch (e) {
  //   //   emit(
  //   //     state.copyWith(
  //   //       status: HomeStatusLoading.failure,
  //   //       errorMessage: e.toString(),
  //   //     ),
  //   //   );
  //   // }
  // }
}
