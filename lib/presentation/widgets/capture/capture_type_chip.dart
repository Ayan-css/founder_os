import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/capture.dart';

class CaptureTypeChip extends StatelessWidget {
  const CaptureTypeChip(
      {super.key,
      required this.type,
      required this.isSelected,
      required this.onTap,
      this.compact = false});
  final CaptureType type;
  final bool isSelected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: AppConstants.animNormal,
        padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 14, vertical: compact ? 6 : 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDim : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.6)
                  : AppColors.border,
              width: isSelected ? 1.5 : 1),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(type.emoji, style: TextStyle(fontSize: compact ? 12 : 14)),
          const SizedBox(width: 6),
          Text(type.label,
              style: (compact ? AppTypography.caption : AppTypography.bodySmall)
                  .copyWith(
                      color: isSelected
                          ? AppColors.primaryLight
                          : AppColors.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400)),
        ]),
      ),
    );
  }
}

class CaptureTypeSelector extends StatelessWidget {
  const CaptureTypeSelector(
      {super.key,
      required this.selected,
      required this.onSelect,
      this.includeAll = false,
      this.compact = false});
  final CaptureType? selected;
  final void Function(CaptureType?) onSelect;
  final bool includeAll;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(children: [
        if (includeAll) ...[
          _AllChip(
              isSelected: selected == null,
              onTap: () => onSelect(null),
              compact: compact),
          const SizedBox(width: 8),
        ],
        ...CaptureType.values.map((type) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CaptureTypeChip(
                  type: type,
                  isSelected: selected == type,
                  onTap: () => onSelect(type),
                  compact: compact),
            )),
      ]),
    );
  }
}

class _AllChip extends StatelessWidget {
  const _AllChip(
      {required this.isSelected, required this.onTap, this.compact = false});
  final bool isSelected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animNormal,
        padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 14, vertical: compact ? 6 : 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDim : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.6)
                  : AppColors.border,
              width: isSelected ? 1.5 : 1),
        ),
        child: Text('All',
            style: (compact ? AppTypography.caption : AppTypography.bodySmall)
                .copyWith(
                    color: isSelected
                        ? AppColors.primaryLight
                        : AppColors.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400)),
      ),
    );
  }
}
