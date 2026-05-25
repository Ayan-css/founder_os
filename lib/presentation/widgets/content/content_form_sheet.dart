import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/content_item.dart';
import '../../providers/content_provider.dart';

Future<void> showContentFormSheet(BuildContext context, {ContentItem? item, ContentStage? initialStage}) {
  return showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
    builder: (_) => _ContentFormSheet(item: item, initialStage: initialStage));
}

class _ContentFormSheet extends ConsumerStatefulWidget {
  const _ContentFormSheet({this.item, this.initialStage});
  final ContentItem? item;
  final ContentStage? initialStage;
  @override
  ConsumerState<_ContentFormSheet> createState() => _ContentFormSheetState();
}

class _ContentFormSheetState extends ConsumerState<_ContentFormSheet> {
  late final TextEditingController _titleCtrl, _notesCtrl;
  late ContentStage _stage;
  bool _saving = false;
  bool get _isEdit => widget.item != null;
  bool get _hasText => _titleCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.item?.title ?? '');
    _notesCtrl = TextEditingController(text: widget.item?.notes ?? '');
    _stage = widget.item?.stage ?? widget.initialStage ?? ContentStage.idea;
    _titleCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() { _titleCtrl.dispose(); _notesCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (!_hasText) return;
    setState(() => _saving = true);
    final notifier = ref.read(contentProvider.notifier);
    final notesText = _notesCtrl.text.trim();
    if (_isEdit) {
      await notifier.updateItem(widget.item!.copyWith(title: _titleCtrl.text.trim(), stage: _stage, notes: notesText.isEmpty ? null : notesText, clearNotes: notesText.isEmpty));
    } else {
      await notifier.add(title: _titleCtrl.text.trim(), stage: _stage, notes: notesText.isEmpty ? null : notesText);
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    if (widget.item == null) return;
    await ref.read(contentProvider.notifier).delete(widget.item!);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(AppConstants.radiusXL), border: Border.all(color: AppColors.border)),
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom + 16, left: 20, right: 20, top: 16),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: Text(_isEdit ? 'Edit Content' : 'New Content', style: AppTypography.subheading)),
          if (_isEdit) GestureDetector(onTap: _delete,
            child: Container(padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.error.withOpacity(0.10), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.error.withOpacity(0.25))),
              child: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18))),
        ]),
        const SizedBox(height: 18),
        Text('MOVE TO STAGE', style: AppTypography.label),
        const SizedBox(height: 10),
        _StageGrid(selected: _stage, onSelect: (s) => setState(() => _stage = s)),
        const SizedBox(height: 18),
        Text('TITLE', style: AppTypography.label),
        const SizedBox(height: 8),
        TextField(controller: _titleCtrl, autofocus: !_isEdit, maxLines: 3, minLines: 1, style: AppTypography.bodyLarge,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Content idea or hook...')),
        const SizedBox(height: 14),
        Text('NOTES', style: AppTypography.label),
        const SizedBox(height: 8),
        TextField(controller: _notesCtrl, maxLines: 4, minLines: 2,
          style: AppTypography.body.copyWith(color: AppColors.textPrimary),
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Outline, hook idea, reference... (optional)')),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity,
          child: AnimatedContainer(
            duration: AppConstants.animNormal,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: _hasText ? _stage.color : AppColors.surfaceHighlight,
              boxShadow: _hasText ? [BoxShadow(color: _stage.color.withOpacity(0.30), blurRadius: 16, offset: const Offset(0, 4))] : []),
            child: Material(color: Colors.transparent, borderRadius: BorderRadius.circular(13),
              child: InkWell(
                onTap: (_saving || !_hasText) ? null : _save, borderRadius: BorderRadius.circular(13),
                child: Padding(padding: const EdgeInsets.symmetric(vertical: 15), child: Center(child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(_stage.emoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(_isEdit ? 'Update' : 'Add to Pipeline',
                          style: AppTypography.bodyLarge.copyWith(color: _hasText ? Colors.white : AppColors.textDisabled, fontWeight: FontWeight.w600)),
                      ])))))),
          )),
      ]),
    );
  }
}

class _StageGrid extends StatelessWidget {
  const _StageGrid({required this.selected, required this.onSelect});
  final ContentStage selected;
  final void Function(ContentStage) onSelect;
  @override
  Widget build(BuildContext context) {
    return Row(children: ContentStage.values.map((stage) {
      final isSelected = stage == selected;
      final isLast = stage == ContentStage.values.last;
      return Expanded(child: GestureDetector(onTap: () => onSelect(stage),
        child: AnimatedContainer(
          duration: AppConstants.animNormal,
          margin: EdgeInsets.only(right: isLast ? 0 : 7),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? stage.dimColor : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? stage.color.withOpacity(0.55) : AppColors.border, width: isSelected ? 1.5 : 1)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(stage.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(stage.shortLabel, style: AppTypography.caption.copyWith(
              color: isSelected ? stage.color : AppColors.textMuted,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400, fontSize: 10),
              textAlign: TextAlign.center),
          ]))));
    }).toList());
  }
}