import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class CompletionOverlay extends StatefulWidget {
  const CompletionOverlay(
      {super.key,
      required this.sessionsCompleted,
      required this.onNewSession,
      required this.onReturn});
  final int sessionsCompleted;
  final VoidCallback onNewSession, onReturn;
  @override
  State<CompletionOverlay> createState() => _CompletionOverlayState();
}

class _CompletionOverlayState extends State<CompletionOverlay>
    with TickerProviderStateMixin {
  late AnimationController _bgCtrl, _contentCtrl, _rippleCtrl, _glowCtrl;
  late Animation<double> _bgFade, _contentScale, _contentFade;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _contentCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 750));
    _rippleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat();
    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _bgFade = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeOut);
    _contentScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.55, end: 1.10), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.10, end: 1.00), weight: 40),
    ]).animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut));
    _contentFade = CurvedAnimation(
        parent: _contentCtrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOut));
    _bgCtrl.forward();
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) _contentCtrl.forward();
    });
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _contentCtrl.dispose();
    _rippleCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  String get _message {
    if (widget.sessionsCompleted == 1) return 'First flow state unlocked.';
    if (widget.sessionsCompleted < 4)
      return '${widget.sessionsCompleted} sessions deep.\nYou\'re building momentum.';
    return '${widget.sessionsCompleted} sessions.\nThis is what elite looks like.';
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _bgFade,
      child: Stack(fit: StackFit.expand, children: [
        Container(
            decoration: BoxDecoration(
                gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.0,
                    colors: [
              AppColors.successDim.withOpacity(0.55),
              AppColors.background.withOpacity(0.96)
            ]))),
        AnimatedBuilder(
            animation: _rippleCtrl,
            builder: (_, __) =>
                CustomPaint(painter: _RipplePainter(value: _rippleCtrl.value))),
        Center(
            child: FadeTransition(
                opacity: _contentFade,
                child: ScaleTransition(
                    scale: _contentScale,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spaceLG),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          AnimatedBuilder(
                              animation: _glowCtrl,
                              builder: (_, __) =>
                                  _CheckmarkBadge(glowValue: _glowCtrl.value)),
                          const SizedBox(height: 30),
                          Text('Session Complete',
                              style: AppTypography.heading
                                  .copyWith(color: AppColors.success)),
                          const SizedBox(height: 10),
                          Text(_message,
                              style: AppTypography.body,
                              textAlign: TextAlign.center),
                          const SizedBox(height: 6),
                          Text('25 min · deep work',
                              style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.success.withOpacity(0.65))),
                          const SizedBox(height: 52),
                          SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                  onPressed: widget.onNewSession,
                                  style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.success,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14))),
                                  child: Text('Start Another Session',
                                      style: AppTypography.bodyLarge.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600)))),
                          const SizedBox(height: 12),
                          SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                  onPressed: widget.onReturn,
                                  style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.textSecondary,
                                      side: const BorderSide(
                                          color: AppColors.border),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14))),
                                  child: Text('Return to Base',
                                      style: AppTypography.bodyLarge))),
                        ]))))),
      ]),
    );
  }
}

class _CheckmarkBadge extends StatelessWidget {
  const _CheckmarkBadge({required this.glowValue});
  final double glowValue;
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.successDim,
            border: Border.all(
                color: AppColors.success.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: AppColors.success.withOpacity(0.18 + glowValue * 0.20),
                  blurRadius: 20 + glowValue * 20,
                  spreadRadius: -2)
            ]),
        child: const Icon(Icons.check_rounded,
            color: AppColors.success, size: 48));
  }
}

class _RipplePainter extends CustomPainter {
  const _RipplePainter({required this.value});
  final double value;
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width * 0.72;
    for (var i = 0; i < 4; i++) {
      var t = (value - (i / 4.0)) % 1.0;
      if (t < 0) t += 1.0;
      final r = maxR * t;
      final opacity = t < 0.1 ? (t / 0.1) * 0.22 : (1.0 - t) * 0.22;
      canvas.drawCircle(
          center,
          r,
          Paint()
            ..color = AppColors.success.withOpacity(opacity.clamp(0, 1))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5);
    }
  }

  @override
  bool shouldRepaint(_RipplePainter old) => old.value != value;
}
