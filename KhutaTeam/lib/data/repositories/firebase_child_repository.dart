import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khuta/core/repositories/child_repository.dart';
import 'package:khuta/models/child.dart';

/// Firebase Firestore implementation of ChildRepository.
/// Handles all child data operations through Firestore.
class FirebaseChildRepository implements ChildRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseChildRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _childrenCollection {
    if (_userId == null) throw Exception('User not authenticated');
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('children');
  }

  @override
  Future<List<Child>> getChildren() async {
    final snapshot = await _childrenCollection
        .orderBy('createdAt', descending: false)
        .get();

    // Filter out soft-deleted children client-side
    // This handles both old records without isDeleted field and new ones
    return snapshot.docs
        .map((doc) => Child.fromFirestore(doc))
        .where((child) => !child.isDeleted)
        .toList();
  }

  @override
  Future<Child?> getChild(String childId) async {
    final doc = await _childrenCollection.doc(childId).get();
    if (!doc.exists) return null;
    final child = Child.fromFirestore(doc);
    return child.isDeleted ? null : child;
  }

  @override
  Future<String> addChild(Child child) async {
    final docRef = await _childrenCollection.add(child.toFirestore());
    return docRef.id;
  }

  @override
  Future<void> updateChild(Child child) async {
    await _childrenCollection.doc(child.id).update(child.toFirestore());
  }

  @override
  Future<void> deleteChild(String childId) async {
    await _childrenCollection.doc(childId).update({
      'isDeleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<Child>> watchChildren() {
    return _childrenCollection
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Child.fromFirestore(doc))
            .where((child) => !child.isDeleted)
            .toList());
  }

  @override
  Future<PaginatedChildren> getChildrenPaginated({
    int limit = 20,
    Object? startAfter,
  }) async {
    var query = _childrenCollection
        .orderBy('createdAt', descending: false)
        .limit(limit + 1); // Fetch one extra to check if more exist

    if (startAfter != null && startAfter is DocumentSnapshot) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    final docs = snapshot.docs;

    // Filter out soft-deleted children
    final children = docs
        .map((doc) => Child.fromFirestore(doc))
        .where((child) => !child.isDeleted)
        .toList();

    // Determine if there are more pages
    final hasMore = docs.length > limit;
    final childrenToReturn = hasMore ? children.take(limit).toList() : children;

    // Use the last document as cursor for next page
    final nextCursor = hasMore && docs.isNotEmpty ? docs[limit - 1] : null;

    return PaginatedChildren(
      children: childrenToReturn,
      nextPageCursor: nextCursor,
    );
  }
}
