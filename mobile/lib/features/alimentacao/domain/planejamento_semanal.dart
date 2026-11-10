/// Situação de um dia no "Planejamento Semanal".
enum StatusDiaPlanejamento { completo, parcial, incompleto }

/// Um dia do "Planejamento Semanal" (`weeklyCalendar` do protótipo).
///
/// No protótipo os status são fixos; a API Django deverá calculá-los a
/// partir das refeições confirmadas (PROJECT_SPEC.md, seção 11).
class DiaPlanejamento {
  const DiaPlanejamento({required this.label, required this.status});

  /// Abreviação do dia da semana (ex.: "Seg").
  final String label;
  final StatusDiaPlanejamento status;
}
