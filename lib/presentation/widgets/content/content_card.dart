import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/content_item.dart';
import '../../providers/content_provider.dart';
import 'content_form_sheet.dart';

class ContentCard extends ConsumerWidget {
  const ContentCard({super.key, required this.item});
  final ContentItem item;
  static final _dateFormat = DateFormat('MMM d');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stage = item.stage;
    final hasNext = stage.next != null;
    return Dismissible(
        key: Key('content_${item.id}'),
        direction: DismissDirection.endToStart,
        background: _DeleteBackground(),
        confirmDismiss: (_) async {
          HapticFeedback.mediumImpact();
          return true;
        },
        onDismissed: (_) => ref.read(contentProvider.notifier).delete(item),
        child: GestureDetector(
          onTap: () => showContentFormSheet(context, item: item),
          child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                  border: Border.all(color: AppColors.border)),
              clipBehavior: Clip.hardEdge,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: 3,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                          stage.color.withOpacity(0.85),
                          stage.color.withOpacity(0.15)
                        ]))),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(item.title,
                                        style: AppTypography.bodyLarge
                                            .copyWith(height: 1.4),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis),
                                    if (item.notes != null &&
                                        item.notes!.isNotEmpty) ...[
                                      const SizedBox(height: 5),
                                      Text(item.notes!,
                                          style: AppTypography.bodySmall
                                              .copyWith(height: 1.45),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis),
                                    ],
                                    const SizedBox(height: 10),
                                    Row(children: [
                                      _StagePill(stage: stage),
                                      const SizedBox(width: 8),
                                      Text(
                                          '· ${_dateFormat.format(item.createdAt)}',
                                          style: AppTypography.caption),
                                    ]),
                                  ])),
                              if (hasNext) ...[
                                const SizedBox(width: 10),
                                _AdvanceButton(item: item)
                              ],
                            ])),
                  ])),
        ));
  }
}

class _StagePill extends StatelessWidget {
  const _StagePill({required this.stage});
  final ContentStage stage;
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
            color: stage.dimColor, borderRadius: BorderRadius.circular(5)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(stage.emoji, style: const TextStyle(fontSize: 9)),
          const SizedBox(width: 4),
          Text(stage.label,
              style: AppTypography.caption.copyWith(
                  color: stage.color,
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
        ]));
  }
}

class _AdvanceButton extends ConsumerWidget {
  const _AdvanceButton({required this.item});
  final ContentItem item;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final next = item.stage.next;
    if (next == null) return const SizedBox.shrink();
    return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          ref.read(contentProvider.notifier).moveToNextStage(item);
        },
        child: Tooltip(
            message: 'Move to ${next.label}',
            child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    color: next.dimColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: next.color.withOpacity(0.3))),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(next.emoji, style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 1),
                      Icon(Icons.arrow_forward_rounded,
                          size: 11, color: next.color),
                    ]))));
  }
}

class _DeleteBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          border: Border.all(color: AppColors.error.withOpacity(0.3))),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete_outline_rounded,
          color: AppColors.error, size: 22));
}
