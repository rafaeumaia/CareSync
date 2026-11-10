import '../domain/hidratacao.dart';
import '../domain/planejamento_semanal.dart';
import '../domain/refeicao.dart';

/// Contrato de acesso às refeições, à hidratação e ao planejamento semanal.
///
/// Hoje implementado em memória por [InMemoryAlimentacaoRepository]; a
/// implementação definitiva consumirá a API Django (CLAUDE.md), sem banco
/// local como fonte principal.
abstract interface class AlimentacaoRepository {
  Future<List<Refeicao>> fetchRefeicoes();
  Future<Refeicao> setRefeicaoCompleted(String id, {required bool completed});
  Future<Hidratacao> fetchHidratacao();

  /// Registra [amountMl] de água e devolve a hidratação atualizada.
  Future<Hidratacao> addAgua(int amountMl);
  Future<List<DiaPlanejamento>> fetchPlanejamentoSemanal();
}

/// Repositório em memória, iniciado com os dados fixos do protótipo
/// (`AlimentacaoScreen.tsx`). Os dados duram enquanto o app estiver aberto.
class InMemoryAlimentacaoRepository implements AlimentacaoRepository {
  InMemoryAlimentacaoRepository({
    List<Refeicao>? refeicoes,
    Hidratacao? hidratacao,
    List<DiaPlanejamento>? planejamento,
  }) : _refeicoes = [...(refeicoes ?? seedRefeicoes)],
       _hidratacao = hidratacao ?? seedHidratacao,
       _planejamento = [...(planejamento ?? seedPlanejamento)];

  static const seedRefeicoes = [
    Refeicao(
      id: 'breakfast',
      name: 'Café da manhã',
      time: '07:00',
      tipo: TipoRefeicao.cafeDaManha,
      description: 'Leite + pão integral + fruta',
      completed: true,
    ),
    Refeicao(
      id: 'lunch',
      name: 'Almoço',
      time: '12:00',
      tipo: TipoRefeicao.almoco,
      description: 'Arroz + feijão + frango + salada',
      completed: true,
    ),
    Refeicao(
      id: 'snack',
      name: 'Lanche',
      time: '15:00',
      tipo: TipoRefeicao.lanche,
      description: 'Iogurte + castanhas',
      completed: false,
    ),
    Refeicao(
      id: 'dinner',
      name: 'Jantar',
      time: '19:00',
      tipo: TipoRefeicao.jantar,
      description: 'Sopa leve + legumes',
      completed: false,
    ),
  ];

  static const seedHidratacao = Hidratacao(intakeMl: 1200, goalMl: 2000);

  static const seedPlanejamento = [
    DiaPlanejamento(label: 'Seg', status: StatusDiaPlanejamento.completo),
    DiaPlanejamento(label: 'Ter', status: StatusDiaPlanejamento.completo),
    DiaPlanejamento(label: 'Qua', status: StatusDiaPlanejamento.completo),
    DiaPlanejamento(label: 'Qui', status: StatusDiaPlanejamento.parcial),
    DiaPlanejamento(label: 'Sex', status: StatusDiaPlanejamento.incompleto),
    DiaPlanejamento(label: 'Sáb', status: StatusDiaPlanejamento.incompleto),
    DiaPlanejamento(label: 'Dom', status: StatusDiaPlanejamento.incompleto),
  ];

  final List<Refeicao> _refeicoes;
  Hidratacao _hidratacao;
  final List<DiaPlanejamento> _planejamento;

  @override
  Future<List<Refeicao>> fetchRefeicoes() async =>
      List.unmodifiable(_refeicoes);

  @override
  Future<Refeicao> setRefeicaoCompleted(
    String id, {
    required bool completed,
  }) async {
    final index = _refeicoes.indexWhere((r) => r.id == id);
    if (index < 0) throw StateError('Refeição $id não encontrada');
    final updated = _refeicoes[index].copyWith(completed: completed);
    _refeicoes[index] = updated;
    return updated;
  }

  @override
  Future<Hidratacao> fetchHidratacao() async => _hidratacao;

  @override
  Future<Hidratacao> addAgua(int amountMl) async =>
      _hidratacao = _hidratacao.add(amountMl);

  @override
  Future<List<DiaPlanejamento>> fetchPlanejamentoSemanal() async =>
      List.unmodifiable(_planejamento);
}
