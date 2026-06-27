import 'dart:async';
import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../models/child.dart';
import '../../models/game_session.dart';
import '../../data/repositories/game_session_repository.dart';

part 'game_state.dart';

// ─── Task Types ────────────────────────────────────────────
enum TaskType { cpt, memory, inhibition }

class GameTask {
  final String id;
  final TaskType type;
  final bool requiresTap;
  final String targetEmoji;
  final int timeoutMs;
  final List<String>? sequence;

  const GameTask({
    required this.id,
    required this.type,
    required this.requiresTap,
    required this.targetEmoji,
    required this.timeoutMs,
    this.sequence,
  });

  static const _cptTargets = ['⭐', '🌟', '✨'];
  static const _cptNoise = ['🔴', '🔷', '🔶', '🟢', '🟣', '⬛', '🔸'];
  static const _memItems = [
    '🍎', '🐶', '🚀', '🌈', '🎈', '🏆', '🦋', '🎯', '🍕', '🐱'
  ];

  factory GameTask.generate(
      {required TaskType type, required int difficulty}) {
    final id = const Uuid().v4();
    final rand = Random();
    final timeoutMs = (3500 - (difficulty - 1) * 400).clamp(1500, 3500);

    switch (type) {
      case TaskType.cpt:
        final isTarget = rand.nextDouble() < 0.6;
        return GameTask(
          id: id,
          type: type,
          requiresTap: isTarget,
          targetEmoji: isTarget
              ? _cptTargets[rand.nextInt(_cptTargets.length)]
              : _cptNoise[rand.nextInt(_cptNoise.length)],
          timeoutMs: timeoutMs,
        );
      case TaskType.inhibition:
        final isGo = rand.nextDouble() < 0.65;
        return GameTask(
          id: id,
          type: type,
          requiresTap: isGo,
          targetEmoji: isGo ? '🟢' : '🔴',
          timeoutMs: timeoutMs,
        );
      case TaskType.memory:
        final len = (difficulty + 1).clamp(2, 6);
        final seq = List.generate(
            len, (_) => _memItems[rand.nextInt(_memItems.length)]);
        return GameTask(
          id: id,
          type: TaskType.memory,
          requiresTap: true,
          targetEmoji: seq.last,
          sequence: seq,
          timeoutMs: (timeoutMs * 1.5).round(),
        );
    }
  }
}

// ─── Cubit ────────────────────────────────────────────────
class GameCubit extends Cubit<GameState> {
  final Child child;
  Timer? _sessionTimer;
  Timer? _taskTimer;
  static const _uuid = Uuid();
  static const int sessionDurationSeconds = 5 * 60; // 5 دقايق
  static const int taskTimeoutMs = 3500;

  GameCubit({required this.child}) : super(GameState.initial());

