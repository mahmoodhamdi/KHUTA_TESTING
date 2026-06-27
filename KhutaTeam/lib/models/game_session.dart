class TaskResult {
  final String taskType;
  final int reactionTimeMs;
  final bool isCorrect;
  final int difficulty;

  const TaskResult({
    required this.taskType,
    required this.reactionTimeMs,
    required this.isCorrect,
    required this.difficulty,
  });

  Map<String, dynamic> toMap() => {
        'taskType': taskType,
        'reactionTimeMs': reactionTimeMs,
        'isCorrect': isCorrect,
        'difficulty': difficulty,
      };

  factory TaskResult.fromMap(Map<String, dynamic> m) => TaskResult(
        taskType: m['taskType'] ?? 'cpt',
        reactionTimeMs: m['reactionTimeMs'] ?? 0,
        isCorrect: m['isCorrect'] ?? false,
        difficulty: m['difficulty'] ?? 1,
      );
}

class GameSession {
  final String id;
  final String childId;
  final DateTime date;
  final int durationSeconds;
  final List<TaskResult> taskResults;
  final int finalDifficulty;

  const GameSession({
    required this.id,
    required this.childId,
    required this.date,
    required this.durationSeconds,
    required this.taskResults,
    required this.finalDifficulty,
  });

  int get totalTasks => taskResults.length;
  int get correctTasks => taskResults.where((t) => t.isCorrect).length;
  double get accuracy =>
      totalTasks == 0 ? 0 : correctTasks / totalTasks * 100;

  int get avgReactionMs {
    final correct = taskResults.where((t) => t.isCorrect).toList();
    if (correct.isEmpty) return 0;
    return correct.fold(0, (s, t) => s + t.reactionTimeMs) ~/ correct.length;
  }

  int get sessionScore {
    final accScore = accuracy.round();
    final speedBonus =
        avgReactionMs < 800 ? 20 : avgReactionMs < 1200 ? 10 : 0;
    final diffBonus = finalDifficulty * 5;
    return (accScore + speedBonus + diffBonus).clamp(0, 150);
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'childId': childId,
        'date': date.toIso8601String(),
        'durationSeconds': durationSeconds,
        'taskResults': taskResults.map((t) => t.toMap()).toList(),
        'finalDifficulty': finalDifficulty,
      };

  factory GameSession.fromMap(Map<String, dynamic> m) => GameSession(
        id: m['id'] ?? '',
        childId: m['childId'] ?? '',
        date: DateTime.tryParse(m['date'] ?? '') ?? DateTime.now(),
        durationSeconds: m['durationSeconds'] ?? 0,
        taskResults: (m['taskResults'] as List<dynamic>? ?? [])
            .map((t) => TaskResult.fromMap(Map<String, dynamic>.from(t)))
            .toList(),
        finalDifficulty: m['finalDifficulty'] ?? 1,
      );
}
