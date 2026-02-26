class WorkoutSession {
  final String id;
  final String exerciseType;
  final int totalReps;
  final int durationSeconds;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? notes;

  const WorkoutSession({
    required this.id,
    required this.exerciseType,
    required this.totalReps,
    required this.durationSeconds,
    required this.startedAt,
    this.endedAt,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'exerciseType': exerciseType,
        'totalReps': totalReps,
        'durationSeconds': durationSeconds,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt?.toIso8601String(),
        'notes': notes,
      };

  factory WorkoutSession.fromMap(Map<String, dynamic> map) => WorkoutSession(
        id: map['id'] as String,
        exerciseType: map['exerciseType'] as String,
        totalReps: map['totalReps'] as int,
        durationSeconds: map['durationSeconds'] as int,
        startedAt: DateTime.parse(map['startedAt'] as String),
        endedAt: map['endedAt'] != null
            ? DateTime.parse(map['endedAt'] as String)
            : null,
        notes: map['notes'] as String?,
      );
}
