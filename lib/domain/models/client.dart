import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum ClientStatus {
  prospect('prospect', '👀', 'Prospect'),
  active('active', '✅', 'Active'),
  paused('paused', '⏸️', 'Paused'),
  churned('churned', '❌', 'Churned');

  const ClientStatus(this.dbValue, this.emoji, this.label);

  final String dbValue;
  final String emoji;
  final String label;

  static ClientStatus fromDb(String v) => ClientStatus.values
      .firstWhere((s) => s.dbValue == v, orElse: () => ClientStatus.prospect);

  Color get color => switch (this) {
        ClientStatus.prospect => AppColors.primary,
        ClientStatus.active => AppColors.success,
        ClientStatus.paused => AppColors.warning,
        ClientStatus.churned => AppColors.error,
      };

  Color get dimColor => switch (this) {
        ClientStatus.prospect => AppColors.primaryDim,
        ClientStatus.active => AppColors.successDim,
        ClientStatus.paused => const Color(0xFF7C2D12),
        ClientStatus.churned => const Color(0xFF450A0A),
      };
}

enum PaymentState {
  pending('pending', '🕐', 'Pending'),
  paid('paid', '💰', 'Paid'),
  overdue('overdue', '🔴', 'Overdue'),
  partial('partial', '⚡', 'Partial');

  const PaymentState(this.dbValue, this.emoji, this.label);

  final String dbValue;
  final String emoji;
  final String label;

  static PaymentState fromDb(String v) => PaymentState.values
      .firstWhere((p) => p.dbValue == v, orElse: () => PaymentState.pending);

  Color get color => switch (this) {
        PaymentState.pending => AppColors.primary,
        PaymentState.paid => AppColors.success,
        PaymentState.overdue => AppColors.error,
        PaymentState.partial => AppColors.warning,
      };

  Color get dimColor => switch (this) {
        PaymentState.pending => AppColors.primaryDim,
        PaymentState.paid => AppColors.successDim,
        PaymentState.overdue => const Color(0xFF450A0A),
        PaymentState.partial => const Color(0xFF7C2D12),
      };
}

class Client {
  final int? id;
  final String name;
  final ClientStatus status;
  final PaymentState paymentState;
  final List<String> deliverables;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Client({
    this.id,
    required this.name,
    required this.status,
    required this.paymentState,
    required this.deliverables,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasUrgentIssue =>
      paymentState == PaymentState.overdue || status == ClientStatus.churned;

  bool get isPending =>
      paymentState == PaymentState.pending ||
      paymentState == PaymentState.partial;

  int get pendingDeliverableCount =>
      deliverables.where((d) => d.trim().isNotEmpty).length;

  Client copyWith({
    int? id,
    String? name,
    ClientStatus? status,
    PaymentState? paymentState,
    List<String>? deliverables,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearNotes = false,
  }) =>
      Client(
        id: id ?? this.id,
        name: name ?? this.name,
        status: status ?? this.status,
        paymentState: paymentState ?? this.paymentState,
        deliverables: deliverables ?? this.deliverables,
        notes: clearNotes ? null : notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'status': status.dbValue,
        'payment_state': paymentState.dbValue,
        'deliverables':
            deliverables.where((d) => d.trim().isNotEmpty).join('\n'),
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Client.fromMap(Map<String, dynamic> map) {
    final raw = (map['deliverables'] as String?) ?? '';
    return Client(
      id: map['id'] as int?,
      name: map['name'] as String,
      status: ClientStatus.fromDb(map['status'] as String),
      paymentState: PaymentState.fromDb(map['payment_state'] as String),
      deliverables: raw.isEmpty
          ? []
          : raw.split('\n').where((s) => s.trim().isNotEmpty).toList(),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Client && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
