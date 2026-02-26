import 'rep_counter.dart';

enum ExerciseType { squat, pushUp, pullUp }

extension ExerciseTypeLabel on ExerciseType {
  String get label {
    switch (this) {
      case ExerciseType.squat:
        return 'Squat';
      case ExerciseType.pushUp:
        return 'Push-Up';
      case ExerciseType.pullUp:
        return 'Pull-Up';
    }
  }

  String get emoji {
    switch (this) {
      case ExerciseType.squat:
        return '🏋️';
      case ExerciseType.pushUp:
        return '💪';
      case ExerciseType.pullUp:
        return '🔝';
    }
  }
}

class ExerciseConfig {
  final ExerciseType type;
  final double downThreshold;
  final double upThreshold;
  final bool invertedPhase;
  final String description;

  const ExerciseConfig({
    required this.type,
    required this.downThreshold,
    required this.upThreshold,
    this.invertedPhase = false,
    required this.description,
  });

  static const squat = ExerciseConfig(
    type: ExerciseType.squat,
    downThreshold: 90,
    upThreshold: 160,
    description: 'Hip → Knee → Ankle angle. Down < 90°, Up > 160°.',
  );

  static const pushUp = ExerciseConfig(
    type: ExerciseType.pushUp,
    downThreshold: 90,
    upThreshold: 150,
    description: 'Shoulder → Elbow → Wrist angle. Down < 90°, Up > 150°.',
  );

  static const pullUp = ExerciseConfig(
    type: ExerciseType.pullUp,
    downThreshold: 150,
    upThreshold: 90,
    invertedPhase: true,
    description:
        'Shoulder → Elbow → Wrist angle (inverted). Hang > 150°, Top < 90°.',
  );

  static List<ExerciseConfig> get all => [squat, pushUp, pullUp];

  RepCounter createCounter() => RepCounter(
        downThreshold: downThreshold,
        upThreshold: upThreshold,
        invertedPhase: invertedPhase,
      );
}
