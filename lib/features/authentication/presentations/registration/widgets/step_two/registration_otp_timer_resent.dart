import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/constants/others.dart';
import '../../../../../../core/constants/sizes.dart';
import '../../../../../../core/utils/ticker.dart';
import '../../bloc/bloc.dart';
import '../../../timer/bloc/bloc.dart';

class RegistrationOtpTimerResend extends StatelessWidget {
  const RegistrationOtpTimerResend({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              TimerBloc(ticker: const Ticker())
                ..add(const TimerStarted(duration: TIME_FOR_RESENDING_MAIL)),
      child: BlocBuilder<TimerBloc, TimerState>(
        builder: (context, state) {
          final isCompleted = state is TimerRunComplete;
          final minutesStr = ((state.duration / 60) % 60)
              .floor()
              .toString()
              .padLeft(2, '0');
          final secondsStr = (state.duration % 60).floor().toString().padLeft(
            2,
            '0',
          );

          return Center(
            child: GestureDetector(
              onTap:
                  isCompleted
                      ? () => {
                        context.read<TimerBloc>().add(
                          const TimerStarted(duration: TIME_FOR_RESENDING_MAIL),
                        ),
                        context.read<RegistrationBloc>().add(
                          RegistrationResendOTPRequested(),
                        ),
                      }
                      : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isCompleted ? 'Gửi lại mã' : 'Gửi lại mã sau ',
                    style: TextStyle(
                      color:
                          isCompleted
                              ? COLORS.PRIMARY_BUTTON
                              : COLORS.PRIMARY_TEXT,
                      fontWeight: FontWeight.bold,
                      fontSize: TextSizes.TITLE_14,
                    ),
                  ),
                  if (!isCompleted)
                    Text(
                      '$minutesStr:$secondsStr',
                      style: TextStyle(
                        color: COLORS.PRIMARY_TEXT,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
