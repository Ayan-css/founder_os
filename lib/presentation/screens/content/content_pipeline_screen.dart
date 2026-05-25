import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/content_item.dart';
import '../../providers/content_provider.dart';
import '../../widgets/content/content_form_sheet.dart';
import '../../widgets/content/stage_column.dart';
import '../../widgets/content/stage_tab_bar.dart';

class ContentPipelineScreen extends ConsumerStatefulWidget {
  const ContentPipelineScreen({super.key});
  @override
  ConsumerState<ContentPipelineScreen> createState() => _ContentPipelineScreenState();
}

class _ContentPipelineScreenState extends ConsumerState<ContentPipelineScreen> {
  late final PageController _pageCtrl;
  int _stageIndex = 0;
  ContentStage get _currentStage => ContentStage.values[_stageIndex];

  @override
  void initState() { super.initState(); _pageCtrl = PageController(); }

  @override
  void dispose() { _pageCtrl.dispose(); super.dispose(); }

  void _goToStage(ContentStage stage) {
    final index = ContentStage.values.indexOf(stage);
    if (index == _stageIndex) return;
    _pageCtrl.animateToPage(index, duration: AppConstants.animNormal, curve: Curves.easeOut);
    setState(() => _stageIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final counts = ref.watch(stageCountsProvider);
    final totalActive = ref.watch(activePipelineCountProvider);
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
              Text('Content Pipeline', style: AppTypography.subheading),
              Text(totalActive == 0 ? 'Pipeline empty' : '$totalActive active item${totalActive == 1 ? '' : 's'}', style: AppTypography.bodySmall),
            ])),
            _StageCounter(stage: _currentStage, count: counts[_currentStage] ?? 0),
          ])),
        const SizedBox(height: 14),
        StagePillTabBar(currentStage: _currentStage, counts: counts, onStageTap: _goToStage),
        const SizedBox(height: 10),
        const Divider(height: 1, color: AppColors.borderSubtle),
        Expanded(child: PageView.builder(
          controller: _pageCtrl,
          itemCount: ContentStage.values.length,
          onPageChanged: (i) => setState(() => _stageIndex = i),
          itemBuilder: (_, i) => StageColumn(stage: ContentStage.values[i]))),
      ])),
      floatingActionButton: _StageFAB(stage: _currentStage),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _StageCounter extends StatelessWidget {
  const _StageCounter({required this.stage, required this.count});
  final ContentStage stage;
  final int count;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppConstants.animNormal,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: stage.dimColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: stage.color.withOpacity(0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(stage.emoji, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 6),
        Text('$count', style: AppTypography.bodySmall.copyWith(color: stage.color, fontWeight: FontWeight.w700)),
      ]));
  }
}

class _StageFAB extends StatelessWidget {
  const _StageFAB({required this.stage});
  final ContentStage stage;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppConstants.animNormal,
      decoration: BoxDecoration(boxShadow: [BoxShadow(color: stage.color.withOpacity(0.30), blurRadius: 20, spreadRadius: -4)]),
      child: FloatingActionButton(
        onPressed: () => showContentFormSheet(context, initialStage: stage),
        backgroundColor: stage.color, foregroundColor: Colors.white, elevation: 0,
        child: const Icon(Icons.add_rounded, size: 26)));
  }
}