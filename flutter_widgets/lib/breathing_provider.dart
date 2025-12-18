import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models.dart';

enum BreathPhase { inhale, hold, exhale }

class BreathingState {
  final BreathPhase phase;
  final String label;
  final String subLabel;
  final Duration duration;
  final BreathingPattern pattern;
  final int remainingSeconds;
  final bool isPlaying;
  final Duration sessionDuration;

  const BreathingState({
    required this.phase,
    required this.label,
    required this.subLabel,
    required this.duration,
    required this.pattern,
    required this.remainingSeconds,
    this.isPlaying = false,
    this.sessionDuration = Duration.zero,
  });

  BreathingState copyWith({
    BreathPhase? phase,
    String? label,
    String? subLabel,
    Duration? duration,
    BreathingPattern? pattern,
    int? remainingSeconds,
    bool? isPlaying,
    Duration? sessionDuration,
  }) {
    return BreathingState(
      phase: phase ?? this.phase,
      label: label ?? this.label,
      subLabel: subLabel ?? this.subLabel,
      duration: duration ?? this.duration,
      pattern: pattern ?? this.pattern,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isPlaying: isPlaying ?? this.isPlaying,
      sessionDuration: sessionDuration ?? this.sessionDuration,
    );
  }
}

class BreathingNotifier extends StateNotifier<BreathingState> {
  Timer? _timer;

  BreathingNotifier()
      : super(
          BreathingState(
            phase: BreathPhase.inhale,
            label: "Inspire",
            subLabel: "Profundamente pelo nariz",
            duration: const Duration(seconds: 4),
            pattern: defaultPatterns[0],
            remainingSeconds: 4,
            isPlaying: false,
            sessionDuration: Duration.zero,
          ),
        ) {
    _initPattern();
  }

  void setPattern(BreathingPattern newPattern) {
    state = state.copyWith(pattern: newPattern);
    _initPattern();
  }

  void _initPattern() {
    _timer?.cancel();
    state = state.copyWith(
      phase: BreathPhase.inhale,
      label: "Inspire",
      subLabel: "Profundamente pelo nariz",
      duration: state.pattern.inhaleDuration,
      remainingSeconds: state.pattern.inhaleDuration.inSeconds,
      isPlaying: false,
      sessionDuration: Duration.zero,
    );
  }

  void togglePlayPause() {
    if (state.isPlaying) {
      _pause();
    } else {
      _play();
    }
  }

  void _play() {
    state = state.copyWith(isPlaying: true);
    _scheduleTick();
  }

  void _pause() {
    state = state.copyWith(isPlaying: false);
    _timer?.cancel();
  }

  void resetSession() {
    _initPattern();
  }

  void _scheduleTick() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.isPlaying) {
        timer.cancel();
        return;
      }

      state = state.copyWith(
        sessionDuration: state.sessionDuration + const Duration(seconds: 1),
      );

      if (state.remainingSeconds > 1) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _nextPhase();
      }
    });
  }

  void _nextPhase() {
    switch (state.phase) {
      case BreathPhase.inhale:
        if (state.pattern.hold > 0) {
          state = state.copyWith(
            phase: BreathPhase.hold,
            label: "Segure",
            subLabel: "Mantenha o peito expandido",
            duration: state.pattern.holdDuration,
            remainingSeconds: state.pattern.holdDuration.inSeconds,
          );
        } else {
          state = state.copyWith(
            phase: BreathPhase.exhale,
            label: "Expire",
            subLabel: "Solte devagar pela boca",
            duration: state.pattern.exhaleDuration,
            remainingSeconds: state.pattern.exhaleDuration.inSeconds,
          );
        }
        break;
      case BreathPhase.hold:
        state = state.copyWith(
          phase: BreathPhase.exhale,
          label: "Expire",
          subLabel: "Solte devagar pela boca",
          duration: state.pattern.exhaleDuration,
          remainingSeconds: state.pattern.exhaleDuration.inSeconds,
        );
        break;
      case BreathPhase.exhale:
        state = state.copyWith(
          phase: BreathPhase.inhale,
          label: "Inspire",
          subLabel: "Profundamente pelo nariz",
          duration: state.pattern.inhaleDuration,
          remainingSeconds: state.pattern.inhaleDuration.inSeconds,
        );
        break;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final breathingProvider =
    StateNotifierProvider.autoDispose<BreathingNotifier, BreathingState>((ref) {
  return BreathingNotifier();
});
