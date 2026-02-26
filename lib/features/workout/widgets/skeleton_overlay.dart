import 'package:flutter/material.dart';
import '../../../data/models/pose_data.dart';

class SkeletonOverlay extends StatelessWidget {
  final PoseData poseData;
  final Size previewSize;

  const SkeletonOverlay({
    super.key,
    required this.poseData,
    required this.previewSize,
  });

  @override
  Widget build(BuildContext context) {
    if (poseData.isEmpty) return const SizedBox.shrink();
    return RepaintBoundary(
      child: CustomPaint(
        painter: _SkeletonPainter(poseData: poseData, previewSize: previewSize),
        size: Size.infinite,
      ),
    );
  }
}

class _SkeletonPainter extends CustomPainter {
  final PoseData poseData;
  final Size previewSize;

  _SkeletonPainter({required this.poseData, required this.previewSize});

  /// Bone connections defined as pairs of MediaPipe landmark indices
  static const _connections = [
    [11, 12], [11, 13], [13, 15], // left arm
    [12, 14], [14, 16], // right arm
    [11, 23], [12, 24], // torso
    [23, 24], [23, 25], [25, 27], // left leg
    [24, 26], [26, 28], // right leg
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..strokeWidth = 1;

    Offset toLandmarkOffset(Landmark lm) => Offset(
          lm.x * size.width,
          lm.y * size.height,
        );

    // Draw bone connections
    for (final conn in _connections) {
      final a = poseData.landmark(conn[0]);
      final b = poseData.landmark(conn[1]);
      if (a != null && b != null && a.isVisible && b.isVisible) {
        canvas.drawLine(toLandmarkOffset(a), toLandmarkOffset(b), linePaint);
      }
    }

    // Draw landmark dots
    for (final lm in poseData.landmarks) {
      if (lm.isVisible) {
        canvas.drawCircle(toLandmarkOffset(lm), 4, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_SkeletonPainter old) => old.poseData != poseData;
}
