import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/content_item.dart';
import '../../providers/content_provider.dart';
import 'content_card.dart';
import 'content_form_sheet.dart';

class StageColumn extends ConsumerWidget {
  const StageColumn({super.key, required this.stage});
  final ContentStage stage;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(contentProvider);
    return async.when(
        loading: () => _SkeletonColumn(),
        error: (e, _) => Center(
            child: Text(e.toString(),
                style:
                    AppTypography.bodySmall.copyWith(color: AppColors.error))),
        data: (allItems) {
          final items = allItems.where((i) => i.stage == stage).toList();
          return items.isEmpty
              ? _EmptyColumn(stage: stage)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                      AppConstants.spaceMD, 12, AppConstants.spaceMD, 120),
                  physics: const BouncingScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (_, i) => ContentCard(item: items[i]));
        });
  }
}

class _EmptyColumn extends StatelessWidget {
  const _EmptyColumn({required this.stage});
  final ContentStage stage;
  String get _headline => switch (stage) {
        ContentStage.idea => 'No ideas yet',
        ContentStage.scripting => 'Nothing scripting',
        ContentStage.editing => 'Nothing to edit',
        ContentStage.posted => 'Nothing posted yet'
      };
  String get _subtitle => switch (stage) {
        ContentStage.idea => 'Tap + to drop a content idea.',
        ContentStage.scripting => 'Advance an idea to start scripting.',
        ContentStage.editing => 'Script something to start editing.',
        ContentStage.posted => 'Keep pushing content through the pipeline.'
      };
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => showContentFormSheet(context, initialStage: stage),
        behavior: HitTestBehavior.opaque,
        child: Center(
            child: Padding(
                padding: const EdgeInsets.all(AppConstants.spaceLG),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                          color: stage.dimColor,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: stage.color.withOpacity(0.3))),
                      child: Center(
                          child: Text(stage.emoji,
                              style: const TextStyle(fontSize: 28)))),
                  const SizedBox(height: 18),
                  Text(_headline, style: AppTypography.subheading),
                  const SizedBox(height: 8),
                  Text(_subtitle,
                      style: AppTypography.body, textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                          color: stage.dimColor,
                          borderRadius: BorderRadius.circular(50),
                          border:
                              Border.all(color: stage.color.withOpacity(0.4))),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.add_rounded, size: 16, color: stage.color),
                        const SizedBox(width: 6),
                        Text('Add to ${stage.label}',
                            style: AppTypography.bodySmall.copyWith(
                                color: stage.color,
                                fontWeight: FontWeight.w600)),
                      ])),
                ]))));
  }
}

class _SkeletonColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spaceMD),
      itemCount: 4,
      itemBuilder: (_, i) => Container(
          height: 86,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppConstants.radiusMD))));
}
