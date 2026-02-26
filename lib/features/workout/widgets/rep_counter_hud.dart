import 'package:flutter/material.dart';
import '../../../core/rep_counter.dart';
import '../../../core/exercise_config.dart';

class RepCounterHud extends StatelessWidget {
  final int repCount;
  final RepState repState;
  final double currentAngle;
  final ExerciseType exerciseType;

  const RepCounterHud({
    super.key,
    required this.repCount,
    required this.repState,
    required this.currentAngle,
    required this.exerciseType,
  });

  Color _stateColor() {
    switch (repState) {
      case RepState.idle:
        return Colors.grey;
      case RepState.down:
        return Colors.orangeAccent;
      case RepState.up:
        return Colors.greenAccent;
    }
  }

  String _stateLabel() {
    switch (repState) {
      case RepState.idle:
        return 'READY';
      case RepState.down:
        return 'DOWN ↓';
      case RepState.up:
        return 'UP ↑';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xCC0A0A0A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Rep count
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$repCount',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00E5FF),
                ),
              ),
              const Text('REPS', style: TextStyle(color: Colors.white54)),
            ],
          ),
          // State badge + angle
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _stateColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _stateColor()),
                ),
                child: Text(
                  _stateLabel(),
                  style: TextStyle(
                    color: _stateColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${currentAngle.toStringAsFixed(1)}°',
                style:
                    const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
          // Exercise type
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                exerciseType.emoji,
                style: const TextStyle(fontSize: 28),
              ),
              Text(
                exerciseType.label,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
