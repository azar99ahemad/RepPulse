import '../models/workout_session.dart';
import '../models/rep_log.dart';

abstract class WorkoutRepository {
  Future<void> saveSession(WorkoutSession session);
  Future<List<WorkoutSession>> getAllSessions();
  Future<WorkoutSession?> getSession(String id);
  Future<void> saveRepLog(RepLog log);
  Future<List<RepLog>> getRepLogsForSession(String sessionId);
  Future<void> deleteSession(String id);
}
