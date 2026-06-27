import 'package:khuta/core/repositories/child_repository.dart';
import 'package:khuta/core/repositories/test_result_repository.dart';
import 'package:khuta/data/repositories/doctor_repository.dart';
import 'package:khuta/data/repositories/firebase_child_repository.dart';
import 'package:khuta/data/repositories/firebase_test_result_repository.dart';

/// Simple service locator for dependency injection.
/// Provides singleton instances of repositories.
/// Supports testing by allowing mock repositories to be registered.
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  ChildRepository? _childRepository;
  TestResultRepository? _testResultRepository;
  DoctorRepository? _doctorRepository;

  /// Get the child repository instance
  ChildRepository get childRepository {
    _childRepository ??= FirebaseChildRepository();
    return _childRepository!;
  }

  /// Get the test result repository instance
  TestResultRepository get testResultRepository {
    _testResultRepository ??= FirebaseTestResultRepository();
    return _testResultRepository!;
  }

  /// Get the doctor repository instance
  DoctorRepository get doctorRepository {
    _doctorRepository ??= DoctorRepository();
    return _doctorRepository!;
  }

  /// For testing - register a mock child repository
  void registerChildRepository(ChildRepository repository) {
    _childRepository = repository;
  }

  /// For testing - register a mock test result repository
  void registerTestResultRepository(TestResultRepository repository) {
    _testResultRepository = repository;
  }

  /// Reset all repositories (useful for testing)
  void reset() {
    _childRepository = null;
    _testResultRepository = null;
    _doctorRepository = null;
  }
}
