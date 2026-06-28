import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';
import 'package:khuta/cubit/doctor/doctor_cubit.dart';
import 'package:khuta/cubit/doctor/doctor_state.dart';
import 'package:khuta/models/doctor.dart';
import 'package:khuta/screens/admin/add_edit_doctor_screen.dart';
import 'package:khuta/screens/admin/admin_appointments_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DoctorCubit()..loadDoctors(activeOnly: false),
      child: const _AdminDashboardView(),
    );
  }
}

class _AdminDashboardView extends StatelessWidget {
  const _AdminDashboardView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: HomeScreenTheme.backgroundColor(isDark),
      appBar: AppBar(
        title: Text('admin_dashboard'.tr()),
        backgroundColor: const Color(0xFF1A56DB),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: 'view_appointments'.tr(),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminAppointmentsScreen(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddEditDoctorScreen()),
          );
          if (result == true && context.mounted) {
            context.read<DoctorCubit>().loadDoctors(activeOnly: false);
          }
        },
        backgroundColor: const Color(0xFF1A56DB),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text('add_doctor'.tr()),
      ),
      body: BlocConsumer<DoctorCubit, DoctorState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!.tr()),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == DoctorStatus.loading ||
              state.status == DoctorStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildStats(context, state, isDark),
              Expanded(
                child: state.doctors.isEmpty
                    ? _buildEmptyState(context, isDark)
                    : _buildDoctorList(context, state, isDark),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStats(BuildContext context, DoctorState state, bool isDark) {
    final total = state.doctors.length;
    final active = state.doctors.where((d) => d.isActive).length;
    final totalCases = state.doctors.fold<int>(
      0,
      (sum, d) => sum + d.adhdCasesHandled,
    );

    return Container(
      color: const Color(0xFF1A56DB),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Row(
        children: [
          Expanded(
            child: _StatBox(
              label: 'total_doctors'.tr(),
              value: '$total',
              icon: Icons.medical_services_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatBox(
              label: 'active_doctors'.tr(),
              value: '$active',
              icon: Icons.check_circle_outline_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatBox(
              label: 'total_cases'.tr(),
              value: '$totalCases',
              icon: Icons.psychology_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorList(
    BuildContext context,
    DoctorState state,
    bool isDark,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.doctors.length,
      itemBuilder: (context, index) {
        final doctor = state.doctors[index];
        return _AdminDoctorCard(doctor: doctor, isDark: isDark, index: index);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'no_doctors_yet'.tr(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: HomeScreenTheme.primaryText(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'add_first_doctor'.tr(),
            style: TextStyle(color: HomeScreenTheme.secondaryText(isDark)),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Box ────────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

// ─── Admin Doctor Card ────────────────────────────────────────

class _AdminDoctorCard extends StatelessWidget {
  final Doctor doctor;
  final bool isDark;
  final int index;

  const _AdminDoctorCard({
    required this.doctor,
    required this.isDark,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: HomeScreenTheme.cardBackground(isDark),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [HomeScreenTheme.cardShadow(isDark)],
            border: doctor.isActive
                ? null
                : Border.all(color: Colors.red.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: _DoctorAvatarSmall(doctor: doctor),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        doctor.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: HomeScreenTheme.primaryText(isDark),
                        ),
                      ),
                    ),
                    if (!doctor.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'inactive'.tr(),
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.specialization,
                      style: const TextStyle(
                        color: Color(0xFF1A56DB),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFF59E0B),
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          doctor.rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.psychology_rounded,
                          color: Colors.teal,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${doctor.adhdCasesHandled} ${'cases'.tr()}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.attach_money_rounded,
                          color: Color(0xFF1A56DB),
                          size: 14,
                        ),
                        Text(
                          doctor.consultationPrice.toStringAsFixed(0),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.edit_rounded,
                      label: 'edit'.tr(),
                      color: const Color(0xFF1A56DB),
                      onTap: () async {
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditDoctorScreen(doctor: doctor),
                          ),
                        );
                        if (result == true && context.mounted) {
                          context.read<DoctorCubit>().loadDoctors(
                            activeOnly: false,
                          );
                        }
                      },
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey.withValues(alpha: 0.2),
                  ),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.delete_outline_rounded,
                      label: 'delete'.tr(),
                      color: Colors.red,
                      onTap: () => _showDeleteDialog(context, doctor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: index * 60))
        .fadeIn(duration: 350.ms)
        .slideX(begin: 0.15, end: 0);
  }

  void _showDeleteDialog(BuildContext context, Doctor doctor) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('delete_doctor_title'.tr()),
        content: Text('delete_doctor_confirm'.tr(args: [doctor.name])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<DoctorCubit>().deleteDoctor(doctor.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'delete'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorAvatarSmall extends StatelessWidget {
  final Doctor doctor;
  const _DoctorAvatarSmall({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A56DB), Color(0xFF0E3B8A)],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          doctor.name.isNotEmpty ? doctor.name[0].toUpperCase() : 'D',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
