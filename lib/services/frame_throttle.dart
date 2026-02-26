class FrameThrottle {
  static const int _targetFps = 20;
  static const int _frameIntervalMs = 1000 ~/ _targetFps;
  int _lastProcessedMs = 0;

  bool shouldProcess() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastProcessedMs >= _frameIntervalMs) {
      _lastProcessedMs = now;
      return true;
    }
    return false;
  }

  void reset() {
    _lastProcessedMs = 0;
  }
}
