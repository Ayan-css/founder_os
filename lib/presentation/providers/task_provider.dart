import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/app_date_utils.dart';
import '../../data/repositories/task_repository.dart';
import '../../domain/models/task.dart';

final taskRepositoryProvider =
    Provider<TaskRepository>((_) => TaskRepository());

class TodayTasksNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final TaskRepository _repo;

  TodayTasksNotifier(this._repo) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final tasks = await _repo.getTasksForDate(AppDateUtils.todayDbDate());
      state = AsyncValue.data(tasks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addTask(String title, int position) async {
    if (title.trim().isEmpty) return;
    try {
      final task = Task(
        title: title.trim(),
        date: AppDateUtils.todayDbDate(),
        position: position,
        createdAt: DateTime.now(),
      );
      final created = await _repo.insertTask(task);
      _mutate((tasks) {
        final updated = [...tasks]..removeWhere((t) => t.position == position);
        return (updated..add(created))
          ..sort((a, b) => a.position.compareTo(b.position));
      });
    } catch (_) {}
  }

  Future<void> toggleTask(Task task) async {
    try {
      final updated = await _repo.toggleCompletion(task);
      _mutate(
          (tasks) => tasks.map((t) => t.id == task.id ? updated : t).toList());
    } catch (_) {}
  }

  Future<void> updateTitle(Task task, String newTitle) async {
    if (newTitle.trim().isEmpty) return;
    try {
      final updated = task.copyWith(title: newTitle.trim());
      await _repo.updateTask(updated);
      _mutate(
          (tasks) => tasks.map((t) => t.id == task.id ? updated : t).toList());
    } catch (_) {}
  }

  Future<void> deleteTask(Task task) async {
    if (task.id == null) return;
    try {
      await _repo.deleteTask(task.id!);
      _mutate((tasks) => tasks.where((t) => t.id != task.id).toList());
    } catch (_) {}
  }

  void _mutate(List<Task> Function(List<Task>) fn) {
    state.whenData((tasks) => state = AsyncValue.data(fn(tasks)));
  }
}

final todayTasksProvider =
    StateNotifierProvider<TodayTasksNotifier, AsyncValue<List<Task>>>(
  (ref) => TodayTasksNotifier(ref.watch(taskRepositoryProvider)),
);

final completedCountProvider = Provider<int>((ref) =>
    ref.watch(todayTasksProvider).whenOrNull(
          data: (t) => t.where((x) => x.isCompleted).length,
        ) ??
    0);

final totalCountProvider = Provider<int>((ref) =>
    ref.watch(todayTasksProvider).whenOrNull(data: (t) => t.length) ?? 0);

final taskProgressProvider = Provider<double>((ref) {
  final done = ref.watch(completedCountProvider);
  final total = ref.watch(totalCountProvider);
  return total == 0 ? 0.0 : done / total;
});

final allTasksDoneProvider = Provider<bool>((ref) {
  final done = ref.watch(completedCountProvider);
  final total = ref.watch(totalCountProvider);
  return total > 0 && done == total;
});
