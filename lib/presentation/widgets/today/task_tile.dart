import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/task.dart';
import '../../providers/task_provider.dart';
import 'add_task_sheet.dart';

class TaskTile extends ConsumerStatefulWidget {
  const TaskTile({super.key, required this.task});
  final Task task;

  @override
  ConsumerState<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends ConsumerState<TaskTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _bounceCtrl =
        AnimationController(vsync: this, duration: AppConstants.animNormal);
    _bounceAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    _bounceCtrl.forward(from: 0);
    ref.read(todayTasksProvider.notifier).toggleTask(widget.task);
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final completed = task.isCompleted;

    return Dismissible(
      key: Key('task_${task.id}'),
      direction: DismissDirection.endToStart,
      background: _DeleteBackground(),
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        ref.read(todayTasksProvider.notifier).deleteTask(task);
      },
      child: AnimatedContainer(
        duration: AppConstants.animNormal,
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: completed
              ? AppColors.successDim.withOpacity(0.25)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          border: Border.all(
            color: completed
                ? AppColors.success.withOpacity(0.3)
                : AppColors.border,
          ),
        ),
        child: InkWell(
          onTap: () => showAddTaskSheet(context,
              position: task.position, existingTask: task),
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          splashColor: AppColors.primary.withOpacity(0.06),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _toggle,
                  behavior: HitTestBehavior.opaque,
                  child: ScaleTransition(
                    scale: _bounceAnim,
                    child: AnimatedContainer(
                      duration: AppConstants.animNormal,
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color:
                            completed ? AppColors.success : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              completed ? AppColors.success : AppColors.border,
                          width: completed ? 0 : 1.5,
                        ),
                      ),
                      child: completed
                          ? const Icon(Icons.check_rounded,
                              size: 16, color: Colors.white)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: AppConstants.animNormal,
                    style: completed
                        ? AppTypography.bodyLarge.copyWith(
                            color: AppColors.textMuted,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: AppColors.textMuted,
                          )
                        : AppTypography.bodyLarge,
                    child: Text(task.title,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDim,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text('${task.position}',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.primaryLight)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete_outline_rounded,
          color: AppColors.error, size: 22),
    );
  }
}
