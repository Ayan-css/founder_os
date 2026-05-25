import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/task.dart';
import '../../providers/focus_timer_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/focus/breathing_background.dart';
import '../../widgets/focus/completion_overlay.dart';
import '../../widgets/focus/focus_ring.dart';

class FocusModeScreen extends ConsumerStatefulWidget {
  const FocusModeScreen({super.key});
  @override
  ConsumerState<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends ConsumerState<FocusModeScreen> with SingleTickerProviderStateMixin {
  bool _showCompletion = false;
  late AnimationController _entranceCtrl;
  late Animation<double> _entranceFade;
  late Animation<Offset> _entranceSlide;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _entranceCtrl = AnimationController(vsync: this, duration: AppConstants.animSlow);
    _entranceFade = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _entranceSlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut));
    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    _entranceCtrl.dispose();
    super.dispose();
  }

  Task? _firstIncompleteTask(List<Task> tasks) {
    for (final t in tasks) { if (!t.isCompleted) return t; }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<FocusTimerState>(focusTimerProvider, (prev, next) {
      if (next.isCompleted && !(prev?.isCompleted ?? false)) {
        HapticFeedback.heavyImpact();
        setState(() => _showCompletion = true);
      }
    });
    final timer = ref.watch(focusTimerProvider);
    final notifier = ref.read(focusTimerProvider.notifier);
    final tasksSnap = ref.watch(todayTasksProvider);
    final focusTask = tasksSnap.whenOrNull(data: (tasks) => _firstIncompleteTask(tasks));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(fit: StackFit.expand, children: [
        BreathingBackground(
          isActive: timer.isRunning,
          child: SafeArea(child: FadeTransition(opacity: _entranceFade, child: SlideTransition(position: _entranceSlide,
            child: _FocusLayout(timer: timer, notifier: notifier, focusTask: focusTask)))),
        ),
        if (_showCompletion) CompletionOverlay(
          sessionsCompleted: timer.sessionsCompleted,
          onNewSession: () {
            setState(() => _showCompletion = false);
            notifier.reset();
            Future.microtask(notifier.start);
          },
          onReturn: () => Navigator.pop(context),
        ),
      ]),
    );
  }
}

class _FocusLayout extends StatelessWidget {
  const _FocusLayout({required this.timer, required this.notifier, required this.focusTask});
  final FocusTimerState timer;
  final FocusTimerNotifier notifier;
  final Task? focusTask;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: Row(children: [
          _ExitButton(onTap: () => Navigator.pop(context)),
          const Spacer(),
          if (timer.sessionsCompleted > 0) _SessionBadge(count: timer.sessionsCompleted),
        ]),
      ),
      const Spacer(flex: 2),
      AnimatedSwitcher(
        duration: AppConstants.animNormal,
        child: focusTask != null
            ? _TaskHint(key: ValueKey(focusTask!.id), title: focusTask!.title)
            : const SizedBox.shrink(),
      ),
      const SizedBox(height: 28),
      FocusRing(
        progress: timer.progress, isCompleted: timer.isCompleted,
        isPaused: timer.isPaused, size: 272,
        child: _TimerDisplay(timer: timer),
      ),
      const Spacer(flex: 2),
      AnimatedSwitcher(
        duration: AppConstants.animNormal,
        child: timer.isCompleted ? const SizedBox.shrink() : _Controls(timer: timer, notifier: notifier),
      ),
      const SizedBox(height: 48),
    ]);
  }
}

class _TimerDisplay extends StatelessWidget {
  const _TimerDisplay({required this.timer});
  final FocusTimerState timer;

