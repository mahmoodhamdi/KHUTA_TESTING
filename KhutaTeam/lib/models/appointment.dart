import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String doctorId;
  final String doctorName;
  final String userId;
  final String childId;
  final String childName;
  final DateTime appointmentDate;
  final String timeSlot;
  final AppointmentStatus status;
  final String? notes;
  final double consultationPrice;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.userId,
    required this.childId,
    required this.childName,
    required this.appointmentDate,
    required this.timeSlot,
    this.status = AppointmentStatus.pending,
    this.notes,
    required this.consultationPrice,
    required this.createdAt,
    this.updatedAt,
  });

  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Appointment(
      id: doc.id,
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      userId: data['userId'] ?? '',
      childId: data['childId'] ?? '',
      childName: data['childName'] ?? '',
      appointmentDate: (data['appointmentDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      timeSlot: data['timeSlot'] ?? '',
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'pending'),
        orElse: () => AppointmentStatus.pending,
      ),
      notes: data['notes'],
      consultationPrice: (data['consultationPrice'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'userId': userId,
      'childId': childId,
      'childName': childName,
      'appointmentDate': Timestamp.fromDate(appointmentDate),
      'timeSlot': timeSlot,
      'status': status.name,
      'notes': notes,
      'consultationPrice': consultationPrice,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  Appointment copyWith({
    AppointmentStatus? status,
    String? notes,
    DateTime? updatedAt,
  }) {
    return Appointment(
      id: id,
      doctorId: doctorId,
      doctorName: doctorName,
      userId: userId,
      childId: childId,
      childName: childName,
      appointmentDate: appointmentDate,
      timeSlot: timeSlot,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      consultationPrice: consultationPrice,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum AppointmentStatus {
  pending,
  confirmed,
  completed,
  cancelled,
}
