import 'dart:async';
import 'package:khuta/core/repositories/child_repository.dart';
import 'package:khuta/models/child.dart';
import 'package:khuta/models/test_result.dart';

/// In-memory mock implementation of ChildRepository for testing.
/// This avoids the complexity of mocking Firestore while still testing
/// repository behavior and integration patterns.
class MockChildRepository implements ChildRepository {
  final List<Child> _children = [];
  final StreamController<List<Child>> _childrenController =
      StreamController<List<Child>>.broadcast();
  int _nextId = 1;
  bool _shouldThrow = false;
  String? _errorMessage;

  /// Configure the mock to throw an exception on the next operation
  void setThrowOnNextOperation([String? message]) {
    _shouldThrow = true;
    _errorMessage = message;
  }

  void _checkThrow() {
    if (_shouldThrow) {
      _shouldThrow = false;
      throw Exception(_errorMessage ?? 'Mock error');
    }
  }

  void _notifyListeners() {
    final nonDeleted = _children.where((c) => !c.isDeleted).toList();
    _childrenController.add(nonDeleted);
  }

  /// Add a child directly for test setup (bypasses the normal add flow)
  void seedChild(Child child) {
    _children.add(child);
    _notifyListeners();
  }

  /// Clear all children (for test cleanup)
  void clear() {
    _children.clear();
    _notifyListeners();
  }

  /// Get all children including deleted ones (for testing)
  List<Child> get allChildrenIncludingDeleted => List.unmodifiable(_children);

  @override
  Future<List<Child>> getChildren() async {
    _checkThrow();
    return _children.where((c) => !c.isDeleted).toList();
  }

  @override
  Future<Child?> getChild(String childId) async {
    _checkThrow();
    try {
      final child = _children.firstWhere((c) => c.id == childId);
      return child.isDeleted ? null : child;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> addChild(Child child) async {
    _checkThrow();
    final id = 'child_${_nextId++}';
    final newChild = Child(
      id: id,
      name: child.name,
      gender: child.gender,
      age: child.age,
      testResults: child.testResults,
      createdAt: child.createdAt,
      isDeleted: false,
    );
    _children.add(newChild);
    _notifyListeners();
    return id;
  }

  @override
  Future<void> updateChild(Child child) async {
    _checkThrow();
    final index = _children.indexWhere((c) => c.id == child.id);
    if (index == -1) {
      throw Exception('Child not found');
    }
    _children[index] = child;
    _notifyListeners();
  }

  @override
  Future<void> deleteChild(String childId) async {
    _checkThrow();
    final index = _children.indexWhere((c) => c.id == childId);
    if (index == -1) {
      throw Exception('Child not found');
    }
    _children[index] = _children[index].copyWithDeleted();
    _notifyListeners();
  }

  @override
  Stream<List<Child>> watchChildren() {
    return _childrenController.stream;
  }

  @override
  Future<PaginatedChildren> getChildrenPaginated({
    int limit = 20,
    Object? startAfter,
  }) async {
    _checkThrow();
    final nonDeleted = _children.where((c) => !c.isDeleted).toList();

    int startIndex = 0;
    if (startAfter != null && startAfter is int) {
      startIndex = startAfter;
    }

    final endIndex = (startIndex + limit).clamp(0, nonDeleted.length);
    final children = nonDeleted.sublist(startIndex, endIndex);
    final hasMore = endIndex < nonDeleted.length;

    return PaginatedChildren(
      children: children,
      nextPageCursor: hasMore ? endIndex : null,
    );
  }

  void dispose() {
    _childrenController.close();
  }
}

/// Factory to create test children with sensible defaults
class TestChildFactory {
  static int _counter = 0;

  static Child create({
    String? id,
    String? name,
    String? gender,
    int? age,
    List<TestResult>? testResults,
    DateTime? createdAt,
    bool isDeleted = false,
  }) {
    _counter++;
    return Child(
      id: id ?? 'test_child_$_counter',
      name: name ?? 'Test Child $_counter',
      gender: gender ?? 'male',
      age: age ?? 8,
      testResults: testResults ?? [],
      createdAt: createdAt ?? DateTime.now(),
      isDeleted: isDeleted,
    );
  }

  static Child createWithTestResults({
    String? id,
    String? name,
    int testCount = 1,
  }) {
    _counter++;
    final results = List<TestResult>.generate(
      testCount,
      (i) => TestResult(
        testType: 'parent',
        date: DateTime.now().subtract(Duration(days: i)),
        score: 50.0 + i,
        notes: '',
        recommendations: ['Recommendation ${i + 1}'],
      ),
    );

    return Child(
      id: id ?? 'test_child_$_counter',
      name: name ?? 'Test Child $_counter',
      gender: 'male',
      age: 8,
      testResults: results,
      createdAt: DateTime.now(),
      isDeleted: false,
    );
  }

  static void reset() {
    _counter = 0;
  }
}
