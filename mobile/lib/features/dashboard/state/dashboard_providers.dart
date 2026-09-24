import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dashboard_repository.dart';
import '../domain/dashboard_summary.dart';

/// Repositório do Dashboard. Trocar pela implementação HTTP quando a API
/// Django existir.
final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => const MockDashboardRepository(),
);

final dashboardSummaryProvider = FutureProvider<DashboardSummary>(
  (ref) => ref.watch(dashboardRepositoryProvider).fetchSummary(),
);

/// Data de hoje exibida abaixo do header (sobrescrevível em testes).
final todayProvider = Provider<DateTime>((ref) => DateTime.now());
