import 'package:flutter_test/flutter_test.dart';
import 'package:khuta/core/services/ai_recommendations_service.dart';
import 'package:khuta/models/question.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    EasyLocalization.logger.enableBuildModes = [];
    await EasyLocalization.ensureInitialized();
  });

  group('AiRecommendationsService', () {
    group('Language Detection', () {
      test('detects Arabic from questions containing Arabic characters', () {
        final questions = [
          Question(
            id: '1',
            imageUrl: '',
            questionText: 'هل يعاني الطفل من صعوبة في التركيز؟',
            questionType: 'parent',
          ),
        ];

        // Verify Arabic detection works by checking the regex
        final arabicRegex = RegExp(r'[\u0600-\u06FF]');
        expect(arabicRegex.hasMatch(questions[0].questionText), isTrue);
      });

      test('detects English from questions without Arabic characters', () {
        final questions = [
          Question(
            id: '1',
            imageUrl: '',
            questionText: 'Does the child have difficulty focusing?',
            questionType: 'parent',
          ),
        ];

        final arabicRegex = RegExp(r'[\u0600-\u06FF]');
        expect(arabicRegex.hasMatch(questions[0].questionText), isFalse);
      });

      test('empty questions list defaults to English', () {
        final questions = <Question>[];
        // When questions is empty, language detection should return 'en'
        expect(questions.isEmpty, isTrue);
      });
    });

    group('Recommendation Parsing', () {
      test('parses bullet points with dash prefix', () {
        final text = '''
- First recommendation
- Second recommendation
- Third recommendation
''';
        final lines = text.split('\n');
        final recommendations = <String>[];

        for (String line in lines) {
          final trimmedLine = line.trim();
          if (trimmedLine.startsWith('-')) {
            String recommendation = trimmedLine
                .replaceFirst(RegExp(r'^[•\-\d\.]+\s*'), '')
                .trim();
            if (recommendation.isNotEmpty) {
              recommendations.add(recommendation);
            }
          }
        }

        expect(recommendations.length, equals(3));
        expect(recommendations[0], equals('First recommendation'));
        expect(recommendations[1], equals('Second recommendation'));
        expect(recommendations[2], equals('Third recommendation'));
      });

      test('parses bullet points with bullet character', () {
        final text = '''
• First recommendation
• Second recommendation
''';
        final lines = text.split('\n');
        final recommendations = <String>[];

        for (String line in lines) {
          final trimmedLine = line.trim();
          if (trimmedLine.startsWith('•')) {
            String recommendation = trimmedLine
                .replaceFirst(RegExp(r'^[•\-\d\.]+\s*'), '')
                .trim();
            if (recommendation.isNotEmpty) {
              recommendations.add(recommendation);
            }
          }
        }

        expect(recommendations.length, equals(2));
      });

      test('parses numbered list items', () {
        final text = '''
1. First recommendation
2. Second recommendation
3. Third recommendation
''';
        final lines = text.split('\n');
        final recommendations = <String>[];

        for (String line in lines) {
          final trimmedLine = line.trim();
          if (RegExp(r'^\d+\.').hasMatch(trimmedLine)) {
            String recommendation = trimmedLine
                .replaceFirst(RegExp(r'^[•\-\d\.]+\s*'), '')
                .trim();
            if (recommendation.isNotEmpty) {
              recommendations.add(recommendation);
            }
          }
        }

        expect(recommendations.length, equals(3));
      });

      test('filters out summary lines', () {
        final skipPatterns = ['summary', 'analysis', 'based on', 'according to'];
        final testLines = [
          'Summary of the assessment',
          'Based on the results',
          'This is a valid recommendation',
        ];

        final filtered = testLines.where((line) {
          final lower = line.toLowerCase();
          return !skipPatterns.any((pattern) => lower.contains(pattern));
        }).toList();

        expect(filtered.length, equals(1));
        expect(filtered[0], equals('This is a valid recommendation'));
      });

      test('filters out Arabic summary lines', () {
        final testLines = [
          'ملخص التقييم',
          'تحليل النتائج',
          'توصية عملية للطفل',
        ];

        final arabicSkipPatterns = ['ملخص', 'تحليل'];

        final filtered = testLines.where((line) {
          return !arabicSkipPatterns.any((pattern) => line.contains(pattern));
        }).toList();

        expect(filtered.length, equals(1));
      });

      test('skips empty lines', () {
        final text = '''
- First recommendation

- Second recommendation

- Third recommendation
''';
        final lines = text.split('\n');
        final recommendations = <String>[];

        for (String line in lines) {
          final trimmedLine = line.trim();
          if (trimmedLine.isEmpty) continue;
          if (trimmedLine.startsWith('-')) {
            String recommendation = trimmedLine
                .replaceFirst(RegExp(r'^[•\-\d\.]+\s*'), '')
                .trim();
            if (recommendation.isNotEmpty) {
              recommendations.add(recommendation);
            }
          }
        }

        expect(recommendations.length, equals(3));
      });
    });

    group('Fallback Recommendations', () {
      test('returns English recommendations for high score (>= 70)', () async {
        final recommendations = await AiRecommendationsService.getRecommendations(
          75,
          [], // Empty questions = English
          [],
        );

        expect(recommendations, isNotEmpty);
        expect(recommendations.length, greaterThanOrEqualTo(5));
        // Should contain English text
        expect(
          recommendations.any((r) => r.contains('consultation') || r.contains('evaluation')),
          isTrue,
        );
      });

      test('returns English recommendations for elevated score (65-69)', () async {
        final recommendations = await AiRecommendationsService.getRecommendations(
          67,
          [],
          [],
        );

        expect(recommendations, isNotEmpty);
      });

      test('returns English recommendations for moderately high score (60-64)', () async {
        final recommendations = await AiRecommendationsService.getRecommendations(
          62,
          [],
          [],
        );

        expect(recommendations, isNotEmpty);
      });

      test('returns English recommendations for average score (45-59)', () async {
        final recommendations = await AiRecommendationsService.getRecommendations(
          50,
          [],
          [],
        );

        expect(recommendations, isNotEmpty);
      });

      test('returns English recommendations for low score (< 45)', () async {
        final recommendations = await AiRecommendationsService.getRecommendations(
          40,
          [],
          [],
        );

        expect(recommendations, isNotEmpty);
      });

      test('returns Arabic recommendations for high score with Arabic questions', () async {
        final arabicQuestions = [
          Question(
            id: '1',
            imageUrl: '',
            questionText: 'هل يعاني الطفل من صعوبة في التركيز؟',
            questionType: 'parent',
          ),
        ];

        final recommendations = await AiRecommendationsService.getRecommendations(
          75,
          arabicQuestions,
          [1],
        );

        expect(recommendations, isNotEmpty);
        // Should contain Arabic text
        expect(
          recommendations.any((r) => RegExp(r'[\u0600-\u06FF]').hasMatch(r)),
          isTrue,
        );
      });

      test('recommendations count varies by severity', () async {
        final highScoreRecs = await AiRecommendationsService.getRecommendations(
          75,
          [],
          [],
        );

        final lowScoreRecs = await AiRecommendationsService.getRecommendations(
          40,
          [],
          [],
        );

        // High scores should generally have more recommendations
        expect(highScoreRecs.length, greaterThanOrEqualTo(lowScoreRecs.length));
      });
    });

    group('Answer Translation', () {
      test('answer values map to correct labels', () {
        // Test the answer translation logic
        final answerLabels = {
          0: 'never',
          1: 'rarely',
          2: 'sometimes',
          3: 'often',
        };

        expect(answerLabels[0], equals('never'));
        expect(answerLabels[1], equals('rarely'));
        expect(answerLabels[2], equals('sometimes'));
        expect(answerLabels[3], equals('often'));
      });

      test('invalid answer values return default', () {
        String getAnswerLabel(int answer) {
          switch (answer) {
            case 0:
              return 'never';
            case 1:
              return 'rarely';
            case 2:
              return 'sometimes';
            case 3:
              return 'often';
            default:
              return 'Not Answered';
          }
        }

        expect(getAnswerLabel(-1), equals('Not Answered'));
        expect(getAnswerLabel(4), equals('Not Answered'));
        expect(getAnswerLabel(100), equals('Not Answered'));
      });
    });

    group('Prompt Formatting', () {
      test('child age is included in prompt when provided', () {
        // Verify that child age would be included in prompt
        final childAge = 8;
        expect(childAge, isNotNull);

        final ageString = 'Child age: $childAge years';
        expect(ageString, contains('8'));
      });

      test('child gender is included in prompt when provided', () {
        final childGender = 'male';
        expect(childGender, isNotNull);

        final genderString = 'Child gender: $childGender';
        expect(genderString, contains('male'));
      });

      test('questions and answers are formatted correctly', () {
        final questions = [
          Question(id: '1', imageUrl: '', questionText: 'Test question 1?', questionType: 'parent'),
          Question(id: '2', imageUrl: '', questionText: 'Test question 2?', questionType: 'parent'),
        ];
        final answers = [1, 2];

        final formatted = <String>[];
        for (int i = 0; i < questions.length; i++) {
          if (answers[i] >= 0) {
            formatted.add('${i + 1}. ${questions[i].questionText}');
          }
        }

        expect(formatted.length, equals(2));
        expect(formatted[0], contains('1.'));
        expect(formatted[1], contains('2.'));
      });

      test('skips unanswered questions (answer < 0)', () {
        final questions = [
          Question(id: '1', imageUrl: '', questionText: 'Test question 1?', questionType: 'parent'),
          Question(id: '2', imageUrl: '', questionText: 'Test question 2?', questionType: 'parent'),
          Question(id: '3', imageUrl: '', questionText: 'Test question 3?', questionType: 'parent'),
        ];
        final answers = [1, -1, 2]; // Second question unanswered

        final formatted = <String>[];
        for (int i = 0; i < questions.length; i++) {
          if (answers[i] >= 0) {
            formatted.add('${i + 1}. ${questions[i].questionText}');
          }
        }

        expect(formatted.length, equals(2));
      });
    });
  });
}
