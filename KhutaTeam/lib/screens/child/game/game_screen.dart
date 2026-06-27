import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';
import 'package:khuta/cubit/game/game_cubit.dart';
import 'package:khuta/models/child.dart';
import 'package:khuta/screens/child/game/game_results_screen.dart';
import 'package:khuta/screens/child/game/widgets/cpt_task_widget.dart';
import 'package:khuta/screens/child/game/widgets/memory_task_widget.dart';
import 'package:khuta/screens/child/game/widgets/session_hud.dart';

class GameScreen extends StatelessWidget {
  final Child child;
  const GameScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GameCubit(child: child),
      child: _GameView(child: child),
    );
  }
}

class _GameView extends StatelessWidget {
  final Child child;
  const _GameView({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocConsumer<GameCubit, GameState>(
      listener: (ctx, state) {
        if (state.status == GameStatus.completed &&
            state.completedSession != null) {
          Navigator.pushReplacement(
            ctx,
            MaterialPageRoute(
              builder: (_) => GameResultsScreen(
                  child: child, session: state.completedSession!),
            ),
          );
        }
      },
      builder: (ctx, state) => Scaffold(
        backgroundColor: HomeScreenTheme.backgroundColor(isDark),
        body: SafeArea(child: _body(ctx, state, isDark)),
      ),
    );
  }

  Widget _body(BuildContext ctx, GameState state, bool isDark) {
    switch (state.status) {
      case GameStatus.initial:
        return _IntroScreen(child: child, isDark: isDark);
      case GameStatus.inProgress:
        return _ActiveGame(isDark: isDark);
      case GameStatus.paused:
        return _PauseScreen(isDark: isDark);
      case GameStatus.saving:
      case GameStatus.completed:
        return _SavingScreen(isDark: isDark);
      case GameStatus.error:
        return _ErrorScreen(isDark: isDark);
    }
  }
}

// ════════════════════════════════════════════════
// شاشة المقدمة
// ════════════════════════════════════════════════
class _IntroScreen extends StatelessWidget {
  final Child child;
  final bool isDark;
  const _IntroScreen({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        const SizedBox(height: 20),
        // أيقونة اللعبة
        Container(
          width: 110, height: 110,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4299E1), Color(0xFF9B59B6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF4299E1).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8))
            ],
          ),
          child: const Icon(Icons.sports_esports_rounded,
              size: 56, color: Colors.white),
        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

        const SizedBox(height: 24),

        Text('game_title'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: HomeScreenTheme.primaryText(isDark))).animate().fadeIn(delay: 150.ms),

        const SizedBox(height: 10),

        Text('game_subtitle'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 15,
                color: HomeScreenTheme.secondaryText(isDark),
                height: 1.5)).animate().fadeIn(delay: 250.ms),

        const SizedBox(height: 28),

        // بطاقات شرح المهام
        _card('⭐', 'game_task_cpt_title'.tr(), 'game_task_cpt_desc'.tr(), isDark, 350),
        const SizedBox(height: 10),
        _card('🧠', 'game_task_memory_title'.tr(), 'game_task_memory_desc'.tr(), isDark, 450),
        const SizedBox(height: 10),
        _card('🛑', 'game_task_inhibition_title'.tr(), 'game_task_inhibition_desc'.tr(), isDark, 550),

        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity, height: 54,
          child: ElevatedButton.icon(
            onPressed: () => context.read<GameCubit>().startSession(),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text('game_start'.tr(),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4299E1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
          ),
        ).animate().fadeIn(delay: 650.ms).slideY(begin: 0.3, end: 0),

        const SizedBox(height: 12),

        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('game_cancel'.tr(),
              style: TextStyle(
                  color: HomeScreenTheme.secondaryText(isDark))),
        ),
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _card(String emoji, String title, String desc, bool isDark,
      int delayMs) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HomeScreenTheme.cardBackground(isDark),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [HomeScreenTheme.cardShadow(isDark)],
      ),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 30)),
        const SizedBox(width: 14),
        Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: HomeScreenTheme.primaryText(isDark))),
          Text(desc,
              style: TextStyle(
                  fontSize: 13,
                  color: HomeScreenTheme.secondaryText(isDark))),
        ])),
      ]),
    ).animate().fadeIn(delay: Duration(milliseconds: delayMs)).slideX(begin: 0.15, end: 0);
  }
}

