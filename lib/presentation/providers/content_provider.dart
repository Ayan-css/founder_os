import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/content_repository.dart';
import '../../domain/models/content_item.dart';

final contentRepositoryProvider =
    Provider<ContentRepository>((_) => ContentRepository());

class ContentNotifier extends StateNotifier<AsyncValue<List<ContentItem>>> {
  ContentNotifier(this._repo) : super(const AsyncValue.loading()) {
    load();
  }

  final ContentRepository _repo;

  Future<void> load() async {
    try {
      final items = await _repo.getAll();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add({
    required String title,
    required ContentStage stage,
    String? notes,
  }) async {
    if (title.trim().isEmpty) return;
    try {
      final now  = DateTime.now();
      final item = ContentItem(
        title:     title.trim(),
        stage:     stage,
        notes:     notes?.trim().isEmpty == true ? null : notes?.trim(),
        createdAt: now,
        updatedAt: now,
      );
      final created = await _repo.insert(item);
      _prepend(created);
    } catch (_) {}
  }

  Future<void> updateItem(ContentItem item) async {
    try {
      final updated = item.copyWith(updatedAt: DateTime.now());
      await _repo.update(updated);
      _replace(updated);
    } catch (_) {}
  }

  Future<void> moveToNextStage(ContentItem item) async {
    final next = item.stage.next;
    if (next == null) return;
    try {
      final updated = await _repo.moveToStage(item, next);
      _replace(updated);
    } catch (_) {}
  }

  Future<void> moveToStage(ContentItem item, ContentStage stage) async {
    if (item.stage == stage) return;
    try {
      final updated = await _repo.moveToStage(item, stage);
      _replace(updated);
    } catch (_) {}
  }

  Future<void> delete(ContentItem item) async {
    if (item.id == null) return;
    try {
      await _repo.delete(item.id!);
      _remove(item);
    } catch (_) {}
  }

  void _prepend(ContentItem item) => state.whenData(
      (list) => state = AsyncValue.data([item, ...list]));

  void _replace(ContentItem item) => state.whenData((list) =>
      state = AsyncValue.data(
          list.map((i) => i.id == item.id ? item : i).toList()));

  void _remove(ContentItem item) => state.whenData((list) =>
      state = AsyncValue.data(
          list.where((i) => i.id != item.id).toList()));
}

final contentProvider =
    StateNotifierProvider<ContentNotifier, AsyncValue<List<ContentItem>>>(
  (ref) => ContentNotifier(ref.watch(contentRepositoryProvider)),
);

final contentByStageProvider =
    Provider.family<List<ContentItem>, ContentStage>((ref, stage) {
  return ref.watch(contentProvider).whenOrNull(
        data: (items) => items.where((i) => i.stage == stage).toList(),
      ) ??
      [];
});

final stageCountsProvider = Provider<Map<ContentStage, int>>((ref) {
  final items =
      ref.watch(contentProvider).whenOrNull(data: (i) => i) ?? [];
  return {
    for (final s in ContentStage.values)
      s: items.where((i) => i.stage == s).length,
  };
});

final activePipelineCountProvider = Provider<int>((ref) {
  return ref.watch(contentProvider).whenOrNull(
        data: (items) =>
            items.where((i) => i.stage != ContentStage.posted).length,
      ) ??
      0;
});
