import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';
import 'package:khuta/cubit/doctor/doctor_cubit.dart';
import 'package:khuta/cubit/doctor/doctor_state.dart';
import 'package:khuta/models/child.dart';
import 'package:khuta/models/doctor.dart';
import 'package:khuta/screens/doctors/booking_screen.dart';
import 'package:khuta/screens/doctors/doctor_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class SpecialistsScreen extends StatelessWidget {
  final Child child;

  const SpecialistsScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DoctorCubit()..loadDoctors(),
      child: _SpecialistsView(child: child),
    );
  }
}

class _SpecialistsView extends StatefulWidget {
  final Child child;
  const _SpecialistsView({required this.child});

  @override
  State<_SpecialistsView> createState() => _SpecialistsViewState();
}

class _SpecialistsViewState extends State<_SpecialistsView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: HomeScreenTheme.backgroundColor(isDark),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(isDark),
          SliverToBoxAdapter(child: _buildAlertBanner(isDark)),
          SliverToBoxAdapter(child: _buildSearchBar(isDark)),
          SliverToBoxAdapter(child: _buildFilterRow(isDark)),
          _buildDoctorList(isDark),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 140,
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
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'specialists_title'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'specialists_subtitle'.tr(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertBanner(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.shade50,
            Colors.orange.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.warning_amber_rounded,
                color: Colors.red.shade700, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'severe_case_alert_title'.tr(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'severe_case_alert_desc'.tr(args: [widget.child.name]),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.red.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (q) => context.read<DoctorCubit>().searchDoctors(q),
        decoration: InputDecoration(
          hintText: 'search_doctors'.tr(),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF1A56DB)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<DoctorCubit>().searchDoctors('');
                  },
                )
              : null,
          filled: true,
          fillColor: HomeScreenTheme.cardBackground(isDark),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterRow(bool isDark) {
    return BlocBuilder<DoctorCubit, DoctorState>(
      builder: (context, state) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              _FilterChip(
                label: 'filter_rating'.tr(),
                icon: Icons.star_rounded,
                isSelected: state.activeFilter == DoctorFilter.rating,
                onTap: () =>
                    context.read<DoctorCubit>().applyFilter(DoctorFilter.rating),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'filter_experience'.tr(),
                icon: Icons.workspace_premium_rounded,
                isSelected: state.activeFilter == DoctorFilter.experience,
                onTap: () =>
                    context.read<DoctorCubit>().applyFilter(DoctorFilter.experience),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'filter_price'.tr(),
                icon: Icons.attach_money_rounded,
                isSelected: state.activeFilter == DoctorFilter.price,
                onTap: () =>
                    context.read<DoctorCubit>().applyFilter(DoctorFilter.price),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'filter_availability'.tr(),
                icon: Icons.schedule_rounded,
                isSelected: state.activeFilter == DoctorFilter.availability,
                onTap: () => context
                    .read<DoctorCubit>()
                    .applyFilter(DoctorFilter.availability),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDoctorList(bool isDark) {
    return BlocBuilder<DoctorCubit, DoctorState>(
      builder: (context, state) {
        if (state.status == DoctorStatus.loading ||
            state.status == DoctorStatus.initial) {
          return SliverToBoxAdapter(
            child: Column(
              children: List.generate(3, (_) => _DoctorCardSkeleton(isDark: isDark)),
            ),
          );
        }

        if (state.status == DoctorStatus.error) {
          return SliverToBoxAdapter(
            child: _ErrorWidget(
              message: state.errorMessage ?? 'error_loading_doctors'.tr(),
              onRetry: () => context.read<DoctorCubit>().loadDoctors(),
              isDark: isDark,
            ),
          );
        }

        if (state.filteredDoctors.isEmpty) {
          return SliverToBoxAdapter(child: _EmptyDoctorsWidget(isDark: isDark));
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final doctor = state.filteredDoctors[index];
              return _DoctorCard(
                doctor: doctor,
                child: widget.child,
                index: index,
                isDark: isDark,
              );
            },
            childCount: state.filteredDoctors.length,
          ),
        );
      },
    );
  }
}

// ─── Filter Chip ──────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A56DB) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1A56DB) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Doctor Card ──────────────────────────────────────────────

class _DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final Child child;
  final int index;
  final bool isDark;

  const _DoctorCard({
    required this.doctor,
    required this.child,
    required this.index,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: HomeScreenTheme.cardBackground(isDark),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DoctorDetailScreen(doctor: doctor, child: child),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              _buildBio(),
              const SizedBox(height: 12),
              _buildAvailability(),
              const SizedBox(height: 14),
              _buildActions(context),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 80))
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.15, end: 0);
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        _DoctorAvatar(doctor: doctor, size: 64),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doctor.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: HomeScreenTheme.primaryText(isDark),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                doctor.specialization,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1A56DB),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _RatingStars(rating: doctor.rating, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${doctor.rating.toStringAsFixed(1)} (${doctor.totalRatings})',
                    style: TextStyle(
                      fontSize: 12,
                      color: HomeScreenTheme.secondaryText(isDark),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.work_outline,
                      size: 13,
                      color: HomeScreenTheme.secondaryText(isDark)),
                  const SizedBox(width: 3),
                  Text(
                    '${doctor.yearsOfExperience} ${'years_exp'.tr()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: HomeScreenTheme.secondaryText(isDark),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF1A56DB).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${doctor.consultationPrice.toStringAsFixed(0)} ${'currency'.tr()}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A56DB),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${doctor.adhdCasesHandled} ${'adhd_cases'.tr()}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.teal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBio() {
    return Text(
      doctor.bio,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 13,
        color: HomeScreenTheme.secondaryText(isDark),
        height: 1.5,
      ),
    );
  }

  Widget _buildAvailability() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: doctor.availableDays.take(5).map((day) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: Text(
            day,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookingScreen(doctor: doctor, child: child),
              ),
            ),
            icon: const Icon(Icons.calendar_today_rounded, size: 16),
            label: Text('book_appointment'.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A56DB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: 10),
        _WhatsAppButton(phone: doctor.whatsappNumber),
      ],
    );
  }
}

