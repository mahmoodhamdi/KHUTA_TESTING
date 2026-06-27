import 'package:flutter_test/flutter_test.dart';
import 'package:khuta/cubit/assessment/assessment_cubit.dart';
import 'package:khuta/models/child.dart';
import 'package:khuta/models/question.dart';
import 'package:khuta/screens/child/assessment/services/assessment_service.dart';
import 'package:khuta/core/repositories/child_repository.dart';
import 'package:khuta/core/repositories/test_result_repository.dart';
import 'package:khuta/models/test_result.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mock ChildRepository for testing
class MockChildRepository implements ChildRepository {
  @override
  Future<List<Child>> getChildren() async => [];

  @override
  Future<Child?> getChild(String childId) async => null;

  @override
  Future<String> addChild(Child child) async => 'mock-id';

  @override
  Future<void> updateChild(Child child) async {}

  @override
  Future<void> deleteChild(String childId) async {}

  @override
  Stream<List<Child>> watchChildren() => Stream.value([]);

  @override
  Future<PaginatedChildren> getChildrenPaginated({
    int limit = 20,
    Object? startAfter,
  }) async =>
      const PaginatedChildren(children: []);
}

/// Mock TestResultRepository for testing
class MockTestResultRepository implements TestResultRepository {
  @override
  Future<List<TestResult>> getTestResults(String childId) async => [];

  @override
  Future<TestResult?> getTestResult(String childId, String resultId) async => null;

  @override
  Future<String> saveTestResult(String childId, TestResult result) async => 'mock-result-id';

