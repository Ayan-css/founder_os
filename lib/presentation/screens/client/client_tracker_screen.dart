import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/client.dart';
import '../../providers/client_provider.dart';
import '../../widgets/client/client_card.dart';
import '../../widgets/client/client_form_sheet.dart';

class ClientTrackerScreen extends ConsumerWidget {
  const ClientTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients    = ref.watch(filteredClientsProvider);
    final filter     = ref.watch(clientStatusFilterProvider);
    final allAsync   = ref.watch(clientsProvider);
    final totalCount = allAsync.whenOrNull(
        data: (list) => list.where((c) => c.status != ClientStatus.churned).length) ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Row(children: [
            GestureDetector(onTap: () => Navigator.pop(context),
              child: Container(width: 38, height: 38,
                decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 15, color: AppColors.textSecondary))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Clients', style: AppTypography.subheading),
              Text('$totalCount active client${totalCount == 1 ? '' : 's'}', style: AppTypography.bodySmall),
            ])),
          ])),
        const SizedBox(height: 16),
        const _SummaryStrip(),
        const SizedBox(height: 14),
        _FilterBar(
          current: filter,
          onSelect: (s) => ref.read(clientStatusFilterProvider.notifier).state = s),
        const SizedBox(height: 10),
        const Divider(height: 1, color: AppColors.borderSubtle),
        Expanded(child: allAsync.when(
          loading: () => _SkeletonList(),
          error: (e, _) => Center(child: Text(e.toString(), style: AppTypography.bodySmall.copyWith(color: AppColors.error))),
          data: (_) => clients.isEmpty ? _EmptyState(filter: filter) : _ClientList(clients: clients),
        )),
      ])),
      floatingActionButton: _AddClientFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _SummaryStrip extends ConsumerWidget {
  const _SummaryStrip();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(clientSummaryProvider);
    return async.when(
      loading: () => const SizedBox(height: 58),
      error: (_, __) => const SizedBox.shrink(),
      data: (counts) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
        child: Row(children: [
          _StatCell(value: '${counts['active'] ?? 0}', label: 'Active', color: AppColors.success),
          const SizedBox(width: 8),
          _StatCell(value: '${counts['awaiting'] ?? 0}', label: 'Awaiting Pay', color: AppColors.warning),
          const SizedBox(width: 8),
          _StatCell(value: '${counts['overdue'] ?? 0}', label: 'Overdue',
            color: (counts['overdue'] ?? 0) > 0 ? AppColors.error : AppColors.textMuted),
        ])));
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label, required this.color});
  final String value, label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppConstants.radiusMD), border: Border.all(color: AppColors.border)),
      child: Column(children: [
        Text(value, style: AppTypography.statValue.copyWith(color: color)),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.statLabel),
      ])));
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.current, required this.onSelect});
  final ClientStatus? current;
  final void Function(ClientStatus?) onSelect;
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 38,
      child: ListView(scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
        physics: const BouncingScrollPhysics(),
        children: [
          _FilterChip(label: 'All', emoji: '👥', isSelected: current == null, color: AppColors.primary, dimColor: AppColors.primaryDim, onTap: () => onSelect(null)),
          const SizedBox(width: 8),
          ...ClientStatus.values.map((s) => Padding(padding: const EdgeInsets.only(right: 8),
            child: _FilterChip(label: s.label, emoji: s.emoji, isSelected: current == s, color: s.color, dimColor: s.dimColor, onTap: () => onSelect(s)))),
        ]));
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.emoji, required this.isSelected, required this.color, required this.dimColor, required this.onTap});
  final String label, emoji;
  final bool isSelected;
  final Color color, dimColor;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animNormal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? dimColor : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: isSelected ? color.withOpacity(0.5) : AppColors.border, width: isSelected ? 1.5 : 1)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Text(label, style: AppTypography.bodySmall.copyWith(color: isSelected ? color : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
        ])));
  }
}

class _ClientList extends StatelessWidget {
  const _ClientList({required this.clients});
  final List<Client> clients;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(AppConstants.spaceMD, 12, AppConstants.spaceMD, 120),
      physics: const BouncingScrollPhysics(),
      itemCount: clients.length,
      itemBuilder: (_, i) => ClientCard(client: clients[i]));
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter});
  final ClientStatus? filter;
  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(padding: const EdgeInsets.all(AppConstants.spaceLG),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(filter != null ? filter!.emoji : '🤝', style: const TextStyle(fontSize: 40)),
        const SizedBox(height: 16),
        Text(filter != null ? 'No ${filter!.label.toLowerCase()} clients' : 'No clients yet', style: AppTypography.subheading),
        const SizedBox(height: 8),
        Text(filter != null ? 'Try a different filter.' : 'Tap + to add your first client.', style: AppTypography.body, textAlign: TextAlign.center),
      ])));
  }
}

class _SkeletonList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spaceMD), itemCount: 5,
      itemBuilder: (_, __) => Container(height: 72, margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(AppConstants.radiusMD))));
  }
}

class _AddClientFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(boxShadow: [BoxShadow(color: AppColors.success.withOpacity(0.28), blurRadius: 20, spreadRadius: -4)]),
      child: FloatingActionButton(
        onPressed: () => showClientFormSheet(context),
        backgroundColor: AppColors.success, foregroundColor: Colors.white, elevation: 0,
        child: const Icon(Icons.person_add_outlined, size: 24)));
  }
}