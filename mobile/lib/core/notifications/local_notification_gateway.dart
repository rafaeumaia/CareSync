import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Repetição de uma notificação agendada.
enum NotificationRepeat {
  /// Todo dia, no mesmo horário.
  daily,

  /// Toda semana, no mesmo dia da semana e horário.
  weekly,
}

/// Notificação local recorrente a agendar no aparelho.
class ScheduledNotification {
  const ScheduledNotification({
    required this.id,
    required this.channel,
    required this.title,
    required this.body,
    required this.firstOccurrence,
    required this.repeat,
    this.payload,
  });

  final int id;
  final NotificationChannel channel;
  final String title;
  final String body;

  /// Primeiro disparo, no horário local do aparelho.
  final DateTime firstOccurrence;
  final NotificationRepeat repeat;
  final String? payload;
}

/// Canal de notificação do Android (no iOS, apenas agrupa a configuração).
class NotificationChannel {
  const NotificationChannel({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;
  final String name;
  final String description;
}

/// Notificação ainda pendente no aparelho.
class PendingNotification {
  const PendingNotification({required this.id, this.payload});

  final int id;
  final String? payload;
}

/// Acesso às notificações locais do aparelho (sem backend, sem push).
///
/// As features dependem deste contrato, não do plugin, para poderem ser
/// testadas com uma implementação falsa.
abstract interface class LocalNotificationGateway {
  /// Pede permissão para mostrar notificações (Android 13+ e iOS).
  Future<void> requestPermissions();

  Future<void> schedule(ScheduledNotification notification);
  Future<void> cancel(int id);
  Future<List<PendingNotification>> pending();
}

/// Implementação com `flutter_local_notifications` para Android e iOS.
///
/// Android:
/// - pede `POST_NOTIFICATIONS` (Android 13+) quando a feature é usada;
/// - usa alarme exato quando o usuário permitiu (`SCHEDULE_EXACT_ALARM`, que
///   no Android 14+ vem negado por padrão); senão, um alarme inexato que
///   também dispara com o aparelho ocioso. Não abre as configurações do
///   sistema para pedir alarmes exatos;
/// - os lembretes são reagendados pelo próprio plugin após reiniciar o
///   aparelho (receivers no `AndroidManifest.xml`).
///
/// iOS: as permissões são pedidas pelo mesmo [requestPermissions] (não na
/// inicialização); o `AppDelegate` define o delegate das notificações.
class FlutterLocalNotificationGateway implements LocalNotificationGateway {
  FlutterLocalNotificationGateway({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  /// Ícone monocromático (`res/drawable/ic_stat_medicacao.xml`).
  static const _androidIcon = 'ic_stat_medicacao';

  /// Fuso usado se o do aparelho não puder ser lido.
  static const _fallbackTimeZone = 'America/Sao_Paulo';

  final FlutterLocalNotificationsPlugin _plugin;
  Future<void>? _initialization;

  Future<void> _ensureInitialized() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    tz_data.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation(_fallbackTimeZone));
    }

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(_androidIcon),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  IOSFlutterLocalNotificationsPlugin? get _ios => _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  @override
  Future<void> requestPermissions() async {
    await _ensureInitialized();
    await _android?.requestNotificationsPermission();
    await _ios?.requestPermissions(alert: true, sound: true);
  }

  @override
  Future<void> schedule(ScheduledNotification notification) async {
    await _ensureInitialized();
    final first = notification.firstOccurrence;
    final exact = await _android?.canScheduleExactNotifications() ?? false;

    await _plugin.zonedSchedule(
      id: notification.id,
      title: notification.title,
      body: notification.body,
      payload: notification.payload,
      scheduledDate: tz.TZDateTime(
        tz.local,
        first.year,
        first.month,
        first.day,
        first.hour,
        first.minute,
      ),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          notification.channel.id,
          notification.channel.name,
          channelDescription: notification.channel.description,
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: switch (notification.repeat) {
        NotificationRepeat.daily => DateTimeComponents.time,
        NotificationRepeat.weekly => DateTimeComponents.dayOfWeekAndTime,
      },
    );
  }

  @override
  Future<void> cancel(int id) async {
    await _ensureInitialized();
    await _plugin.cancel(id: id);
  }

  @override
  Future<List<PendingNotification>> pending() async {
    await _ensureInitialized();
    final requests = await _plugin.pendingNotificationRequests();
    return [
      for (final r in requests)
        PendingNotification(id: r.id, payload: r.payload),
    ];
  }
}

/// Usado onde não há notificações locais (testes, desktop, web).
class NoopNotificationGateway implements LocalNotificationGateway {
  const NoopNotificationGateway();

  @override
  Future<void> requestPermissions() async {}

  @override
  Future<void> schedule(ScheduledNotification notification) async {}

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<List<PendingNotification>> pending() async => const [];
}

/// Notificações locais do aparelho: o plugin em Android e iOS; nas demais
/// plataformas, nada é agendado.
final localNotificationGatewayProvider = Provider<LocalNotificationGateway>(
  (ref) => !kIsWeb && (Platform.isAndroid || Platform.isIOS)
      ? FlutterLocalNotificationGateway()
      : const NoopNotificationGateway(),
);
