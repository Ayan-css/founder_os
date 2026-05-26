import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/capture.dart';
import '../../providers/capture_provider.dart';

class CaptureListTile extends ConsumerWidget {
  const CaptureListTile({super.key, required this.capture});
  final Capture capture;
  static final _timeFormat = DateFormat('h:mm a · MMM d');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key('capture_${capture.id}'),
      direction: DismissDirection.endToStart,
      background: _DeleteBg(),
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        ref.read(capturesProvider.notifier).delete(capture);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            border: Border.all(color: AppColors.border)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border)),
              child: Center(
                  child: Text(capture.type.emoji,
                      style: const TextStyle(fontSize: 16))),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(capture.content,
                      style: AppTypography.bodyLarge.copyWith(height: 1.5),
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(children: [
                    _TypeLabel(type: capture.type),
                    const SizedBox(width: 8),
                    Text('·', style: AppTypography.caption),
                    const SizedBox(width: 8),
                    Text(_timeFormat.format(capture.createdAt),
                        style: AppTypography.caption),
                  ]),
                ])),
          ]),
        ),
      ),
    );
  }
}

class _TypeLabel extends StatelessWidget {
  const _TypeLabel({required this.type});
  final CaptureType type;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
          color: AppColors.primaryDim, borderRadius: BorderRadius.circular(5)),
      child: Text(type.label,
          style: AppTypography.caption
              .copyWith(color: AppColors.primaryLight, fontSize: 10)),
    );
  }
}

class _DeleteBg extends StatelessWidget {
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
            color: AppColors.error, size: 22),
      );
}
