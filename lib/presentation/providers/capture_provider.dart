import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/capture_repository.dart';
import '../../domain/models/capture.dart';

final captureRepositoryProvider =
    Provider<CaptureRepository>((_) => CaptureRepository());

final captureFilterProvider = StateProvider<CaptureType?>((ref) => null);

class CapturesNotifier extends StateNotifier<AsyncValue<List<Capture>>> {
  CapturesNotifier(this._repo) : super(const AsyncValue.loading()) {
    load();
  }

  final CaptureRepository _repo;
  CaptureType? _currentFilter;

  Future<void> load({CaptureType? filterType}) async {
    _currentFilter = filterType;
    try {
      final items = await _repo.getAll(filterType: filterType);
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(String content, CaptureType type) async {
    if (content.trim().isEmpty) return;
    try {
      final capture = Capture(
        content:   content.trim(),
        type:      type,
        createdAt: DateTime.now(),
      );
      final created = await _repo.insert(capture);
      if (_currentFilter == null || _currentFilter == type) {
        state.whenData((list) =>
            state = AsyncValue.data([created, ...list]));
      }
    } catch (_) {}
  }

  Future<void> delete(Capture capture) async {
    if (capture.id == null) return;
    try {
      await _repo.delete(capture.id!);
      state.whenData((list) => state = AsyncValue.data(
          list.where((c) => c.id != capture.id).toList()));
    } catch (_) {}
  }
}

final capturesProvider =
    StateNotifierProvider<CapturesNotifier, AsyncValue<List<Capture>>>(
  (ref) => CapturesNotifier(ref.watch(captureRepositoryProvider)),
);

final todayCaptureCountProvider = FutureProvider<int>((ref) {
  ref.watch(capturesProvider);
  return ref.watch(captureRepositoryProvider).getTodayCount();
});
