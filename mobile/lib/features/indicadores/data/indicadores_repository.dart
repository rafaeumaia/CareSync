import '../domain/indicador.dart';

/// Contrato de acesso às medições de indicadores de saúde.
///
/// Hoje implementado em memória por [InMemoryIndicadoresRepository]; a
/// implementação definitiva consumirá a API Django (CLAUDE.md), sem banco
/// local como fonte principal.
abstract interface class IndicadoresRepository {
  Future<List<IndicatorRecord>> fetchRecords();
  Future<IndicatorRecord> addRecord(IndicatorRecordDraft draft);
}

/// Repositório em memória, iniciado com os dados do protótipo
/// (`IndicadoresScreen.tsx`). Os registros duram enquanto o app estiver
/// aberto.
class InMemoryIndicadoresRepository implements IndicadoresRepository {
  InMemoryIndicadoresRepository({
    required DateTime today,
    List<IndicatorRecord>? initial,
  }) : _items = [...(initial ?? seed(today))],
       _nextId = (initial ?? seed(today)).length + 1;

  /// Dados do protótipo com datas reais:
  /// - pressão e glicemia: os 7 valores do protótipo, um por dia, do mais
  ///   antigo (6 dias atrás) ao mais recente (hoje), às 08:00 — o último é
  ///   o valor do card ("126/80", "109");
  /// - temperatura e peso: o protótipo só tem o valor atual ("36.5",
  ///   "72.5"), registrado hoje às 08:00.
  static List<IndicatorRecord> seed(DateTime today) {
    DateTime day(int daysAgo) =>
        DateTime(today.year, today.month, today.day - daysAgo, 8);

    const pressure = [
      (130, 85),
      (125, 80),
      (128, 82),
      (132, 86),
      (127, 81),
      (129, 83),
      (126, 80),
    ];
    const glucose = [110, 105, 115, 108, 112, 107, 109];

    var id = 0;
    return [
      for (var i = 0; i < 7; i++)
        IndicatorRecord(
          id: ++id,
          type: IndicatorType.pressure,
          recordedAt: day(6 - i),
          value: pressure[i].$1.toDouble(),
          diastolic: pressure[i].$2.toDouble(),
        ),
      for (var i = 0; i < 7; i++)
        IndicatorRecord(
          id: ++id,
          type: IndicatorType.glucose,
          recordedAt: day(6 - i),
          value: glucose[i].toDouble(),
        ),
      IndicatorRecord(
        id: ++id,
        type: IndicatorType.temperature,
        recordedAt: day(0),
        value: 36.5,
      ),
      IndicatorRecord(
        id: ++id,
        type: IndicatorType.weight,
        recordedAt: day(0),
        value: 72.5,
      ),
    ];
  }

  final List<IndicatorRecord> _items;
  int _nextId;

  @override
  Future<List<IndicatorRecord>> fetchRecords() async =>
      List.unmodifiable(_items);

  @override
  Future<IndicatorRecord> addRecord(IndicatorRecordDraft draft) async {
    final record = IndicatorRecord(
      id: _nextId++,
      type: draft.type,
      recordedAt: draft.recordedAt,
      value: draft.value,
      diastolic: draft.diastolic,
    );
    _items.add(record);
    return record;
  }
}
