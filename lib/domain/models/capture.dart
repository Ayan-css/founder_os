enum CaptureType {
  thought( 'thought',  '💭'),
  idea(    'idea',     '💡'),
  hook(    'hook',     '🎣'),
  business('business', '📈');

  const CaptureType(this.dbValue, this.emoji);

  final String dbValue;
  final String emoji;

  static CaptureType fromDb(String v) =>
      CaptureType.values.firstWhere((t) => t.dbValue == v,
          orElse: () => CaptureType.thought);

  String get label => switch (this) {
    CaptureType.thought  => 'Thought',
    CaptureType.idea     => 'Idea',
    CaptureType.hook     => 'Hook',
    CaptureType.business => 'Business',
  };
}

class Capture {
  final int?        id;
  final String      content;
  final CaptureType type;
  final DateTime    createdAt;

  const Capture({
    this.id,
    required this.content,
    required this.type,
    required this.createdAt,
  });

  Capture copyWith({
    int?         id,
    String?      content,
    CaptureType? type,
    DateTime?    createdAt,
  }) =>
      Capture(
        id:        id        ?? this.id,
        content:   content   ?? this.content,
        type:      type      ?? this.type,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'content':    content,
    'type':       type.dbValue,
    'created_at': createdAt.toIso8601String(),
  };

  factory Capture.fromMap(Map<String, dynamic> map) => Capture(
    id:        map['id'] as int?,
    content:   map['content'] as String,
    type:      CaptureType.fromDb(map['type'] as String),
    createdAt: DateTime.parse(map['created_at'] as String),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Capture && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
