import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/client.dart';
import '../../providers/client_provider.dart';
import '../../widgets/client/client_form_sheet.dart';
import '../../widgets/client/client_status_badge.dart';

Future<void> showClientDetailSheet(BuildContext context,
    {required Client client}) {
  return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ClientDetailSheet(client: client));
}

class _ClientDetailSheet extends ConsumerWidget {
  const _ClientDetailSheet({required this.client});
  final Client client;
  static final _dateFormat = DateFormat('MMM d, yyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveClient = ref.watch(clientsProvider).whenOrNull(
            data: (list) => list.firstWhereOrNull((c) => c.id == client.id)) ??
        client;

    return DraggableScrollableSheet(
        initialChildSize: 0.68,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        expand: false,
        builder: (ctx, scrollCtrl) => Container(
            decoration: const BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            child: Column(children: [
              const SizedBox(height: 12),
              Center(
                  child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 4),
              Expanded(
                  child: ListView(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                      physics: const BouncingScrollPhysics(),
                      children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ClientAvatar(
                              name: liveClient.name, status: liveClient.status),
                          const SizedBox(width: 14),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(liveClient.name,
                                    style: AppTypography.subheading,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 8),
                                Wrap(spacing: 6, runSpacing: 6, children: [
                                  ClientStatusBadge(status: liveClient.status),
                                  PaymentStateBadge(
                                      payment: liveClient.paymentState),
                                ]),
                              ])),
                          GestureDetector(
                              onTap: () =>
                                  showClientFormSheet(ctx, client: liveClient),
                              child: Container(
                                  padding: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(9),
                                      border:
                                          Border.all(color: AppColors.border)),
                                  child: const Icon(Icons.edit_outlined,
                                      size: 16,
                                      color: AppColors.textSecondary))),
                        ]),
                    const SizedBox(height: 22),
                    const Divider(color: AppColors.borderSubtle, height: 1),
                    const SizedBox(height: 20),
                    Text('PAYMENT STATUS', style: AppTypography.label),
                    const SizedBox(height: 10),
                    _QuickPaymentRow(client: liveClient),
                    const SizedBox(height: 20),
                    if (liveClient.deliverables.isNotEmpty) ...[
                      Row(children: [
                        Expanded(
                            child: Text('DELIVERABLES',
                                style: AppTypography.label)),
                        Text('${liveClient.pendingDeliverableCount} pending',
                            style: AppTypography.caption),
                      ]),
                      const SizedBox(height: 10),
                      _DeliverableList(deliverables: liveClient.deliverables),
                      const SizedBox(height: 20),
                    ],
                    if (liveClient.notes != null &&
                        liveClient.notes!.isNotEmpty) ...[
                      Text('NOTES', style: AppTypography.label),
                      const SizedBox(height: 10),
                      Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius:
                                  BorderRadius.circular(AppConstants.radiusMD),
                              border: Border.all(color: AppColors.border)),
                          child: Text(liveClient.notes!,
                              style: AppTypography.body.copyWith(height: 1.6))),
                      const SizedBox(height: 20),
                    ],
                    const Divider(color: AppColors.borderSubtle, height: 1),
                    const SizedBox(height: 14),
                    Row(children: [
                      Text('Added ', style: AppTypography.caption),
                      Text(_dateFormat.format(liveClient.createdAt),
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textSecondary)),
                      const Spacer(),
                      Text('Updated ', style: AppTypography.caption),
                      Text(_dateFormat.format(liveClient.updatedAt),
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textSecondary)),
                    ]),
                  ])),
            ])));
  }
}

class _ClientAvatar extends StatelessWidget {
  const _ClientAvatar({required this.name, required this.status});
  final String name;
  final ClientStatus status;

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2)
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
            color: status.dimColor,
            shape: BoxShape.circle,
            border:
                Border.all(color: status.color.withOpacity(0.45), width: 1.5)),
        child: Center(
            child: Text(_initials,
                style: AppTypography.subheading
                    .copyWith(color: status.color, fontSize: 18))));
  }
}

class _QuickPaymentRow extends ConsumerWidget {
  const _QuickPaymentRow({required this.client});
  final Client client;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
        children: PaymentState.values.map((p) {
      final isSelected = p == client.paymentState;
      final isLast = p == PaymentState.values.last;
      return Expanded(
          child: GestureDetector(
              onTap: () {
                if (isSelected) return;
                HapticFeedback.selectionClick();
                ref
                    .read(clientsProvider.notifier)
                    .updateClient(client.copyWith(paymentState: p));
              },
              child: AnimatedContainer(
                  duration: AppConstants.animNormal,
                  margin: EdgeInsets.only(right: isLast ? 0 : 6),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                      color: isSelected ? p.dimColor : AppColors.surface,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                          color: isSelected
                              ? p.color.withOpacity(0.55)
                              : AppColors.border,
                          width: isSelected ? 1.5 : 1)),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(p.emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(p.label,
                        style: AppTypography.caption.copyWith(
                            color: isSelected ? p.color : AppColors.textMuted,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w400,
                            fontSize: 10),
                        textAlign: TextAlign.center),
                  ]))));
    }).toList());
  }
}

class _DeliverableList extends StatelessWidget {
  const _DeliverableList({required this.deliverables});
  final List<String> deliverables;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            border: Border.all(color: AppColors.border)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: deliverables.map((d) {
              final isLast = d == deliverables.last;
              return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            width: 7,
                            height: 7,
                            margin: const EdgeInsets.only(top: 6, right: 10),
                            decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.6),
                                shape: BoxShape.circle)),
                        Expanded(
                            child: Text(d,
                                style:
                                    AppTypography.body.copyWith(height: 1.5))),
                      ]));
            }).toList()));
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
