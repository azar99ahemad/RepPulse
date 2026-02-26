import 'package:flutter/services.dart';
import '../data/models/pose_data.dart';

class PoseService {
  static const EventChannel _channel =
      EventChannel('com.reppulse.app/pose_stream');
  static const MethodChannel _methodChannel =
      MethodChannel('com.reppulse.app/pose_control');

  Stream<PoseData> get poseStream => _channel
      .receiveBroadcastStream()
      .where((data) => data != null)
      .map((data) =>
          PoseData.fromMap(Map<String, dynamic>.from(data as Map)))
      .where((pose) => !pose.isEmpty);

  Future<void> startCamera() async {
    await _methodChannel.invokeMethod('startCamera');
  }

  Future<void> stopCamera() async {
    await _methodChannel.invokeMethod('stopCamera');
  }

  Future<void> flipCamera() async {
    await _methodChannel.invokeMethod('flipCamera');
  }
}
