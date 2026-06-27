import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:khuta/core/di/service_locator.dart';
import 'package:khuta/core/repositories/child_repository.dart';
import 'package:khuta/core/repositories/test_result_repository.dart';
import 'package:khuta/core/services/sdq_scoring_service.dart';
import 'package:khuta/models/child.dart';
import 'package:khuta/models/test_result.dart';

class AssessmentService {
  final ChildRepository _childRepository;
  final TestResultRepository _testResultRepository;
  final Child child;
  final String assessmentType;

  AssessmentService({
    required this.assessmentType,
    required this.child,
    ChildRepository? childRepository,
    TestResultRepository? testResultRepository,
  }) : _childRepository = childRepository ?? ServiceLocator().childRepository,
       _testResultRepository =
           testResultRepository ?? ServiceLocator().testResultRepository;

  Future<void> saveTestResult(
    int tScore,
    String interpretation,
    List<String> recommendations,
  ) async {
    final testResult = TestResult(
      testType: assessmentType.tr(),
      score: tScore.toDouble(),
      date: DateTime.now(),
      notes: interpretation,
      recommendations: recommendations,
    );

    // FIX: Each Firebase call is isolated so one failure doesn't block the other
    bool savedToSubcollection = false;
    bool savedToChild = false;

    try {
      await _testResultRepository.saveTestResult(child.id, testResult);
      savedToSubcollection = true;
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to save to testResults subcollection: $e');
    }

    try {
      child.testResults.add(testResult);
      await _childRepository.updateChild(child);
      savedToChild = true;
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to update child with embedded result: $e');
    }

    // Only throw if BOTH saves failed completely
    if (!savedToSubcollection && !savedToChild) {
      throw Exception('Failed to persist test result to any storage');
    }
  }

  /// Get the interpretation text based on the T-score
  String getScoreInterpretation(int tScore) {
    return SdqScoringService.getScoreInterpretation(tScore);
  }

  /// Calculate the SDQ T-score from raw answers
  int calculateScore(List<int> answers, String questionType) {
    if (child.age < 6 || child.age > 17) {
      throw Exception('Age must be between 6 and 17');
    }

    final validAnswers = answers.where((a) => a != -1).toList();

    if (validAnswers.isEmpty) {
      throw Exception('No valid answers provided');
    }

    return SdqScoringService.calculateTScore(
      answers: validAnswers,
      gender: child.gender.toLowerCase(),
      age: child.age,
      assessmentType: questionType,
    );
  }
}
