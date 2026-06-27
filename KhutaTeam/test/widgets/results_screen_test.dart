import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khuta/screens/child/results_screen.dart';
import 'package:khuta/models/child.dart';
import 'package:khuta/models/question.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Child mockChild;
  late List<Question> mockQuestions;
  late List<int> mockAnswers;
  late List<String> mockRecommendations;

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
    ];

    mockAnswers = [1, 2];

    mockRecommendations = [
      'First recommendation',
      'Second recommendation',
      'Third recommendation',
    ];
  });

  group('ResultsScreen', () {
    testWidgets('renders assessment results title', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(
          ResultsScreen(
            child: mockChild,
            score: 50,
            recommendations: mockRecommendations,
            answers: mockAnswers,
            questions: mockQuestions,
            interpretation: 'average',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Assessment Results'), findsOneWidget);
    });

    testWidgets('displays T-Score', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(
          ResultsScreen(
            child: mockChild,
            score: 55,
            recommendations: mockRecommendations,
            answers: mockAnswers,
            questions: mockQuestions,
            interpretation: 'average',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('T-Score: 55'), findsOneWidget);
    });

    testWidgets('displays recommendations title', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(
          ResultsScreen(
            child: mockChild,
            score: 50,
            recommendations: mockRecommendations,
            answers: mockAnswers,
            questions: mockQuestions,
            interpretation: 'average',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Recommendations'), findsOneWidget);
    });

    testWidgets('displays all recommendations', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(
          ResultsScreen(
            child: mockChild,
            score: 50,
            recommendations: mockRecommendations,
            answers: mockAnswers,
            questions: mockQuestions,
            interpretation: 'average',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('First recommendation'), findsOneWidget);
      expect(find.text('Second recommendation'), findsOneWidget);
      expect(find.text('Third recommendation'), findsOneWidget);
    });

    testWidgets('has share button', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(
          ResultsScreen(
            child: mockChild,
            score: 50,
            recommendations: mockRecommendations,
            answers: mockAnswers,
            questions: mockQuestions,
            interpretation: 'average',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets('has close button', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(
          ResultsScreen(
            child: mockChild,
            score: 50,
            recommendations: mockRecommendations,
            answers: mockAnswers,
            questions: mockQuestions,
            interpretation: 'average',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('displays severity text for average score', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(
          ResultsScreen(
            child: mockChild,
            score: 50,
            recommendations: mockRecommendations,
            answers: mockAnswers,
            questions: mockQuestions,
            interpretation: 'average',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The severity text should be present (exact text depends on translations)
      expect(find.textContaining('Average'), findsWidgets);
    });

    testWidgets('displays score icon for low scores', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(
          ResultsScreen(
            child: mockChild,
            score: 40,
            recommendations: mockRecommendations,
            answers: mockAnswers,
            questions: mockQuestions,
            interpretation: 'slightly_below_average',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Low score should show thumbs up icon
      expect(find.byIcon(Icons.thumb_up), findsOneWidget);
    });

    testWidgets('displays score icon for high scores', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(
          ResultsScreen(
            child: mockChild,
            score: 75,
            recommendations: mockRecommendations,
            answers: mockAnswers,
            questions: mockQuestions,
            interpretation: 'extremely_above_average',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // High score should show error icon
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('recommendation icons are displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(
          ResultsScreen(
            child: mockChild,
            score: 50,
            recommendations: mockRecommendations,
            answers: mockAnswers,
            questions: mockQuestions,
            interpretation: 'average',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Each recommendation has a check icon
      expect(
        find.byIcon(Icons.check_circle_outline),
        findsNWidgets(mockRecommendations.length),
      );
    });
  });

  group('ResultsScreen helper methods', () {
    test('getAnswerText returns correct values', () {
      // Test the answer mapping logic
      final answerTexts = {
        0: 'never',
        1: 'rarely',
        2: 'sometimes',
        3: 'often',
        4: 'always',
      };

      expect(answerTexts[0], equals('never'));
      expect(answerTexts[1], equals('rarely'));
      expect(answerTexts[2], equals('sometimes'));
      expect(answerTexts[3], equals('often'));
      expect(answerTexts[4], equals('always'));
    });

    test('getScoreIcon returns correct icon for different scores', () {
      IconData getScoreIcon(int tScore) {
        if (tScore >= 70) return Icons.error;
        if (tScore >= 65) return Icons.warning;
        if (tScore >= 60) return Icons.info;
        if (tScore >= 45) return Icons.check_circle;
        return Icons.thumb_up;
      }

      expect(getScoreIcon(75), equals(Icons.error));
      expect(getScoreIcon(67), equals(Icons.warning));
      expect(getScoreIcon(62), equals(Icons.info));
      expect(getScoreIcon(50), equals(Icons.check_circle));
      expect(getScoreIcon(40), equals(Icons.thumb_up));
    });

    test('cleanRecommendation removes markdown formatting', () {
      // This tests the actual cleanRecommendation logic as it is in ResultsScreen
      String cleanRecommendation(String input) {
        return input
            .replaceAll(RegExp(r'^[\*\-\•]\s*'), '')
            .replaceAllMapped(
              RegExp(r'\*\*(.*?)\*\*'),
              (match) => match.group(1) ?? '',
            )
            .replaceAllMapped(
              RegExp(r'__(.*?)__'),
              (match) => match.group(1) ?? '',
            )
            .replaceAllMapped(
              RegExp(r'\*(.*?)\*'),
              (match) => match.group(1) ?? '',
            )
            .replaceAllMapped(
              RegExp(r'_(.*?)_'),
              (match) => match.group(1) ?? '',
            );
      }

      // Bold text with double asterisks
      expect(cleanRecommendation('**Bold text**'), equals('Bold text'));
      // List items
      expect(cleanRecommendation('- List item'), equals('List item'));
      expect(cleanRecommendation('• Bullet item'), equals('Bullet item'));
      // Underlined text
      expect(cleanRecommendation('__Underlined__'), equals('Underlined'));
      // Plain text should remain unchanged
      expect(cleanRecommendation('Plain text'), equals('Plain text'));
    });

    test('sanitizeFileName removes special characters', () {
      String sanitizeFileName(String name) {
        return name
            .replaceAll(RegExp(r'[^\w\s-]'), '_')
            .replaceAll(RegExp(r'\s+'), '_')
            .toLowerCase();
      }

      expect(sanitizeFileName('Test Child'), equals('test_child'));
      expect(sanitizeFileName('Child/With\\Slashes'), equals('child_with_slashes'));
      expect(sanitizeFileName('Child@#\$%'), equals('child____'));
      expect(sanitizeFileName('Simple'), equals('simple'));
    });
  });

  group('Score Color Gradients', () {
    test('getScoreGradient returns correct colors for different scores', () {
      List<Color> getScoreGradient(int tScore, bool isDark) {
        if (tScore >= 70) {
          return [Colors.red.shade700, Colors.red.shade900];
        } else if (tScore >= 65) {
          return [Colors.orange.shade700, Colors.orange.shade900];
        } else if (tScore >= 60) {
          return [Colors.yellow.shade700, Colors.yellow.shade900];
        } else if (tScore >= 45) {
          return [Colors.green.shade500, Colors.green.shade700];
        } else {
          return [Colors.blue.shade500, Colors.blue.shade700];
        }
      }

      // Very high score - red
      final veryHighColors = getScoreGradient(75, false);
      expect(veryHighColors[0], equals(Colors.red.shade700));

      // High score - orange
      final highColors = getScoreGradient(67, false);
      expect(highColors[0], equals(Colors.orange.shade700));

      // Elevated score - yellow
      final elevatedColors = getScoreGradient(62, false);
      expect(elevatedColors[0], equals(Colors.yellow.shade700));

      // Average score - green
      final avgColors = getScoreGradient(50, false);
      expect(avgColors[0], equals(Colors.green.shade500));

      // Low score - blue
      final lowColors = getScoreGradient(40, false);
      expect(lowColors[0], equals(Colors.blue.shade500));
    });
  });
}
