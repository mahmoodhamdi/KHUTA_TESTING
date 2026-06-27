// Test Result Model
import 'package:cloud_firestore/cloud_firestore.dart';

class TestResult {
  final String testType;
  final double score;
  final DateTime date;
  final String notes;
  final List<String> recommendations;

  TestResult({
    required this.testType,
    required this.score,
    required this.date,
    required this.notes,
    this.recommendations = const [],
  });

  factory TestResult.fromMap(Map<String, dynamic> map) {
    return TestResult(
      testType: map['testType'] ?? '',
      score: (map['score'] ?? 0).toDouble(),
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: map['notes'] ?? '',
      recommendations: List<String>.from(map['recommendations'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'testType': testType,
      'score': score,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'recommendations': recommendations,
    };
  }
}
