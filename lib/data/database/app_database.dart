import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

// Generated code lives in app_database.g.dart.
// Run: dart run build_runner build --delete-conflicting-outputs
part 'app_database.g.dart';

// ─── Tables ──────────────────────────────────────────────────────────────────

class WorkoutSessionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get exerciseType => text()();
  IntColumn get totalReps => integer()();
  IntColumn get durationSeconds => integer()();
  TextColumn get startedAt => text()();
  TextColumn get endedAt => text().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class RepLogsTable extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId =>
      text().references(WorkoutSessionsTable, #id)();
  IntColumn get repNumber => integer()();
  RealColumn get jointAngleAtBottom => real()();
  RealColumn get jointAngleAtTop => real()();
  IntColumn get durationMs => integer()();
  TextColumn get recordedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class ExerciseConfigsTable extends Table {
  TextColumn get exerciseType => text()();
  RealColumn get downThreshold => real()();
  RealColumn get upThreshold => real()();
  BoolColumn get invertedPhase => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {exerciseType};
}

// ─── Database ─────────────────────────────────────────────────────────────────

@DriftDatabase(
  tables: [WorkoutSessionsTable, RepLogsTable, ExerciseConfigsTable],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ── WorkoutSession DAOs ──────────────────────────────────────────────────

  Future<void> insertWorkoutSession(WorkoutSessionsTableCompanion entry) =>
      into(workoutSessionsTable).insert(entry);

  Future<List<WorkoutSessionsTableData>> getAllWorkoutSessions() =>
      select(workoutSessionsTable).get();

  Future<WorkoutSessionsTableData?> getWorkoutSessionById(String id) =>
      (select(workoutSessionsTable)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<int> deleteWorkoutSession(String id) =>
      (delete(workoutSessionsTable)..where((t) => t.id.equals(id))).go();

  // ── RepLog DAOs ──────────────────────────────────────────────────────────

  Future<void> insertRepLog(RepLogsTableCompanion entry) =>
      into(repLogsTable).insert(entry);

  Future<List<RepLogsTableData>> getRepLogsForSession(String sessionId) =>
      (select(repLogsTable)
            ..where((t) => t.sessionId.equals(sessionId))
            ..orderBy([(t) => OrderingTerm.asc(t.repNumber)]))
          .get();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'reppulse.db'));
    return NativeDatabase.createInBackground(file);
  });
}
