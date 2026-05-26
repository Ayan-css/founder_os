class Reflection {
  final int? id;
  final String date;
  final String? distraction;
  final String? forward;
  final String? improvement;
  final DateTime createdAt;

  const Reflection({
    this.id,
    required this.date,
    this.distraction,
    this.forward,
    this.improvement,
    required this.createdAt,
  });

  bool get isEmpty =>
      (distraction == null || distraction!.isEmpty) &&
      (forward == null || forward!.isEmpty) &&
      (improvement == null || improvement!.isEmpty);

  int get answeredCount => [distraction, forward, improvement]
      .where((s) => s != null && s!.isNotEmpty)
      .length;

  Reflection copyWith({
    int? id,
    String? date,
    String? distraction,
    String? forward,
    String? improvement,
    DateTime? createdAt,
    bool clearDistraction = false,
    bool clearForward = false,
    bool clearImprovement = false,
  }) =>
      Reflection(
        id: id ?? this.id,
        date: date ?? this.date,
        distraction: clearDistraction ? null : distraction ?? this.distraction,
        forward: clearForward ? null : forward ?? this.forward,
        improvement: clearImprovement ? null : improvement ?? this.improvement,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'date': date,
        'distraction': distraction,
        'forward': forward,
        'improvement': improvement,
        'created_at': createdAt.toIso8601String(),
      };

  factory Reflection.fromMap(Map<String, dynamic> map) => Reflection(
        id: map['id'] as int?,
        date: map['date'] as String,
        distraction: map['distraction'] as String?,
        forward: map['forward'] as String?,
        improvement: map['improvement'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}
