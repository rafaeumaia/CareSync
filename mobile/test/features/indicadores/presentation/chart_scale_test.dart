import 'package:flutter_test/flutter_test.dart';

import 'package:caresync/features/indicadores/presentation/widgets/chart_scale.dart';

void main() {
  void expectRange(AxisRange r, double min, double max, double step) {
    expect(r.min, min, reason: '$r');
    expect(r.max, max, reason: '$r');
    expect(r.step, step, reason: '$r');
  }

  test('Pressão (80 a 132): de 60 a 140, de 20 em 20', () {
    final r = niceAxisRange([130, 125, 128, 132, 127, 129, 126, 85, 80, 86]);
    expectRange(r, 60, 140, 20);
    expect(r.ticks, [60, 80, 100, 120, 140]);
  });

  test('Glicemia (105 a 115): de 100 a 120, de 5 em 5', () {
    final r = niceAxisRange([110, 105, 115, 108, 112, 107, 109]);
    expectRange(r, 100, 120, 5);
  });

  test('Temperatura e peso com um único valor ficam centralizados', () {
    final t = niceAxisRange([36.5]);
    expectRange(t, 35, 38, 1);
    final w = niceAxisRange([72.5]);
    expectRange(w, 70, 76, 2);
  });

  test('Nunca corta pontos e mantém margem acima e abaixo', () {
    for (final values in [
      [36.1, 36.4, 37.9],
      [70.0, 70.2],
      [55.0, 180.0],
      [0.5, 0.7],
      [98.0, 99.5, 101.2],
    ]) {
      final r = niceAxisRange(values);
      final min = values.reduce((a, b) => a < b ? a : b);
      final max = values.reduce((a, b) => a > b ? a : b);
      expect(r.min, lessThan(min), reason: '$values $r');
      expect(r.max, greaterThan(max), reason: '$values $r');
      // Escala compreensível: entre 3 e 7 marcas.
      expect(r.ticks.length, inInclusiveRange(3, 7), reason: '$values $r');
    }
  });

  test('Variações pequenas não viram escalas exageradas', () {
    // 36.5 → 36.6 °C: amplitude mínima de 5% do valor.
    final r = niceAxisRange([36.5, 36.6]);
    expect(r.max - r.min, greaterThanOrEqualTo(36.6 * 0.05));
  });

  test('Valores positivos nunca geram eixo negativo', () {
    final r = niceAxisRange([0.2, 1.0]);
    expect(r.min, greaterThanOrEqualTo(0));
  });

  test('Passos sempre "redondos"', () {
    for (final values in [
      [12.0, 97.0],
      [36.1, 38.4],
      [1000.0, 1300.0],
    ]) {
      final step = niceAxisRange(values).step;
      final normalized =
          step / _pow10((step.abs()).toString().split('.').first.length - 1);
      expect([1, 2, 2.5, 5, 10], contains(normalized), reason: '$step');
    }
  });

  test('Sem valores: escala padrão', () {
    expect(niceAxisRange(const []).ticks, isNotEmpty);
  });
}

double _pow10(int exponent) {
  var value = 1.0;
  for (var i = 0; i < exponent; i++) {
    value *= 10;
  }
  return value;
}
