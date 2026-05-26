import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/focus_timer_provider.dart';
import '../../screens/focus/focus_mode_screen.dart';
import '../common/app_card.dart';

class FocusTimerCard extends ConsumerWidget {
  const FocusTimerCard({super.key});

  void _openFocusMode(BuildContext context, FocusTimerNotifier notifier,
      FocusTimerState timer) {
    if (timer.isIdle) notifier.start();
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, __, ___) => const FocusModeScreen(),
      transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child),
      transitionDuration: AppConstants.animSlow,
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(focusTimerProvider);
    final notifier = ref.read(focusTimerProvider.notifier);

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Row(children: [
          Text('FOCUS TIMER', style: AppTypography.label),
          const Spacer(),
          if (timer.sessionsCompleted > 0)
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: AppColors.primaryDim,
                    borderRadius: BorderRadius.circular(6)),
                child: Text('${timer.sessionsCompleted} ✓',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.primaryLight))),
        ]),
        const SizedBox(height: 20),
        SizedBox(
            width: 148,
            height: 148,
            child: Stack(alignment: Alignment.center, children: [
              SizedBox.expand(
                  child: CustomPaint(
                      painter: _MiniRingPainter(
                          progress: timer.progress,
                          isCompleted: timer.isCompleted))),
              Column(mainAxisSize: MainAxisSize.min, children: [
                AnimatedDefaultTextStyle(
                    duration: AppConstants.animNormal,
                    style: AppTypography.timerDisplay.copyWith(
                        fontSize: 38,
                        color: timer.isCompleted
                            ? AppColors.success
                            : AppColors.textPrimary),
                    child: Text(timer.formattedTime)),
                if (timer.isCompleted)
                  Text('Done! 🎉',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.success))
                else if (!timer.isIdle)
                  Text(timer.isRunning ? 'in flow' : 'paused',
                      style: AppTypography.caption),
              ]),
            ])),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (!timer.isIdle) ...[
            _SmallBtn(icon: Icons.refresh_rounded, onTap: notifier.reset),
            const SizedBox(width: 12),
          ],
          _SmallBtn(
              icon: timer.isRunning
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              onTap: timer.isRunning ? notifier.pause : notifier.start,
              filled: !timer.isRunning && !timer.isCompleted),
        ]),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: () => _openFocusMode(context, notifier, timer),
            child: AnimatedContainer(
              duration: AppConstants.animNormal,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                  color: timer.isRunning
                      ? AppColors.primaryDim
                      : AppColors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: timer.isRunning
                          ? AppColors.primary.withOpacity(0.4)
                          : AppColors.border)),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.fullscreen_rounded,
                    size: 18,
                    color: timer.isRunning
                        ? AppColors.primaryLight
                        : AppColors.textMuted),
                const SizedBox(width: 8),
                Text(
                    timer.isRunning
                        ? 'Enter Focus Mode'
                        : timer.isIdle
                            ? 'Start Focus Mode'
                            : 'Resume in Focus Mode',
                    style: AppTypography.bodySmall.copyWith(
                        color: timer.isRunning
                            ? AppColors.primaryLight
                            : AppColors.textMuted,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

class _MiniRingPainter extends CustomPainter {
  const _MiniRingPainter({required this.progress, required this.isCompleted});
  final double progress;
  final bool isCompleted;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 10) / 2;
    const stroke = 5.5;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = AppColors.border
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke);
    if (progress <= 0) return;
    canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        Paint()
          ..color = (isCompleted ? AppColors.success : AppColors.primary)
              .withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke + 5
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        Paint()
          ..shader = SweepGradient(
                  startAngle: -math.pi / 2,
                  endAngle: -math.pi / 2 + math.pi * 2,
                  colors: isCompleted
                      ? [AppColors.success, AppColors.success]
                      : [AppColors.primary, AppColors.primaryLight])
              .createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_MiniRingPainter old) =>
      old.progress != progress || old.isCompleted != isCompleted;
}

class _SmallBtn extends StatelessWidget {
  const _SmallBtn(
      {required this.icon, required this.onTap, this.filled = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
            duration: AppConstants.animNormal,
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: filled ? AppColors.primary : AppColors.surfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(
                    color: filled
                        ? AppColors.primaryLight.withOpacity(0.3)
                        : AppColors.border),
                boxShadow: filled
                    ? [
                        BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: -3)
                      ]
                    : []),
            child: Icon(icon,
                size: 19,
                color: filled ? Colors.white : AppColors.textSecondary)));
  }
}
