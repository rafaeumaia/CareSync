import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/alimentacao_repository.dart';
import '../domain/hidratacao.dart';
import '../domain/planejamento_semanal.dart';
import '../domain/refeicao.dart';

/// Repositório de alimentação. Trocar pela implementação HTTP quando a API
/// Django existir.
final alimentacaoRepositoryProvider = Provider<AlimentacaoRepository>(
  (ref) => InMemoryAlimentacaoRepository(),
);

/// Refeições do dia, na ordem do protótipo.
final refeicoesProvider =
    AsyncNotifierProvider<RefeicoesNotifier, List<Refeicao>>(
      RefeicoesNotifier.new,
    );

class RefeicoesNotifier extends AsyncNotifier<List<Refeicao>> {
  AlimentacaoRepository get _repository =>
      ref.read(alimentacaoRepositoryProvider);

  /// Refeições com uma alteração em andamento: toques repetidos não geram
  /// alterações duplicadas.
  final _updating = <String>{};

  @override
  Future<List<Refeicao>> build() =>
      ref.watch(alimentacaoRepositoryProvider).fetchRefeicoes();

  List<Refeicao> get _items => state.value ?? const [];

  /// Alterna a refeição entre confirmada e pendente (`handleToggleMeal`).
  ///
  /// Retorna a refeição atualizada, ou `null` se ela não existe ou se outra
  /// alteração dela está em andamento.
  Future<Refeicao?> toggle(String id) async {
    final current = _find(id);
    if (current == null || !_updating.add(id)) return null;
    try {
      final updated = await _repository.setRefeicaoCompleted(
        id,
        completed: !current.completed,
      );
      state = AsyncData([for (final r in _items) r.id == id ? updated : r]);
      return updated;
    } finally {
      _updating.remove(id);
    }
  }

  Refeicao? _find(String id) {
    for (final r in _items) {
      if (r.id == id) return r;
    }
    return null;
  }
}

/// Hidratação do dia.
final hidratacaoProvider =
    AsyncNotifierProvider<HidratacaoNotifier, Hidratacao>(
      HidratacaoNotifier.new,
    );

class HidratacaoNotifier extends AsyncNotifier<Hidratacao> {
  @override
  Future<Hidratacao> build() =>
      ref.watch(alimentacaoRepositoryProvider).fetchHidratacao();

  /// Registra [amountMl] de água (`handleAddWater`); o total não passa da
  /// meta.
  Future<void> addAgua(int amountMl) async {
    final updated = await ref
        .read(alimentacaoRepositoryProvider)
        .addAgua(amountMl);
    state = AsyncData(updated);
  }
}

/// Dias do "Planejamento Semanal".
final planejamentoSemanalProvider = FutureProvider<List<DiaPlanejamento>>(
  (ref) => ref.watch(alimentacaoRepositoryProvider).fetchPlanejamentoSemanal(),
);
