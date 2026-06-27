import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:khuta/models/appointment.dart';
import 'package:khuta/models/doctor.dart';
import 'package:khuta/screens/main_screen.dart';

class AppointmentSuccessScreen extends StatelessWidget {
  final Appointment appointment;
  final Doctor doctor;

  const AppointmentSuccessScreen({
    super.key,
    required this.appointment,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A56DB),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            _buildSuccessAnimation(),
            const SizedBox(height: 32),
            _buildTitle(),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildDetailsCard(context),
            ),
            const Spacer(),
            _buildBottomButtons(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15), // FIXED: withOpacity instead of withValues
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.check_circle_rounded,
          color: Colors.white,
          size: 72,
        ),
      ),
    )
        .animate()
        .scale(duration: 600.ms, curve: Curves.elasticOut)
        .fadeIn(duration: 400.ms);
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'booking_success_title'.tr(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.2),
        const SizedBox(height: 8),
        Text(
          'booking_success_subtitle'.tr(),
          style: TextStyle(
            color: Colors.orange.withOpacity(0.1), // FIXED: withOpacity
            fontSize: 15,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
      ],
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15), // FIXED: withOpacity
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            // FIXED: Removed const from BoxDecoration to resolve Radius.circular errors
            decoration: const BoxDecoration(
              color: Color(0xFF1A56DB),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  'appointment_details'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _AppointmentDetailRow(
                  icon: Icons.medical_services_rounded,
                  label: 'doctor'.tr(),
                  value: appointment.doctorName,
                ),
                const Divider(height: 20),
                _AppointmentDetailRow(
                  icon: Icons.child_care_rounded,
                  label: 'child'.tr(),
                  value: appointment.childName,
                ),
                const Divider(height: 20),
                _AppointmentDetailRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'date'.tr(),
                  value: DateFormat('EEEE, MMMM d, yyyy')
                      .format(appointment.appointmentDate),
                ),
                const Divider(height: 20),
                _AppointmentDetailRow(
                  icon: Icons.access_time_rounded,
                  label: 'time'.tr(),
                  value: appointment.timeSlot,
                ),
                const Divider(height: 20),
                _AppointmentDetailRow(
                  icon: Icons.location_on_rounded,
                  label: 'clinic'.tr(),
                  value: doctor.clinicAddress,
                ),
                const Divider(height: 20),
                _AppointmentDetailRow(
                  icon: Icons.attach_money_rounded,
                  label: 'fee'.tr(),
                  value:
                      '${appointment.consultationPrice.toStringAsFixed(0)} ${'currency'.tr()}',
                  valueColor: const Color(0xFF1A56DB),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1), // FIXED: withOpacity
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.orange.withOpacity(0.3)), // FIXED: withOpacity
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.pending_rounded,
                          color: Colors.orange, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'status_pending'.tr(),
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 500.ms, duration: 500.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MainScreen()),
                (route) => false,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1A56DB),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(
                'back_to_home'.tr(),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _AppointmentDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1A56DB)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}