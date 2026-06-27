part of 'assessment_cubit.dart';

enum AssessmentStatus { initial, inProgress, submitting, success, error }

class AssessmentState extends Equatable {
  final int currentIndex;
  final List<int> answers;
  final AssessmentStatus status;
  final String? errorMessage;
  final int? finalScore;
  final String? interpretation;
  final List<String>? recommendations;

  const AssessmentState({
    required this.currentIndex,
    required this.answers,
    this.status = AssessmentStatus.initial,
    this.errorMessage,
    this.finalScore,
    this.interpretation,
    this.recommendations,
  });

  factory AssessmentState.initial(int questionCount) {
    return AssessmentState(
      currentIndex: 0,
      answers: List.filled(questionCount, -1),
      status: AssessmentStatus.inProgress,
    );
  }

  AssessmentState copyWith({
    int? currentIndex,
    List<int>? answers,
    AssessmentStatus? status,
    String? errorMessage,
    int? finalScore,
    String? interpretation,
    List<String>? recommendations,
  }) {
    return AssessmentState(
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      status: status ?? this.status,
      errorMessage: errorMessage,
      finalScore: finalScore ?? this.finalScore,
      interpretation: interpretation ?? this.interpretation,
      recommendations: recommendations ?? this.recommendations,
    );
  }

  bool get isFirstQuestion => currentIndex == 0;
  bool get canGoBack => currentIndex > 0;
  int get answeredCount => answers.where((a) => a >= 0).length;
  double get progress => answers.isEmpty ? 0 : answeredCount / answers.length;

  @override
  List<Object?> get props => [
        currentIndex,
        answers,
        status,
        errorMessage,
        finalScore,
        interpretation,
        recommendations,
      ];
}
