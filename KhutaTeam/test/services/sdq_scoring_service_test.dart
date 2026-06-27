import 'package:flutter_test/flutter_test.dart';
import 'package:khuta/core/services/sdq_scoring_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    EasyLocalization.logger.enableBuildModes = [];
    await EasyLocalization.ensureInitialized();
  });

  group('SdqScoringService', () {
    group('calculateTScore', () {
      test('calculates correct T-score for male 6-8 years with raw score 0', () {
        final tScore = SdqScoringService.calculateTScore(
          answers: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          gender: 'male',
          age: 7,
          assessmentType: 'parent',
        );
        expect(tScore, equals(37));
      });

      test('calculates correct T-score for male 6-8 years with raw score 5', () {
        final tScore = SdqScoringService.calculateTScore(
          answers: [1, 1, 1, 1, 1, 0, 0, 0, 0, 0],
          gender: 'male',
          age: 7,
          assessmentType: 'parent',
        );
        expect(tScore, equals(52));
      });

      test('calculates correct T-score for male 6-8 years with raw score 10', () {
        final tScore = SdqScoringService.calculateTScore(
          answers: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
          gender: 'male',
          age: 6,
          assessmentType: 'parent',
        );
        expect(tScore, equals(67));
      });

      test('calculates correct T-score for male 9-11 years', () {
        final tScore = SdqScoringService.calculateTScore(
          answers: [1, 1, 1, 1, 1, 0, 0, 0, 0, 0],
          gender: 'male',
          age: 10,
          assessmentType: 'parent',
        );
        expect(tScore, equals(53));
      });

      test('calculates correct T-score for male 12-14 years', () {
        final tScore = SdqScoringService.calculateTScore(
          answers: [1, 1, 1, 1, 1, 0, 0, 0, 0, 0],
          gender: 'male',
          age: 13,
          assessmentType: 'parent',
        );
        expect(tScore, equals(53));
      });

      test('calculates correct T-score for male 15-17 years', () {
        final tScore = SdqScoringService.calculateTScore(
          answers: [1, 1, 1, 1, 1, 0, 0, 0, 0, 0],
          gender: 'male',
          age: 16,
          assessmentType: 'parent',
        );
        expect(tScore, equals(56));
      });

      test('calculates correct T-score for female 6-8 years', () {
        final tScore = SdqScoringService.calculateTScore(
          answers: [1, 1, 1, 1, 1, 0, 0, 0, 0, 0],
          gender: 'female',
          age: 7,
          assessmentType: 'parent',
        );
        expect(tScore, equals(56));
      });

      test('calculates correct T-score for female 9-11 years', () {
        final tScore = SdqScoringService.calculateTScore(
          answers: [1, 1, 1, 1, 1, 0, 0, 0, 0, 0],
          gender: 'female',
          age: 10,
          assessmentType: 'parent',
        );
        expect(tScore, equals(57));
      });

      test('calculates correct T-score for female 12-14 years', () {
        final tScore = SdqScoringService.calculateTScore(
          answers: [1, 1, 1, 1, 1, 0, 0, 0, 0, 0],
          gender: 'female',
          age: 13,
          assessmentType: 'parent',
        );
        expect(tScore, equals(58));
      });

      test('calculates correct T-score for female 15-17 years', () {
        final tScore = SdqScoringService.calculateTScore(
          answers: [1, 1, 1, 1, 1, 0, 0, 0, 0, 0],
          gender: 'female',
          age: 16,
          assessmentType: 'parent',
        );
        expect(tScore, equals(60));
      });

      test('throws exception for age too young (5 years)', () {
        expect(
          () => SdqScoringService.calculateTScore(
            answers: [1, 1, 1, 1, 1],
            gender: 'male',
            age: 5,
            assessmentType: 'parent',
          ),
          throwsException,
        );
      });

      test('throws exception for age too old (18 years)', () {
        expect(
          () => SdqScoringService.calculateTScore(
            answers: [1, 1, 1, 1, 1],
            gender: 'male',
            age: 18,
            assessmentType: 'parent',
          ),
          throwsException,
        );
      });

      test('handles boundary age 6 correctly', () {
        final tScore = SdqScoringService.calculateTScore(
          answers: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          gender: 'male',
          age: 6,
          assessmentType: 'parent',
        );
        expect(tScore, equals(37));
      });

      test('handles boundary age 8 correctly', () {
        final tScore = SdqScoringService.calculateTScore(
          answers: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          gender: 'male',
          age: 8,
          assessmentType: 'parent',
        );
        expect(tScore, equals(37));
      });

      test('handles boundary age 9 correctly', () {
        final tScore = SdqScoringService.calculateTScore(
          answers: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          gender: 'male',
          age: 9,
          assessmentType: 'parent',
        );
        expect(tScore, equals(37));
      });

      test('handles boundary age 17 correctly', () {
        final tScore = SdqScoringService.calculateTScore(
          answers: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          gender: 'male',
          age: 17,
          assessmentType: 'parent',
        );
        expect(tScore, equals(39));
      });

      test('handles max score (10) correctly for all answer values', () {
        final tScore = SdqScoringService.calculateTScore(
          answers: [2, 2, 2, 2, 2, 0, 0, 0, 0, 0],
          gender: 'male',
          age: 7,
          assessmentType: 'parent',
        );
        expect(tScore, equals(67)); // raw score = 10
      });

      test('female scores are generally higher than male for same raw score', () {
        final maleScore = SdqScoringService.calculateTScore(
          answers: [1, 1, 1, 1, 1, 0, 0, 0, 0, 0],
          gender: 'male',
          age: 10,
          assessmentType: 'parent',
        );
        final femaleScore = SdqScoringService.calculateTScore(
          answers: [1, 1, 1, 1, 1, 0, 0, 0, 0, 0],
          gender: 'female',
          age: 10,
          assessmentType: 'parent',
        );
        expect(femaleScore, greaterThan(maleScore));
      });
    });

    group('getScoreInterpretation', () {
      test('returns extremely_above_average for tScore >= 70', () {
        final result = SdqScoringService.getScoreInterpretation(75);
        expect(result.toLowerCase(), contains('above'));
      });

      test('returns significantly_above_average for tScore 66-69', () {
        final result = SdqScoringService.getScoreInterpretation(67);
        expect(result.toLowerCase(), contains('above'));
      });

      test('returns above_average for tScore 61-65', () {
        final result = SdqScoringService.getScoreInterpretation(63);
        expect(result.toLowerCase(), contains('above'));
      });

      test('returns slightly_above_average for tScore 56-60', () {
        final result = SdqScoringService.getScoreInterpretation(58);
        expect(result.toLowerCase(), contains('above'));
      });

      test('returns average for tScore 45-55', () {
        final result = SdqScoringService.getScoreInterpretation(50);
        expect(result.toLowerCase(), contains('average'));
      });

      test('returns slightly_below_average for tScore 40-44', () {
        final result = SdqScoringService.getScoreInterpretation(42);
        expect(result.toLowerCase(), contains('below'));
      });

      test('returns below_average for tScore 35-39', () {
        final result = SdqScoringService.getScoreInterpretation(37);
        expect(result.toLowerCase(), contains('below'));
      });

      test('returns significantly_below_average for tScore 30-34', () {
        final result = SdqScoringService.getScoreInterpretation(32);
        expect(result.toLowerCase(), contains('below'));
      });

      test('returns extremely_below_average for tScore < 30', () {
        final result = SdqScoringService.getScoreInterpretation(25);
        expect(result.toLowerCase(), contains('below'));
      });

      test('handles boundary value 70 correctly', () {
        final result = SdqScoringService.getScoreInterpretation(70);
        expect(result, isNotEmpty);
      });

      test('handles boundary value 45 correctly', () {
        final result = SdqScoringService.getScoreInterpretation(45);
        expect(result.toLowerCase(), contains('average'));
      });

      test('handles boundary value 55 correctly', () {
        final result = SdqScoringService.getScoreInterpretation(55);
        expect(result.toLowerCase(), contains('average'));
      });
    });
  });

  group('getTScore function', () {
    test('returns correct score from table for valid inputs', () {
      final score = getTScore('parent', 'male', '6-8', 5);
      expect(score, equals(52));
    });

    test('returns -1 for invalid assessment type', () {
      final score = getTScore('invalid', 'male', '6-8', 5);
      expect(score, equals(-1));
    });

    test('returns -1 for invalid gender', () {
      final score = getTScore('parent', 'invalid', '6-8', 5);
      expect(score, equals(-1));
    });

    test('returns -1 for invalid age group', () {
      final score = getTScore('parent', 'male', 'invalid', 5);
      expect(score, equals(-1));
    });

    test('returns -1 for score out of range', () {
      final score = getTScore('parent', 'male', '6-8', 15);
      expect(score, equals(-1));
    });
  });
}
