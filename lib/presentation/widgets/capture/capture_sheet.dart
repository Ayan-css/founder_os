import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/capture.dart';
import '../../providers/capture_provider.dart';
import 'capture_type_chip.dart';

Future<void> showCaptureSheet(BuildContext context) {
  return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CaptureSheet());
}

class _CaptureSheet extends ConsumerStatefulWidget {
  const _CaptureSheet();
  @override
  ConsumerState<_CaptureSheet> createState() => _CaptureSheetState();
}

class _CaptureSheetState extends ConsumerState<_CaptureSheet>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  CaptureType _type = CaptureType.thought;
  bool _saving = false;
  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _slideCtrl =
        AnimationController(vsync: this, duration: AppConstants.animNormal);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _fadeAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      Navigator.pop(context);
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _saving = true);
    await ref.read(capturesProvider.notifier).add(text, _type);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppConstants.radiusXL),
              border: Border.all(color: AppColors.border)),
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
                left: 20,
                right: 20,
                top: 16),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                      child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 16),
                  Row(children: [
                    Text(_type.emoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Text('Capture', style: AppTypography.subheading),
                    const Spacer(),
                    Text('${_controller.text.length}',
                        style: AppTypography.caption),
                  ]),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    maxLines: 6,
                    minLines: 3,
                    style: AppTypography.bodyLarge.copyWith(height: 1.6),
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                        hintText: "What's on your mind?",
                        hintStyle: AppTypography.bodyLarge
                            .copyWith(color: AppColors.textDisabled),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  CaptureTypeSelector(
                      selected: _type,
                      onSelect: (t) =>
                          setState(() => _type = t ?? CaptureType.thought)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: AnimatedContainer(
                      duration: AppConstants.animNormal,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                            colors: _controller.text.trim().isEmpty
                                ? [
                                    AppColors.surfaceHighlight,
                                    AppColors.surfaceHighlight
                                  ]
                                : [AppColors.primary, AppColors.primaryLight]),
                        boxShadow: _controller.text.trim().isNotEmpty
                            ? [
                                BoxShadow(
                                    color: AppColors.primary.withOpacity(0.35),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4))
                              ]
                            : [],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          onTap: _saving ? null : _save,
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: Center(
                                child: _saving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white))
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                            Icon(Icons.bolt_rounded,
                                                size: 18,
                                                color: _controller.text
                                                        .trim()
                                                        .isEmpty
                                                    ? AppColors.textDisabled
                                                    : Colors.white),
                                            const SizedBox(width: 8),
                                            Text('Capture it',
                                                style: AppTypography.bodyLarge
                                                    .copyWith(
                                                        color: _controller
                                                                .text
                                                                .trim()
                                                                .isEmpty
                                                            ? AppColors
                                                                .textDisabled
                                                            : Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                          ])),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}
