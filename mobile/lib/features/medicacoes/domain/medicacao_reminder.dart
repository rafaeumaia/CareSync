import 'medicacao.dart';

/// Recorrência de um lembrete de medicação.
enum ReminderRecurrence { daily, weekly }

/// Lembrete local de uma medicação, já calculado.
class MedicacaoReminder {
  const MedicacaoReminder({
    required this.notificationId,
    required this.title,
    required this.body,
    required this.firstOccurrence,
    required this.recurrence,
    required this.payload,
  });

  /// Identificador da notificação no aparelho (inteiro de 31 bits).
  final int notificationId;
  final String title;
  final String body;

  /// Próximo disparo, em horário local do aparelho.
  final DateTime firstOccurrence;
  final ReminderRecurrence recurrence;

  /// Identifica a medicação de origem (ex.: `medicacao:3`).
  final String payload;
}

/// Prefixo do `payload` das notificações de medicação.
const medicacaoReminderPayloadPrefix = 'medicacao:';

/// Id da notificação de uma medicação: o id dela limitado a 31 bits (o
/// Android exige um `int` de 32 bits com sinal).
int medicacaoNotificationId(int medicacaoId) => medicacaoId & 0x7FFFFFFF;

/// Calcula o lembrete de [medicacao] a partir de [now], ou `null` quando
/// não há lembrete a agendar.
///
/// O protótipo só tem um horário por medicação e trata a frequência como
/// texto. Regras (decididas com o usuário, sem novos campos no formulário):
/// - "Diariamente", "2x ao dia", "3x ao dia": todo dia no horário
///   cadastrado (o único informado);
/// - "Semanalmente": toda semana, no dia da semana do cadastro;
/// - "Quando necessário" (ou frequência desconhecida): sem lembrete;
/// - horário inválido: sem lembrete.
MedicacaoReminder? planMedicacaoReminder(
  Medicacao medicacao, {
  required DateTime now,
}) {
  final time = _parseTime(medicacao.time);
  if (time == null) return null;

  final ReminderRecurrence recurrence;
  switch (medicacao.frequency) {
    case 'Diariamente' || '2x ao dia' || '3x ao dia':
      recurrence = ReminderRecurrence.daily;
    case 'Semanalmente':
      recurrence = ReminderRecurrence.weekly;
    default:
      return null;
  }

  var next = DateTime(now.year, now.month, now.day, time.hour, time.minute);
  if (recurrence == ReminderRecurrence.weekly) {
    final daysAhead = (medicacao.createdAt.weekday - next.weekday) % 7;
    next = DateTime(
      next.year,
      next.month,
      next.day + daysAhead,
      time.hour,
      time.minute,
    );
  }
  if (!next.isAfter(now)) {
    final step = recurrence == ReminderRecurrence.weekly ? 7 : 1;
    next = DateTime(
      next.year,
      next.month,
      next.day + step,
      time.hour,
      time.minute,
    );
  }

  return MedicacaoReminder(
    notificationId: medicacaoNotificationId(medicacao.id),
    title: 'Hora de tomar ${medicacao.name}',
    body:
        '${medicacao.name} ${medicacao.dosage} · ${medicacao.time} · '
        '${medicacao.frequency}',
    firstOccurrence: next,
    recurrence: recurrence,
    payload: '$medicacaoReminderPayloadPrefix${medicacao.id}',
  );
}

({int hour, int minute})? _parseTime(String value) {
  final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(value.trim());
  if (match == null) return null;
  final hour = int.parse(match.group(1)!);
  final minute = int.parse(match.group(2)!);
  if (hour > 23 || minute > 59) return null;
  return (hour: hour, minute: minute);
}
