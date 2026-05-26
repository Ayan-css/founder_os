import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class DeliverableRow extends StatelessWidget {
  const DeliverableRow(
      {super.key,
      required this.controller,
      required this.index,
      required this.onRemove,
      required this.onSubmitted,
      this.autofocus = false});
  final TextEditingController controller;
  final int index;
  final VoidCallback onRemove, onSubmitted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(right: 10, top: 1),
              decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.6),
                  shape: BoxShape.circle)),
          Expanded(
              child: TextField(
                  controller: controller,
                  autofocus: autofocus,
                  style:
                      AppTypography.body.copyWith(color: AppColors.textPrimary),
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                      hintText: 'Deliverable ${index + 1}...',
                      hintStyle: AppTypography.body
                          .copyWith(color: AppColors.textDisabled),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: AppColors.primary.withOpacity(0.4),
                              width: 1)),
                      contentPadding: const EdgeInsets.only(bottom: 4),
                      isDense: true),
                  onSubmitted: (_) => onSubmitted())),
          GestureDetector(
              onTap: onRemove,
              child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(Icons.remove_circle_outline_rounded,
                      size: 18, color: AppColors.textDisabled))),
        ]));
  }
}
