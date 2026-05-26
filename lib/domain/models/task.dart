class Task {
  final int? id;
  final String title;
  final bool isCompleted;
  final String date;
  final int position;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Task({
    this.id,
    required this.title,
    this.isCompleted = false,
    required this.date,
    required this.position,
    required this.createdAt,
    this.completedAt,
  });

  Task copyWith({
    int? id,
    String? title,
    bool? isCompleted,
    String? date,
    int? position,
    DateTime? createdAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'is_completed': isCompleted ? 1 : 0,
        'date': date,
        'position': position,
        'created_at': createdAt.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
      };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
        id: map['id'] as int?,
        title: map['title'] as String,
        isCompleted: (map['is_completed'] as int) == 1,
        date: map['date'] as String,
        position: map['position'] as int,
        createdAt: DateTime.parse(map['created_at'] as String),
        completedAt: map['completed_at'] != null
            ? DateTime.parse(map['completed_at'] as String)
            : null,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Task && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
