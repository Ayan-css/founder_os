import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/content_item.dart';

class StagePillTabBar extends StatelessWidget {
  const StagePillTabBar(
      {super.key,
      required this.currentStage,
      required this.counts,
      required this.onStageTap});
  final ContentStage currentStage;
  final Map<ContentStage, int> counts;
  final void Function(ContentStage) onStageTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 44,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
            physics: const BouncingScrollPhysics(),
            itemCount: ContentStage.values.length,
            itemBuilder: (_, i) {
              final stage = ContentStage.values[i];
              final isSelected = stage == currentStage;
              final count = counts[stage] ?? 0;
              return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onStageTap(stage);
                      },
                      child: AnimatedContainer(
                        duration: AppConstants.animNormal,
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                            color: isSelected
                                ? stage.dimColor
                                : AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                                color: isSelected
                                    ? stage.color.withOpacity(0.5)
                                    : AppColors.border,
                                width: isSelected ? 1.5 : 1),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                        color: stage.glowColor,
                                        blurRadius: 10,
                                        spreadRadius: -2)
                                  ]
                                : []),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(stage.emoji,
                              style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 6),
                          Text(stage.label,
                              style: AppTypography.bodySmall.copyWith(
                                  color: isSelected
                                      ? stage.color
                                      : AppColors.textSecondary,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400)),
                          if (count > 0) ...[
                            const SizedBox(width: 6),
                            AnimatedContainer(
                                duration: AppConstants.animNormal,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                    color: isSelected
                                        ? stage.color.withOpacity(0.22)
                                        : AppColors.border,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Text('$count',
                                    style: AppTypography.caption.copyWith(
                                        color: isSelected
                                            ? stage.color
                                            : AppColors.textMuted,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10))),
                          ],
                        ]),
                      )));
            }));
  }
}
