import 'package:equatable/equatable.dart';
import 'package:khuta/models/appointment.dart';
import 'package:khuta/models/doctor.dart';

enum DoctorStatus { initial, loading, loaded, submitting, success, error }

enum DoctorFilter { none, rating, experience, price, availability }

class DoctorState extends Equatable {
  final DoctorStatus status;
  final List<Doctor> doctors;
  final List<Doctor> filteredDoctors;
  final String searchQuery;
  final DoctorFilter activeFilter;
  final String? errorMessage;
  final String? successMessage;

  const DoctorState({
    this.status = DoctorStatus.initial,
    this.doctors = const [],
    this.filteredDoctors = const [],
    this.searchQuery = '',
    this.activeFilter = DoctorFilter.none,
    this.errorMessage,
    this.successMessage,
  });

  DoctorState copyWith({
    DoctorStatus? status,
    List<Doctor>? doctors,
    List<Doctor>? filteredDoctors,
    String? searchQuery,
    DoctorFilter? activeFilter,
    String? errorMessage,
    String? successMessage,
  }) {
    return DoctorState(
      status: status ?? this.status,
      doctors: doctors ?? this.doctors,
      filteredDoctors: filteredDoctors ?? this.filteredDoctors,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilter: activeFilter ?? this.activeFilter,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        doctors,
        filteredDoctors,
        searchQuery,
        activeFilter,
        errorMessage,
        successMessage,
      ];
}

// ─── Appointment States ─────────────────────────────────────────

enum AppointmentStatus2 { initial, loading, loaded, booking, booked, error }

class AppointmentState extends Equatable {
  final AppointmentStatus2 status;
  final List<Appointment> appointments;
  final String? selectedDoctorId;
  final DateTime? selectedDate;
  final String? selectedTimeSlot;
  final String? errorMessage;
  final Appointment? lastBookedAppointment;

  const AppointmentState({
    this.status = AppointmentStatus2.initial,
    this.appointments = const [],
    this.selectedDoctorId,
    this.selectedDate,
    this.selectedTimeSlot,
    this.errorMessage,
    this.lastBookedAppointment,
  });

  AppointmentState copyWith({
    AppointmentStatus2? status,
    List<Appointment>? appointments,
    String? selectedDoctorId,
    DateTime? selectedDate,
    String? selectedTimeSlot,
    String? errorMessage,
    Appointment? lastBookedAppointment,
  }) {
    return AppointmentState(
      status: status ?? this.status,
      appointments: appointments ?? this.appointments,
      selectedDoctorId: selectedDoctorId ?? this.selectedDoctorId,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      errorMessage: errorMessage,
      lastBookedAppointment: lastBookedAppointment ?? this.lastBookedAppointment,
    );
  }

  @override
  List<Object?> get props => [
        status,
        appointments,
        selectedDoctorId,
        selectedDate,
        selectedTimeSlot,
        errorMessage,
        lastBookedAppointment,
      ];
}
