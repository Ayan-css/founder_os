import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/task.dart';
import '../../providers/task_provider.dart';
import 'add_task_sheet.dart';
import 'task_tile.dart';

class TasksSection extends ConsumerWidget {
  const TasksSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(todayTasksProvider);
    final progress = ref.watch(taskProgressProvider);
    final done = ref.watch(completedCountProvider);
    final total = ref.watch(totalCountProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text("TODAY'S PRIORITIES", style: AppTypography.label),
          const Spacer(),
          Text('$done / $total',
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textSecondary)),
        ]),
        const SizedBox(height: 12),
        _ProgressBar(progress: progress),
        const SizedBox(height: 16),
        tasksAsync.when(
          loading: () => const _SkeletonSlots(),
          error: (e, _) => Text('Error: $e',
              style: AppTypography.bodySmall.copyWith(color: AppColors.error)),
          data: (tasks) => _TaskSlots(tasks: tasks),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      return Container(
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: AppConstants.animSlow,
            curve: Curves.easeOut,
            width: constraints.maxWidth * progress,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight]),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.5),
                  blurRadius: 6,
                  spreadRadius: -1,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _TaskSlots extends StatelessWidget {
  const _TaskSlots({required this.tasks});
  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(AppConstants.maxDailyTasks, (i) {
        final pos = i + 1;
        final task = tasks.firstWhereOrNull((t) => t.position == pos);
        if (task != null) return TaskTile(task: task);
        return _EmptySlot(position: pos);
      }),
    );
  }
}

extension _FirstWhereOrNull<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({required this.position});
  final int position;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showAddTaskSheet(context, position: position),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        ),
        child: Row(children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border.withOpacity(0.6)),
            ),
          ),
          const SizedBox(width: 14),
          Text('Add priority $position',
              style:
                  AppTypography.body.copyWith(color: AppColors.textDisabled)),
          const Spacer(),
          Icon(Icons.add_rounded, color: AppColors.textDisabled, size: 18),
        ]),
      ),
    );
  }
}

class _SkeletonSlots extends StatelessWidget {
  const _SkeletonSlots();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
          3,
          (_) => Container(
                height: 56,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                ),
              )),
    );
  }
}