// ─── WhatsApp Button ──────────────────────────────────────────

class _WhatsAppButton extends StatelessWidget {
  final String phone;
  const _WhatsAppButton({required this.phone});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
        final url = Uri.parse('https://wa.me/$cleaned');
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF25D366),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.chat_rounded, color: Colors.white, size: 22),
      ),
    );
  }
}

// ─── Doctor Avatar ───────────────────────────────────────────

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
          errorBuilder: (_, __, ___) => _placeholder(size),
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

// ─── Rating Stars ────────────────────────────────────────────

class _RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  const _RatingStars({required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.floor();
        final half = !filled && i < rating;
        return Icon(
          half ? Icons.star_half_rounded : (filled ? Icons.star_rounded : Icons.star_outline_rounded),
          size: size,
          color: const Color(0xFFF59E0B),
        );
      }),
    );
  }
}

// ─── Skeleton ────────────────────────────────────────────────

class _DoctorCardSkeleton extends StatelessWidget {
  final bool isDark;
  const _DoctorCardSkeleton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HomeScreenTheme.cardBackground(isDark),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: 140,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 100,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms);
  }
}

// ─── Error & Empty ────────────────────────────────────────────

class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool isDark;
  const _ErrorWidget(
      {required this.message, required this.onRetry, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: Text('retry'.tr())),
        ],
      ),
    );
  }
}

class _EmptyDoctorsWidget extends StatelessWidget {
  final bool isDark;
  const _EmptyDoctorsWidget({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Icon(Icons.medical_services_outlined,
              size: 72, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'no_doctors_available'.tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: HomeScreenTheme.primaryText(isDark),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'no_doctors_desc'.tr(),
            style: TextStyle(color: HomeScreenTheme.secondaryText(isDark)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
