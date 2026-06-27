import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khuta/core/repositories/test_result_repository.dart';
import 'package:khuta/models/test_result.dart';

/// Firebase Firestore implementation of TestResultRepository.
/// Handles all test result data operations through Firestore.
class FirebaseTestResultRepository implements TestResultRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseTestResultRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _testResultsCollection(String childId) {
    if (_userId == null) throw Exception('User not authenticated');
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('children')
        .doc(childId)
        .collection('testResults');
  }

  @override
  Future<List<TestResult>> getTestResults(String childId) async {
    final snapshot = await _testResultsCollection(childId)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => TestResult.fromMap({...doc.data(), 'id': doc.id}))
        .toList();
  }

  @override
  Future<TestResult?> getTestResult(String childId, String resultId) async {
    final doc = await _testResultsCollection(childId).doc(resultId).get();
    if (!doc.exists) return null;
    return TestResult.fromMap({...doc.data()!, 'id': doc.id});
  }

  @override
  Future<String> saveTestResult(String childId, TestResult result) async {
    final docRef = await _testResultsCollection(childId).add(result.toMap());
    return docRef.id;
  }

  @override
  Stream<List<TestResult>> watchTestResults(String childId) {
    return _testResultsCollection(childId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TestResult.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }
}
