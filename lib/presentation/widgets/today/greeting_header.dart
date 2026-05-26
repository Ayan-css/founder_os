import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../providers/streak_provider.dart';

class GreetingHeader extends ConsumerWidget {
  const GreetingHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(streakProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppDateUtils.getGreeting(), style: AppTypography.heading),
              const SizedBox(height: 4),
              Text(
                AppDateUtils.formatDisplayDate(DateTime.now()),
                style: AppTypography.body,
              ),
            ],
          ),
        ),
        streakAsync.when(
          data: (n) => _StreakBadge(streak: n),
          loading: () => const _StreakBadge(streak: 0),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    final active = streak > 0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active
            ? AppColors.streakFlame.withOpacity(0.12)
            : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active
              ? AppColors.streakFlame.withOpacity(0.3)
              : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(active ? '🔥' : '○', style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$streak',
                style: active
                    ? AppTypography.streakCount
                    : AppTypography.streakCount
                        .copyWith(color: AppColors.textMuted),
              ),
              Text(
                streak == 1 ? 'day' : 'days',
                style: AppTypography.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
