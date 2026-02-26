import 'dart:math';
import '../data/models/pose_data.dart';

class AngleCalculator {
  /// Returns the angle in degrees at point [b], formed by vectors BA and BC.
  /// [a] = first joint (e.g., hip), [b] = vertex joint (e.g., knee), [c] = third joint (e.g., ankle)
  static double calculateAngle(Landmark a, Landmark b, Landmark c) {
    final double bax = a.x - b.x;
    final double bay = a.y - b.y;
    final double bcx = c.x - b.x;
    final double bcy = c.y - b.y;

    final double dot = (bax * bcx) + (bay * bcy);
    final double magBA = sqrt(bax * bax + bay * bay);
    final double magBC = sqrt(bcx * bcx + bcy * bcy);

    if (magBA == 0 || magBC == 0) return 0;

    final double cosAngle = (dot / (magBA * magBC)).clamp(-1.0, 1.0);
    return acos(cosAngle) * 180 / pi;
  }

  /// Exponential moving average to smooth jittery angle readings.
  /// [alpha] controls smoothing: lower = smoother but more lag.
  static double smoothAngle(double newAngle, double prevAngle,
      {double alpha = 0.4}) {
    return alpha * newAngle + (1 - alpha) * prevAngle;
  }
}
