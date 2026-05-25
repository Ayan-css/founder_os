import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/task.dart';
import '../../providers/task_provider.dart';

Future<void> showAddTaskSheet(
  BuildContext context, {
  required int position,
  Task? existingTask,
}) {
  return showModalBottomSheet(
    context:            context,
    isScrollControlled: true,
    builder: (_) =>
        _AddTaskSheet(position: position, existingTask: existingTask),
  );
}

class _AddTaskSheet extends ConsumerStatefulWidget {
  const _AddTaskSheet({required this.position, this.existingTask});
  final int  position;
  final Task? existingTask;

  @override
  ConsumerState<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<_AddTaskSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.existingTask?.title ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() {
    final notifier = ref.read(todayTasksProvider.notifier);
    final text     = _ctrl.text.trim();
    if (text.isEmpty) { Navigator.pop(context); return; }

    if (widget.existingTask != null) {
      notifier.updateTitle(widget.existingTask!, text);
    } else {
      notifier.addTask(text, widget.position);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingTask != null;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
        left: 24, right: 24, top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color:        AppColors.primaryDim,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text('${widget.position}',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.primaryLight)),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              isEdit ? 'Edit Priority' : 'Priority ${widget.position}',
              style: AppTypography.subheading,
            ),
          ]),
          const SizedBox(height: 20),
          TextField(
            controller:   _ctrl,
            autofocus:    true,
            maxLines:     3,
            minLines:     1,
            maxLength:    AppConstants.maxTaskTitleLength,
            style:        AppTypography.bodyLarge,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText:    'What must get done?',
              counterStyle: TextStyle(color: AppColors.textDisabled),
            ),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 16),
          Row(children: [
            if (isEdit) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(todayTasksProvider.notifier)
                        .deleteTask(widget.existingTask!);
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Delete'),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(isEdit ? 'Update' : 'Set Priority',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
              ),
            ),
          ]),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}
