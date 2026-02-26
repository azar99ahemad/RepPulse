class RepLog {
  final String id;
  final String sessionId;
  final int repNumber;
  final double jointAngleAtBottom;
  final double jointAngleAtTop;
  final int durationMs;
  final DateTime recordedAt;

  const RepLog({
    required this.id,
    required this.sessionId,
    required this.repNumber,
    required this.jointAngleAtBottom,
    required this.jointAngleAtTop,
    required this.durationMs,
    required this.recordedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'sessionId': sessionId,
        'repNumber': repNumber,
        'jointAngleAtBottom': jointAngleAtBottom,
        'jointAngleAtTop': jointAngleAtTop,
        'durationMs': durationMs,
        'recordedAt': recordedAt.toIso8601String(),
      };
}
