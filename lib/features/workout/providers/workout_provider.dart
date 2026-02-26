import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/angle_calculator.dart';
import '../../../core/exercise_config.dart';
import '../../../core/rep_counter.dart';
import '../../../data/models/pose_data.dart';
import '../../../data/models/workout_session.dart';
import '../../../data/repositories/workout_repository.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class WorkoutState {
  final int repCount;
  final RepState repState;
  final double currentAngle;
  final bool isActive;
  final int elapsedSeconds;
  final ExerciseType? exerciseType;

  const WorkoutState({
    this.repCount = 0,
    this.repState = RepState.idle,
    this.currentAngle = 180.0,
    this.isActive = false,
    this.elapsedSeconds = 0,
    this.exerciseType,
  });

  WorkoutState copyWith({
    int? repCount,
    RepState? repState,
    double? currentAngle,
    bool? isActive,
    int? elapsedSeconds,
    ExerciseType? exerciseType,
  }) =>
      WorkoutState(
        repCount: repCount ?? this.repCount,
        repState: repState ?? this.repState,
        currentAngle: currentAngle ?? this.currentAngle,
        isActive: isActive ?? this.isActive,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
        exerciseType: exerciseType ?? this.exerciseType,
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class WorkoutNotifier extends StateNotifier<WorkoutState> {
  final WorkoutRepository? _repository;
  RepCounter? _counter;
  ExerciseConfig? _config;
  Timer? _timer;
  DateTime? _startTime;
  String? _sessionId;

  static const _uuid = Uuid();

  WorkoutNotifier({WorkoutRepository? repository})
      : _repository = repository,
        super(const WorkoutState());

  void startWorkout(ExerciseType type) {
    _config = ExerciseConfig.all.firstWhere((c) => c.type == type);
    _counter = _config!.createCounter();
    _sessionId = _uuid.v4();
    _startTime = DateTime.now();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.isActive) {
        state = state.copyWith(
          elapsedSeconds: state.elapsedSeconds + 1,
        );
      }
    });

    state = WorkoutState(
      isActive: true,
      exerciseType: type,
      repCount: 0,
      repState: RepState.idle,
      currentAngle: 180.0,
      elapsedSeconds: 0,
    );
  }

  void stopWorkout() {
    _timer?.cancel();
    _timer = null;

    if (_repository != null && _sessionId != null && _startTime != null) {
      final session = WorkoutSession(
        id: _sessionId!,
        exerciseType: state.exerciseType?.name ?? 'unknown',
        totalReps: state.repCount,
        durationSeconds: state.elapsedSeconds,
        startedAt: _startTime!,
        endedAt: DateTime.now(),
      );
      // Fire-and-forget; errors are non-critical for the UI
      _repository!.saveSession(session);
    }

    state = state.copyWith(isActive: false);
  }

  /// Feed a new [PoseData] frame into the counter.
  /// Computes the relevant joint angle for the active exercise type.
  void processPoseData(PoseData pose) {
    if (!state.isActive || _counter == null || _config == null) return;

    final angle = _computeAngle(pose, _config!.type);
    final result = _counter!.processAngle(angle);

    state = state.copyWith(
      repCount: result.count,
      repState: result.state,
      currentAngle: result.angle,
    );
  }

  /// Compute the joint angle relevant to the given [exerciseType] using
  /// the left-side landmarks (preferred; fall back to right side if needed).
  double _computeAngle(PoseData pose, ExerciseType type) {
    switch (type) {
      case ExerciseType.squat:
        // Hip → Knee → Ankle
        final hip = pose.landmark(PoseLandmarkIndex.leftHip);
        final knee = pose.landmark(PoseLandmarkIndex.leftKnee);
        final ankle = pose.landmark(PoseLandmarkIndex.leftAnkle);
        if (hip != null && knee != null && ankle != null) {
          return AngleCalculator.calculateAngle(hip, knee, ankle);
        }
        break;
      case ExerciseType.pushUp:
        // Shoulder → Elbow → Wrist
        final shoulder = pose.landmark(PoseLandmarkIndex.leftShoulder);
        final elbow = pose.landmark(PoseLandmarkIndex.leftElbow);
        final wrist = pose.landmark(PoseLandmarkIndex.leftWrist);
        if (shoulder != null && elbow != null && wrist != null) {
          return AngleCalculator.calculateAngle(shoulder, elbow, wrist);
        }
        break;
      case ExerciseType.pullUp:
        // Shoulder → Elbow → Wrist (inverted phase handled by RepCounter)
        final shoulder = pose.landmark(PoseLandmarkIndex.leftShoulder);
        final elbow = pose.landmark(PoseLandmarkIndex.leftElbow);
        final wrist = pose.landmark(PoseLandmarkIndex.leftWrist);
        if (shoulder != null && elbow != null && wrist != null) {
          return AngleCalculator.calculateAngle(shoulder, elbow, wrist);
        }
        break;
    }
    return state.currentAngle; // keep last known angle if landmarks missing
  }

  void resetWorkout() {
    _timer?.cancel();
    _timer = null;
    _counter?.reset();
    state = const WorkoutState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final workoutProvider =
    StateNotifierProvider<WorkoutNotifier, WorkoutState>((ref) {
  return WorkoutNotifier();
});
