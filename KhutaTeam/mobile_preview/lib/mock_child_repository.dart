import 'dart:async';

import 'package:khuta/core/repositories/child_repository.dart';
import 'package:khuta/models/child.dart';

/// In-memory [ChildRepository] used exclusively by the mobile_preview package.
///
/// Stores children in a local list so no Firebase Auth token or network
/// connection is required. All CRUD operations work immediately in the
/// demo environment.
class MockChildRepository implements ChildRepository {
  final List<Child> _children = [];
  int _idCounter = 1;

  final StreamController<List<Child>> _controller =
      StreamController<List<Child>>.broadcast();

  List<Child> get _active => _children.where((c) => !c.isDeleted).toList();

  void _notifyListeners() => _controller.add(List.unmodifiable(_active));

  // ─── Read ────────────────────────────────────────────────────────────────────

  @override
  Future<List<Child>> getChildren() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_active);
  }

  @override
  Future<Child?> getChild(String childId) async {
    try {
      return _active.firstWhere((c) => c.id == childId);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<List<Child>> watchChildren() => _controller.stream;

  @override
  Future<PaginatedChildren> getChildrenPaginated({
    int limit = 20,
    Object? startAfter,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final all = _active;
    int start = 0;

    if (startAfter is int) {
      start = startAfter;
    }

    final page = all.skip(start).take(limit).toList();
    final hasMore = start + limit < all.length;

    return PaginatedChildren(
      children: page,
      nextPageCursor: hasMore ? start + limit : null,
    );
  }

  // ─── Write ───────────────────────────────────────────────────────────────────

  @override
  Future<String> addChild(Child child) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final id = 'mock-child-${_idCounter++}';
    _children.add(Child(
      id: id,
      name: child.name,
      gender: child.gender,
      age: child.age,
      testResults: child.testResults,
      createdAt: child.createdAt,
      isDeleted: false,
    ));
    _notifyListeners();
    return id;
  }

  @override
  Future<void> updateChild(Child child) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _children.indexWhere((c) => c.id == child.id);
    if (index != -1) {
      _children[index] = child;
      _notifyListeners();
    }
  }

  @override
  Future<void> deleteChild(String childId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _children.indexWhere((c) => c.id == childId);
    if (index != -1) {
      _children[index] = _children[index].copyWithDeleted();
      _notifyListeners();
    }
  }
}
