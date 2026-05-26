import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class BreathingBackground extends StatefulWidget {
  const BreathingBackground(
      {super.key, required this.child, required this.isActive});
  final Widget child;
  final bool isActive;
  @override
  State<BreathingBackground> createState() => _BreathingBackgroundState();
}

class _BreathingBackgroundState extends State<BreathingBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    if (widget.isActive) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(BreathingBackground old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.isActive && old.isActive) {
      _ctrl.animateTo(0.0,
          duration: const Duration(seconds: 2), curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Container(
        color: AppColors.background,
        child: CustomPaint(
            painter: _BreathPainter(value: _anim.value), child: child),
      ),
      child: widget.child,
    );
  }
}

class _BreathPainter extends CustomPainter {
  const _BreathPainter({required this.value});
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width * 0.65;
    canvas.drawCircle(
        center,
        maxR * (0.45 + value * 0.35),
        Paint()
          ..shader = RadialGradient(colors: [
            AppColors.primary.withOpacity(0.09 + value * 0.06),
            Colors.transparent
          ]).createShader(Rect.fromCircle(center: center, radius: maxR)));
    canvas.drawCircle(
        center,
        maxR * (0.75 + value * 0.25),
        Paint()
          ..shader = RadialGradient(colors: [
            AppColors.primaryDim.withOpacity(0.06 + value * 0.03),
            Colors.transparent
          ]).createShader(Rect.fromCircle(center: center, radius: maxR * 1.3)));
  }

  @override
  bool shouldRepaint(_BreathPainter old) => old.value != value;
}
