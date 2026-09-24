import '../domain/dashboard_summary.dart';

/// Contrato de acesso aos dados do Dashboard.
///
/// Hoje implementado em memória por [MockDashboardRepository]; a
/// implementação definitiva consumirá a API Django (CLAUDE.md), sem banco
/// local como fonte principal.
abstract interface class DashboardRepository {
  Future<DashboardSummary> fetchSummary();
}

/// Dados fixos do protótipo Figma Make (`Dashboard.tsx` e o `Header` que
/// ele usa).
class MockDashboardRepository implements DashboardRepository {
  const MockDashboardRepository();

  static const summary = DashboardSummary(
    userName: 'Gustavo Werneck',
    notificationCount: 3,
    daysUntilNextAppointment: 2,
    medicationsToday: 3,
    tasks: [
      DashboardTask(
        id: 1,
        title: 'Losartana 50mg',
        timeLabel: '14:00',
        type: DashboardTaskType.medication,
        done: true,
      ),
      DashboardTask(
        id: 2,
        title: 'Consulta – Dr. Silva',
        timeLabel: '15:30',
        type: DashboardTaskType.appointment,
        done: false,
      ),
      DashboardTask(
        id: 3,
        title: 'Medir pressão',
        timeLabel: 'Manhã',
        type: DashboardTaskType.health,
        done: false,
      ),
    ],
  );

  @override
  Future<DashboardSummary> fetchSummary() async => summary;
}
