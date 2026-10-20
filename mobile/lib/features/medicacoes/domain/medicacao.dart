/// Medicação (PROJECT_SPEC.md, seção 12 — entidade `Medicacao`), com os
/// campos do protótipo (`MedicacoesScreen.tsx`).
class Medicacao {
  const Medicacao({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.time,
    required this.taken,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String dosage;

  /// Uma das [frequenciasMedicacao] (ou texto livre vindo da API).
  final String frequency;

  /// Horário no formato `HH:mm`.
  final String time;

  /// Se a dose de hoje já foi tomada.
  final bool taken;

  /// Quando a medicação foi cadastrada. Define o dia da semana do lembrete
  /// das medicações "Semanalmente" (o formulário não tem esse campo).
  final DateTime createdAt;

  Medicacao copyWith({bool? taken}) => Medicacao(
    id: id,
    name: name,
    dosage: dosage,
    frequency: frequency,
    time: time,
    taken: taken ?? this.taken,
    createdAt: createdAt,
  );
}

/// Dados preenchidos no formulário "Adicionar Medicação".
class MedicacaoDraft {
  const MedicacaoDraft({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.time,
  });

  final String name;
  final String dosage;
  final String frequency;
  final String time;
}

/// Opções do campo "Frequência", na ordem do protótipo.
const frequenciasMedicacao = [
  'Diariamente',
  '2x ao dia',
  '3x ao dia',
  'Semanalmente',
  'Quando necessário',
];
