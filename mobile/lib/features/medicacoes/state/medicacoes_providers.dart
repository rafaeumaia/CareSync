import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/local_notification_gateway.dart';
import '../data/medicacao_reminder_scheduler.dart';
import '../data/medicacao_repository.dart';
import '../domain/medicacao.dart';

/// Repositório de medicações. Trocar pela implementação HTTP quando a API
/// Django existir.
final medicacaoRepositoryProvider = Provider<MedicacaoRepository>(
  (ref) => InMemoryMedicacaoRepository(),
);

/// Lembretes locais das medicações.
final medicacaoReminderSchedulerProvider = Provider<MedicacaoReminderScheduler>(
  (ref) =>
      MedicacaoReminderScheduler(ref.watch(localNotificationGatewayProvider)),
);

/// Lista de medicações, na ordem de cadastro (o protótipo não ordena).
final medicacoesProvider =
    AsyncNotifierProvider<MedicacoesNotifier, List<Medicacao>>(
      MedicacoesNotifier.new,
    );

class MedicacoesNotifier extends AsyncNotifier<List<Medicacao>> {
  MedicacaoRepository get _repository => ref.read(medicacaoRepositoryProvider);
  MedicacaoReminderScheduler get _reminders =>
      ref.read(medicacaoReminderSchedulerProvider);

  /// Medicações com uma alteração de "tomado" em andamento: toques repetidos
  /// não geram alterações duplicadas.
  final _updating = <int>{};

  @override
  Future<List<Medicacao>> build() async {
    final medicacoes = await ref.watch(medicacaoRepositoryProvider).fetchAll();
    // Os lembretes do aparelho passam a refletir a lista carregada.
    unawaited(ref.read(medicacaoReminderSchedulerProvider).sync(medicacoes));
    return medicacoes;
  }

  List<Medicacao> get _items => state.value ?? const [];

  Future<void> add(MedicacaoDraft draft) async {
    final medicacao = await _repository.add(draft);
    state = AsyncData([..._items, medicacao]);
    await _reminders.schedule(medicacao);
  }

  /// Marca ([taken] `true`) ou desmarca a medicação como tomada.
  ///
  /// Retorna `true` se o estado mudou; `false` se já estava assim, se a
  /// medicação não existe ou se outra alteração dela está em andamento.
  Future<bool> setTaken(int id, {required bool taken}) async {
    final current = _find(id);
    if (current == null || current.taken == taken || !_updating.add(id)) {
      return false;
    }
    try {
      final updated = await _repository.setTaken(id, taken: taken);
      state = AsyncData([for (final m in _items) m.id == id ? updated : m]);
      return true;
    } finally {
      _updating.remove(id);
    }
  }

  /// Exclui a medicação e cancela o lembrete dela. Retorna a medicação
  /// excluída, ou `null` se ela não existia.
  Future<Medicacao?> delete(int id) async {
    final current = _find(id);
    if (current == null) return null;
    await _repository.delete(id);
    state = AsyncData([
      for (final m in _items)
        if (m.id != id) m,
    ]);
    await _reminders.cancel(id);
    return current;
  }

  Medicacao? _find(int id) {
    for (final m in _items) {
      if (m.id == id) return m;
    }
    return null;
  }
}
