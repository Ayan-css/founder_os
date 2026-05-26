import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/client.dart';
import '../../providers/client_provider.dart';
import '../../screens/client/client_detail_sheet.dart';
import 'client_status_badge.dart';

class ClientCard extends ConsumerWidget {
  const ClientCard({super.key, required this.client});
  final Client client;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUrgent = client.hasUrgentIssue;
    return Dismissible(
      key: Key('client_${client.id}'),
      direction: DismissDirection.endToStart,
      background: _DeleteBg(),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        ref.read(clientsProvider.notifier).delete(client);
      },
      child: GestureDetector(
        onTap: () => showClientDetailSheet(context, client: client),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              border: Border.all(
                  color: isUrgent && client.paymentState == PaymentState.overdue
                      ? AppColors.error.withOpacity(0.38)
                      : AppColors.border,
                  width: isUrgent ? 1.5 : 1)),
          clipBehavior: Clip.hardEdge,
          child: Row(children: [
            Container(
                width: 3,
                height: 72,
                color: isUrgent
                    ? (client.paymentState == PaymentState.overdue
                        ? AppColors.error
                        : client.status.color)
                    : client.status.color.withOpacity(0.4)),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                                child: Text(client.name,
                                    style: AppTypography.bodyLarge.copyWith(
                                        fontWeight: FontWeight.w600,
                                        height: 1.2),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis)),
                            if (client.pendingDeliverableCount > 0)
                              _DeliverableCount(
                                  count: client.pendingDeliverableCount),
                          ]),
                          const SizedBox(height: 8),
                          Row(children: [
                            ClientStatusBadge(status: client.status),
                            const SizedBox(width: 6),
                            PaymentStateBadge(payment: client.paymentState),
                          ]),
                        ]))),
            Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(Icons.chevron_right_rounded,
                    color: AppColors.textDisabled, size: 20)),
          ]),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.surfaceElevated,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusLG)),
                title: Text('Remove ${client.name}?',
                    style: AppTypography.subheading),
                content: Text('This will permanently delete the client.',
                    style: AppTypography.body),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text('Cancel',
                          style: AppTypography.body
                              .copyWith(color: AppColors.textMuted))),
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text('Delete',
                          style: AppTypography.body
                              .copyWith(color: AppColors.error))),
                ]));
  }
}

class _DeliverableCount extends StatelessWidget {
  const _DeliverableCount({required this.count});
  final int count;
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
            color: AppColors.surfaceHighlight,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: AppColors.border)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.checklist_rounded,
              size: 11, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text('$count',
              style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
        ]));
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
          color: AppColors.error, size: 22));
}
