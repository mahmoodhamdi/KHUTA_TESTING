import 'package:khuta/models/test_result.dart';

/// Abstract repository interface for test result data operations.
///
/// This interface defines the contract for managing ADHD assessment results.
/// Test results are stored as a subcollection under each child document.
///
/// ## Data Structure
///
/// Each test result contains:
/// - **testType**: The type of assessment (e.g., 'Parent Rating')
/// - **score**: The calculated T-score (standardized score)
/// - **date**: When the assessment was completed
/// - **notes**: Interpretation of the score
/// - **recommendations**: AI-generated or fallback recommendations
///
/// ## Usage
///
/// ```dart
/// final repository = ServiceLocator().testResultRepository;
///
/// // Save a new test result
/// final resultId = await repository.saveTestResult(childId, testResult);
///
/// // Get all results for a child
/// final results = await repository.getTestResults(childId);
///
/// // Watch for real-time updates
/// repository.watchTestResults(childId).listen((results) {
///   // Update UI with latest results
/// });
/// ```
abstract class TestResultRepository {
  /// Retrieves all test results for a specific child.
  ///
  /// Results are typically ordered by date (newest first).
  Future<List<TestResult>> getTestResults(String childId);

  /// Retrieves a single test result by its ID.
  ///
  /// Returns `null` if the result doesn't exist.
  Future<TestResult?> getTestResult(String childId, String resultId);

  /// Saves a new test result for a child.
  ///
  /// This is called after an assessment is completed to persist the results.
  /// Returns the generated ID of the new test result document.
  Future<String> saveTestResult(String childId, TestResult result);

  /// Returns a stream of test results for real-time updates.
  ///
  /// Useful for displaying a live history of assessments on the child's
  /// detail screen.
  Stream<List<TestResult>> watchTestResults(String childId);
}
