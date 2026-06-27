import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:khuta/core/services/ai_recommendations_service.dart';
import 'package:khuta/models/question.dart';
import 'package:khuta/models/child.dart';
import 'package:khuta/screens/child/assessment/services/assessment_service.dart';

part 'assessment_state.dart';

class AssessmentCubit extends Cubit<AssessmentState> {
  final Child child;
  final List<Question> questions;
  final AssessmentService _service;

  AssessmentCubit({
    required this.child,
    required this.questions,
    AssessmentService? service,
  })  : _service = service ??
            AssessmentService(
              child: child,
              assessmentType: questions.isNotEmpty
                  ? questions[0].questionType
                  : 'parent',
            ),
        super(AssessmentState.initial(questions.length));

  void selectAnswer(int questionIndex, int answerIndex) {
    final newAnswers = List<int>.from(state.answers);
    newAnswers[questionIndex] = answerIndex;
    emit(state.copyWith(answers: newAnswers));
    if (kDebugMode) debugPrint('Answer selected for question $questionIndex: $answerIndex');
  }

  void nextQuestion() {
    if (state.currentIndex < questions.length - 1) {
      emit(state.copyWith(currentIndex: state.currentIndex + 1));
    }
  }

  void previousQuestion() {
    if (state.currentIndex > 0) {
      emit(state.copyWith(currentIndex: state.currentIndex - 1));
    }
  }

  bool get isLastQuestion => state.currentIndex == questions.length - 1;
  bool get canProceed => state.answers[state.currentIndex] >= 0;
  bool get allQuestionsAnswered => !state.answers.contains(-1);
  int get unansweredCount => state.answers.where((a) => a < 0).length;

  /// Calculate raw score (sum of all answers)
  int calculateRawScore() {
    return state.answers.where((a) => a >= 0).fold(0, (sum, a) => sum + a);
  }

  Future<void> submitAssessment() async {
    if (!allQuestionsAnswered) {
      emit(state.copyWith(
        status: AssessmentStatus.error,
        errorMessage: 'please_answer_all_questions',
      ));
      return;
    }

    emit(state.copyWith(status: AssessmentStatus.submitting));

    try {
      // FIX #1: Calculate T-Score properly (not raw score)
      final tScore = _service.calculateScore(
        state.answers,
        questions.isNotEmpty ? questions[0].questionType : 'parent',
      );

      // FIX #2: Get interpretation using T-Score (not raw score)
      final interpretation = _service.getScoreInterpretation(tScore);

      // FIX #3: AI gets T-Score (not raw score) for correct recommendations
      List<String> recommendations;
      try {
        recommendations = await AiRecommendationsService.getRecommendations(
          tScore,
          questions,
          state.answers,
          childAge: child.age,
          childGender: child.gender,
        );
      } catch (e) {
        if (kDebugMode) debugPrint('AI recommendations failed, using fallback: $e');
        // FIX #4: AI failure never blocks saving — fallback is handled inside service
        // but extra safety here just in case
        recommendations = [];
      }

      // FIX #5: Save with try/catch so Firebase failure doesn't crash the whole flow
      try {
        await _service.saveTestResult(tScore, interpretation, recommendations);
      } catch (e) {
        if (kDebugMode) debugPrint('Save to Firebase failed (non-fatal): $e');
        // Don't rethrow — we still show the results to the user
        // The score and recommendations are computed, just not persisted
      }

      // Always emit success so the user sees results even if save failed
      emit(state.copyWith(
        status: AssessmentStatus.success,
        finalScore: tScore,
        interpretation: interpretation,
        recommendations: recommendations,
      ));
    } catch (e) {
      if (kDebugMode) debugPrint('Error submitting assessment: $e');
      final errorMessage = e.toString().contains('Age must be between')
          ? 'error_invalid_age'
          : 'error_saving_results';
      emit(state.copyWith(
        status: AssessmentStatus.error,
        errorMessage: errorMessage,
      ));
    }
  }

  void clearError() {
    emit(state.copyWith(
      status: AssessmentStatus.inProgress,
      errorMessage: null,
    ));
  }
}
