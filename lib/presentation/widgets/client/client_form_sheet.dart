import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/client.dart';
import '../../providers/client_provider.dart';
import '../client/deliverable_row.dart';

Future<void> showClientFormSheet(BuildContext context, {Client? client}) {
  return showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => _ClientFormSheet(client: client));
}

class _ClientFormSheet extends ConsumerStatefulWidget {
  const _ClientFormSheet({this.client});
  final Client? client;
  @override
  ConsumerState<_ClientFormSheet> createState() => _ClientFormSheetState();
}

class _ClientFormSheetState extends ConsumerState<_ClientFormSheet> {
  late final TextEditingController _nameCtrl, _notesCtrl;
  late ClientStatus _status;
  late PaymentState _payment;
  late List<TextEditingController> _deliverablesCtrls;
  bool _saving = false;
  bool get _isEdit => widget.client != null;
  bool get _hasName => _nameCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    final c = widget.client;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _notesCtrl = TextEditingController(text: c?.notes ?? '');
    _status = c?.status ?? ClientStatus.prospect;
    _payment = c?.paymentState ?? PaymentState.pending;
    final existing = c?.deliverables ?? [];
    _deliverablesCtrls = existing.isEmpty ? [TextEditingController()] : existing.map((d) => TextEditingController(text: d)).toList();
    _nameCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() { _nameCtrl.dispose(); _notesCtrl.dispose(); for (final c in _deliverablesCtrls) c.dispose(); super.dispose(); }

  void _addDeliverableRow() => setState(() => _deliverablesCtrls.add(TextEditingController()));

  void _removeDeliverableRow(int i) {
    if (_deliverablesCtrls.length <= 1) { _deliverablesCtrls.first.clear(); setState(() {}); return; }
    _deliverablesCtrls[i].dispose();
    setState(() => _deliverablesCtrls.removeAt(i));
  }

  List<String> get _deliverables => _deliverablesCtrls.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();

  Future<void> _save() async {
    if (!_hasName) return;
    setState(() => _saving = true);
    final notes = _notesCtrl.text.trim();
    final notifier = ref.read(clientsProvider.notifier);
    if (_isEdit) {
      await notifier.updateClient(widget.client!.copyWith(name: _nameCtrl.text.trim(), status: _status, paymentState: _payment, deliverables: _deliverables, notes: notes.isEmpty ? null : notes, clearNotes: notes.isEmpty));
    } else {
      await notifier.add(name: _nameCtrl.text.trim(), status: _status, paymentState: _payment, deliverables: _deliverables, notes: notes.isEmpty ? null : notes);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(AppConstants.radiusXL), border: Border.all(color: AppColors.border)),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom + 16, left: 20, right: 20, top: 16),
        child: SingleChildScrollView(physics: const BouncingScrollPhysics(),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text(_isEdit ? 'Edit Client' : 'New Client', style: AppTypography.subheading),
            const SizedBox(height: 20),
            Text('CLIENT NAME', style: AppTypography.label),
            const SizedBox(height: 8),
            TextField(controller: _nameCtrl, autofocus: !_isEdit, style: AppTypography.bodyLarge,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(hintText: 'Company or person name...')),
            const SizedBox(height: 20),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('STATUS', style: AppTypography.label),
                const SizedBox(height: 8),
                _StatusSelector(selected: _status, onSelect: (s) => setState(() => _status = s)),
              ])),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('PAYMENT', style: AppTypography.label),
                const SizedBox(height: 8),
                _PaymentSelector(selected: _payment, onSelect: (p) => setState(() => _payment = p)),
              ])),
            ]),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: Text('DELIVERABLES', style: AppTypography.label)),
              GestureDetector(onTap: _addDeliverableRow,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.add_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 3),
                  Text('Add', style: AppTypography.caption.copyWith(color: AppColors.primary)),
                ])),
            ]),
            const SizedBox(height: 10),
            ...List.generate(_deliverablesCtrls.length, (i) => DeliverableRow(
              key: ValueKey(i), controller: _deliverablesCtrls[i], index: i, autofocus: false,
              onRemove: () => _removeDeliverableRow(i), onSubmitted: _addDeliverableRow)),
            const SizedBox(height: 20),
            Text('NOTES', style: AppTypography.label),
            const SizedBox(height: 8),
            TextField(controller: _notesCtrl, maxLines: 3, minLines: 2,
              style: AppTypography.body.copyWith(color: AppColors.textPrimary),
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Anything else to remember... (optional)')),
            const SizedBox(height: 22),
            SizedBox(width: double.infinity,
              child: AnimatedContainer(
                duration: AppConstants.animNormal,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  color: _hasName ? _status.color : AppColors.surfaceHighlight,
                  boxShadow: _hasName ? [BoxShadow(color: _status.color.withOpacity(0.28), blurRadius: 16, offset: const Offset(0, 4))] : []),
                child: Material(color: Colors.transparent, borderRadius: BorderRadius.circular(13),
                  child: InkWell(onTap: (_saving || !_hasName) ? null : _save, borderRadius: BorderRadius.circular(13),
                    child: Padding(padding: const EdgeInsets.symmetric(vertical: 15), child: Center(child: _saving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Row(mainAxisSize: MainAxisSize.min, children: [
                            Text(_status.emoji, style: const TextStyle(fontSize: 15)),
                            const SizedBox(width: 8),
                            Text(_isEdit ? 'Update Client' : 'Add Client',
                              style: AppTypography.bodyLarge.copyWith(color: _hasName ? Colors.white : AppColors.textDisabled, fontWeight: FontWeight.w600)),
                          ])))))),
            )),
          ])),
      ));
  }
}

class _StatusSelector extends StatelessWidget {
  const _StatusSelector({required this.selected, required this.onSelect});
  final ClientStatus selected;
  final void Function(ClientStatus) onSelect;
  @override
  Widget build(BuildContext context) {
    return Column(children: ClientStatus.values.map((s) {
      final isSelected = s == selected;
      return GestureDetector(onTap: () => onSelect(s),
        child: AnimatedContainer(
          duration: AppConstants.animNormal,
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? s.dimColor : AppColors.surface,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: isSelected ? s.color.withOpacity(0.55) : AppColors.border, width: isSelected ? 1.5 : 1)),
          child: Row(children: [
            Text(s.emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 7),
            Text(s.label, style: AppTypography.bodySmall.copyWith(color: isSelected ? s.color : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
          ])));
    }).toList());
  }
}

class _PaymentSelector extends StatelessWidget {
  const _PaymentSelector({required this.selected, required this.onSelect});
  final PaymentState selected;
  final void Function(PaymentState) onSelect;
  @override
  Widget build(BuildContext context) {
    return Column(children: PaymentState.values.map((p) {
      final isSelected = p == selected;
      return GestureDetector(onTap: () => onSelect(p),
        child: AnimatedContainer(
          duration: AppConstants.animNormal,
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? p.dimColor : AppColors.surface,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: isSelected ? p.color.withOpacity(0.55) : AppColors.border, width: isSelected ? 1.5 : 1)),
          child: Row(children: [
            Text(p.emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 7),
            Text(p.label, style: AppTypography.bodySmall.copyWith(color: isSelected ? p.color : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
          ])));
    }).toList());
  }
}