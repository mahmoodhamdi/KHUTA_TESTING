part of 'game_cubit.dart';

enum GameStatus { initial, inProgress, paused, saving, completed, error }

enum FeedbackType { none, correct, wrong }

class GameState extends Equatable {
  final GameStatus status;
  final int difficulty;
  final int timeLeftSeconds;
  final List<TaskResult> taskResults;
  final GameTask? currentTask;
  final DateTime? taskShownAt;
  final DateTime? sessionStartTime;
  final FeedbackType feedback;
  final GameSession? completedSession;
  final String? errorMessage;

  const GameState({
    required this.status,
    required this.difficulty,
    required this.timeLeftSeconds,
    required this.taskResults,
    this.currentTask,
    this.taskShownAt,
    this.sessionStartTime,
    required this.feedback,
    this.completedSession,
    this.errorMessage,
  });

  factory GameState.initial() => const GameState(
        status: GameStatus.initial,
        difficulty: 1,
        timeLeftSeconds: GameCubit.sessionDurationSeconds,
        taskResults: [],
        feedback: FeedbackType.none,
      );

  double get liveAccuracy {
    if (taskResults.isEmpty) return 0;
    return taskResults.where((r) => r.isCorrect).length /
        taskResults.length *
        100;
  }

  int get liveCorrect => taskResults.where((r) => r.isCorrect).length;
  int get liveTotal => taskResults.length;

  GameState copyWith({
    GameStatus? status,
    int? difficulty,
    int? timeLeftSeconds,
    List<TaskResult>? taskResults,
    GameTask? currentTask,
    bool clearTask = false,
    DateTime? taskShownAt,
    DateTime? sessionStartTime,
    FeedbackType? feedback,
    GameSession? completedSession,
    String? errorMessage,
  }) =>
      GameState(
        status: status ?? this.status,
        difficulty: difficulty ?? this.difficulty,
        timeLeftSeconds: timeLeftSeconds ?? this.timeLeftSeconds,
        taskResults: taskResults ?? this.taskResults,
        currentTask: clearTask ? null : (currentTask ?? this.currentTask),
        taskShownAt: taskShownAt ?? this.taskShownAt,
        sessionStartTime: sessionStartTime ?? this.sessionStartTime,
        feedback: feedback ?? this.feedback,
        completedSession: completedSession ?? this.completedSession,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [
        status,
        difficulty,
        timeLeftSeconds,
        taskResults.length,
        currentTask?.id,
        feedback,
        completedSession?.id,
      ];
}
