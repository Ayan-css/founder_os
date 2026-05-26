import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum ContentStage {
  idea('idea', '💡', 'Idea', 'Idea'),
  scripting('scripting', '✍️', 'Scripting', 'Script'),
  editing('editing', '🎬', 'Editing', 'Editing'),
  posted('posted', '🚀', 'Posted', 'Posted');

  const ContentStage(this.dbValue, this.emoji, this.label, this.shortLabel);

  final String dbValue;
  final String emoji;
  final String label;
  final String shortLabel;

  static ContentStage fromDb(String v) => ContentStage.values
      .firstWhere((s) => s.dbValue == v, orElse: () => ContentStage.idea);

  ContentStage? get next => switch (this) {
        ContentStage.idea => ContentStage.scripting,
        ContentStage.scripting => ContentStage.editing,
        ContentStage.editing => ContentStage.posted,
        ContentStage.posted => null,
      };

  Color get color => switch (this) {
        ContentStage.idea => AppColors.primary,
        ContentStage.scripting => const Color(0xFF0EA5E9),
        ContentStage.editing => AppColors.warning,
        ContentStage.posted => AppColors.success,
      };

  Color get dimColor => switch (this) {
        ContentStage.idea => AppColors.primaryDim,
        ContentStage.scripting => const Color(0xFF0C4A6E),
        ContentStage.editing => const Color(0xFF7C2D12),
        ContentStage.posted => AppColors.successDim,
      };

  Color get glowColor => switch (this) {
        ContentStage.idea => AppColors.primaryGlow,
        ContentStage.scripting => const Color(0x200EA5E9),
        ContentStage.editing => const Color(0x20F97316),
        ContentStage.posted => AppColors.successGlow,
      };
}

class ContentItem {
  final int? id;
  final String title;
  final ContentStage stage;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ContentItem({
    this.id,
    required this.title,
    required this.stage,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  ContentItem copyWith({
    int? id,
    String? title,
    ContentStage? stage,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearNotes = false,
  }) =>
      ContentItem(
        id: id ?? this.id,
        title: title ?? this.title,
        stage: stage ?? this.stage,
        notes: clearNotes ? null : notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'stage': stage.dbValue,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory ContentItem.fromMap(Map<String, dynamic> map) => ContentItem(
        id: map['id'] as int?,
        title: map['title'] as String,
        stage: ContentStage.fromDb(map['stage'] as String),
        notes: map['notes'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
        updatedAt: DateTime.parse(map['updated_at'] as String),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ContentItem && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
