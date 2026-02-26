class Landmark {
  final double x;
  final double y;
  final double z;
  final double visibility;

  const Landmark({
    required this.x,
    required this.y,
    required this.z,
    required this.visibility,
  });

  factory Landmark.fromMap(Map<String, dynamic> map) => Landmark(
        x: (map['x'] as num).toDouble(),
        y: (map['y'] as num).toDouble(),
        z: (map['z'] as num).toDouble(),
        visibility: (map['visibility'] as num).toDouble(),
      );

  bool get isVisible => visibility >= 0.6;
}

/// MediaPipe Pose landmark indices (BlazePose 33-point model)
class PoseLandmarkIndex {
  static const int leftShoulder = 11;
  static const int rightShoulder = 12;
  static const int leftElbow = 13;
  static const int rightElbow = 14;
  static const int leftWrist = 15;
  static const int rightWrist = 16;
  static const int leftHip = 23;
  static const int rightHip = 24;
  static const int leftKnee = 25;
  static const int rightKnee = 26;
  static const int leftAnkle = 27;
  static const int rightAnkle = 28;
}

class PoseData {
  final List<Landmark> landmarks;
  final int timestampMs;

  const PoseData({required this.landmarks, required this.timestampMs});

  factory PoseData.empty() => const PoseData(landmarks: [], timestampMs: 0);

  bool get isEmpty => landmarks.isEmpty;

  Landmark? landmark(int index) {
    if (index < 0 || index >= landmarks.length) return null;
    return landmarks[index];
  }

  factory PoseData.fromMap(Map<String, dynamic> map) {
    final rawLandmarks = map['landmarks'] as List<dynamic>;
    return PoseData(
      landmarks: rawLandmarks
          .map((l) => Landmark.fromMap(Map<String, dynamic>.from(l as Map)))
          .toList(),
      timestampMs: (map['timestampMs'] as num).toInt(),
    );
  }
}
