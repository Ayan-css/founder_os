import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/client.dart';

class ClientStatusBadge extends StatelessWidget {
  const ClientStatusBadge({super.key, required this.status});
  final ClientStatus status;
  @override
  Widget build(BuildContext context) => _Pill(
      emoji: status.emoji,
      label: status.label,
      color: status.color,
      dim: status.dimColor);
}

class PaymentStateBadge extends StatelessWidget {
  const PaymentStateBadge({super.key, required this.payment});
  final PaymentState payment;
  @override
  Widget build(BuildContext context) => _Pill(
      emoji: payment.emoji,
      label: payment.label,
      color: payment.color,
      dim: payment.dimColor);
}

class _Pill extends StatelessWidget {
  const _Pill(
      {required this.emoji,
      required this.label,
      required this.color,
      required this.dim});
  final String emoji, label;
  final Color color, dim;
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: dim,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.35))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(emoji, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          Text(label,
              style: AppTypography.caption.copyWith(
                  color: color, fontWeight: FontWeight.w600, fontSize: 10)),
        ]));
  }
}
