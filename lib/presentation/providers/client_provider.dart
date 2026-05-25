import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/client_repository.dart';
import '../../domain/models/client.dart';

final clientRepositoryProvider =
    Provider<ClientRepository>((_) => ClientRepository());

final clientStatusFilterProvider = StateProvider<ClientStatus?>((ref) => null);

class ClientNotifier extends StateNotifier<AsyncValue<List<Client>>> {
  ClientNotifier(this._repo) : super(const AsyncValue.loading()) {
    load();
  }

  final ClientRepository _repo;

  Future<void> load() async {
    try {
      final clients = await _repo.getAll();
      state = AsyncValue.data(clients);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add({
    required String       name,
    required ClientStatus status,
    required PaymentState paymentState,
    List<String>          deliverables = const [],
    String?               notes,
  }) async {
    if (name.trim().isEmpty) return;
    try {
      final now    = DateTime.now();
      final client = Client(
        name:         name.trim(),
        status:       status,
        paymentState: paymentState,
        deliverables: deliverables,
        notes:        notes?.trim().isEmpty == true ? null : notes?.trim(),
        createdAt:    now,
        updatedAt:    now,
      );
      final created = await _repo.insert(client);
      _prepend(created);
    } catch (_) {}
  }

  Future<void> updateClient(Client client) async {
    try {
      final updated = client.copyWith(updatedAt: DateTime.now());
      await _repo.update(updated);
      _replace(updated);
    } catch (_) {}
  }

  Future<void> delete(Client client) async {
    if (client.id == null) return;
    try {
      await _repo.delete(client.id!);
      _remove(client);
    } catch (_) {}
  }

  void _prepend(Client c) => state.whenData(
      (list) => state = AsyncValue.data([c, ...list]));

  void _replace(Client c) => state.whenData((list) =>
      state = AsyncValue.data(
          list.map((x) => x.id == c.id ? c : x).toList()));

  void _remove(Client c) => state.whenData((list) =>
      state = AsyncValue.data(
          list.where((x) => x.id != c.id).toList()));
}

final clientsProvider =
    StateNotifierProvider<ClientNotifier, AsyncValue<List<Client>>>(
  (ref) => ClientNotifier(ref.watch(clientRepositoryProvider)),
);

final filteredClientsProvider = Provider<List<Client>>((ref) {
  final filter = ref.watch(clientStatusFilterProvider);
  return ref.watch(clientsProvider).whenOrNull(
        data: (clients) => filter == null
            ? clients
            : clients.where((c) => c.status == filter).toList(),
      ) ??
      [];
});

final clientSummaryProvider = FutureProvider<Map<String, int>>((ref) {
  ref.watch(clientsProvider);
  return ref.watch(clientRepositoryProvider).getSummaryCounts();
});

final activeClientCountProvider = Provider<int>((ref) {
  return ref.watch(clientsProvider).whenOrNull(
        data: (clients) =>
            clients.where((c) => c.status == ClientStatus.active).length,
      ) ??
      0;
});
