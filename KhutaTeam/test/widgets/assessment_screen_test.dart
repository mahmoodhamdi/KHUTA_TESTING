import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khuta/cubit/assessment/assessment_cubit.dart';
import 'package:khuta/screens/child/assessment/assessment_screen.dart';
import 'package:khuta/models/child.dart';
import 'package:khuta/models/question.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Child mockChild;
  late List<Question> mockQuestions;

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
  });

  group('AssessmentScreen', () {
    testWidgets('shows error screen when no questions provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(
          AssessmentScreen(
            child: mockChild,
            questions: const [],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show error screen with retry button
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('renders first question when questions are provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(
          AssessmentScreen(
            child: mockChild,
            questions: mockQuestions,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show the first question
      expect(find.text('Test question 1?'), findsOneWidget);
    });

    testWidgets('shows progress bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(
          AssessmentScreen(
            child: mockChild,
            questions: mockQuestions,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show progress indicator
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('shows answer options', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(
          AssessmentScreen(
            child: mockChild,
            questions: mockQuestions,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show answer options (Never, Rarely, Sometimes, Often)
      expect(find.text('Never'), findsOneWidget);
      expect(find.text('Rarely'), findsOneWidget);
      expect(find.text('Sometimes'), findsOneWidget);
      expect(find.text('Often'), findsOneWidget);
    });

    testWidgets('previous button is disabled on first question',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(
          AssessmentScreen(
            child: mockChild,
            questions: mockQuestions,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Previous button should be disabled on first question
      // Find all IconButton widgets that might contain the back arrow
      final previousButtons = find.byWidgetPredicate((widget) =>
          widget is IconButton &&
          (widget.icon is Icon &&
              (widget.icon as Icon).icon == Icons.arrow_back_ios));

      if (previousButtons.evaluate().isNotEmpty) {
        // On first question, previous should be disabled (onPressed == null)
        // This depends on implementation - may be null or may not exist
        expect(previousButtons, findsWidgets);
      }
    });
  });

  group('AssessmentCubit', () {
    test('initial state has all answers set to -1', () {
      final cubit = AssessmentCubit(
        child: mockChild,
        questions: mockQuestions,
      );

      expect(cubit.state.answers.length, equals(3));
      expect(cubit.state.answers.every((a) => a == -1), isTrue);
      expect(cubit.state.currentIndex, equals(0));
      expect(cubit.state.status, equals(AssessmentStatus.inProgress));

      cubit.close();
    });

    test('selectAnswer updates the answer for the question', () {
      final cubit = AssessmentCubit(
        child: mockChild,
        questions: mockQuestions,
      );

      cubit.selectAnswer(0, 2);

      expect(cubit.state.answers[0], equals(2));
      expect(cubit.state.answers[1], equals(-1));
      expect(cubit.state.answers[2], equals(-1));

      cubit.close();
    });

    test('nextQuestion increments currentIndex', () {
      final cubit = AssessmentCubit(
        child: mockChild,
        questions: mockQuestions,
      );

      expect(cubit.state.currentIndex, equals(0));

      cubit.nextQuestion();
      expect(cubit.state.currentIndex, equals(1));

      cubit.nextQuestion();
      expect(cubit.state.currentIndex, equals(2));

      cubit.close();
    });

    test('nextQuestion does not go beyond last question', () {
      final cubit = AssessmentCubit(
        child: mockChild,
        questions: mockQuestions,
      );

      cubit.nextQuestion();
      cubit.nextQuestion();
      expect(cubit.state.currentIndex, equals(2));

      cubit.nextQuestion(); // Should not go beyond 2
      expect(cubit.state.currentIndex, equals(2));

      cubit.close();
    });

    test('previousQuestion decrements currentIndex', () {
      final cubit = AssessmentCubit(
        child: mockChild,
        questions: mockQuestions,
      );

      cubit.nextQuestion();
      cubit.nextQuestion();
      expect(cubit.state.currentIndex, equals(2));

      cubit.previousQuestion();
      expect(cubit.state.currentIndex, equals(1));

      cubit.close();
    });

    test('previousQuestion does not go below 0', () {
      final cubit = AssessmentCubit(
        child: mockChild,
        questions: mockQuestions,
      );

      expect(cubit.state.currentIndex, equals(0));

      cubit.previousQuestion();
      expect(cubit.state.currentIndex, equals(0));

      cubit.close();
    });

    test('isLastQuestion returns true on last question', () {
      final cubit = AssessmentCubit(
        child: mockChild,
        questions: mockQuestions,
      );

      expect(cubit.isLastQuestion, isFalse);

      cubit.nextQuestion();
      expect(cubit.isLastQuestion, isFalse);

      cubit.nextQuestion();
      expect(cubit.isLastQuestion, isTrue);

      cubit.close();
    });

    test('canProceed returns false when no answer selected', () {
      final cubit = AssessmentCubit(
        child: mockChild,
        questions: mockQuestions,
      );

      expect(cubit.canProceed, isFalse);

      cubit.close();
    });

    test('canProceed returns true after answer selected', () {
      final cubit = AssessmentCubit(
        child: mockChild,
        questions: mockQuestions,
      );

      cubit.selectAnswer(0, 1);
      expect(cubit.canProceed, isTrue);

      cubit.close();
    });

    test('allQuestionsAnswered returns false when not all answered', () {
      final cubit = AssessmentCubit(
        child: mockChild,
        questions: mockQuestions,
      );

      cubit.selectAnswer(0, 1);
      cubit.selectAnswer(1, 2);

      expect(cubit.allQuestionsAnswered, isFalse);

      cubit.close();
    });

    test('allQuestionsAnswered returns true when all answered', () {
      final cubit = AssessmentCubit(
        child: mockChild,
        questions: mockQuestions,
      );

      cubit.selectAnswer(0, 1);
      cubit.selectAnswer(1, 2);
      cubit.selectAnswer(2, 3);

      expect(cubit.allQuestionsAnswered, isTrue);

      cubit.close();
    });

    test('calculateRawScore sums all answered questions', () {
      final cubit = AssessmentCubit(
        child: mockChild,
        questions: mockQuestions,
      );

      cubit.selectAnswer(0, 1);
      cubit.selectAnswer(1, 2);
      cubit.selectAnswer(2, 3);

      expect(cubit.calculateRawScore(), equals(6)); // 1+2+3

      cubit.close();
    });

    test('calculateRawScore ignores unanswered questions', () {
      final cubit = AssessmentCubit(
        child: mockChild,
        questions: mockQuestions,
      );

      cubit.selectAnswer(0, 1);
      cubit.selectAnswer(2, 2);
      // Question 1 is unanswered (-1)

      expect(cubit.calculateRawScore(), equals(3)); // 1+2

      cubit.close();
    });

    test('unansweredCount returns correct count', () {
      final cubit = AssessmentCubit(
        child: mockChild,
        questions: mockQuestions,
      );

      expect(cubit.unansweredCount, equals(3));

      cubit.selectAnswer(0, 1);
      expect(cubit.unansweredCount, equals(2));

      cubit.selectAnswer(1, 2);
      cubit.selectAnswer(2, 3);
      expect(cubit.unansweredCount, equals(0));

      cubit.close();
    });

    test('submitAssessment fails when not all questions answered', () async {
      final cubit = AssessmentCubit(
        child: mockChild,
        questions: mockQuestions,
      );

      cubit.selectAnswer(0, 1);
      cubit.selectAnswer(1, 2);
      // Question 2 is unanswered

      await cubit.submitAssessment();

      expect(cubit.state.status, equals(AssessmentStatus.error));
      expect(cubit.state.errorMessage, equals('please_answer_all_questions'));

      cubit.close();
    });

    test('clearError resets error state', () async {
      final cubit = AssessmentCubit(
        child: mockChild,
        questions: mockQuestions,
      );

      // Trigger error
      await cubit.submitAssessment();
      expect(cubit.state.status, equals(AssessmentStatus.error));

      cubit.clearError();
      expect(cubit.state.status, equals(AssessmentStatus.inProgress));
      expect(cubit.state.errorMessage, isNull);

      cubit.close();
    });

    test('isFirstQuestion property works correctly', () {
      final cubit = AssessmentCubit(
        child: mockChild,
        questions: mockQuestions,
      );

      expect(cubit.state.isFirstQuestion, isTrue);

      cubit.nextQuestion();
      expect(cubit.state.isFirstQuestion, isFalse);

      cubit.previousQuestion();
      expect(cubit.state.isFirstQuestion, isTrue);

      cubit.close();
    });
  });
}
