import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:caresync/core/session/current_user.dart';
import 'package:caresync/features/indicadores/domain/indicador.dart';
import 'package:caresync/features/indicadores/state/indicadores_providers.dart';

void main() {
  final today = DateTime(2026, 10, 22);
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [currentDateProvider.overrideWithValue(today)],
    );
    addTearDown(container.dispose);
  });

  Future<List<IndicatorRecord>> load() =>
      container.read(indicadoresProvider.future);
  List<IndicatorRecord> items() => container.read(indicadoresProvider).value!;

  test('Dados do protótipo, terminando hoje', () async {
    final records = await load();
    final pressure = recordsInPeriod(
      records,
      IndicatorType.pressure,
      ChartPeriod.week,
      today,
    );
    expect(
      [for (final r in pressure) r.value],
      [130, 125, 128, 132, 127, 129, 126],
    );
    expect(
      [for (final r in pressure) r.diastolic],
      [85, 80, 82, 86, 81, 83, 80],
    );
    expect(pressure.first.recordedAt, DateTime(2026, 10, 16, 8));
    expect(pressure.last.recordedAt, DateTime(2026, 10, 22, 8));

    String card(IndicatorType t) => latestRecord(records, t)!.formattedValue;
    expect(card(IndicatorType.pressure), '126/80');
    expect(card(IndicatorType.glucose), '109');
    expect(card(IndicatorType.temperature), '36.5');
    expect(card(IndicatorType.weight), '72.5');
  });

  test('Adicionar entra no histórico e mantém os anteriores', () async {
    await load();
    final before = items().length;
    final added = await container
        .read(indicadoresProvider.notifier)
        .add(
          IndicatorRecordDraft(
            type: IndicatorType.pressure,
            recordedAt: DateTime(2026, 10, 22, 10),
            value: 140,
            diastolic: 90,
          ),
        );
    expect(items(), hasLength(before + 1));
    expect(items().last, same(added));
    expect(
      latestRecord(items(), IndicatorType.pressure)!.formattedValue,
      '140/90',
    );
    // Ids únicos.
    expect({for (final r in items()) r.id}, hasLength(items().length));
  });

  test('Medição antiga entra no gráfico, mas não muda o card', () async {
    await load();
    await container
        .read(indicadoresProvider.notifier)
        .add(
          IndicatorRecordDraft(
            type: IndicatorType.weight,
            recordedAt: DateTime(2026, 10, 10, 8),
            value: 74,
          ),
        );
    expect(latestRecord(items(), IndicatorType.weight)!.value, 72.5);
    expect(
      recordsInPeriod(
        items(),
        IndicatorType.weight,
        ChartPeriod.month,
        today,
      ).map((r) => r.value),
      [74, 72.5],
    );
  });
}
