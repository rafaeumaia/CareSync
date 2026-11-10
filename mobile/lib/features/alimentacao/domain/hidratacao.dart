/// Hidratação do dia (PROJECT_SPEC.md, seção 12 — `RegistroHidratacao` e
/// `MetaHidratacao`): o total ingerido e a meta diária, em ml.
class Hidratacao {
  const Hidratacao({required this.intakeMl, required this.goalMl});

  final int intakeMl;
  final int goalMl;

  /// Fração da meta atingida, de 0 a 1.
  double get progress => goalMl <= 0 ? 0 : (intakeMl / goalMl).clamp(0, 1);

  /// Percentual exibido (`Math.round((waterIntake / waterGoal) * 100)`).
  int get percent => (progress * 100).round();

  /// Soma [amountMl] ao total, sem passar da meta, como no protótipo
  /// (`Math.min(waterIntake + amount, waterGoal)`).
  Hidratacao add(int amountMl) => Hidratacao(
    intakeMl: (intakeMl + amountMl).clamp(0, goalMl),
    goalMl: goalMl,
  );
}

/// Quantidades dos botões de registro de água, na ordem do protótipo.
const quantidadesAguaMl = [200, 300, 500];
