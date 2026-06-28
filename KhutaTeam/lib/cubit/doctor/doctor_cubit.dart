import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khuta/core/services/error_handler_service.dart';
import 'package:khuta/cubit/doctor/doctor_state.dart';
import 'package:khuta/data/repositories/doctor_repository.dart';
import 'package:khuta/models/appointment.dart';
import 'package:khuta/models/doctor.dart';

class DoctorCubit extends Cubit<DoctorState> {
  final DoctorRepository _repository;

  DoctorCubit({DoctorRepository? repository})
      : _repository = repository ?? DoctorRepository(),
        super(const DoctorState());

  // ─── Load Doctors ──────────────────────────────────────────────

  Future<void> loadDoctors({bool activeOnly = true}) async {
    emit(state.copyWith(status: DoctorStatus.loading));
    try {
      final doctors = await _repository.getDoctors(activeOnly: activeOnly);
      emit(state.copyWith(
        status: DoctorStatus.loaded,
        doctors: doctors,
        filteredDoctors: doctors,
      ));
    } catch (e) {
      if (kDebugMode) debugPrint('DoctorCubit.loadDoctors: $e');
      emit(state.copyWith(
        status: DoctorStatus.error,
        errorMessage: ErrorHandlerService.getErrorMessage(e),
      ));
    }
  }

  // ─── Search & Filter ──────────────────────────────────────────

  void searchDoctors(String query) {
    final filtered = state.doctors.where((d) {
      final q = query.toLowerCase();
      return d.name.toLowerCase().contains(q) ||
          d.specialization.toLowerCase().contains(q) ||
          d.bio.toLowerCase().contains(q);
    }).toList();

    _applySort(
      doctors: filtered,
      filter: state.activeFilter,
      searchQuery: query,
    );
  }

  void applyFilter(DoctorFilter filter) {
    final query = state.searchQuery;
    List<Doctor> doctors = state.doctors;

    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      doctors = doctors
          .where((d) =>
              d.name.toLowerCase().contains(q) ||
              d.specialization.toLowerCase().contains(q))
          .toList();
    }

    // Toggle off same filter
    final newFilter = filter == state.activeFilter ? DoctorFilter.none : filter;
    _applySort(doctors: doctors, filter: newFilter, searchQuery: query);
  }

  void _applySort({
    required List<Doctor> doctors,
    required DoctorFilter filter,
    required String searchQuery,
  }) {
    final sorted = List<Doctor>.from(doctors);
    switch (filter) {
      case DoctorFilter.rating:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case DoctorFilter.experience:
        sorted.sort((a, b) => b.yearsOfExperience.compareTo(a.yearsOfExperience));
        break;
      case DoctorFilter.price:
        sorted.sort((a, b) => a.consultationPrice.compareTo(b.consultationPrice));
        break;
      case DoctorFilter.availability:
        // Doctors with more available slots first
        sorted.sort((a, b) =>
            b.availableTimeSlots.length.compareTo(a.availableTimeSlots.length));
        break;
      case DoctorFilter.none:
        break;
    }
    emit(state.copyWith(
      filteredDoctors: sorted,
      activeFilter: filter,
      searchQuery: searchQuery,
    ));
  }

  // ─── Admin: Add Doctor ─────────────────────────────────────────

  Future<void> addDoctor(Doctor doctor) async {
    emit(state.copyWith(status: DoctorStatus.submitting));
    try {
      await _repository.addDoctor(doctor);
      await loadDoctors(activeOnly: false);
      emit(state.copyWith(
        status: DoctorStatus.success,
        successMessage: 'doctor_added_success',
      ));
    } catch (e) {
      if (kDebugMode) debugPrint('DoctorCubit.addDoctor: $e');
      emit(state.copyWith(
        status: DoctorStatus.error,
        errorMessage: ErrorHandlerService.getErrorMessage(e),
      ));
    }
  }

  // ─── Admin: Update Doctor ──────────────────────────────────────

  Future<void> updateDoctor(Doctor doctor) async {
    emit(state.copyWith(status: DoctorStatus.submitting));
    try {
      await _repository.updateDoctor(doctor);
      await loadDoctors(activeOnly: false);
      emit(state.copyWith(
        status: DoctorStatus.success,
        successMessage: 'doctor_updated_success',
      ));
    } catch (e) {
      if (kDebugMode) debugPrint('DoctorCubit.updateDoctor: $e');
      emit(state.copyWith(
        status: DoctorStatus.error,
        errorMessage: ErrorHandlerService.getErrorMessage(e),
      ));
    }
  }

  // ─── Admin: Delete Doctor ──────────────────────────────────────

  Future<void> deleteDoctor(String doctorId) async {
    emit(state.copyWith(status: DoctorStatus.submitting));
    try {
      await _repository.deleteDoctor(doctorId);
      final updated = state.doctors.where((d) => d.id != doctorId).toList();
      final filteredUpdated =
          state.filteredDoctors.where((d) => d.id != doctorId).toList();
      emit(state.copyWith(
        status: DoctorStatus.loaded,
        doctors: updated,
        filteredDoctors: filteredUpdated,
        successMessage: 'doctor_deleted_success',
      ));
    } catch (e) {
      if (kDebugMode) debugPrint('DoctorCubit.deleteDoctor: $e');
      emit(state.copyWith(
        status: DoctorStatus.error,
        errorMessage: ErrorHandlerService.getErrorMessage(e),
      ));
    }
  }

  void clearMessages() {
    emit(state.copyWith(status: DoctorStatus.loaded));
  }
}