  @override
  Widget build(BuildContext context) {
    final statusText = switch (timer.status) {
      TimerStatus.idle => 'ready',
      TimerStatus.running => 'in flow',
      TimerStatus.paused => 'paused',
      TimerStatus.completed => 'done ✓',
    };
    return Column(mainAxisSize: MainAxisSize.min, children: [
      AnimatedDefaultTextStyle(
        duration: AppConstants.animNormal,
        style: AppTypography.timerDisplay.copyWith(fontSize: 54,
          color: timer.isCompleted ? AppColors.success : timer.isPaused ? AppColors.textMuted : AppColors.textPrimary),
        child: Text(timer.formattedTime)),
      const SizedBox(height: 5),
      AnimatedSwitcher(
        duration: AppConstants.animNormal,
        child: Text(statusText, key: ValueKey(timer.status),
          style: AppTypography.caption.copyWith(letterSpacing: 1.6,
            color: timer.isCompleted ? AppColors.success : AppColors.textMuted)),
      ),
    ]);
  }
}

class _TaskHint extends StatelessWidget {
  const _TaskHint({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('FOCUSING ON', style: AppTypography.label),
        const SizedBox(height: 8),
        Text(title, style: AppTypography.body.copyWith(fontStyle: FontStyle.italic, color: AppColors.textSecondary.withOpacity(0.85)),
          textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
      ]));
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.timer, required this.notifier});
  final FocusTimerState timer;
  final FocusTimerNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      AnimatedOpacity(
        duration: AppConstants.animNormal, opacity: timer.isIdle ? 0.0 : 1.0,
        child: _SmallControl(icon: Icons.refresh_rounded, onTap: timer.isIdle ? null : notifier.reset, tooltip: 'Reset')),
      const SizedBox(width: 22),
      _PrimaryButton(timer: timer, notifier: notifier),
      const SizedBox(width: 22),
      const SizedBox(width: 48),
    ]);
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.timer, required this.notifier});
  final FocusTimerState timer;
  final FocusTimerNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final (icon, fn) = switch (timer.status) {
      TimerStatus.idle => (Icons.play_arrow_rounded, notifier.start),
      TimerStatus.running => (Icons.pause_rounded, notifier.pause),
      TimerStatus.paused => (Icons.play_arrow_rounded, notifier.resume),
      TimerStatus.completed => (Icons.refresh_rounded, notifier.reset),
    };
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); fn(); },
      child: AnimatedContainer(
        duration: AppConstants.animNormal,
        width: 76, height: 76,
        decoration: BoxDecoration(shape: BoxShape.circle,
          color: timer.isPaused || timer.isIdle ? AppColors.surfaceElevated : AppColors.primary,
          border: Border.all(color: timer.isPaused || timer.isIdle ? AppColors.border : AppColors.primaryLight.withOpacity(0.35), width: 1.5),
          boxShadow: timer.isRunning ? [BoxShadow(color: AppColors.primary.withOpacity(0.38), blurRadius: 28, spreadRadius: -4)] : []),
        child: Icon(icon, size: 32, color: timer.isPaused || timer.isIdle ? AppColors.textSecondary : Colors.white),
      ),
    );
  }
}

class _SmallControl extends StatelessWidget {
  const _SmallControl({required this.icon, required this.tooltip, this.onTap});
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(message: tooltip,
      child: GestureDetector(onTap: onTap,
        child: Container(width: 48, height: 48,
          decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.surfaceElevated, border: Border.all(color: AppColors.border)),
          child: Icon(icon, size: 20, color: AppColors.textMuted))));
  }
}

class _ExitButton extends StatelessWidget {
  const _ExitButton({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: AppColors.surfaceElevated.withOpacity(0.75), borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border.withOpacity(0.45))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.arrow_back_ios_new_rounded, size: 13, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Text('Exit', style: AppTypography.caption.copyWith(color: AppColors.textMuted, letterSpacing: 0.4)),
        ])));
  }
}

class _SessionBadge extends StatelessWidget {
  const _SessionBadge({required this.count});
  final int count;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: AppColors.primaryDim, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.primary.withOpacity(0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Text('🔥', style: TextStyle(fontSize: 12)),
        const SizedBox(width: 5),
        Text('$count session${count == 1 ? '' : 's'}', style: AppTypography.caption.copyWith(color: AppColors.primaryLight)),
      ]));
  }
}