import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/app_date_utils.dart';
import 'task_provider.dart';

final streakProvider = FutureProvider<int>((ref) async {
  ref.watch(todayTasksProvider);
  final dates = await ref
      .watch(taskRepositoryProvider)
      .getDatesWithCompletedTasks();
  return _calcStreak(dates);
});

int _calcStreak(List<String> datesDesc) {
  if (datesDesc.isEmpty) return 0;

  final now     = DateTime.now();
  final today   = DateTime(now.year, now.month, now.day);
  final latest  = AppDateUtils.fromDbDate(datesDesc.first);
  final latestDay = DateTime(latest.year, latest.month, latest.day);

  if (today.difference(latestDay).inDays > 1) return 0;

  int streak   = 0;
  DateTime expected = latestDay;

  for (final ds in datesDesc) {
    final d   = AppDateUtils.fromDbDate(ds);
    final day = DateTime(d.year, d.month, d.day);
    if (day == expected) {
      streak++;
      expected = expected.subtract(const Duration(days: 1));
    } else {
      break;
    }
  }
  return streak;
}
