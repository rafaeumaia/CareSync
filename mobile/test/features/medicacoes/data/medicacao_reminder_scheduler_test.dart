import 'package:flutter_test/flutter_test.dart';

import 'package:caresync/core/notifications/local_notification_gateway.dart';
import 'package:caresync/features/medicacoes/data/medicacao_reminder_scheduler.dart';
import 'package:caresync/features/medicacoes/domain/medicacao.dart';

import '../../../helpers/fake_notification_gateway.dart';

Medicacao _med(int id, {String frequency = 'Diariamente'}) => Medicacao(
      id: id,
      name: 'Med $id',
      dosage: '10mg',
      frequency: frequency,
      time: '21:00',
      taken: false,
      createdAt: DateTime(2026, 10, 19),
    );

void main() {
  late FakeNotificationGateway gateway;
  late MedicacaoReminderScheduler scheduler;

  setUp(() {
    gateway = FakeNotificationGateway();
    scheduler = MedicacaoReminderScheduler(
      gateway,
      clock: () => DateTime(2026, 10, 20, 10),
    );
  });

  test('schedule agenda o lembrete diário da medicação', () async {
    await scheduler.schedule(_med(3));

    final n = gateway.scheduled[3]!;
    expect(n.title, 'Hora de tomar Med 3');
    expect(n.repeat, NotificationRepeat.daily);
    expect(n.firstOccurrence, DateTime(2026, 10, 20, 21));
    expect(n.payload, 'medicacao:3');
    expect(n.channel.id, 'medicacoes_lembretes');
  });

  test('schedule semanal usa repetição semanal', () async {
    await scheduler.schedule(_med(4, frequency: 'Semanalmente'));
    expect(gateway.scheduled[4]!.repeat, NotificationRepeat.weekly);
  });

  test('schedule de novo reagenda sem duplicar', () async {
    await scheduler.schedule(_med(3));
    await scheduler.schedule(_med(3));
    expect(gateway.scheduled, hasLength(1));
    expect(gateway.cancelled, [3, 3]);
  });

  test('"Quando necessário" não agenda e remove lembrete anterior', () async {
    await scheduler.schedule(_med(5));
    await scheduler.schedule(_med(5, frequency: 'Quando necessário'));
    expect(gateway.scheduled, isEmpty);
  });

  test('cancel remove o lembrete da medicação', () async {
    await scheduler.schedule(_med(3));
    await scheduler.cancel(3);
    expect(gateway.scheduled, isEmpty);
    expect(gateway.cancelled.last, 3);
  });

  test('sync cancela lembretes órfãos de medicação e agenda os atuais',
      () async {
    gateway.extraPending.addAll(const [
      // Medicação de uma execução anterior, que não existe mais.
      PendingNotification(id: 99, payload: 'medicacao:99'),
      // Notificação de outra feature: não é tocada.
      PendingNotification(id: 500, payload: 'consulta:1'),
    ]);

    await scheduler.sync([_med(1), _med(2, frequency: 'Quando necessário')]);

    expect(gateway.cancelled, contains(99));
    expect(gateway.cancelled, isNot(contains(500)));
    expect(gateway.scheduled.keys, [1]);
    expect(
      (await gateway.pending()).map((p) => p.id),
      unorderedEquals([1, 500]),
    );
  });

  test('Falhas do aparelho não propagam', () async {
    final failing = MedicacaoReminderScheduler(_FailingGateway());
    await failing.schedule(_med(1));
    await failing.cancel(1);
    await failing.sync([_med(1)]);
    await failing.requestPermissions();
  });

  test('requestPermissions delega ao gateway', () async {
    await scheduler.requestPermissions();
    expect(gateway.permissionRequests, 1);
  });
}

class _FailingGateway implements LocalNotificationGateway {
  @override
  Future<void> cancel(int id) => Future.error(StateError('falhou'));
  @override
  Future<List<PendingNotification>> pending() =>
      Future.error(StateError('falhou'));
  @override
  Future<void> requestPermissions() => Future.error(StateError('falhou'));
  @override
  Future<void> schedule(ScheduledNotification notification) =>
      Future.error(StateError('falhou'));
}
