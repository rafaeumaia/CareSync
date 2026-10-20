import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dados do usuário logado exibidos no header padrão.
class CurrentUser {
  const CurrentUser({required this.name, required this.notificationCount});

  final String name;
  final int notificationCount;
}

/// Usuário logado. Enquanto não há autenticação real (API Django), usa os
/// valores fixos do protótipo, passados ao `Header` de cada tela
/// (`userName="Gustavo Werneck"`, `notificationCount={3}`).
final currentUserProvider = Provider<CurrentUser>(
  (ref) => const CurrentUser(name: 'Gustavo Werneck', notificationCount: 3),
);

/// Data de hoje (sem horário), sobrescrevível em testes.
final currentDateProvider = Provider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});
