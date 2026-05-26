import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../providers/reflection_provider.dart';
import 'past_reflections_screen.dart';

class ReflectionPrompt {
  final String emoji, question, hint;
  final Color accent;
  const ReflectionPrompt(
      {required this.emoji,
      required this.question,
      required this.hint,
      required this.accent});
}

const reflectionPrompts = [
  ReflectionPrompt(
      emoji: '🌪️',
      question: 'What pulled you away today?',
      hint: 'Scroll holes, interruptions, mental resistance, anxiety...',
      accent: AppColors.warning),
  ReflectionPrompt(
      emoji: '⚡',
      question: 'What actually moved you forward?',
      hint: 'A win, a decision made, momentum, a good conversation...',
      accent: AppColors.primary),
  ReflectionPrompt(
      emoji: '🎯',
      question: 'One thing to do differently tomorrow.',
      hint: 'A habit, a process change, a mindset shift...',
      accent: AppColors.success),
];

const _closingLines = [
  'Awareness is how founders stay sharp.',
  'Reflection is the compounding edge.',
  'You showed up. That\'s the whole game.',
  'Small adjustments, daily. That\'s the system.',
  'One day wiser. One day closer.',
  'The founders who reflect, adapt. Keep going.',
  'Honest review is how you keep leveling up.',
];

class ReflectionScreen extends ConsumerStatefulWidget {
  const ReflectionScreen({super.key});
  @override
  ConsumerState<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends ConsumerState<ReflectionScreen> {
  int _step = 0, _dir = 1;
  bool _loading = true, _saving = false, _done = false, _hadExisting = false;
  final _ctrls = List.generate(3, (_) => TextEditingController());
  final _focusNodes = List.generate(3, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    final existing =
        await ref.read(reflectionRepositoryProvider).getTodayReflection();
    if (existing != null && mounted) {
      _ctrls[0].text = existing.distraction ?? '';
      _ctrls[1].text = existing.forward ?? '';
      _ctrls[2].text = existing.improvement ?? '';
      _hadExisting = true;
    }
    if (mounted) {
      setState(() => _loading = false);
      Future.delayed(const Duration(milliseconds: 380), () {
        if (mounted) _focusNodes[0].requestFocus();
      });
    }
  }

  Future<void> _goNext() async {
    if (_step < 2) {
      _transition(_step + 1, forward: true);
    } else {
      await _save();
    }
  }

  void _goBack() {
    if (_done) return;
    if (_step > 0) {
      _transition(_step - 1, forward: false);
    } else {
      Navigator.pop(context);
    }
  }

  void _transition(int newStep, {required bool forward}) {
    FocusScope.of(context).unfocus();
    setState(() {
      _dir = forward ? 1 : -1;
      _step = newStep;
    });
    Future.delayed(const Duration(milliseconds: 330), () {
      if (mounted) _focusNodes[_step].requestFocus();
    });
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      await ref.read(reflectionRepositoryProvider).upsert(
            distraction: _nullIfEmpty(_ctrls[0].text),
            forward: _nullIfEmpty(_ctrls[1].text),
            improvement: _nullIfEmpty(_ctrls[2].text),
          );
      ref.invalidate(todayReflectionProvider);
      ref.invalidate(allReflectionsProvider);
      HapticFeedback.mediumImpact();
      if (mounted)
        setState(() {
          _saving = false;
          _done = true;
        });
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _nullIfEmpty(String s) => s.trim().isEmpty ? null : s.trim();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == 0 || _done,
      onPopInvoked: (didPop) {
        if (!didPop) _goBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
            child: AnimatedSwitcher(
          duration: AppConstants.animSlow,
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: _loading
              ? const _LoadingView(key: ValueKey('loading'))
              : _done
                  ? _CompletionView(
                      key: const ValueKey('done'),
                      answers: [
                        _ctrls[0].text.trim(),
                        _ctrls[1].text.trim(),
                        _ctrls[2].text.trim()
                      ],
                      onReturn: () => Navigator.pop(context))
                  : _StepFlow(
                      key: const ValueKey('flow'),
                      step: _step,
                      dir: _dir,
                      ctrls: _ctrls,
                      focusNodes: _focusNodes,
                      hadExisting: _hadExisting,
                      saving: _saving,
                      onNext: _goNext,
                      onBack: _goBack),
        )),
      ),
    );
  }
}

