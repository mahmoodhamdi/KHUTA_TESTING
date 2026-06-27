import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';
import 'package:khuta/cubit/doctor/doctor_cubit.dart';
import 'package:khuta/cubit/doctor/doctor_state.dart';
import 'package:khuta/models/child.dart';
import 'package:khuta/models/doctor.dart';
import 'package:khuta/screens/doctors/appointment_success_screen.dart';

class BookingScreen extends StatefulWidget {
  final Doctor doctor;
  final Child child;

  const BookingScreen({super.key, required this.doctor, required this.child});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  final TextEditingController _notesController = TextEditingController();
  int _currentStep = 0;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (_) => AppointmentCubit(),
      child: BlocConsumer<AppointmentCubit, AppointmentState>(
        listener: (context, state) {
          if (state.status == AppointmentStatus2.booked &&
              state.lastBookedAppointment != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => AppointmentSuccessScreen(
                  appointment: state.lastBookedAppointment!,
                  doctor: widget.doctor,
                ),
              ),
            );
          }
          if (state.status == AppointmentStatus2.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage == 'time_slot_unavailable'
                      ? 'time_slot_unavailable'.tr()
                      : state.errorMessage ?? 'booking_error'.tr(),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: HomeScreenTheme.backgroundColor(isDark),
            appBar: AppBar(
              title: Text('book_appointment'.tr()),
              backgroundColor: const Color(0xFF1A56DB),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            body: Column(
              children: [
                _buildStepIndicator(isDark),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _buildCurrentStep(context, isDark, state),
                  ),
                ),
                _buildBottomBar(context, isDark, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepIndicator(bool isDark) {
    final steps = [
      'step_date'.tr(),
      'step_time'.tr(),
      'step_confirm'.tr(),
    ];
    return Container(
      color: const Color(0xFF1A56DB),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone || isActive
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.3),
                        ),
                        child: Center(
                          child: isDone
                              ? const Icon(Icons.check,
                                  color: Color(0xFF1A56DB), size: 16)
                              : Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isActive
                                        ? const Color(0xFF1A56DB)
                                        : Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        steps[i],
                        style: TextStyle(
                          fontSize: 10,
                          color: isActive || isDone
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.6),
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                if (i < steps.length - 1)
                  Container(
                    height: 2,
                    width: 20,
                    color: i < _currentStep
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.3),
                    margin: const EdgeInsets.only(bottom: 20),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep(
      BuildContext context, bool isDark, AppointmentState state) {
    switch (_currentStep) {
      case 0:
        return _buildDateStep(isDark);
      case 1:
        return _buildTimeStep(isDark);
      case 2:
        return _buildConfirmStep(context, isDark, state);
      default:
        return const SizedBox();
    }
  }

  Widget _buildDateStep(bool isDark) {
    final now = DateTime.now();
    final lastDate = now.add(const Duration(days: 60));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'select_appointment_date'.tr(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: HomeScreenTheme.primaryText(isDark),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: HomeScreenTheme.cardBackground(isDark),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [HomeScreenTheme.cardShadow(isDark)],
          ),
          child: CalendarDatePicker(
            initialDate: _selectedDate ?? now.add(const Duration(days: 1)),
            firstDate: now.add(const Duration(days: 1)),
            lastDate: lastDate,
            onDateChanged: (date) {
              // Filter: only allow available days
              final weekday = _weekdayName(date.weekday);
              if (widget.doctor.availableDays.any((d) =>
                  d.toLowerCase().contains(weekday.toLowerCase()))) {
                setState(() => _selectedDate = date);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('doctor_not_available_this_day'.tr()),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
          ),
        ),
        if (_selectedDate != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 10),
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate!),
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  String _weekdayName(int weekday) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return days[weekday - 1];
  }

  Widget _buildTimeStep(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'select_time_slot'.tr(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: HomeScreenTheme.primaryText(isDark),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: widget.doctor.availableTimeSlots.length,
          itemBuilder: (context, index) {
            final slot = widget.doctor.availableTimeSlots[index];
            final isSelected = slot == _selectedTimeSlot;
            return GestureDetector(
              onTap: () => setState(() => _selectedTimeSlot = slot),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1A56DB)
                      : HomeScreenTheme.cardBackground(isDark),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF1A56DB)
                        : Colors.grey.withValues(alpha: 0.3),
                  ),
                  boxShadow: [HomeScreenTheme.cardShadow(isDark)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      slot,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isSelected
                            ? Colors.white
                            : HomeScreenTheme.primaryText(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildConfirmStep(
      BuildContext context, bool isDark, AppointmentState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'confirm_appointment'.tr(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: HomeScreenTheme.primaryText(isDark),
          ),
        ),
        const SizedBox(height: 16),
        _ConfirmCard(
          doctor: widget.doctor,
          child: widget.child,
          date: _selectedDate!,
          timeSlot: _selectedTimeSlot!,
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HomeScreenTheme.cardBackground(isDark),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [HomeScreenTheme.cardShadow(isDark)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'notes_optional'.tr(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: HomeScreenTheme.primaryText(isDark),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'notes_placeholder'.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (state.status == AppointmentStatus2.booking) ...[
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildBottomBar(
      BuildContext context, bool isDark, AppointmentState state) {
    final isLoading = state.status == AppointmentStatus2.booking;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HomeScreenTheme.cardBackground(isDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () => setState(() => _currentStep--),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('back'.tr()),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: isLoading ? null : () => _onNext(context, state),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A56DB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        _currentStep == 2
                            ? 'confirm_booking'.tr()
                            : 'next'.tr(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onNext(BuildContext context, AppointmentState state) {
    if (_currentStep == 0) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('please_select_date'.tr()),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      if (_selectedTimeSlot == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('please_select_time'.tr()),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      setState(() => _currentStep = 2);
    } else {
      context.read<AppointmentCubit>().bookAppointment(
            doctor: widget.doctor,
            childId: widget.child.id,
            childName: widget.child.name,
            date: _selectedDate!,
            timeSlot: _selectedTimeSlot!,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );
    }
  }
}

// ─── Confirm Card ─────────────────────────────────────────────

class _ConfirmCard extends StatelessWidget {
  final Doctor doctor;
  final Child child;
  final DateTime date;
  final String timeSlot;
  final bool isDark;

  const _ConfirmCard({
    required this.doctor,
    required this.child,
    required this.date,
    required this.timeSlot,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A56DB).withValues(alpha: 0.05),
            const Color(0xFF0E3B8A).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFF1A56DB).withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.person_rounded,
            label: 'doctor'.tr(),
            value: doctor.name,
            isDark: isDark,
          ),
          const Divider(height: 20),
          _DetailRow(
            icon: Icons.child_care_rounded,
            label: 'child'.tr(),
            value: child.name,
            isDark: isDark,
          ),
          const Divider(height: 20),
          _DetailRow(
            icon: Icons.calendar_today_rounded,
            label: 'date'.tr(),
            value: DateFormat('EEEE, MMMM d, yyyy').format(date),
            isDark: isDark,
          ),
          const Divider(height: 20),
          _DetailRow(
            icon: Icons.access_time_rounded,
            label: 'time'.tr(),
            value: timeSlot,
            isDark: isDark,
          ),
          const Divider(height: 20),
          _DetailRow(
            icon: Icons.attach_money_rounded,
            label: 'consultation_fee'.tr(),
            value:
                '${doctor.consultationPrice.toStringAsFixed(0)} ${'currency'.tr()}',
            isDark: isDark,
            valueColor: const Color(0xFF1A56DB),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1A56DB)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: HomeScreenTheme.secondaryText(isDark),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? HomeScreenTheme.primaryText(isDark),
          ),
        ),
      ],
    );
  }
}
