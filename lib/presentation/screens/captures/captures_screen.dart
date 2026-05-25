import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/capture.dart';
import '../../providers/capture_provider.dart';
import '../../widgets/capture/capture_list_tile.dart';
import '../../widgets/capture/capture_sheet.dart';
import '../../widgets/capture/capture_type_chip.dart';

class CapturesScreen extends ConsumerStatefulWidget {
  const CapturesScreen({super.key});
  @override
  ConsumerState<CapturesScreen> createState() => _CapturesScreenState();
}

class _CapturesScreenState extends ConsumerState<CapturesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(capturesProvider.notifier).load();
    });
  }

  void _onFilterChanged(CaptureType? type) {
    ref.read(captureFilterProvider.notifier).state = type;
    ref.read(capturesProvider.notifier).load(filterType: type);
  }

  @override
  Widget build(BuildContext context, ) {
    final capturesAsync = ref.watch(capturesProvider);
    final filter = ref.watch(captureFilterProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppConstants.spaceMD, AppConstants.spaceLG, AppConstants.spaceMD, 0),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(width: 38, height: 38,
                decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textSecondary)),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Captures', style: AppTypography.subheading),
              capturesAsync.whenOrNull(data: (list) => Text('${list.length} notes', style: AppTypography.bodySmall)) ?? const SizedBox.shrink(),
            ])),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppConstants.spaceMD, 20, AppConstants.spaceMD, 0),
          child: CaptureTypeSelector(selected: filter, onSelect: _onFilterChanged, includeAll: true),
        ),
        const SizedBox(height: 16),
        Divider(height: 1, color: AppColors.borderSubtle),
        const SizedBox(height: 4),
        Expanded(child: capturesAsync.when(
          loading: () => _LoadingState(),
          error: (e, _) => Center(child: Text(e.toString(), style: AppTypography.bodySmall.copyWith(color: AppColors.error))),
          data: (items) => items.isEmpty ? _EmptyState(filterType: filter) : _CaptureList(captures: items),
        )),
      ])),
      floatingActionButton: _CapturesFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _CaptureList extends StatelessWidget {
  const _CaptureList({required this.captures});
  final List<Capture> captures;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(AppConstants.spaceMD, 12, AppConstants.spaceMD, AppConstants.spaceXXL),
      physics: const BouncingScrollPhysics(),
      itemCount: captures.length,
      itemBuilder: (_, i) => CaptureListTile(capture: captures[i]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filterType});
  final CaptureType? filterType;
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(filterType != null ? filterType!.emoji : '⚡', style: const TextStyle(fontSize: 40)),
      const SizedBox(height: 16),
      Text(filterType != null ? 'No \${filterType!.label.toLowerCase()}s yet' : 'Nothing captured yet', style: AppTypography.subheading),
      const SizedBox(height: 8),
      Text('Hit ⚡ and dump everything in your head.', style: AppTypography.body, textAlign: TextAlign.center),
    ]));
  }
}

class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spaceMD),
      itemCount: 5,
      itemBuilder: (_, __) => Container(height: 80, margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(AppConstants.radiusMD))),
    );
  }
}

class _CapturesFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, spreadRadius: -4)]),
      child: FloatingActionButton(
        onPressed: () => showCaptureSheet(context),
        backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0,
        child: const Icon(Icons.bolt_rounded, size: 26)),
    );
  }
}