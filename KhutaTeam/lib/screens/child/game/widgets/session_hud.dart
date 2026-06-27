import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';
import 'package:khuta/cubit/game/game_cubit.dart';

class SessionHud extends StatelessWidget {
  final bool isDark;
  const SessionHud({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, GameState>(
      buildWhen: (p, c) =>
          p.timeLeftSeconds != c.timeLeftSeconds ||
          p.taskResults.length != c.taskResults.length ||
          p.difficulty != c.difficulty,
      builder: (context, state) {
        final mins = state.timeLeftSeconds ~/ 60;
        final secs = state.timeLeftSeconds % 60;
        final timeStr = '$mins:${secs.toString().padLeft(2, '0')}';
        final isLow = state.timeLeftSeconds < 60;

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: HomeScreenTheme.cardBackground(isDark),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [HomeScreenTheme.cardShadow(isDark)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Item(
                icon: Icons.timer_outlined,
                label: timeStr,
                color: isLow
                    ? const Color(0xFFE53E3E)
                    : HomeScreenTheme.accentBlue(isDark),
              ),
              _divider(isDark),
              _Item(
                icon: Icons.track_changes_rounded,
                label: '${state.liveAccuracy.round()}%',
                color: state.liveAccuracy >= 70
                    ? HomeScreenTheme.accentGreen(isDark)
                    : HomeScreenTheme.accentOrange(isDark),
              ),
              _divider(isDark),
              _DiffDots(difficulty: state.difficulty, isDark: isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _divider(bool isDark) => Container(
        width: 1,
        height: 28,
        color: HomeScreenTheme.secondaryText(isDark).withValues(alpha: 0.2),
      );
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Item({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: color)),
      ]);
}

class _DiffDots extends StatelessWidget {
  final int difficulty;
  final bool isDark;
  const _DiffDots({required this.difficulty, required this.isDark});

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(Icons.bolt_rounded,
            color: HomeScreenTheme.accentOrange(isDark), size: 20),
        const SizedBox(width: 4),
        Row(
          children: List.generate(
            5,
            (i) => Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < difficulty
                    ? HomeScreenTheme.accentOrange(isDark)
                    : HomeScreenTheme.secondaryText(isDark)
                        .withValues(alpha: 0.25),
              ),
            ),
          ),
        ),
      ]);
}
