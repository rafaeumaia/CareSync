import 'package:caresync/core/notifications/local_notification_gateway.dart';

/// Gateway em memória que imita o agendador do aparelho.
class FakeNotificationGateway implements LocalNotificationGateway {
  /// Notificações pendentes, por id.
  final scheduled = <int, ScheduledNotification>{};
  final cancelled = <int>[];
  var permissionRequests = 0;

  /// Pendentes que não vieram de [schedule] (ex.: de outra execução).
  final extraPending = <PendingNotification>[];

  @override
  Future<void> requestPermissions() async => permissionRequests++;

  @override
  Future<void> schedule(ScheduledNotification notification) async =>
      scheduled[notification.id] = notification;

  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
    scheduled.remove(id);
    extraPending.removeWhere((p) => p.id == id);
  }

  @override
  Future<List<PendingNotification>> pending() async => [
        for (final n in scheduled.values)
          PendingNotification(id: n.id, payload: n.payload),
        ...extraPending,
      ];
}
