import 'package:flutter_test/flutter_test.dart';

import 'package:caresync/features/medicacoes/domain/medicacao.dart';
import 'package:caresync/features/medicacoes/domain/medicacao_reminder.dart';

Medicacao _med({
  int id = 7,
  String frequency = 'Diariamente',
  String time = '14:00',
  DateTime? createdAt,
}) =>
    Medicacao(
      id: id,
      name: 'Metformina',
      dosage: '850mg',
      frequency: frequency,
      time: time,
      taken: false,
      createdAt: createdAt ?? DateTime(2026, 10, 19), // segunda-feira
    );

void main() {
  // Terça-feira, 20/10/2026, 10:00.
  final now = DateTime(2026, 10, 20, 10);

  test('Diário: hoje se o horário ainda não passou, senão amanhã', () {
    final today = planMedicacaoReminder(_med(), now: now)!;
    expect(today.recurrence, ReminderRecurrence.daily);
    expect(today.firstOccurrence, DateTime(2026, 10, 20, 14));

    final tomorrow = planMedicacaoReminder(_med(time: '08:00'), now: now)!;
    expect(tomorrow.firstOccurrence, DateTime(2026, 10, 21, 8));

    // Exatamente agora também vai para amanhã.
    final exact = planMedicacaoReminder(_med(time: '10:00'), now: now)!;
    expect(exact.firstOccurrence, DateTime(2026, 10, 21, 10));
  });

  test('"2x ao dia" e "3x ao dia": diário no único horário cadastrado', () {
    for (final f in ['2x ao dia', '3x ao dia']) {
      final r = planMedicacaoReminder(_med(frequency: f), now: now)!;
      expect(r.recurrence, ReminderRecurrence.daily, reason: f);
      expect(r.firstOccurrence, DateTime(2026, 10, 20, 14), reason: f);
    }
  });

  test('Semanalmente: no dia da semana do cadastro', () {
    // Cadastrada numa segunda: próxima segunda, 26/10.
    final r = planMedicacaoReminder(
      _med(frequency: 'Semanalmente'),
      now: now,
    )!;
    expect(r.recurrence, ReminderRecurrence.weekly);
    expect(r.firstOccurrence, DateTime(2026, 10, 26, 14));
    expect(r.firstOccurrence.weekday, DateTime.monday);

    // Cadastrada numa terça (hoje), horário ainda por vir: hoje.
    final todayWeekly = planMedicacaoReminder(
      _med(frequency: 'Semanalmente', createdAt: DateTime(2026, 10, 20)),
      now: now,
    )!;
    expect(todayWeekly.firstOccurrence, DateTime(2026, 10, 20, 14));

    // Cadastrada numa terça, horário já passou: terça que vem.
    final nextWeek = planMedicacaoReminder(
      _med(
        frequency: 'Semanalmente',
        time: '08:00',
        createdAt: DateTime(2026, 10, 20),
      ),
      now: now,
    )!;
    expect(nextWeek.firstOccurrence, DateTime(2026, 10, 27, 8));
  });

  test(
      '"Quando necessário", frequência desconhecida e horário inválido: '
      'sem lembrete', () {
    expect(
      planMedicacaoReminder(_med(frequency: 'Quando necessário'), now: now),
      isNull,
    );
    expect(planMedicacaoReminder(_med(frequency: 'Mensal'), now: now), isNull);
    for (final t in ['', '25:00', '12:60', 'abc']) {
      expect(planMedicacaoReminder(_med(time: t), now: now), isNull, reason: t);
    }
  });

  test('Identifica a medicação no texto, no id e no payload', () {
    final r = planMedicacaoReminder(_med(id: 7), now: now)!;
    expect(r.title, 'Hora de tomar Metformina');
    expect(r.body, contains('Metformina 850mg'));
    expect(r.body, contains('14:00'));
    expect(r.notificationId, 7);
    expect(r.payload, 'medicacao:7');
  });

  test('Ids grandes (Date.now) viram ids de notificação de 31 bits', () {
    final id = DateTime(2026, 10, 20).microsecondsSinceEpoch;
    final notificationId = medicacaoNotificationId(id);
    expect(notificationId, inInclusiveRange(0, 0x7FFFFFFF));
    expect(medicacaoNotificationId(id), notificationId);
  });
}
