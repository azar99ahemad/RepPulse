// Rep-counting state machine:
// idle  → down  : angle crosses the "down" threshold (joint sufficiently bent)
// down  → up    : angle crosses the "up" threshold (joint sufficiently extended)
// up    → idle  : one rep is counted (with cooldown to prevent double-counting)
enum RepState { idle, down, up }

class RepResult {
  final int count;
  final RepState state;
  final double angle;

  const RepResult({
    required this.count,
    required this.state,
    this.angle = 0.0,
  });
}

class RepCounter {
  RepState _state = RepState.idle;
  int _repCount = 0;
  double _smoothedAngle = 180.0;

  static const int _cooldownMs = 500;
  DateTime? _lastRepTime;

  final double downThreshold;
  final double upThreshold;

  /// When [invertedPhase] is true (e.g., pull-ups), the angle is large at the
  /// bottom (arms extended) and small at the top (arms bent).
  final bool invertedPhase;

  RepCounter({
    required this.downThreshold,
    required this.upThreshold,
    this.invertedPhase = false,
  });

  int get repCount => _repCount;
  RepState get state => _state;
  double get smoothedAngle => _smoothedAngle;

  RepResult processAngle(double rawAngle, {double visibility = 1.0}) {
    // Skip processing if landmarks are not sufficiently visible
    if (visibility < 0.6) {
      return RepResult(count: _repCount, state: _state, angle: _smoothedAngle);
    }

    // Smooth the incoming angle with an EMA filter to reduce noise
    _smoothedAngle = _smoothedAngle * 0.6 + rawAngle * 0.4;

    if (!invertedPhase) {
      // Normal phase: idle → down (angle decreases) → up (angle increases)
      switch (_state) {
        case RepState.idle:
          if (_smoothedAngle < downThreshold) _state = RepState.down;
          break;
        case RepState.down:
          if (_smoothedAngle > upThreshold) _state = RepState.up;
          break;
        case RepState.up:
          _tryCountRep();
          break;
      }
    } else {
      // Inverted phase (pull-up): idle → down (arms extended) → up (arms bent)
      switch (_state) {
        case RepState.idle:
          if (_smoothedAngle > downThreshold) _state = RepState.down;
          break;
        case RepState.down:
          if (_smoothedAngle < upThreshold) _state = RepState.up;
          break;
        case RepState.up:
          _tryCountRep();
          break;
      }
    }

    return RepResult(count: _repCount, state: _state, angle: _smoothedAngle);
  }

  void _tryCountRep() {
    final now = DateTime.now();
    if (_lastRepTime == null ||
        now.difference(_lastRepTime!).inMilliseconds > _cooldownMs) {
      _repCount++;
      _lastRepTime = now;
      _state = RepState.idle;
    }
  }

  void reset() {
    _state = RepState.idle;
    _repCount = 0;
    _smoothedAngle = 180.0;
    _lastRepTime = null;
  }
}