// ─── Appointment Cubit ─────────────────────────────────────────

class AppointmentCubit extends Cubit<AppointmentState> {
  final DoctorRepository _repository;

  AppointmentCubit({DoctorRepository? repository})
      : _repository = repository ?? DoctorRepository(),
        super(const AppointmentState());

  Future<void> loadUserAppointments() async {
    emit(state.copyWith(status: AppointmentStatus2.loading));
    try {
      final appointments = await _repository.getUserAppointments();
      emit(state.copyWith(
        status: AppointmentStatus2.loaded,
        appointments: appointments,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AppointmentStatus2.error,
        errorMessage: ErrorHandlerService.getErrorMessage(e),
      ));
    }
  }

  Future<void> bookAppointment({
    required Doctor doctor,
    required String childId,
    required String childName,
    required DateTime date,
    required String timeSlot,
    String? notes,
  }) async {
    emit(state.copyWith(status: AppointmentStatus2.booking));
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

      // Check if slot is already taken
      final isBooked = await _repository.isTimeSlotBooked(
        doctorId: doctor.id,
        date: date,
        timeSlot: timeSlot,
      );

      if (isBooked) {
        emit(state.copyWith(
          status: AppointmentStatus2.error,
          errorMessage: 'time_slot_unavailable',
        ));
        return;
      }

      final appointment = Appointment(
        id: '',
        doctorId: doctor.id,
        doctorName: doctor.name,
        userId: userId,
        childId: childId,
        childName: childName,
        appointmentDate: date,
        timeSlot: timeSlot,
        status: AppointmentStatus.pending,
        notes: notes,
        consultationPrice: doctor.consultationPrice,
        createdAt: DateTime.now(),
      );

      final id = await _repository.createAppointment(appointment);
      final booked = Appointment(
        id: id,
        doctorId: appointment.doctorId,
        doctorName: appointment.doctorName,
        userId: appointment.userId,
        childId: appointment.childId,
        childName: appointment.childName,
        appointmentDate: appointment.appointmentDate,
        timeSlot: appointment.timeSlot,
        status: appointment.status,
        notes: appointment.notes,
        consultationPrice: appointment.consultationPrice,
        createdAt: appointment.createdAt,
      );

      emit(state.copyWith(
        status: AppointmentStatus2.booked,
        lastBookedAppointment: booked,
      ));
    } catch (e) {
      if (kDebugMode) debugPrint('AppointmentCubit.bookAppointment: $e');
      emit(state.copyWith(
        status: AppointmentStatus2.error,
        errorMessage: ErrorHandlerService.getErrorMessage(e),
      ));
    }
  }

  void resetBooking() {
    emit(const AppointmentState());
  }
}
