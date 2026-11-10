/// Tipo da refeição, que define o ícone do card (`Coffee`, `Sun`,
/// `Sandwich`, `Moon` no protótipo).
enum TipoRefeicao { cafeDaManha, almoco, lanche, jantar }

/// Refeição do dia (PROJECT_SPEC.md, seção 12 — entidade `Refeicao`), com os
/// campos do protótipo (`AlimentacaoScreen.tsx`).
class Refeicao {
  const Refeicao({
    required this.id,
    required this.name,
    required this.time,
    required this.tipo,
    required this.description,
    required this.completed,
  });

  final String id;
  final String name;

  /// Horário planejado no formato `HH:mm`.
  final String time;
  final TipoRefeicao tipo;
  final String description;

  /// Se a refeição de hoje já foi confirmada.
  final bool completed;

  Refeicao copyWith({bool? completed}) => Refeicao(
    id: id,
    name: name,
    time: time,
    tipo: tipo,
    description: description,
    completed: completed ?? this.completed,
  );
}
