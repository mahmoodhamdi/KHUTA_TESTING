import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khuta/models/appointment.dart';
import 'package:khuta/models/doctor.dart';

class DoctorRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DoctorRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _doctorsCollection =>
      _firestore.collection('doctors');

  CollectionReference<Map<String, dynamic>> get _appointmentsCollection =>
      _firestore.collection('appointments');

  String? get _userId => _auth.currentUser?.uid;

  // ─── Doctor CRUD ──────────────────────────────────────────────

  Future<List<Doctor>> getDoctors({bool activeOnly = true}) async {
    Query<Map<String, dynamic>> query = _doctorsCollection;
    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }
    final snapshot = await query.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => Doctor.fromFirestore(doc)).toList();
  }

  Stream<List<Doctor>> watchDoctors({bool activeOnly = true}) {
    Query<Map<String, dynamic>> query = _doctorsCollection;
    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }
    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Doctor.fromFirestore(d)).toList());
  }

  Future<Doctor?> getDoctor(String doctorId) async {
    final doc = await _doctorsCollection.doc(doctorId).get();
    if (!doc.exists) return null;
    return Doctor.fromFirestore(doc);
  }

  Future<String> addDoctor(Doctor doctor) async {
    final docRef = await _doctorsCollection.add(doctor.toFirestore());
    return docRef.id;
  }

  Future<void> updateDoctor(Doctor doctor) async {
    final data = doctor.toFirestore();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _doctorsCollection.doc(doctor.id).update(data);
  }

  Future<void> deleteDoctor(String doctorId) async {
    await _doctorsCollection.doc(doctorId).update({
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> hardDeleteDoctor(String doctorId) async {
    await _doctorsCollection.doc(doctorId).delete();
  }

  Future<void> incrementAdhdCases(String doctorId) async {
    await _doctorsCollection.doc(doctorId).update({
      'adhdCasesHandled': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── Appointment CRUD ──────────────────────────────────────────

  Future<String> createAppointment(Appointment appointment) async {
    final batch = _firestore.batch();

    final apptRef = _appointmentsCollection.doc();
    batch.set(apptRef, appointment.toFirestore());

    // Increment doctor's ADHD cases count
    final doctorRef = _doctorsCollection.doc(appointment.doctorId);
    batch.update(doctorRef, {
      'adhdCasesHandled': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    return apptRef.id;
  }

  Future<List<Appointment>> getUserAppointments() async {
    if (_userId == null) throw Exception('User not authenticated');
    final snapshot = await _appointmentsCollection
        .where('userId', isEqualTo: _userId)
        .orderBy('appointmentDate', descending: true)
        .get();
    return snapshot.docs.map((d) => Appointment.fromFirestore(d)).toList();
  }

  Stream<List<Appointment>> watchUserAppointments() {
    if (_userId == null) return const Stream.empty();
    return _appointmentsCollection
        .where('userId', isEqualTo: _userId)
        .orderBy('appointmentDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Appointment.fromFirestore(d)).toList());
  }

  Future<List<Appointment>> getDoctorAppointments(String doctorId) async {
    final snapshot = await _appointmentsCollection
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('appointmentDate', descending: true)
        .get();
    return snapshot.docs.map((d) => Appointment.fromFirestore(d)).toList();
  }

  Future<List<Appointment>> getAllAppointments() async {
    final snapshot = await _appointmentsCollection
        .orderBy('appointmentDate', descending: true)
        .get();
    return snapshot.docs.map((d) => Appointment.fromFirestore(d)).toList();
  }

  Future<void> updateAppointmentStatus(String appointmentId, AppointmentStatus status) async {
    await _appointmentsCollection.doc(appointmentId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> isTimeSlotBooked({
    required String doctorId,
    required DateTime date,
    required String timeSlot,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _appointmentsCollection
        .where('doctorId', isEqualTo: doctorId)
        .where('timeSlot', isEqualTo: timeSlot)
        .where('appointmentDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('appointmentDate', isLessThan: Timestamp.fromDate(endOfDay))
        .where('status', whereIn: ['pending', 'confirmed'])
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // ─── Ratings ──────────────────────────────────────────────────

  Future<void> updateDoctorRating({
    required String doctorId,
    required double newRating,
    required int previousTotalRatings,
    required double previousAverageRating,
  }) async {
    final newTotal = previousTotalRatings + 1;
    final newAverage =
        ((previousAverageRating * previousTotalRatings) + newRating) / newTotal;

    await _doctorsCollection.doc(doctorId).update({
      'rating': newAverage,
      'totalRatings': newTotal,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
