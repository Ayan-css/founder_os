import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FocusRing extends StatefulWidget {
  const FocusRing({super.key, required this.progress, required this.isCompleted, required this.isPaused, required this.child, this.size = 272});
  final double progress;
  final bool isCompleted;
  final bool isPaused;
  final Widget child;
  final double size;
  @override
  State<FocusRing> createState() => _FocusRingState();
}

class _FocusRingState extends State<FocusRing> with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(FocusRing old) {
    super.didUpdateWidget(old);
    if (widget.isPaused && !old.isPaused) { _pulseCtrl.stop(); }
    else if (!widget.isPaused && old.isPaused) { _pulseCtrl.repeat(reverse: true); }
  }

  @override
  void dispose() { _pulseCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, child) => SizedBox(
        width: widget.size, height: widget.size,
        child: CustomPaint(
          painter: _FocusRingPainter(progress: widget.progress, tipPulse: _pulseAnim.value, isCompleted: widget.isCompleted, isPaused: widget.isPaused),
          child: Center(child: child),
        ),
      ),
      child: widget.child,
    );
  }
}

class _FocusRingPainter extends CustomPainter {
  const _FocusRingPainter({required this.progress, required this.tipPulse, required this.isCompleted, required this.isPaused});
  final double progress, tipPulse;
  final bool isCompleted, isPaused;
  static const double _stroke = 9.0, _glowBlur = 14.0, _padding = 12.0;

  Color get _arcColor => isCompleted ? AppColors.success : isPaused ? AppColors.primary.withOpacity(0.45) : AppColors.primary;
  Color get _glowColor => isCompleted ? AppColors.success.withOpacity(0.38) : isPaused ? AppColors.primary.withOpacity(0.18) : AppColors.primary.withOpacity(0.32);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - _stroke * 2 - _padding) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -math.pi / 2;
    final sweepAngle = math.pi * 2 * progress.clamp(0.0, 1.0);

    canvas.drawCircle(center, radius, Paint()..color = AppColors.border.withOpacity(0.35)..style = PaintingStyle.stroke..strokeWidth = _stroke - 2);
    if (progress <= 0.005) return;

    canvas.drawArc(rect, startAngle, sweepAngle, false, Paint()
      ..color = _glowColor..style = PaintingStyle.stroke..strokeWidth = _stroke + 8..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, _glowBlur));

    canvas.drawArc(rect, startAngle, sweepAngle, false, Paint()
      ..shader = SweepGradient(
        startAngle: startAngle, endAngle: startAngle + math.pi * 2,
        colors: isCompleted ? [AppColors.success, AppColors.success.withOpacity(0.8)]
            : isPaused ? [AppColors.primary.withOpacity(0.3), AppColors.primary.withOpacity(0.5)]
            : [AppColors.primary.withOpacity(0.55), AppColors.primaryLight],
      ).createShader(rect)
      ..style = PaintingStyle.stroke..strokeWidth = _stroke..strokeCap = StrokeCap.round);

    final tipAngle = startAngle + sweepAngle;
    final tipCenter = Offset(center.dx + radius * math.cos(tipAngle), center.dy + radius * math.sin(tipAngle));
    final dotRadius = (_stroke / 2) + 2.0 + (tipPulse * 2.8);
    canvas.drawCircle(tipCenter, dotRadius + 5, Paint()..color = _arcColor.withOpacity(0.38)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7));
    canvas.drawCircle(tipCenter, dotRadius, Paint()..color = isCompleted ? AppColors.success : Colors.white);
    canvas.drawCircle(tipCenter - Offset(dotRadius * 0.18, dotRadius * 0.18), dotRadius * 0.32, Paint()..color = Colors.white.withOpacity(0.5));
  }

  @override
  bool shouldRepaint(_FocusRingPainter old) => old.progress != progress || old.tipPulse != tipPulse || old.isCompleted != isCompleted || old.isPaused != isPaused;
}