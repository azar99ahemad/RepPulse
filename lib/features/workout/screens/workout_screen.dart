import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/exercise_config.dart';
import '../../../data/models/pose_data.dart';
import '../providers/workout_provider.dart';
import '../widgets/rep_counter_hud.dart';
import '../widgets/skeleton_overlay.dart';
import 'workout_summary_screen.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  final ExerciseType exerciseType;

  const WorkoutScreen({super.key, required this.exerciseType});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  @override
  void dispose() {
    ref.read(workoutProvider.notifier).resetWorkout();
    super.dispose();
  }

  Future<bool> _confirmLeave() async {
    final isActive = ref.read(workoutProvider).isActive;
    if (!isActive) return true;

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Stop Workout?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Your current workout progress will be lost.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Going',
                style: TextStyle(color: Color(0xFF00E5FF))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Stop', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    return shouldLeave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final workoutState = ref.watch(workoutProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final canLeave = await _confirmLeave();
        if (canLeave && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            '${widget.exerciseType.emoji} ${widget.exerciseType.label}',
            style: const TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: Stack(
          children: [
            // Camera preview placeholder
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined,
                      color: Colors.white24, size: 64),
                  SizedBox(height: 12),
                  Text(
                    'Camera Preview',
                    style: TextStyle(color: Colors.white24, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '(Native camera integration required)',
                    style: TextStyle(color: Colors.white12, fontSize: 12),
                  ),
                ],
              ),
            ),
            // Skeleton overlay (RepaintBoundary for performance)
            RepaintBoundary(
              child: SkeletonOverlay(
                poseData: PoseData.empty(),
                previewSize: MediaQuery.of(context).size,
              ),
            ),
            // Bottom HUD
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RepCounterHud(
                    repCount: workoutState.repCount,
                    repState: workoutState.repState,
                    currentAngle: workoutState.currentAngle,
                    exerciseType: widget.exerciseType,
                  ),
                  // Start / Stop button
                  Container(
                    color: const Color(0xCC0A0A0A),
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: workoutState.isActive
                              ? Colors.redAccent
                              : const Color(0xFF00E5FF),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (workoutState.isActive) {
                            ref
                                .read(workoutProvider.notifier)
                                .stopWorkout();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WorkoutSummaryScreen(
                                  exerciseType: widget.exerciseType,
                                  totalReps: workoutState.repCount,
                                  durationSeconds:
                                      workoutState.elapsedSeconds,
                                ),
                              ),
                            );
                          } else {
                            ref
                                .read(workoutProvider.notifier)
                                .startWorkout(widget.exerciseType);
                          }
                        },
                        child: Text(
                          workoutState.isActive ? 'Stop Workout' : 'Start Workout',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
