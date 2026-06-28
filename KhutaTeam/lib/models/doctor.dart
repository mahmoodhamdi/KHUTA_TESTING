import 'package:cloud_firestore/cloud_firestore.dart';

class Doctor {
  final String id;
  final String name;
  final String specialization;
  final int yearsOfExperience;
  final String bio;
  final String phoneNumber;
  final String whatsappNumber;
  final String email;
  final String clinicAddress;
  final List<String> availableDays;
  final List<String> availableTimeSlots;
  final double consultationPrice;
  final double rating;
  final int totalRatings;
  final int adhdCasesHandled;
  final String? profileImageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.yearsOfExperience,
    required this.bio,
    required this.phoneNumber,
    required this.whatsappNumber,
    required this.email,
    required this.clinicAddress,
    required this.availableDays,
    required this.availableTimeSlots,
    required this.consultationPrice,
    this.rating = 0.0,
    this.totalRatings = 0,
    this.adhdCasesHandled = 0,
    this.profileImageUrl,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory Doctor.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? <String, dynamic>{};
    return Doctor(
      id: doc.id,
      name: data['name'] ?? '',
      specialization: data['specialization'] ?? '',
      yearsOfExperience: data['yearsOfExperience'] ?? 0,
      bio: data['bio'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      whatsappNumber: data['whatsappNumber'] ?? '',
      email: data['email'] ?? '',
      clinicAddress: data['clinicAddress'] ?? '',
      availableDays: List<String>.from(data['availableDays'] ?? []),
      availableTimeSlots: List<String>.from(data['availableTimeSlots'] ?? []),
      consultationPrice: (data['consultationPrice'] ?? 0).toDouble(),
      rating: (data['rating'] ?? 0).toDouble(),
      totalRatings: data['totalRatings'] ?? 0,
      adhdCasesHandled: data['adhdCasesHandled'] ?? 0,
      profileImageUrl: data['profileImageUrl'],
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'specialization': specialization,
      'yearsOfExperience': yearsOfExperience,
      'bio': bio,
      'phoneNumber': phoneNumber,
      'whatsappNumber': whatsappNumber,
      'email': email,
      'clinicAddress': clinicAddress,
      'availableDays': availableDays,
      'availableTimeSlots': availableTimeSlots,
      'consultationPrice': consultationPrice,
      'rating': rating,
      'totalRatings': totalRatings,
      'adhdCasesHandled': adhdCasesHandled,
      'profileImageUrl': profileImageUrl,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  Doctor copyWith({
    String? name,
    String? specialization,
    int? yearsOfExperience,
    String? bio,
    String? phoneNumber,
    String? whatsappNumber,
    String? email,
    String? clinicAddress,
    List<String>? availableDays,
    List<String>? availableTimeSlots,
    double? consultationPrice,
    double? rating,
    int? totalRatings,
    int? adhdCasesHandled,
    String? profileImageUrl,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return Doctor(
      id: id,
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      bio: bio ?? this.bio,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      email: email ?? this.email,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      availableDays: availableDays ?? this.availableDays,
      availableTimeSlots: availableTimeSlots ?? this.availableTimeSlots,
      consultationPrice: consultationPrice ?? this.consultationPrice,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      adhdCasesHandled: adhdCasesHandled ?? this.adhdCasesHandled,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
