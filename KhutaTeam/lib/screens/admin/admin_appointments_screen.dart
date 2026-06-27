import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';
import 'package:khuta/data/repositories/doctor_repository.dart';
import 'package:khuta/models/appointment.dart';

class AdminAppointmentsScreen extends StatefulWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  State<AdminAppointmentsScreen> createState() =>
      _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState extends State<AdminAppointmentsScreen> {
  late Future<List<Appointment>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = DoctorRepository().getAllAppointments();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: HomeScreenTheme.backgroundColor(isDark),
      appBar: AppBar(
        title: Text('all_appointments'.tr()),
        backgroundColor: const Color(0xFF1A56DB),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() {
                _appointmentsFuture = DoctorRepository().getAllAppointments();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Appointment>>(
        future: _appointmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('error_occurred'.tr()));
          }
          final appointments = snapshot.data ?? [];
          if (appointments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 72, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('no_appointments_yet'.tr(),
                      style: const TextStyle(fontSize: 18)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appt = appointments[index];
              return _AppointmentAdminCard(appt: appt, isDark: isDark);
            },
          );
        },
      ),
    );
  }
}

class _AppointmentAdminCard extends StatelessWidget {
  final Appointment appt;
  final bool isDark;

  const _AppointmentAdminCard({required this.appt, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(appt.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HomeScreenTheme.cardBackground(isDark),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [HomeScreenTheme.cardShadow(isDark)],
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  appt.doctorName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: HomeScreenTheme.primaryText(isDark),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  appt.status.name.tr(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.child_care_rounded,
            label: 'child'.tr(),
            value: appt.childName,
            isDark: isDark,
          ),
          _InfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'date'.tr(),
            value: DateFormat('EEE, MMM d, yyyy').format(appt.appointmentDate),
            isDark: isDark,
          ),
          _InfoRow(
            icon: Icons.access_time_rounded,
            label: 'time'.tr(),
            value: appt.timeSlot,
            isDark: isDark,
          ),
          _InfoRow(
            icon: Icons.attach_money_rounded,
            label: 'fee'.tr(),
            value: '${appt.consultationPrice.toStringAsFixed(0)} ${'currency'.tr()}',
            isDark: isDark,
          ),
          if (appt.notes != null && appt.notes!.isNotEmpty) ...[
            const SizedBox(height: 4),
            _InfoRow(
              icon: Icons.note_rounded,
              label: 'notes'.tr(),
              value: appt.notes!,
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.confirmed:
        return Colors.blue;
      case AppointmentStatus.completed:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return Colors.red;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 15, color: const Color(0xFF1A56DB)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: HomeScreenTheme.secondaryText(isDark),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: HomeScreenTheme.primaryText(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
