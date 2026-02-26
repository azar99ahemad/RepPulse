import 'package:flutter/material.dart';
import '../../../core/exercise_config.dart';
import 'workout_screen.dart';

class ExerciseSelectScreen extends StatelessWidget {
  const ExerciseSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        title: const Text(
          'Select Exercise',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: ExerciseConfig.all.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final config = ExerciseConfig.all[index];
          return _ExerciseSelectionCard(config: config);
        },
      ),
    );
  }
}

class _ExerciseSelectionCard extends StatelessWidget {
  final ExerciseConfig config;

  const _ExerciseSelectionCard({required this.config});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WorkoutScreen(exerciseType: config.type),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF00E5FF33)),
        ),
        child: Row(
          children: [
            Text(config.type.emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.type.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    config.description,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _ThresholdChip(
                          label:
                              'Down: ${config.downThreshold.toInt()}°'),
                      const SizedBox(width: 8),
                      _ThresholdChip(
                          label: 'Up: ${config.upThreshold.toInt()}°'),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Color(0xFF00E5FF), size: 16),
          ],
        ),
      ),
    );
  }
}

class _ThresholdChip extends StatelessWidget {
  final String label;

  const _ThresholdChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF00E5FF1A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF00E5FF4D)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 11),
      ),
    );
  }
}
