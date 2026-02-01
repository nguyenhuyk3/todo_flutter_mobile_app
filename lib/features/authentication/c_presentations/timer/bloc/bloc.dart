import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/others.dart';
import '../../../../../core/utils/ticker.dart';

part 'event.dart';
part 'state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Ticker _ticker;

  StreamSubscription<int>? _tickerSubscription;

  TimerBloc({required Ticker ticker})
    : _ticker = ticker,
      super(TimerInitial(TIME_FOR_RESENDING_MAIL)) {
    on<TimerStarted>(_onStarted);
    on<_TimerTicked>(_onTicked);
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();

    return super.close();
  }

  Future<void> _onStarted(TimerStarted event, Emitter<TimerState> emit) async {
    emit(TimerRunInProgress(event.duration));
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker
        .tick(ticks: event.duration)
        .listen((duration) => add(_TimerTicked(duration: duration)));
  }
}

void _onTicked(_TimerTicked event, Emitter<TimerState> emit) {
  emit(
    event.duration > 0
        ? TimerRunInProgress(event.duration)
        : TimerRunComplete(),
  );
}