  @override
  Stream<List<TestResult>> watchTestResults(String childId) => Stream.value([]);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Child mockChild;
  late List<Question> mockQuestions;
  late AssessmentService mockService;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    EasyLocalization.logger.enableBuildModes = [];
    await EasyLocalization.ensureInitialized();
  });

  setUp(() {
    mockChild = Child(
      id: 'test_child_1',
      name: 'Test Child',
      age: 8,
      gender: 'male',
      testResults: [],
      createdAt: DateTime.now(),
    );

    mockQuestions = [
      Question(
        id: '1',
        imageUrl: '',
        questionText: 'Test question 1?',
        questionType: 'parent',
      ),
      Question(
        id: '2',
        imageUrl: '',
        questionText: 'Test question 2?',
        questionType: 'parent',
      ),
      Question(
        id: '3',
        imageUrl: '',
        questionText: 'Test question 3?',
        questionType: 'parent',
      ),
    ];

    mockService = AssessmentService(
      child: mockChild,
      assessmentType: 'parent',
      childRepository: MockChildRepository(),
      testResultRepository: MockTestResultRepository(),
    );
  });

  group('Assessment Flow Integration Tests', () {
    test('complete assessment flow: start → answer all → submit', () async {
      final cubit = AssessmentCubit(
        child: mockChild,
        questions: mockQuestions,
        service: mockService,
      );

      // Initial state
      expect(cubit.state.status, equals(AssessmentStatus.inProgress));
      expect(cubit.state.currentIndex, equals(0));
      expect(cubit.allQuestionsAnswered, isFalse);

      // Answer first question
      cubit.selectAnswer(0, 1);
      expect(cubit.state.answers[0], equals(1));
      expect(cubit.canProceed, isTrue);

      // Navigate to second question
      cubit.nextQuestion();
      expect(cubit.state.currentIndex, equals(1));
      expect(cubit.canProceed, isFalse); // No answer selected yet

      // Answer second question
      cubit.selectAnswer(1, 2);
      expect(cubit.canProceed, isTrue);

      // Navigate to third question
      cubit.nextQuestion();
      expect(cubit.state.currentIndex, equals(2));
      expect(cubit.isLastQuestion, isTrue);

      // Answer third question
      cubit.selectAnswer(2, 1);

      // Verify all questions answered
      expect(cubit.allQuestionsAnswered, isTrue);
      expect(cubit.unansweredCount, equals(0));
      expect(cubit.calculateRawScore(), equals(4)); // 1 + 2 + 1 = 4

      cubit.close();
    });

    test('assessment flow with back navigation', () async {
      final cubit = AssessmentCubit(
        child: mockChild,
        questions: mockQuestions,
        service: mockService,
      );

      // Answer first question and navigate forward
      cubit.selectAnswer(0, 1);
      cubit.nextQuestion();
      cubit.selectAnswer(1, 2);
      cubit.nextQuestion();

      // Navigate back
      cubit.previousQuestion();
      expect(cubit.state.currentIndex, equals(1));
      expect(cubit.state.answers[1], equals(2)); // Answer preserved

      cubit.previousQuestion();
      expect(cubit.state.currentIndex, equals(0));
      expect(cubit.state.answers[0], equals(1)); // Answer preserved

      cubit.close();
    });

    test('assessment flow with answer changes', () async {
      final cubit = AssessmentCubit(
        child: mockChild,
        questions: mockQuestions,
        service: mockService,
      );

      // Answer first question
      cubit.selectAnswer(0, 1);
      expect(cubit.state.answers[0], equals(1));

      // Change answer
      cubit.selectAnswer(0, 3);
      expect(cubit.state.answers[0], equals(3));

      // Navigate and come back
      cubit.nextQuestion();
      cubit.previousQuestion();
      expect(cubit.state.answers[0], equals(3)); // Changed answer preserved

      cubit.close();
    });

    test('assessment flow: partial completion and submission failure', () async {
      final cubit = AssessmentCubit(
        child: mockChild,
        questions: mockQuestions,
        service: mockService,
      );

      // Only answer 2 of 3 questions
      cubit.selectAnswer(0, 1);
      cubit.selectAnswer(1, 2);
      // Question 3 left unanswered

      expect(cubit.allQuestionsAnswered, isFalse);
      expect(cubit.unansweredCount, equals(1));

      // Attempt to submit
      await cubit.submitAssessment();

      // Should fail with error
      expect(cubit.state.status, equals(AssessmentStatus.error));
      expect(cubit.state.errorMessage, equals('please_answer_all_questions'));

      // Clear error
      cubit.clearError();
      expect(cubit.state.status, equals(AssessmentStatus.inProgress));
      expect(cubit.state.errorMessage, isNull);

      cubit.close();
    });

    test('score calculation is correct for various answer patterns', () async {
      final cubit = AssessmentCubit(
        child: mockChild,
        questions: mockQuestions,
        service: mockService,
      );

      // Test pattern: all 0s
      cubit.selectAnswer(0, 0);
      cubit.selectAnswer(1, 0);
      cubit.selectAnswer(2, 0);
      expect(cubit.calculateRawScore(), equals(0));

      // Test pattern: all 3s
      cubit.selectAnswer(0, 3);
      cubit.selectAnswer(1, 3);
      cubit.selectAnswer(2, 3);
      expect(cubit.calculateRawScore(), equals(9));

      // Test pattern: mixed
      cubit.selectAnswer(0, 0);
      cubit.selectAnswer(1, 2);
      cubit.selectAnswer(2, 3);
      expect(cubit.calculateRawScore(), equals(5));

      cubit.close();
    });

    test('state transitions during assessment flow', () async {
      final cubit = AssessmentCubit(
        child: mockChild,
        questions: mockQuestions,
        service: mockService,
      );

      final states = <AssessmentStatus>[];
      final subscription = cubit.stream.listen((state) {
        states.add(state.status);
      });

      // Complete all answers
      cubit.selectAnswer(0, 1);
      cubit.selectAnswer(1, 2);
      cubit.selectAnswer(2, 1);

      // Submit - will transition to submitting then either success or error
      await cubit.submitAssessment();

      await Future.delayed(const Duration(milliseconds: 100));

      // Should have at least gone through submitting state
      expect(states, contains(AssessmentStatus.submitting));

      await subscription.cancel();
      cubit.close();
    });

    test('navigation boundary conditions', () async {
      final cubit = AssessmentCubit(
        child: mockChild,
        questions: mockQuestions,
        service: mockService,
      );

      // At first question, previousQuestion should not change index
      expect(cubit.state.currentIndex, equals(0));
      cubit.previousQuestion();
      expect(cubit.state.currentIndex, equals(0));

      // Navigate to last question
      cubit.nextQuestion();
      cubit.nextQuestion();
      expect(cubit.state.currentIndex, equals(2));
      expect(cubit.isLastQuestion, isTrue);

      // At last question, nextQuestion should not change index
      cubit.nextQuestion();
      expect(cubit.state.currentIndex, equals(2));

      cubit.close();
    });

    test('isFirstQuestion and isLastQuestion properties', () async {
      final cubit = AssessmentCubit(
        child: mockChild,
        questions: mockQuestions,
        service: mockService,
      );

      // First question
      expect(cubit.state.isFirstQuestion, isTrue);
      expect(cubit.isLastQuestion, isFalse);

      // Middle question
      cubit.nextQuestion();
      expect(cubit.state.isFirstQuestion, isFalse);
      expect(cubit.isLastQuestion, isFalse);

      // Last question
      cubit.nextQuestion();
      expect(cubit.state.isFirstQuestion, isFalse);
      expect(cubit.isLastQuestion, isTrue);

      cubit.close();
    });

    test('empty answers list initialization', () async {
      final cubit = AssessmentCubit(
        child: mockChild,
        questions: mockQuestions,
        service: mockService,
      );

      // All answers should be initialized to -1
      expect(cubit.state.answers.length, equals(3));
      expect(cubit.state.answers, equals([-1, -1, -1]));

      cubit.close();
    });

    test('single question assessment', () async {
      final singleQuestion = [
        Question(
          id: '1',
          imageUrl: '',
          questionText: 'Only question?',
          questionType: 'parent',
        ),
      ];

      final cubit = AssessmentCubit(
        child: mockChild,
        questions: singleQuestion,
        service: mockService,
      );

      expect(cubit.state.isFirstQuestion, isTrue);
      expect(cubit.isLastQuestion, isTrue);
      expect(cubit.state.answers.length, equals(1));

      cubit.selectAnswer(0, 2);
      expect(cubit.allQuestionsAnswered, isTrue);
      expect(cubit.calculateRawScore(), equals(2));

      cubit.close();
    });
  });
}
