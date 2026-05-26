import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../domain/models/reflection.dart';
import '../../providers/reflection_provider.dart';
import 'reflection_screen.dart' show reflectionPrompts, ReflectionPrompt;

class PastReflectionsScreen extends ConsumerWidget {
  const PastReflectionsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(allReflectionsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(children: [
              GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border)),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 15, color: AppColors.textSecondary))),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Past Reflections', style: AppTypography.subheading),
                    async.whenOrNull(
                            data: (list) => Text('${list.length} entries',
                                style: AppTypography.bodySmall)) ??
                        const SizedBox.shrink(),
                  ])),
            ])),
        const SizedBox(height: 16),
        const Divider(height: 1, color: AppColors.borderSubtle),
        Expanded(
            child: async.when(
          loading: () => const Center(
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary)),
          error: (e, _) => Center(
              child: Text(e.toString(),
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.error))),
          data: (list) =>
              list.isEmpty ? _EmptyState() : _ReflectionList(reflections: list),
        )),
      ])),
    );
  }
}

class _ReflectionList extends StatelessWidget {
  const _ReflectionList({required this.reflections});
  final List<Reflection> reflections;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 56),
      physics: const BouncingScrollPhysics(),
      itemCount: reflections.length,
      itemBuilder: (_, i) => _ReflectionCard(reflection: reflections[i]),
    );
  }
}

class _ReflectionCard extends StatefulWidget {
  const _ReflectionCard({required this.reflection});
  final Reflection reflection;
  @override
  State<_ReflectionCard> createState() => _ReflectionCardState();
}

class _ReflectionCardState extends State<_ReflectionCard> {
  bool _expanded = false;
  static final _dateFormat = DateFormat('EEEE, MMMM d · yyyy');

  bool get _isToday => widget.reflection.date == AppDateUtils.todayDbDate();

  String? _previewText() {
    final r = widget.reflection;
    if (r.distraction != null && r.distraction!.isNotEmpty)
      return r.distraction;
    if (r.forward != null && r.forward!.isNotEmpty) return r.forward;
    if (r.improvement != null && r.improvement!.isNotEmpty)
      return r.improvement;
    return null;
  }

  String? _answerAt(int i) => switch (i) {
        0 => widget.reflection.distraction,
        1 => widget.reflection.forward,
        2 => widget.reflection.improvement,
        _ => null
      };

  @override
  Widget build(BuildContext context) {
    final r = widget.reflection;
    final count = r.answeredCount;
    return GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: AnimatedContainer(
          duration: AppConstants.animNormal,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
              color: _isToday
                  ? AppColors.primaryDim.withOpacity(0.35)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              border: Border.all(
                  color: _isToday
                      ? AppColors.primary.withOpacity(0.28)
                      : AppColors.border)),
          child: Column(children: [
            Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          color: count == 3
                              ? AppColors.successDim
                              : count == 2
                                  ? AppColors.primaryDim
                                  : AppColors.surfaceHighlight,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: AppColors.border)),
                      child: Center(
                          child: Text('$count/3',
                              style: AppTypography.caption.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: count == 3
                                      ? AppColors.success
                                      : AppColors.textSecondary)))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Row(children: [
                          Flexible(
                              child: Text(
                                  _dateFormat
                                      .format(AppDateUtils.fromDbDate(r.date)),
                                  style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary))),
                          if (_isToday) ...[
                            const SizedBox(width: 6),
                            _TodayBadge()
                          ],
                        ]),
                        if (!_expanded) ...[
                          const SizedBox(height: 3),
                          Text(_previewText() ?? 'Tap to view',
                              style: AppTypography.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis)
                        ],
                      ])),
                  AnimatedRotation(
                      turns: _expanded ? 0.5 : 0.0,
                      duration: AppConstants.animNormal,
                      child: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textMuted, size: 20)),
                ])),
            AnimatedSize(
                duration: AppConstants.animNormal,
                curve: Curves.easeOut,
                child: _expanded
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                        child: Column(children: [
                          const Divider(
                              height: 1, color: AppColors.borderSubtle),
                          const SizedBox(height: 14),
                          ...List.generate(
                              3,
                              (i) => _ExpandedAnswer(
                                  prompt: reflectionPrompts[i],
                                  answer: _answerAt(i))),
                        ]))
                    : const SizedBox.shrink()),
          ]),
        ));
  }
}

class _ExpandedAnswer extends StatelessWidget {
  const _ExpandedAnswer({required this.prompt, required this.answer});
  final ReflectionPrompt prompt;
  final String? answer;
  @override
  Widget build(BuildContext context) {
    final hasAnswer = answer != null && answer!.isNotEmpty;
    return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(prompt.emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(prompt.question,
                    style: AppTypography.caption.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                Text(hasAnswer ? answer! : '— left blank',
                    style: hasAnswer
                        ? AppTypography.body.copyWith(height: 1.58)
                        : AppTypography.caption.copyWith(
                            color: AppColors.textDisabled,
                            fontStyle: FontStyle.italic)),
              ])),
        ]));
  }
}

class _TodayBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: AppColors.primaryDim, borderRadius: BorderRadius.circular(4)),
      child: Text('today',
          style: AppTypography.caption
              .copyWith(color: AppColors.primaryLight, fontSize: 9)));
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('📖', style: TextStyle(fontSize: 38)),
        const SizedBox(height: 16),
        Text('No reflections yet', style: AppTypography.subheading),
        const SizedBox(height: 8),
        Text('Your nightly reflections\nwill appear here.',
            style: AppTypography.body, textAlign: TextAlign.center),
      ]));
}