// ════════════════════════════════════════════════
// شاشة اللعبة النشطة
// ════════════════════════════════════════════════
class _ActiveGame extends StatelessWidget {
  final bool isDark;
  const _ActiveGame({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, GameState>(
      builder: (ctx, state) => Stack(
        children: [
          Column(children: [
            SessionHud(isDark: isDark),
            Expanded(
              child: Center(child: _taskWidget(ctx, state)),
            ),
            _FeedbackBar(feedback: state.feedback, isDark: isDark),
            const SizedBox(height: 16),
          ]),
          Positioned(
            top: 8, right: 8,
            child: IconButton(
              icon: Icon(Icons.pause_circle_outline,
                  color: HomeScreenTheme.secondaryText(isDark), size: 28),
              onPressed: () => ctx.read<GameCubit>().pauseSession(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskWidget(BuildContext ctx, GameState state) {
    final task = state.currentTask;
    if (task == null) return const SizedBox.shrink();
    switch (task.type) {
      case TaskType.cpt:
        return CptTaskWidget(task: task);
      case TaskType.memory:
        return MemoryTaskWidget(task: task);
      case TaskType.inhibition:
        return InhibitionTaskWidget(task: task);
    }
  }
}

// ════════════════════════════════════════════════
// Feedback Bar
// ════════════════════════════════════════════════
class _FeedbackBar extends StatelessWidget {
  final FeedbackType feedback;
  final bool isDark;
  const _FeedbackBar({required this.feedback, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (feedback == FeedbackType.none) return const SizedBox(height: 60);
    final isOk = feedback == FeedbackType.correct;
    final color = isOk
        ? HomeScreenTheme.accentGreen(isDark)
        : HomeScreenTheme.accentRed(isDark);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 58,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(
            isOk ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: color, size: 26),
        const SizedBox(width: 8),
        Text(isOk ? 'game_correct'.tr() : 'game_wrong'.tr(),
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: color)),
      ]),
    ).animate().fadeIn(duration: 150.ms).scale(begin: const Offset(0.9, 0.9));
  }
}

// ════════════════════════════════════════════════
// شاشة الإيقاف
// ════════════════════════════════════════════════
class _PauseScreen extends StatelessWidget {
  final bool isDark;
  const _PauseScreen({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.pause_circle_filled_rounded,
              size: 90, color: HomeScreenTheme.accentBlue(isDark))
              .animate().scale(),
          const SizedBox(height: 24),
          Text('game_paused'.tr(),
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: HomeScreenTheme.primaryText(isDark))),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton.icon(
              onPressed: () => context.read<GameCubit>().resumeSession(),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text('game_resume'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: HomeScreenTheme.accentBlue(isDark),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: () => context.read<GameCubit>().endSessionEarly(),
            icon: const Icon(Icons.stop_circle_outlined),
            label: Text('game_end_early'.tr()),
            style: TextButton.styleFrom(
                foregroundColor: HomeScreenTheme.accentRed(isDark)),
          ),
        ]),
      ),
    );
  }
}

class _SavingScreen extends StatelessWidget {
  final bool isDark;
  const _SavingScreen({required this.isDark});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const CircularProgressIndicator(strokeWidth: 3),
          const SizedBox(height: 20),
          Text('game_saving'.tr(),
              style: TextStyle(
                  color: HomeScreenTheme.secondaryText(isDark))),
        ]),
      );
}

class _ErrorScreen extends StatelessWidget {
  final bool isDark;
  const _ErrorScreen({required this.isDark});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.error_outline,
              size: 60, color: HomeScreenTheme.accentRed(isDark)),
          const SizedBox(height: 16),
          Text('error_saving_results'.tr(),
              style: TextStyle(color: HomeScreenTheme.primaryText(isDark))),
          const SizedBox(height: 24),
          ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('game_cancel'.tr())),
        ]),
      );
}
