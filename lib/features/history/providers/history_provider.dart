import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/workout_session.dart';
import '../../../data/repositories/workout_repository.dart';

/// Provider that exposes all past workout sessions as [AsyncValue].
/// Call [refresh] to reload from the repository.
final historyProvider =
    StateNotifierProvider<HistoryNotifier, AsyncValue<List<WorkoutSession>>>(
  (ref) => HistoryNotifier(),
);

class HistoryNotifier
    extends StateNotifier<AsyncValue<List<WorkoutSession>>> {
  final WorkoutRepository? _repository;

  HistoryNotifier({WorkoutRepository? repository})
      : _repository = repository,
        super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    if (_repository == null) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository!.getAllSessions());
  }

  Future<void> refresh() => _load();
}