class _StepFlow extends StatelessWidget {
  const _StepFlow(
      {super.key,
      required this.step,
      required this.dir,
      required this.ctrls,
      required this.focusNodes,
      required this.hadExisting,
      required this.saving,
      required this.onNext,
      required this.onBack});
  final int step, dir;
  final List<TextEditingController> ctrls;
  final List<FocusNode> focusNodes;
  final bool hadExisting, saving;
  final VoidCallback onNext, onBack;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _TopBar(step: step, onBack: onBack),
      const SizedBox(height: AppConstants.spaceLG),
      Align(alignment: Alignment.center, child: _ProgressDots(current: step)),
      const SizedBox(height: AppConstants.spaceXXL),
      Expanded(
          child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          final isIncoming = (child.key as ValueKey<int>).value == step;
          final slide = Tween<Offset>(
            begin: isIncoming ? Offset(dir * 0.10, 0) : Offset(-dir * 0.10, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
          return SlideTransition(
              position: slide,
              child: FadeTransition(opacity: animation, child: child));
        },
        layoutBuilder: (current, previous) => Stack(
            alignment: Alignment.topCenter,
            children: [...previous, if (current != null) current]),
        child: _StepContent(
            key: ValueKey<int>(step),
            prompt: reflectionPrompts[step],
            ctrl: ctrls[step],
            focusNode: focusNodes[step]),
      )),
      _BottomControls(
          step: step,
          ctrl: ctrls[step],
          hadExisting: hadExisting,
          saving: saving,
          onNext: onNext),
    ]);
  }
}

class _StepContent extends StatelessWidget {
  const _StepContent(
      {super.key,
      required this.prompt,
      required this.ctrl,
      required this.focusNode});
  final ReflectionPrompt prompt;
  final TextEditingController ctrl;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
      physics: const BouncingScrollPhysics(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(prompt.emoji, style: const TextStyle(fontSize: 44)),
        const SizedBox(height: 18),
        Text(prompt.question, style: AppTypography.heading),
        const SizedBox(height: 10),
        Text(prompt.hint, style: AppTypography.body.copyWith(height: 1.6)),
        const SizedBox(height: 28),
        Container(
            decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                border: Border.all(color: AppColors.border)),
            child: TextField(
              controller: ctrl,
              focusNode: focusNode,
              maxLines: null,
              minLines: 6,
              style: AppTypography.bodyLarge.copyWith(height: 1.72),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                  hintText: 'Write freely. No one is reading this.',
                  hintStyle: AppTypography.bodyLarge
                      .copyWith(color: AppColors.textDisabled, height: 1.72),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMD),
                      borderSide: BorderSide(color: prompt.accent, width: 1.5)),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.all(16)),
            )),
        const SizedBox(height: AppConstants.spaceLG),
      ]),
    );
  }
}

class _BottomControls extends StatefulWidget {
  const _BottomControls(
      {required this.step,
      required this.ctrl,
      required this.hadExisting,
      required this.saving,
      required this.onNext});
  final int step;
  final TextEditingController ctrl;
  final bool hadExisting, saving;
  final VoidCallback onNext;
  @override
  State<_BottomControls> createState() => _BottomControlsState();
}

class _BottomControlsState extends State<_BottomControls> {
  @override
  void initState() {
    super.initState();
    widget.ctrl.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(_BottomControls old) {
    super.didUpdateWidget(old);
    if (old.ctrl != widget.ctrl) {
      old.ctrl.removeListener(_rebuild);
      widget.ctrl.addListener(_rebuild);
    }
  }

  @override
  void dispose() {
    widget.ctrl.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  bool get _isFinal => widget.step == 2;
  bool get _hasText => widget.ctrl.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final prompt = reflectionPrompts[widget.step];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        AnimatedOpacity(
            duration: AppConstants.animNormal,
            opacity: _hasText ? 0.0 : 1.0,
            child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text("It's okay to leave blank — just tap Continue",
                    style: AppTypography.caption,
                    textAlign: TextAlign.center))),
        SizedBox(
            width: double.infinity,
            child: AnimatedContainer(
              duration: AppConstants.animNormal,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: _isFinal
                      ? AppColors.success
                      : _hasText
                          ? prompt.accent
                          : AppColors.surfaceHighlight,
                  boxShadow: _hasText
                      ? [
                          BoxShadow(
                              color:
                                  (_isFinal ? AppColors.success : prompt.accent)
                                      .withOpacity(0.30),
                              blurRadius: 18,
                              offset: const Offset(0, 4))
                        ]
                      : []),
              child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: widget.saving ? null : widget.onNext,
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                            child: widget.saving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                        Text(
                                            _isFinal
                                                ? (widget.hadExisting
                                                    ? 'Update reflection'
                                                    : 'Wrap up the day')
                                                : 'Continue',
                                            style: AppTypography.bodyLarge
                                                .copyWith(
                                                    color: _hasText
                                                        ? Colors.white
                                                        : AppColors
                                                            .textDisabled,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                        if (!_isFinal) ...[
                                          const SizedBox(width: 8),
                                          Icon(Icons.arrow_forward_rounded,
                                              size: 18,
                                              color: _hasText
                                                  ? Colors.white
                                                  : AppColors.textDisabled)
                                        ],
                                      ]))),
                  )),
            )),
      ]),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.current});
  final int current;
  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final isActive = i == current, isDone = i < current;
          return AnimatedContainer(
              duration: AppConstants.animNormal,
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 28.0 : 8.0,
              height: 8,
              decoration: BoxDecoration(
                  color: isDone
                      ? AppColors.success.withOpacity(0.55)
                      : isActive
                          ? reflectionPrompts[current].accent
                          : AppColors.border,
                  borderRadius: BorderRadius.circular(4)));
        }));
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.step, required this.onBack});
  final int step;
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Row(children: [
          GestureDetector(
              onTap: onBack,
              child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border)),
                  child: Icon(
                      step == 0
                          ? Icons.close_rounded
                          : Icons.arrow_back_ios_new_rounded,
                      size: 15,
                      color: AppColors.textSecondary))),
          const Spacer(),
          Text('Reflect',
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textMuted, letterSpacing: 0.5)),
          const Spacer(),
          GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PastReflectionsScreen())),
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: AppColors.border)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.history_rounded,
                        size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 5),
                    Text('History', style: AppTypography.caption),
                  ]))),
        ]));
  }
}

