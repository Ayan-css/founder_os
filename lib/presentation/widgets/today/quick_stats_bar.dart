import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../providers/focus_timer_provider.dart';
import '../../providers/streak_provider.dart';
import '../../providers/task_provider.dart';

class QuickStatsBar extends ConsumerWidget {
  const QuickStatsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done     = ref.watch(completedCountProvider);
    final sessions = ref.watch(focusTimerProvider).sessionsCompleted;
    final streak   = ref.watch(streakProvider).valueOrNull ?? 0;
    final quote    = _todayQuote();

    return Column(
      children: [
        Row(children: [
          _Stat(value: '$done',      label: 'completed'),
          _Divider(),
          _Stat(value: '$sessions',  label: 'sessions'),
          _Divider(),
          _Stat(value: '${streak}d', label: 'streak'),
        ]),
        const SizedBox(height: 20),
        Container(
          width:   double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:        AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(children: [
            Container(
              width: 3, height: 36,
              decoration: BoxDecoration(
                color:        AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(quote, style: AppTypography.quote)),
          ]),
        ),
      ],
    );
  }

  String _todayQuote() {
    final idx = AppDateUtils.getDayOfYear() %
        AppConstants.motivationalQuotes.length;
    return AppConstants.motivationalQuotes[idx];
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value, label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Text(value, style: AppTypography.statValue),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.statLabel, textAlign: TextAlign.center),
      ]),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 36, color: AppColors.border);
}
