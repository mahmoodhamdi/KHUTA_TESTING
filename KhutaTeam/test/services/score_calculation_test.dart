import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Score Calculation', () {
    test('Score calculation ignores unanswered questions (-1 values)', () {
      final answers = [0, 1, 2, -1, 3, -1, 2];

      // This is the same logic used in AssessmentController._showResults()
      final score = answers.where((answer) => answer >= 0).fold<int>(
        0,
        (sum, answer) => sum + answer,
      );

      // Expected: 0+1+2+3+2 = 8 (not 6 which would include -1 values)
      expect(score, equals(8));
    });

    test('Score calculation handles all valid answers', () {
      final answers = [0, 1, 2, 3, 2, 1, 0];

      final score = answers.where((answer) => answer >= 0).fold<int>(
        0,
        (sum, answer) => sum + answer,
      );

      expect(score, equals(9)); // 0+1+2+3+2+1+0 = 9
    });

    test('Score calculation handles all unanswered questions', () {
      final answers = [-1, -1, -1, -1];

      final score = answers.where((answer) => answer >= 0).fold<int>(
        0,
        (sum, answer) => sum + answer,
      );

      expect(score, equals(0));
    });

    test('Unanswered count detection works correctly', () {
      final answers = [0, 1, -1, 2, -1, 3];

      final unansweredCount = answers.where((a) => a < 0).length;

      expect(unansweredCount, equals(2));
    });

    test('No unanswered questions when all are answered', () {
      final answers = [0, 1, 2, 3, 2, 1, 0];

      final unansweredCount = answers.where((a) => a < 0).length;

      expect(unansweredCount, equals(0));
    });
  });
}
