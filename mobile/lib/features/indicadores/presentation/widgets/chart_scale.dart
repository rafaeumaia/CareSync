import 'dart:math' as math;

/// Escala do eixo Y: de [min] a [max], com marcas a cada [step].
class AxisRange {
  const AxisRange({required this.min, required this.max, required this.step});

  final double min;
  final double max;
  final double step;

  /// Valores das marcas, de [min] a [max].
  List<double> get ticks {
    final count = ((max - min) / step).round();
    return [for (var i = 0; i <= count; i++) _round(min + i * step)];
  }

  @override
  String toString() => 'AxisRange($min..$max, step $step)';
}

/// Eixo Y ajustado aos valores visíveis, para que pequenas variações não
/// virem linhas retas (como acontecia com o eixo começando em zero):
/// - margem de 10% da amplitude acima e abaixo dos dados, sem cortar pontos;
/// - amplitude mínima de 5% do maior valor, para que oscilações pequenas
///   (ex.: 36.5 → 36.6 °C) não pareçam enormes;
/// - passo "redondo" (1, 2, 2.5 ou 5 × 10ⁿ) e limites múltiplos dele, com
///   cerca de [targetTicks] marcas;
/// - nunca abaixo de zero quando todos os valores são positivos.
AxisRange niceAxisRange(Iterable<double> values, {int targetTicks = 5}) {
  if (values.isEmpty) return const AxisRange(min: 0, max: 1, step: 0.25);
  final dataMin = values.reduce(math.min);
  final dataMax = values.reduce(math.max);

  final magnitude = math.max(dataMax.abs(), dataMin.abs());
  final minSpan = magnitude == 0 ? 1.0 : magnitude * 0.05;
  var low = dataMin;
  var high = dataMax;
  if (high - low < minSpan) {
    final center = (high + low) / 2;
    low = center - minSpan / 2;
    high = center + minSpan / 2;
  }
  final padding = (high - low) * 0.1;
  low -= padding;
  high += padding;
  if (dataMin >= 0 && low < 0) low = 0;

  final step = _niceStep((high - low) / (targetTicks - 1));
  var min = _round((low / step).floor() * step);
  final max = _round((high / step).ceil() * step);
  if (dataMin >= 0 && min < 0) min = 0;
  return AxisRange(min: min, max: max, step: step);
}

/// Menor passo "redondo" (1, 2, 2.5, 5 × 10ⁿ) maior ou igual a [rough].
double _niceStep(double rough) {
  final exponent = (math.log(rough) / math.ln10).floor();
  final base = math.pow(10, exponent).toDouble();
  for (final factor in const [1.0, 2.0, 2.5, 5.0, 10.0]) {
    if (factor * base >= rough - 1e-9) return _round(factor * base);
  }
  return _round(10 * base);
}

double _round(double value) => double.parse(value.toStringAsFixed(6));
