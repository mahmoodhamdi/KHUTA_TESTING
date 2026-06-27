import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';
import 'package:khuta/cubit/game/game_cubit.dart';

class CptTaskWidget extends StatelessWidget {
  final GameTask task;
  const CptTaskWidget({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('game_cpt_instruction'.tr(),
          textAlign: TextAlign.center,
          style:
              TextStyle(fontSize: 15, color: HomeScreenTheme.secondaryText(isDark))),
      const SizedBox(height: 28),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: GestureDetector(
          key: ValueKey(task.id),
          onTap: () => context.read<GameCubit>().onUserTap(tapped: true),
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFF4299E1).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                  color: const Color(0xFF4299E1).withValues(alpha: 0.25),
                  width: 2),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF4299E1).withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 6))
              ],
            ),
            child: Center(
                child: Text(task.targetEmoji,
                    style: const TextStyle(fontSize: 80))),
          ),
        ),
      ).animate().scale(duration: 200.ms, curve: Curves.easeOut),
      const SizedBox(height: 32),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _ActionBtn(
          label: 'game_tap_here'.tr(),
          color: const Color(0xFF4299E1),
          icon: Icons.touch_app_rounded,
          onTap: () => context.read<GameCubit>().onUserTap(tapped: true),
        ),
        const SizedBox(width: 16),
        _ActionBtn(
          label: 'game_ignore'.tr(),
          color: Colors.grey,
          icon: Icons.close_rounded,
          onTap: () => context.read<GameCubit>().onUserTap(tapped: false),
        ),
      ]),
    ]);
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.label,
      required this.color,
      required this.icon,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Row(children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
          ]),
        ),
      );
}
