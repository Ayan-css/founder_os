import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/capture_provider.dart';
import '../../providers/client_provider.dart';
import '../../providers/content_provider.dart';
import '../../providers/reflection_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/capture/capture_sheet.dart';
import '../../widgets/today/focus_timer_card.dart';
import '../../widgets/today/greeting_header.dart';
import '../../widgets/today/quick_stats_bar.dart';
import '../../widgets/today/tasks_section.dart';
import '../captures/captures_screen.dart';
import '../client/client_tracker_screen.dart';
import '../content/content_pipeline_screen.dart';
import '../reflection/reflection_screen.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allDone = ref.watch(allTasksDoneProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: AppConstants.spaceLG)),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
              sliver: const SliverToBoxAdapter(child: GreetingHeader())),

            if (allDone) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
                sliver: const SliverToBoxAdapter(child: _CelebrationBanner())),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: AppConstants.spaceMD)),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
              sliver: const SliverToBoxAdapter(child: _UtilityRow())),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
              sliver: const SliverToBoxAdapter(child: _BottomUtilityRow())),

            const SliverToBoxAdapter(child: SizedBox(height: AppConstants.spaceMD)),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
              sliver: const SliverToBoxAdapter(child: TasksSection())),

            const SliverToBoxAdapter(child: SizedBox(height: AppConstants.spaceMD)),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
              sliver: const SliverToBoxAdapter(child: FocusTimerCard())),

            const SliverToBoxAdapter(child: SizedBox(height: AppConstants.spaceMD)),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
              sliver: const SliverToBoxAdapter(child: QuickStatsBar())),

            const SliverToBoxAdapter(child: SizedBox(height: AppConstants.spaceXXL)),
          ],
        ),
      ),
      floatingActionButton: _CaptureFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _UtilityRow extends ConsumerWidget {
  const _UtilityRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final captureCount = ref.watch(todayCaptureCountProvider).valueOrNull ?? 0;
    final activeCount  = ref.watch(activePipelineCountProvider);
    final counts       = ref.watch(stageCountsProvider);
    final summary = ContentStage.values
        .where((s) => s != ContentStage.posted && (counts[s] ?? 0) > 0)
        .map((s) => '${counts[s]} ${s.shortLabel.toLowerCase()}')
        .join(' · ');

    return Row(children: [
      Expanded(child: _MiniCard(
        icon: '⚡', iconBg: AppColors.primaryDim,
        title: 'Captures',
        subtitle: captureCount == 0 ? 'None today' : '$captureCount today',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CapturesScreen())))),
      const SizedBox(width: 8),
      Expanded(child: _MiniCard(
        icon: '🎬', iconBg: AppColors.surfaceHighlight,
        title: 'Pipeline',
        subtitle: activeCount == 0 ? 'Nothing active' : summary.isEmpty ? '$activeCount active' : summary,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContentPipelineScreen())))),
    ]);
  }
}

class _BottomUtilityRow extends ConsumerWidget {
  const _BottomUtilityRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync  = ref.watch(clientSummaryProvider);
    final overdue = summaryAsync.whenOrNull(data: (m) => (m['overdue'] ?? 0)) ?? 0;
    final active  = summaryAsync.whenOrNull(data: (m) => (m['active']  ?? 0)) ?? 0;
    final clientSubtitle = overdue > 0 ? '$overdue overdue 🔴' : active == 0 ? 'No active clients' : '$active active';

    final reflectionAsync = ref.watch(todayReflectionProvider);
    final reflectionDone  = reflectionAsync.whenOrNull(data: (r) => r != null && !r.isEmpty) ?? false;
    final isEvening = DateTime.now().hour >= 17;
    final reflectionSubtitle = reflectionDone ? 'Done today ✅' : isEvening ? 'Time to reflect 🌙' : 'Reflect tonight';

    return Row(children: [
      Expanded(child: _MiniCard(
        icon: '🤝',
        iconBg: overdue > 0 ? AppColors.error.withOpacity(0.18) : AppColors.successDim,
        iconBorderColor: overdue > 0 ? AppColors.error.withOpacity(0.35) : null,
        title: 'Clients',
        subtitle: clientSubtitle,
        subtitleColor: overdue > 0 ? AppColors.error : null,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientTrackerScreen())))),
      const SizedBox(width: 8),
      Expanded(child: _MiniCard(
        icon: reflectionDone ? '✅' : isEvening ? '🌙' : '📝',
        iconBg: reflectionDone ? AppColors.successDim : isEvening ? AppColors.primaryDim : AppColors.surfaceHighlight,
        title: 'Reflect',
        subtitle: reflectionSubtitle,
        subtitleColor: reflectionDone ? AppColors.success : null,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReflectionScreen())))),
    ]);
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.icon, required this.iconBg, required this.title,
    required this.subtitle, required this.onTap,
    this.iconBorderColor, this.subtitleColor,
  });
  final String icon, title, subtitle;
  final Color iconBg;
  final VoidCallback onTap;
  final Color? iconBorderColor, subtitleColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          border: Border.all(color: iconBorderColor ?? AppColors.border)),
        child: Row(children: [
          Container(width: 30, height: 30,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8),
              border: iconBorderColor != null ? Border.all(color: iconBorderColor!) : null),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 14)))),
          const SizedBox(width: 9),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            Text(subtitle, style: AppTypography.caption.copyWith(color: subtitleColor ?? AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          Icon(Icons.chevron_right_rounded, color: AppColors.textDisabled, size: 16),
        ])));
  }
}

class _CelebrationBanner extends StatelessWidget {
  const _CelebrationBanner();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.success.withOpacity(0.15), AppColors.primary.withOpacity(0.10)]),
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(color: AppColors.success.withOpacity(0.3))),
      child: Row(children: [
        const Text('🎯', style: TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('All priorities done!', style: AppTypography.bodyLarge.copyWith(color: AppColors.success)),
          Text("You're executing at a high level today.", style: AppTypography.bodySmall),
        ])),
      ]));
  }
}

class _CaptureFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.30), blurRadius: 20, spreadRadius: -4)]),
      child: FloatingActionButton(
        onPressed: () => showCaptureSheet(context),
        backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0,
        child: const Icon(Icons.bolt_rounded, size: 26)));
  }
}