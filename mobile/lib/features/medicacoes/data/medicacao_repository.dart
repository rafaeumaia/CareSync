import '../domain/medicacao.dart';

/// Contrato de acesso às medicações.
///
/// Hoje implementado em memória por [InMemoryMedicacaoRepository]; a
/// implementação definitiva consumirá a API Django (CLAUDE.md), sem banco
/// local como fonte principal.
abstract interface class MedicacaoRepository {
  Future<List<Medicacao>> fetchAll();
  Future<Medicacao> add(MedicacaoDraft draft);
  Future<Medicacao> setTaken(int id, {required bool taken});
  Future<void> delete(int id);
}

/// Repositório em memória, iniciado com as medicações fixas do protótipo
/// (`MedicacoesScreen.tsx`). Os dados duram enquanto o app estiver aberto.
class InMemoryMedicacaoRepository implements MedicacaoRepository {
  InMemoryMedicacaoRepository({
    List<Medicacao>? initial,
    DateTime Function()? clock,
  }) : _items = [...(initial ?? seed)],
       _clock = clock ?? DateTime.now;

  /// Data de referência do protótipo ("Segunda-feira, 27 de Outubro").
  static final _seedDate = DateTime(2025, 10, 27);

  static final seed = [
    Medicacao(
      id: 1,
      name: 'Losartana',
      dosage: '50mg',
      frequency: 'Diariamente',
      time: '08:00',
      taken: true,
      createdAt: _seedDate,
    ),
    Medicacao(
      id: 2,
      name: 'Metformina',
      dosage: '850mg',
      frequency: '2x ao dia',
      time: '14:00',
      taken: false,
      createdAt: _seedDate,
    ),
    Medicacao(
      id: 3,
      name: 'Sinvastatina',
      dosage: '20mg',
      frequency: 'Diariamente',
      time: '21:00',
      taken: false,
      createdAt: _seedDate,
    ),
  ];

  final List<Medicacao> _items;
  final DateTime Function() _clock;

  @override
  Future<List<Medicacao>> fetchAll() async => List.unmodifiable(_items);

  @override
  Future<Medicacao> add(MedicacaoDraft draft) async {
    final now = _clock();
    final medicacao = Medicacao(
      // `id: Date.now()` no protótipo.
      id: now.microsecondsSinceEpoch,
      name: draft.name,
      dosage: draft.dosage,
      frequency: draft.frequency,
      time: draft.time,
      taken: false,
      createdAt: now,
    );
    _items.add(medicacao);
    return medicacao;
  }

  @override
  Future<Medicacao> setTaken(int id, {required bool taken}) async {
    final index = _items.indexWhere((m) => m.id == id);
    if (index < 0) throw StateError('Medicação $id não encontrada');
    final updated = _items[index].copyWith(taken: taken);
    _items[index] = updated;
    return updated;
  }

  @override
  Future<void> delete(int id) async => _items.removeWhere((m) => m.id == id);
}
