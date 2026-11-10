import 'package:flutter_test/flutter_test.dart';

import 'package:caresync/features/indicadores/domain/indicador.dart';
import 'package:caresync/features/indicadores/domain/indicator_validation.dart';

IndicatorRecord _rec(
  int id,
  IndicatorType type,
  DateTime at,
  double value, [
  double? diastolic,
]) => IndicatorRecord(
  id: id,
  type: type,
  recordedAt: at,
  value: value,
  diastolic: diastolic,
);

void main() {
  final today = DateTime(2026, 10, 22);
  final now = DateTime(2026, 10, 22, 10);

  group('Formatação', () {
    test('Valores como no protótipo', () {
      expect(formatMeasurement(109), '109');
      expect(formatMeasurement(36.5), '36.5');
      expect(formatMeasurement(72.50), '72.5');
      expect(formatMeasurement(37.25), '37.25');
      expect(
        _rec(1, IndicatorType.pressure, now, 126, 80).formattedValue,
        '126/80',
      );
    });
  });

  group('Histórico', () {
    final records = [
      _rec(1, IndicatorType.glucose, DateTime(2026, 10, 22, 8), 109),
      _rec(2, IndicatorType.glucose, DateTime(2026, 10, 1, 8), 100),
      _rec(3, IndicatorType.glucose, DateTime(2026, 8, 1, 8), 95),
      _rec(4, IndicatorType.glucose, DateTime(2026, 10, 16, 0, 0), 120),
      _rec(5, IndicatorType.weight, DateTime(2026, 10, 22, 9), 70),
    ];

    test('A medição mais recente vira o valor do card', () {
      expect(latestRecord(records, IndicatorType.glucose)!.id, 1);
      expect(latestRecord(records, IndicatorType.weight)!.value, 70);
      expect(latestRecord(records, IndicatorType.temperature), isNull);
    });

    test('Períodos de 7, 30 e 90 dias contando hoje', () {
      expect(ChartPeriod.week.start(today), DateTime(2026, 10, 16));
      List<int> ids(ChartPeriod p) => [
        for (final r in recordsInPeriod(
          records,
          IndicatorType.glucose,
          p,
          today,
        ))
          r.id,
      ];
      // Ordenados do mais antigo para o mais recente.
      expect(ids(ChartPeriod.week), [4, 1]);
      expect(ids(ChartPeriod.month), [2, 4, 1]);
      expect(ids(ChartPeriod.quarter), [3, 2, 4, 1]);
    });
  });

  group('Validação', () {
    IndicatorFormErrors validate(
      IndicatorType type, {
      String value = '',
      String diastolic = '',
      DateTime? at,
    }) => validateIndicatorForm(
      type: type,
      valueText: value,
      diastolicText: diastolic,
      dateTime: at,
      now: now,
    );

    test('Formulário vazio', () {
      final e = validate(IndicatorType.glucose);
      expect(e.isValid, isFalse);
      expect(e.value, 'Informe o valor.');
      expect(e.dateTime, 'Informe a data e hora.');
      expect(e.diastolic, isNull);
    });

    test('Pressão vazia: sistólica e diastólica separadamente', () {
      final e = validate(IndicatorType.pressure);
      expect(e.value, 'Informe a sistólica.');
      expect(e.diastolic, 'Informe a diastólica.');
    });

    test('Valores inválidos', () {
      for (final text in ['abc', '12a', '-5', '1e3', '3.', ',5', '1.2.3']) {
        expect(
          validate(IndicatorType.weight, value: text, at: now).value,
          'Digite um número válido.',
          reason: text,
        );
      }
      expect(
        validate(IndicatorType.weight, value: '0', at: now).value,
        'O valor deve ser maior que zero.',
      );
    });

    test('Aceita ponto ou vírgula decimal', () {
      expect(parseMeasurement('36,5'), 36.5);
      expect(parseMeasurement(' 72.5 '), 72.5);
      expect(
        validate(IndicatorType.temperature, value: '36,5', at: now).isValid,
        isTrue,
      );
    });

    test('Pressão: diastólica menor que a sistólica', () {
      expect(
        validate(
          IndicatorType.pressure,
          value: '80',
          diastolic: '120',
          at: now,
        ).diastolic,
        'A diastólica deve ser menor que a sistólica.',
      );
      expect(
        validate(
          IndicatorType.pressure,
          value: '120',
          diastolic: 'x',
          at: now,
        ).diastolic,
        'Digite um número válido.',
      );
      expect(
        validate(
          IndicatorType.pressure,
          value: '120',
          diastolic: '80',
          at: now,
        ).isValid,
        isTrue,
      );
    });

    test('Data e hora no futuro', () {
      expect(
        validate(
          IndicatorType.glucose,
          value: '100',
          at: now.add(const Duration(minutes: 1)),
        ).dateTime,
        'A data e hora não pode estar no futuro.',
      );
    });
  });
}
