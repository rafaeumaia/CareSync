import 'package:flutter/foundation.dart';

import '../../../core/notifications/local_notification_gateway.dart';
import '../domain/medicacao.dart';
import '../domain/medicacao_reminder.dart';

/// Agenda e cancela os lembretes locais das medicações.
///
/// Não depende do repositório: recebe as medicações já salvas, então
/// continua igual quando os dados vierem da API Django.
class MedicacaoReminderScheduler {
  MedicacaoReminderScheduler(this._gateway, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  static const channel = NotificationChannel(
    id: 'medicacoes_lembretes',
    name: 'Lembretes de medicação',
    description: 'Avisos nos horários programados das medicações.',
  );

  final LocalNotificationGateway _gateway;
  final DateTime Function() _clock;

  Future<void> requestPermissions() => _guard(_gateway.requestPermissions);

  /// Agenda (ou reagenda) o lembrete de [medicacao]: o anterior é sempre
  /// cancelado, então serve também para quando os dados mudarem. Sem
  /// lembrete a agendar (ex.: "Quando necessário"), só cancela.
  Future<void> schedule(Medicacao medicacao) => _guard(() async {
    await _gateway.cancel(medicacaoNotificationId(medicacao.id));
    final reminder = planMedicacaoReminder(medicacao, now: _clock());
    if (reminder == null) return;
    await _gateway.schedule(
      ScheduledNotification(
        id: reminder.notificationId,
        channel: channel,
        title: reminder.title,
        body: reminder.body,
        firstOccurrence: reminder.firstOccurrence,
        repeat: switch (reminder.recurrence) {
          ReminderRecurrence.daily => NotificationRepeat.daily,
          ReminderRecurrence.weekly => NotificationRepeat.weekly,
        },
        payload: reminder.payload,
      ),
    );
  });

  /// Cancela o lembrete da medicação [medicacaoId].
  Future<void> cancel(int medicacaoId) =>
      _guard(() => _gateway.cancel(medicacaoNotificationId(medicacaoId)));

  /// Deixa o aparelho com exatamente os lembretes de [medicacoes]: cancela
  /// lembretes de medicação que não existem mais (ex.: cadastradas numa
  /// execução anterior do app) e (re)agenda os atuais.
  Future<void> sync(List<Medicacao> medicacoes) => _guard(() async {
    final current = {for (final m in medicacoes) medicacaoNotificationId(m.id)};
    for (final p in await _gateway.pending()) {
      final isMedicacao =
          p.payload?.startsWith(medicacaoReminderPayloadPrefix) ?? false;
      if (isMedicacao && !current.contains(p.id)) {
        await _gateway.cancel(p.id);
      }
    }
    for (final m in medicacoes) {
      await schedule(m);
    }
  });

  /// Falhas de notificação nunca interrompem o cadastro de medicações.
  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (error, stack) {
      debugPrint('Lembretes de medicação: $error\n$stack');
    }
  }
}
