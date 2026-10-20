/// Consulta médica (PROJECT_SPEC.md, seção 12 — entidade `Consulta`), com
/// os campos do formulário "Nova Consulta" do protótipo.
class Consulta {
  const Consulta({
    required this.id,
    required this.doctor,
    required this.specialty,
    required this.date,
    required this.time,
    required this.location,
    this.notes,
  });

  final int id;
  final String doctor;
  final String specialty;

  /// Dia da consulta (sem horário).
  final DateTime date;

  /// Horário no formato `HH:mm`; pode ser vazio, como no protótipo.
  final String time;
  final String location;
  final String? notes;

  /// A consulta é "próxima" a partir do próprio dia: consultas de hoje
  /// ainda aparecem em "Próximas".
  bool isUpcoming(DateTime today) =>
      !DateTime(date.year, date.month, date.day)
          .isBefore(DateTime(today.year, today.month, today.day));
}

/// Dados preenchidos no formulário "Nova Consulta".
class ConsultaDraft {
  const ConsultaDraft({
    required this.doctor,
    required this.specialty,
    required this.date,
    required this.time,
    required this.location,
    required this.notes,
  });

  final String doctor;
  final String specialty;
  final DateTime date;
  final String time;
  final String location;
  final String notes;
}