  // ─── Start ────────────────────────────────────────────
  Future<void> startSession() async {
    final lastDiff =
        await GameSessionRepository.getLastDifficulty(child.id);
    emit(state.copyWith(
      status: GameStatus.inProgress,
      difficulty: lastDiff,
      timeLeftSeconds: sessionDurationSeconds,
      taskResults: [],
      clearTask: true,
      sessionStartTime: DateTime.now(),
      feedback: FeedbackType.none,
    ));
    _startTimer();
    _nextTask();
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (isClosed) { t.cancel(); return; }
      final newTime = state.timeLeftSeconds - 1;
      if (newTime <= 0) {
        t.cancel();
        _endSession();
      } else {
        emit(state.copyWith(timeLeftSeconds: newTime));
      }
    });
  }

  // ─── Pause / Resume ──────────────────────────────────
  void pauseSession() {
    _sessionTimer?.cancel();
    _taskTimer?.cancel();
    emit(state.copyWith(status: GameStatus.paused));
  }

  void resumeSession() {
    emit(state.copyWith(status: GameStatus.inProgress));
    _startTimer();
    _nextTask();
  }

  Future<void> endSessionEarly() => _endSession();

  // ─── Task logic ──────────────────────────────────────
  void _nextTask() {
    _taskTimer?.cancel();
    if (state.status != GameStatus.inProgress) return;

    final rand = Random();
    final roll = rand.nextDouble();
    final TaskType type;
    if (roll < 0.55) {
      type = TaskType.cpt;
    } else if (roll < 0.78) {
      type = TaskType.memory;
    } else {
      type = TaskType.inhibition;
    }

    final task =
        GameTask.generate(type: type, difficulty: state.difficulty);
    emit(state.copyWith(
        currentTask: task,
        taskShownAt: DateTime.now(),
        feedback: FeedbackType.none));

    _taskTimer = Timer(Duration(milliseconds: task.timeoutMs), () {
      if (!isClosed &&
          state.status == GameStatus.inProgress &&
          state.currentTask?.id == task.id) {
        _recordResult(responded: false);
      }
    });
  }

  void onUserTap({required bool tapped}) {
    if (state.status != GameStatus.inProgress) return;
    if (state.currentTask == null) return;
    _taskTimer?.cancel();
    _recordResult(responded: tapped);
  }

  void _recordResult({required bool responded}) {
    final task = state.currentTask;
    if (task == null) return;

    final shownAt = state.taskShownAt ?? DateTime.now();
    final reactionMs =
        DateTime.now().difference(shownAt).inMilliseconds.clamp(0, taskTimeoutMs);
    final isCorrect = task.requiresTap == responded;

    final result = TaskResult(
      taskType: task.type.name,
      reactionTimeMs: reactionMs,
      isCorrect: isCorrect,
      difficulty: state.difficulty,
    );

    final newResults = [...state.taskResults, result];
    final newDiff = _adaptDifficulty(newResults);

    emit(state.copyWith(
      taskResults: newResults,
      difficulty: newDiff,
      clearTask: true,
      feedback: isCorrect ? FeedbackType.correct : FeedbackType.wrong,
    ));

    Future.delayed(const Duration(milliseconds: 650), () {
      if (!isClosed && state.status == GameStatus.inProgress) {
        emit(state.copyWith(feedback: FeedbackType.none));
        _nextTask();
      }
    });
  }

  int _adaptDifficulty(List<TaskResult> results) {
    if (results.length < 5) return state.difficulty;
    final last5 = results.length > 5
        ? results.sublist(results.length - 5)
        : results;
    final acc = last5.where((r) => r.isCorrect).length / 5 * 100;
    final correct = last5.where((r) => r.isCorrect && r.reactionTimeMs > 0);
    final avgR = correct.isEmpty
        ? 9999
        : correct.fold(0, (s, r) => s + r.reactionTimeMs) ~/ correct.length;

    int d = state.difficulty;
    if (acc >= 80 && avgR < 1600 && d < 5) d++;
    else if (acc < 45 && d > 1) d--;
    return d;
  }

  // ─── End Session ────────────────────────────────────
  Future<void> _endSession() async {
    _sessionTimer?.cancel();
    _taskTimer?.cancel();

    if (state.taskResults.isEmpty) {
      if (!isClosed) emit(GameState.initial());
      return;
    }

    if (!isClosed) emit(state.copyWith(status: GameStatus.saving));

    final session = GameSession(
      id: _uuid.v4(),
      childId: child.id,
      date: DateTime.now(),
      durationSeconds: sessionDurationSeconds - state.timeLeftSeconds,
      taskResults: state.taskResults,
      finalDifficulty: state.difficulty,
    );

    try {
      await GameSessionRepository.saveSession(child.id, session);
    } catch (e) {
      if (kDebugMode) debugPrint('Save session error (non-fatal): $e');
    }

    if (!isClosed) {
      emit(state.copyWith(
          status: GameStatus.completed, completedSession: session));
    }
  }

  void resetGame() {
    _sessionTimer?.cancel();
    _taskTimer?.cancel();
    if (!isClosed) emit(GameState.initial());
  }

  @override
  Future<void> close() {
    _sessionTimer?.cancel();
    _taskTimer?.cancel();
    return super.close();
  }
}