class _CompletionView extends StatefulWidget {
  const _CompletionView(
      {super.key, required this.answers, required this.onReturn});
  final List<String> answers;
  final VoidCallback onReturn;
  @override
  State<_CompletionView> createState() => _CompletionViewState();
}

class _CompletionViewState extends State<_CompletionView>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.07), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  String get _closingLine {
    final idx = DateTime.now().day % _closingLines.length;
    return _closingLines[idx];
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
        opacity: _fade,
        child: SlideTransition(
            position: _slide,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                  AppConstants.spaceMD,
                  AppConstants.spaceLG,
                  AppConstants.spaceMD,
                  AppConstants.spaceXXL),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                              color: AppColors.successDim,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.success.withOpacity(0.4))),
                          child: const Icon(Icons.check_rounded,
                              color: AppColors.success, size: 26)),
                      const SizedBox(width: 16),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Day wrapped.',
                                style: AppTypography.subheading
                                    .copyWith(color: AppColors.success)),
                            Text(
                                DateFormat('EEEE, MMMM d')
                                    .format(DateTime.now()),
                                style: AppTypography.bodySmall),
                          ]),
                    ]),
                    const SizedBox(height: AppConstants.spaceLG),
                    ...List.generate(
                        3,
                        (i) => _AnswerCard(
                            prompt: reflectionPrompts[i],
                            answer: widget.answers[i])),
                    const SizedBox(height: AppConstants.spaceMD),
                    Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusMD),
                            border: Border.all(color: AppColors.borderSubtle)),
                        child: Row(children: [
                          Container(
                              width: 3,
                              height: 34,
                              decoration: BoxDecoration(
                                  color: AppColors.success,
                                  borderRadius: BorderRadius.circular(2))),
                          const SizedBox(width: 14),
                          Expanded(
                              child: Text(_closingLine,
                                  style: AppTypography.quote)),
                        ])),
                    const SizedBox(height: 28),
                    SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                            onPressed: widget.onReturn,
                            style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                                side: const BorderSide(color: AppColors.border),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14))),
                            child: Text('Back to Base',
                                style: AppTypography.bodyLarge))),
                  ]),
            )));
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({required this.prompt, required this.answer});
  final ReflectionPrompt prompt;
  final String answer;
  @override
  Widget build(BuildContext context) {
    final hasAnswer = answer.isNotEmpty;
    return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(0, 14, 14, 14),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            border: Border.all(color: AppColors.border)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              width: 3,
              margin: const EdgeInsets.only(left: 14, right: 12, top: 2),
              constraints: const BoxConstraints(minHeight: 36),
              decoration: BoxDecoration(
                  color: prompt.accent.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(2))),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  Text(prompt.emoji, style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 6),
                  Expanded(
                      child: Text(prompt.question,
                          style: AppTypography.caption.copyWith(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500))),
                ]),
                const SizedBox(height: 7),
                Text(hasAnswer ? answer : '— left blank',
                    style: hasAnswer
                        ? AppTypography.body.copyWith(height: 1.58)
                        : AppTypography.bodySmall.copyWith(
                            color: AppColors.textDisabled,
                            fontStyle: FontStyle.italic)),
              ])),
        ]));
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({super.key});
  @override
  Widget build(BuildContext context) => const Center(
      child: CircularProgressIndicator(
          strokeWidth: 2.0, color: AppColors.primary));
}
