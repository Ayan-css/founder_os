import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';

enum TimerStatus { idle, running, paused, completed }

class FocusTimerState {
  static const _total = AppConstants.focusDurationMinutes * 60;

  final TimerStatus status;
  final int remainingSeconds;
  final int totalSeconds;
  final int sessionsCompleted;

  const FocusTimerState({
    this.status = TimerStatus.idle,
    this.remainingSeconds = _total,
    this.totalSeconds = _total,
    this.sessionsCompleted = 0,
  });

  bool get isIdle => status == TimerStatus.idle;
  bool get isRunning => status == TimerStatus.running;
  bool get isPaused => status == TimerStatus.paused;
  bool get isCompleted => status == TimerStatus.completed;

  double get progress =>
      totalSeconds > 0 ? 1 - (remainingSeconds / totalSeconds) : 0;

  String get formattedTime {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  FocusTimerState copyWith({
    TimerStatus? status,
    int? remainingSeconds,
    int? sessionsCompleted,
  }) =>
      FocusTimerState(
        status: status ?? this.status,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        totalSeconds: totalSeconds,
        sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
      );
}

class FocusTimerNotifier extends StateNotifier<FocusTimerState> {
  Timer? _ticker;

  FocusTimerNotifier() : super(const FocusTimerState());

  void start() {
    if (state.isRunning) return;
    state = state.copyWith(status: TimerStatus.running);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void pause() {
    _ticker?.cancel();
    if (state.isRunning) state = state.copyWith(status: TimerStatus.paused);
  }

  void resume() {
    if (state.isPaused) start();
  }

  void reset() {
    _ticker?.cancel();
    state = FocusTimerState(sessionsCompleted: state.sessionsCompleted);
  }

  void _tick() {
    if (state.remainingSeconds <= 1) {
      _ticker?.cancel();
      state = state.copyWith(
        status: TimerStatus.completed,
        remainingSeconds: 0,
        sessionsCompleted: state.sessionsCompleted + 1,
      );
    } else {
      state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

final focusTimerProvider =
    StateNotifierProvider<FocusTimerNotifier, FocusTimerState>(
  (_) => FocusTimerNotifier(),
);
