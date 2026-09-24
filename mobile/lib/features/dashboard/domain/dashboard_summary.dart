/// Tipo de uma tarefa do dia, que define ícone e cor no Dashboard.
enum DashboardTaskType { medication, appointment, health }

/// Item do card "Tarefas do Dia".
class DashboardTask {
  const DashboardTask({
    required this.id,
    required this.title,
    required this.timeLabel,
    required this.type,
    required this.done,
  });

  final int id;
  final String title;

  /// Horário ou período exibido (ex.: `'14:00'`, `'Manhã'`).
  final String timeLabel;
  final DashboardTaskType type;
  final bool done;
}

/// Dados exibidos pelo Dashboard / Início.
class DashboardSummary {
  const DashboardSummary({
    required this.userName,
    required this.notificationCount,
    required this.daysUntilNextAppointment,
    required this.medicationsToday,
    required this.tasks,
  });

  /// Nome do usuário logado, usado na saudação e nas iniciais do avatar.
  final String userName;
  final int notificationCount;
  final int daysUntilNextAppointment;
  final int medicationsToday;
  final List<DashboardTask> tasks;
}
