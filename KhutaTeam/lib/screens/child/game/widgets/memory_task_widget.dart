import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';
import 'package:khuta/cubit/game/game_cubit.dart';

// ════════════════════════════════════════
// مهمة الذاكرة العاملة
// ════════════════════════════════════════
class MemoryTaskWidget extends StatefulWidget {
  final GameTask task;
  const MemoryTaskWidget({super.key, required this.task});

  @override
  State<MemoryTaskWidget> createState() => _MemoryTaskWidgetState();
}

class _MemoryTaskWidgetState extends State<MemoryTaskWidget> {
  bool _showing = true;
  int _idx = 0;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(milliseconds: 750), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _idx++;
        if (_idx >= (widget.task.sequence?.length ?? 0)) {
          t.cancel();
          Future.delayed(const Duration(milliseconds: 300),
              () { if (mounted) setState(() => _showing = false); });
        }
      });
    });
  }

  @override
  void dispose() { _t?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final seq = widget.task.sequence ?? [];

    if (_showing && _idx < seq.length) {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('game_memory_watch'.tr(),
            style: TextStyle(
                fontSize: 16,
                color: HomeScreenTheme.secondaryText(isDark))),
        const SizedBox(height: 28),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Container(
            key: ValueKey(_idx),
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFF9B59B6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                  color: const Color(0xFF9B59B6).withValues(alpha: 0.35),
                  width: 2),
            ),
            child: Center(
                child: Text(seq[_idx],
                    style: const TextStyle(fontSize: 72))),
          ),
        ).animate().scale(duration: 200.ms),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            seq.length,
            (i) => Container(
              width: 10, height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i <= _idx
                    ? const Color(0xFF9B59B6)
                    : const Color(0xFF9B59B6).withValues(alpha: 0.2),
              ),
            ),
          ),
        ),
      ]);
    }

    // طور الاستجابة
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('game_memory_remember'.tr(),
          style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: HomeScreenTheme.primaryText(isDark))),
      const SizedBox(height: 8),
      Text('game_memory_last'.tr(),
          style: TextStyle(
              fontSize: 14,
              color: HomeScreenTheme.secondaryText(isDark))),
      const SizedBox(height: 28),
      Text(seq.isNotEmpty ? seq.last : '?',
          style: const TextStyle(fontSize: 80)),
      const SizedBox(height: 32),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _Btn(
          label: 'game_yes'.tr(),
          color: const Color(0xFF48BB78),
          onTap: () =>
              context.read<GameCubit>().onUserTap(tapped: true),
        ),
        const SizedBox(width: 20),
        _Btn(
          label: 'game_no'.tr(),
          color: const Color(0xFFE53E3E),
          onTap: () =>
              context.read<GameCubit>().onUserTap(tapped: false),
        ),
      ]),
    ]).animate().fadeIn(duration: 300.ms);
  }
}

// ════════════════════════════════════════
// مهمة الضبط الذاتي — Go/No-Go
// ════════════════════════════════════════
class InhibitionTaskWidget extends StatelessWidget {
  final GameTask task;
  const InhibitionTaskWidget({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isGo = task.requiresTap;
    final color =
        isGo ? const Color(0xFF48BB78) : const Color(0xFFE53E3E);

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(
        isGo
            ? 'game_inhibition_go'.tr()
            : 'game_inhibition_stop'.tr(),
        style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.bold, color: color),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 28),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Container(
          key: ValueKey(task.id),
          width: 160, height: 160,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(80),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 3),
            boxShadow: [
              BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 6))
            ],
          ),
          child: Center(
              child: Text(task.targetEmoji,
                  style: const TextStyle(fontSize: 80))),
        ),
      ).animate().scale(duration: 250.ms, curve: Curves.elasticOut),
      const SizedBox(height: 36),
      if (isGo)
        GestureDetector(
          onTap: () =>
              context.read<GameCubit>().onUserTap(tapped: true),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 40, vertical: 14),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Text('game_tap_here'.tr(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
        )
      else
        Column(children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Text('game_inhibition_wait'.tr(),
                style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: () =>
                context.read<GameCubit>().onUserTap(tapped: false),
            child: Text('game_inhibition_confirm_wait'.tr(),
                style: TextStyle(
                    color:
                        HomeScreenTheme.secondaryText(isDark))),
          ),
        ]),
    ]);
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _Btn(
      {required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 110, height: 54,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Center(
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold))),
        ),
      );
}
