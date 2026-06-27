import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';
import 'package:khuta/data/repositories/game_session_repository.dart';
import 'package:khuta/models/child.dart';
import 'package:khuta/models/game_session.dart';
import 'package:khuta/screens/child/game/game_screen.dart';
import 'package:khuta/screens/main_screen.dart';

class GameResultsScreen extends StatefulWidget {
  final Child child;
  final GameSession session;
  const GameResultsScreen(
      {super.key, required this.child, required this.session});

  @override
  State<GameResultsScreen> createState() => _GameResultsScreenState();
}

class _GameResultsScreenState extends State<GameResultsScreen> {
  List<GameSession> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final h =
        await GameSessionRepository.getSessionHistory(widget.child.id);
    if (mounted) setState(() { _history = h; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = widget.session;

    return Scaffold(
      backgroundColor: HomeScreenTheme.backgroundColor(isDark),
      appBar: AppBar(
        title: Text('game_results_title'.tr()),
        backgroundColor: HomeScreenTheme.cardBackground(isDark),
        foregroundColor: HomeScreenTheme.primaryText(isDark),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded),
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainScreen()),
              (r) => false,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          _ScoreCard(session: s, isDark: isDark)
              .animate()
              .scale(duration: 500.ms, curve: Curves.elasticOut),

          const SizedBox(height: 18),

          _Details(session: s, isDark: isDark)
              .animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 18),

          if (!_loading && _history.length > 1)
            _HistoryChart(history: _history, isDark: isDark)
                .animate().fadeIn(delay: 350.ms),

          const SizedBox(height: 24),

          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => GameScreen(child: widget.child)),
                ),
                icon: const Icon(Icons.replay_rounded),
                label: Text('game_play_again'.tr()),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainScreen()),
                  (r) => false,
                ),
                icon: const Icon(Icons.check_rounded),
                label: Text('game_done'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4299E1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ]).animate().fadeIn(delay: 500.ms),
        ]),
      ),
    );
  }
}

// ─── Score Card ──────────────────────────────────────────
class _ScoreCard extends StatelessWidget {
  final GameSession session;
  final bool isDark;
  const _ScoreCard({required this.session, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final acc = session.accuracy;
    final colors = acc >= 80
        ? [const Color(0xFF48BB78), const Color(0xFF276749)]
        : acc >= 55
            ? [const Color(0xFFED8936), const Color(0xFFC05621)]
            : [const Color(0xFFE53E3E), const Color(0xFF9B2335)];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: colors[0].withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(children: [
        Text(acc >= 80 ? '🏆' : acc >= 55 ? '👏' : '💪',
            style: const TextStyle(fontSize: 56)),
        const SizedBox(height: 12),
        Text('${acc.round()}%',
            style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        Text('game_accuracy'.tr(),
            style: const TextStyle(fontSize: 15, color: Colors.white70)),
        const SizedBox(height: 14),
        Text(
          acc >= 80
              ? 'game_msg_excellent'.tr()
              : acc >= 55
                  ? 'game_msg_good'.tr()
                  : 'game_msg_keep_going'.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 15, color: Colors.white, height: 1.4),
        ),
      ]),
    );
  }
}

// ─── Details ─────────────────────────────────────────────
class _Details extends StatelessWidget {
  final GameSession session;
  final bool isDark;
  const _Details({required this.session, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final mins = session.durationSeconds ~/ 60;
    final secs = session.durationSeconds % 60;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HomeScreenTheme.cardBackground(isDark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [HomeScreenTheme.cardShadow(isDark)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('game_session_details'.tr(),
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: HomeScreenTheme.primaryText(isDark))),
        const SizedBox(height: 16),
        Row(children: [
          _Stat('✅', 'game_correct'.tr(),
              '${session.correctTasks}/${session.totalTasks}', isDark),
          _Stat('⚡', 'game_reaction'.tr(),
              '${session.avgReactionMs}ms', isDark),
          _Stat('🎯', 'game_difficulty'.tr(),
              '${session.finalDifficulty}/5', isDark),
          _Stat('⏱️', 'game_duration'.tr(),
              '$mins:${secs.toString().padLeft(2, '0')}', isDark),
        ]),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  final String icon, label, value;
  final bool isDark;
  const _Stat(this.icon, this.label, this.value, this.isDark);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: HomeScreenTheme.primaryText(isDark))),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 11,
                  color: HomeScreenTheme.secondaryText(isDark))),
        ]),
      );
}

// ─── History Chart ────────────────────────────────────────
class _HistoryChart extends StatelessWidget {
  final List<GameSession> history;
  final bool isDark;
  const _HistoryChart({required this.history, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final recent = history.take(7).toList().reversed.toList();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HomeScreenTheme.cardBackground(isDark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [HomeScreenTheme.cardShadow(isDark)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('game_progress'.tr(),
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: HomeScreenTheme.primaryText(isDark))),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: recent.asMap().entries.map((e) {
              final s = e.value;
              final isLast = e.key == recent.length - 1;
              final h = (s.accuracy / 100 * 85).clamp(8.0, 85.0);
              final c = s.accuracy >= 80
                  ? const Color(0xFF48BB78)
                  : s.accuracy >= 55
                      ? const Color(0xFFED8936)
                      : const Color(0xFFE53E3E);
              return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                if (isLast)
                  Text('${s.accuracy.round()}%',
                      style: TextStyle(
                          fontSize: 10,
                          color: c,
                          fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Container(
                  width: 30,
                  height: h,
                  decoration: BoxDecoration(
                    color: isLast ? c : c.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('d/M').format(s.date),
                  style: TextStyle(
                      fontSize: 9,
                      color: HomeScreenTheme.secondaryText(isDark)),
                ),
              ]);
            }).toList(),
          ),
        ),
      ]),
    );
  }
}
