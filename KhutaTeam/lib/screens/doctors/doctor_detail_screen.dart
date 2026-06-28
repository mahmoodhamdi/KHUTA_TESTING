import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';
import 'package:khuta/models/child.dart';
import 'package:khuta/models/doctor.dart';
import 'package:khuta/screens/doctors/booking_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorDetailScreen extends StatelessWidget {
  final Doctor doctor;
  final Child child;

  const DoctorDetailScreen({
    super.key,
    required this.doctor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: HomeScreenTheme.backgroundColor(isDark),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, isDark),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatRow(isDark),
                  const SizedBox(height: 20),
                  _buildInfoCard(context, isDark),
                  const SizedBox(height: 20),
                  _buildAvailableSection(isDark),
                  const SizedBox(height: 20),
                  _buildContactSection(context, isDark),
                  const SizedBox(height: 20),
                  _buildBookButton(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: const Color(0xFF1A56DB),
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A56DB), Color(0xFF0E3B8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              _DoctorAvatar(doctor: doctor, size: 88),
              const SizedBox(height: 12),
              Text(
                doctor.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                doctor.specialization,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.star_rounded,
            value: doctor.rating.toStringAsFixed(1),
            label: 'rating'.tr(),
            color: const Color(0xFFF59E0B),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.workspace_premium_rounded,
            value: '${doctor.yearsOfExperience}',
            label: 'years_exp'.tr(),
            color: const Color(0xFF1A56DB),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.psychology_rounded,
            value: '${doctor.adhdCasesHandled}',
            label: 'adhd_cases'.tr(),
            color: Colors.teal,
            isDark: isDark,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildInfoCard(BuildContext context, bool isDark) {
    return _Section(
      title: 'about_doctor'.tr(),
      isDark: isDark,
      child: Text(
        doctor.bio,
        style: TextStyle(
          fontSize: 14,
          height: 1.7,
          color: HomeScreenTheme.secondaryText(isDark),
        ),
      ),
    );
  }

  Widget _buildAvailableSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Section(
          title: 'available_days'.tr(),
          isDark: isDark,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: doctor.availableDays.map((day) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  day,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        _Section(
          title: 'available_times'.tr(),
          isDark: isDark,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: doctor.availableTimeSlots.map((slot) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A56DB).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF1A56DB).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: Color(0xFF1A56DB),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      slot,
                      style: const TextStyle(
                        color: Color(0xFF1A56DB),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(BuildContext context, bool isDark) {
    return _Section(
      title: 'contact_info'.tr(),
      isDark: isDark,
      child: Column(
        children: [
          _ContactTile(
            icon: Icons.location_on_rounded,
            label: doctor.clinicAddress,
            color: Colors.red,
            onTap: () async {
              final url = Uri.parse(
                'https://maps.google.com/?q=${Uri.encodeComponent(doctor.clinicAddress)}',
              );
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
          ),
          const SizedBox(height: 10),
          _ContactTile(
            icon: Icons.phone_rounded,
            label: doctor.phoneNumber,
            color: Colors.green,
            onTap: () async {
              final url = Uri.parse('tel:${doctor.phoneNumber}');
              if (await canLaunchUrl(url)) await launchUrl(url);
            },
          ),
          const SizedBox(height: 10),
          _ContactTile(
            icon: Icons.email_rounded,
            label: doctor.email,
            color: const Color(0xFF1A56DB),
            onTap: () async {
              final url = Uri.parse('mailto:${doctor.email}');
              if (await canLaunchUrl(url)) await launchUrl(url);
            },
          ),
          const SizedBox(height: 10),
          _ContactTile(
            icon: Icons.chat_rounded,
            label: 'whatsapp_contact'.tr(),
            color: const Color(0xFF25D366),
            onTap: () async {
              final cleaned = doctor.whatsappNumber.replaceAll(
                RegExp(r'[^0-9+]'),
                '',
              );
              final url = Uri.parse('https://wa.me/$cleaned');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BookingScreen(doctor: doctor, child: child),
          ),
        ),
        icon: const Icon(Icons.calendar_today_rounded),
        label: Text(
          'book_appointment'.tr(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A56DB),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}

// ─── Supporting Widgets ───────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: HomeScreenTheme.cardBackground(isDark),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [HomeScreenTheme.cardShadow(isDark)],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: HomeScreenTheme.secondaryText(isDark),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isDark;

  const _Section({
    required this.title,
    required this.child,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: HomeScreenTheme.primaryText(isDark),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 14, color: color)),
            ),
            Icon(Icons.chevron_right_rounded, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─── Doctor Avatar (local copy) ──────────────────────────────

class _DoctorAvatar extends StatelessWidget {
  final Doctor doctor;
  final double size;

  const _DoctorAvatar({required this.doctor, required this.size});

  @override
  Widget build(BuildContext context) {
    if (doctor.profileImageUrl != null && doctor.profileImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Image.network(
          doctor.profileImageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _placeholder(size),
        ),
      );
    }
    return _placeholder(size);
  }

  Widget _placeholder(double s) {
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A56DB), Color(0xFF0E3B8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(s / 2),
      ),
      child: Center(
        child: Text(
          doctor.name.isNotEmpty ? doctor.name[0].toUpperCase() : 'D',
          style: TextStyle(
            color: Colors.white,
            fontSize: s * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
