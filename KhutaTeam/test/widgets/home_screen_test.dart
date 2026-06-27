import 'package:flutter_test/flutter_test.dart';
import 'package:khuta/cubit/child/child_cubit.dart';
import 'package:khuta/models/child.dart';
import 'package:khuta/models/test_result.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repositories/mock_child_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockChildRepository mockChildRepository;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    EasyLocalization.logger.enableBuildModes = [];
    await EasyLocalization.ensureInitialized();
  });

  setUp(() {
    mockChildRepository = MockChildRepository();
    TestChildFactory.reset();
  });

  tearDown(() {
    mockChildRepository.dispose();
  });

  group('ChildCubit', () {
    test('initial state is correct', () {
      final cubit = ChildCubit(repository: mockChildRepository);

      expect(cubit.state.status, equals(ChildStatus.initial));
      expect(cubit.state.children, isEmpty);
      expect(cubit.state.errorMessage, isNull);

      cubit.close();
    });

    test('loadChildren emits loading then loaded with empty list', () async {
      final cubit = ChildCubit(repository: mockChildRepository);

      final states = <ChildState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.loadChildren();

      await Future.delayed(const Duration(milliseconds: 50));

      expect(states.length, greaterThanOrEqualTo(2));
      expect(states.first.status, equals(ChildStatus.loading));
      expect(states.last.status, equals(ChildStatus.loaded));
      expect(states.last.children, isEmpty);

      await subscription.cancel();
      cubit.close();
    });

    test('loadChildren emits loaded with children when data exists', () async {
      mockChildRepository.seedChild(
        TestChildFactory.create(id: '1', name: 'Child 1'),
      );
      mockChildRepository.seedChild(
        TestChildFactory.create(id: '2', name: 'Child 2'),
      );

      final cubit = ChildCubit(repository: mockChildRepository);

      await cubit.loadChildren();

      expect(cubit.state.status, equals(ChildStatus.loaded));
      expect(cubit.state.children.length, equals(2));

      cubit.close();
    });

    test('loadChildren emits error when repository throws', () async {
      mockChildRepository.setThrowOnNextOperation('Database error');

      final cubit = ChildCubit(repository: mockChildRepository);

      await cubit.loadChildren();

      expect(cubit.state.status, equals(ChildStatus.error));
      expect(cubit.state.errorMessage, isNotNull);

      cubit.close();
    });

    test('addChild adds child and refreshes list', () async {
      final cubit = ChildCubit(repository: mockChildRepository);

      final newChild = TestChildFactory.create(name: 'New Child');
      final result = await cubit.addChild(newChild);

      expect(result, isTrue);
      expect(cubit.state.children.length, equals(1));
      expect(cubit.state.children.first.name, equals('New Child'));

      cubit.close();
    });

    test('addChild returns false and emits error when repository throws', () async {
      mockChildRepository.setThrowOnNextOperation();

      final cubit = ChildCubit(repository: mockChildRepository);

      final newChild = TestChildFactory.create();
      final result = await cubit.addChild(newChild);

      expect(result, isFalse);
      expect(cubit.state.status, equals(ChildStatus.error));

      cubit.close();
    });

    test('deleteChild removes child and refreshes list', () async {
      mockChildRepository.seedChild(
        TestChildFactory.create(id: 'delete_me'),
      );

      final cubit = ChildCubit(repository: mockChildRepository);
      await cubit.loadChildren();
      expect(cubit.state.children.length, equals(1));

      final result = await cubit.deleteChild('delete_me');

      expect(result, isTrue);
      expect(cubit.state.children, isEmpty);

      cubit.close();
    });

    test('getChildById returns correct child', () async {
      mockChildRepository.seedChild(
        TestChildFactory.create(id: 'find_me', name: 'Found Child'),
      );
      mockChildRepository.seedChild(
        TestChildFactory.create(id: 'other', name: 'Other Child'),
      );

      final cubit = ChildCubit(repository: mockChildRepository);
      await cubit.loadChildren();

      final found = cubit.getChildById('find_me');

      expect(found, isNotNull);
      expect(found!.name, equals('Found Child'));

      cubit.close();
    });

    test('getChildById returns null for non-existent child', () async {
      final cubit = ChildCubit(repository: mockChildRepository);
      await cubit.loadChildren();

      final found = cubit.getChildById('nonexistent');

      expect(found, isNull);

      cubit.close();
    });

    test('clearError resets error state to loaded', () async {
      mockChildRepository.setThrowOnNextOperation();

      final cubit = ChildCubit(repository: mockChildRepository);
      await cubit.loadChildren();
      expect(cubit.state.hasError, isTrue);

      cubit.clearError();

      expect(cubit.state.status, equals(ChildStatus.loaded));
      expect(cubit.state.errorMessage, isNull);

      cubit.close();
    });

    test('updateChild updates and refreshes list', () async {
      mockChildRepository.seedChild(
        TestChildFactory.create(id: 'update_me', name: 'Old Name'),
      );

      final cubit = ChildCubit(repository: mockChildRepository);
      await cubit.loadChildren();

      final updatedChild = Child(
        id: 'update_me',
        name: 'New Name',
        gender: 'male',
        age: 10,
        testResults: [],
        createdAt: DateTime.now(),
      );

      final result = await cubit.updateChild(updatedChild);

      expect(result, isTrue);
      expect(cubit.state.children.first.name, equals('New Name'));

      cubit.close();
    });

    test('refresh calls loadChildren', () async {
      mockChildRepository.seedChild(TestChildFactory.create());

      final cubit = ChildCubit(repository: mockChildRepository);

      await cubit.refresh();

      expect(cubit.state.status, equals(ChildStatus.loaded));
      expect(cubit.state.children.length, equals(1));

      cubit.close();
    });
  });

  group('ChildState', () {
    test('isEmpty returns true when no children', () {
      const state = ChildState(
        status: ChildStatus.loaded,
        children: [],
      );

      expect(state.isEmpty, isTrue);
    });

    test('isEmpty returns false when children exist', () {
      final state = ChildState(
        status: ChildStatus.loaded,
        children: [TestChildFactory.create()],
      );

      expect(state.isEmpty, isFalse);
    });

    test('hasError returns true for error status', () {
      const state = ChildState(
        status: ChildStatus.error,
        children: [],
        errorMessage: 'Some error',
      );

      expect(state.hasError, isTrue);
    });

    test('hasError returns false for non-error status', () {
      const state = ChildState(
        status: ChildStatus.loaded,
        children: [],
      );

      expect(state.hasError, isFalse);
    });

    test('isLoading returns true for loading status', () {
      const state = ChildState(
        status: ChildStatus.loading,
        children: [],
      );

      expect(state.isLoading, isTrue);
    });

    test('copyWith preserves unchanged values', () {
      final original = ChildState(
        status: ChildStatus.loaded,
        children: [TestChildFactory.create()],
        errorMessage: null,
      );

      final copied = original.copyWith(status: ChildStatus.error);

      expect(copied.status, equals(ChildStatus.error));
      expect(copied.children.length, equals(1));
    });
  });

  group('Child with TestResults', () {
    test('child displays latest score correctly', () {
      final testResult = TestResult(
        testType: 'parent',
        date: DateTime.now(),
        score: 55.5,
        notes: 'Average score',
        recommendations: ['Test recommendation'],
      );

      final child = Child(
        id: 'test_id',
        name: 'Test Child',
        gender: 'male',
        age: 8,
        testResults: [testResult],
        createdAt: DateTime.now(),
      );

      expect(child.testResults.isNotEmpty, isTrue);
      expect(child.testResults.last.score, equals(55.5));
    });

    test('child handles multiple test results', () {
      final testResults = [
        TestResult(
          testType: 'parent',
          date: DateTime.now().subtract(const Duration(days: 7)),
          score: 50.0,
          notes: 'Previous result',
          recommendations: ['First recommendation'],
        ),
        TestResult(
          testType: 'parent',
          date: DateTime.now(),
          score: 55.0,
          notes: 'Latest result',
          recommendations: ['Latest recommendation'],
        ),
      ];

      final child = Child(
        id: 'test_id',
        name: 'Test Child',
        gender: 'male',
        age: 8,
        testResults: testResults,
        createdAt: DateTime.now(),
      );

      expect(child.testResults.length, equals(2));
      expect(child.testResults.last.score, equals(55.0));
    });
  });
}
