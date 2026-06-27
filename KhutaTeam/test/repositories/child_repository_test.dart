import 'package:flutter_test/flutter_test.dart';
import 'package:khuta/models/child.dart';
import 'mock_child_repository.dart';

void main() {
  late MockChildRepository repository;

  setUp(() {
    repository = MockChildRepository();
    TestChildFactory.reset();
  });

  tearDown(() {
    repository.dispose();
  });

  group('ChildRepository', () {
    group('getChildren', () {
      test('returns empty list when no children exist', () async {
        final children = await repository.getChildren();
        expect(children, isEmpty);
      });

      test('returns all non-deleted children', () async {
        repository.seedChild(TestChildFactory.create(id: '1', name: 'Child 1'));
        repository.seedChild(TestChildFactory.create(id: '2', name: 'Child 2'));
        repository.seedChild(TestChildFactory.create(id: '3', name: 'Child 3'));

        final children = await repository.getChildren();

        expect(children.length, equals(3));
      });

      test('excludes deleted children', () async {
        repository.seedChild(TestChildFactory.create(id: '1', name: 'Active'));
        repository.seedChild(
            TestChildFactory.create(id: '2', name: 'Deleted', isDeleted: true));

        final children = await repository.getChildren();

        expect(children.length, equals(1));
        expect(children.first.name, equals('Active'));
      });

      test('throws exception when configured to fail', () async {
        repository.setThrowOnNextOperation('Database error');

        expect(
          () => repository.getChildren(),
          throwsException,
        );
      });
    });

    group('getChild', () {
      test('returns child by ID when exists', () async {
        repository.seedChild(TestChildFactory.create(id: 'test_id', name: 'Test'));

        final child = await repository.getChild('test_id');

        expect(child, isNotNull);
        expect(child!.name, equals('Test'));
      });

      test('returns null when child does not exist', () async {
        final child = await repository.getChild('nonexistent');

        expect(child, isNull);
      });

      test('returns null for deleted child', () async {
        repository.seedChild(
            TestChildFactory.create(id: 'deleted_id', isDeleted: true));

        final child = await repository.getChild('deleted_id');

        expect(child, isNull);
      });
    });

    group('addChild', () {
      test('adds child and returns ID', () async {
        final newChild = TestChildFactory.create(name: 'New Child');

        final id = await repository.addChild(newChild);

        expect(id, isNotEmpty);
        final children = await repository.getChildren();
        expect(children.length, equals(1));
        expect(children.first.name, equals('New Child'));
      });

      test('generates unique IDs for each child', () async {
        final id1 = await repository.addChild(TestChildFactory.create());
        final id2 = await repository.addChild(TestChildFactory.create());

        expect(id1, isNot(equals(id2)));
      });

      test('throws exception when configured to fail', () async {
        repository.setThrowOnNextOperation();

        expect(
          () => repository.addChild(TestChildFactory.create()),
          throwsException,
        );
      });
    });

    group('updateChild', () {
      test('updates existing child', () async {
        repository.seedChild(TestChildFactory.create(id: 'update_id', name: 'Old Name'));

        final updatedChild = Child(
          id: 'update_id',
          name: 'New Name',
          gender: 'male',
          age: 10,
          testResults: [],
          createdAt: DateTime.now(),
        );

        await repository.updateChild(updatedChild);

        final child = await repository.getChild('update_id');
        expect(child!.name, equals('New Name'));
        expect(child.age, equals(10));
      });

      test('throws exception when child does not exist', () async {
        final nonExistentChild = TestChildFactory.create(id: 'nonexistent');

        expect(
          () => repository.updateChild(nonExistentChild),
          throwsException,
        );
      });
    });

    group('deleteChild', () {
      test('soft deletes child by setting isDeleted flag', () async {
        repository.seedChild(TestChildFactory.create(id: 'delete_id'));

        await repository.deleteChild('delete_id');

        final child = await repository.getChild('delete_id');
        expect(child, isNull);

        // Verify child still exists but is marked as deleted
        final allChildren = repository.allChildrenIncludingDeleted;
        final deletedChild = allChildren.firstWhere((c) => c.id == 'delete_id');
        expect(deletedChild.isDeleted, isTrue);
      });

      test('child no longer appears in getChildren after deletion', () async {
        repository.seedChild(TestChildFactory.create(id: 'delete_id'));
        expect((await repository.getChildren()).length, equals(1));

        await repository.deleteChild('delete_id');

        expect((await repository.getChildren()).length, equals(0));
      });

      test('throws exception when child does not exist', () async {
        expect(
          () => repository.deleteChild('nonexistent'),
          throwsException,
        );
      });
    });

    group('watchChildren', () {
      test('emits updates when children change', () async {
        final stream = repository.watchChildren();
        final emissions = <List<Child>>[];

        final subscription = stream.listen((children) {
          emissions.add(children);
        });

        // Trigger an update by adding a child
        await repository.addChild(TestChildFactory.create(name: 'Stream Test'));

        await Future.delayed(const Duration(milliseconds: 50));

        expect(emissions, isNotEmpty);
        expect(emissions.last.length, equals(1));
        expect(emissions.last.first.name, equals('Stream Test'));

        await subscription.cancel();
      });

      test('stream excludes deleted children', () async {
        final stream = repository.watchChildren();
        final emissions = <List<Child>>[];

        final subscription = stream.listen((children) {
          emissions.add(children);
        });

        final id = await repository.addChild(TestChildFactory.create());
        await Future.delayed(const Duration(milliseconds: 50));
        expect(emissions.last.length, equals(1));

        await repository.deleteChild(id);
        await Future.delayed(const Duration(milliseconds: 50));
        expect(emissions.last.length, equals(0));

        await subscription.cancel();
      });
    });

    group('Child model', () {
      test('copyWithDeleted creates deleted copy', () {
        final child = TestChildFactory.create();
        expect(child.isDeleted, isFalse);

        final deletedChild = child.copyWithDeleted();

        expect(deletedChild.isDeleted, isTrue);
        expect(deletedChild.id, equals(child.id));
        expect(deletedChild.name, equals(child.name));
        expect(deletedChild.updatedAt, isNotNull);
      });

      test('child with test results is created correctly', () {
        final child = TestChildFactory.createWithTestResults(testCount: 3);

        expect(child.testResults.length, equals(3));
        expect(child.testResults.first.score, isNotNull);
        expect(child.testResults.first.recommendations, isNotEmpty);
      });
    });
  });
}
