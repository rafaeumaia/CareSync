/// Tipos de indicador de saúde do protótipo (`IndicadoresScreen.tsx`) e da
/// entidade `IndicadorSaude` (PROJECT_SPEC.md, seção 12).
enum IndicatorType {
  pressure('Pressão Arterial', 'mmHg'),
  glucose('Glicemia', 'mg/dL'),
  temperature('Temperatura', '°C'),
  weight('Peso', 'kg');

  const IndicatorType(this.label, this.unit);

  final String label;
  final String unit;
}

/// Uma medição de um indicador.
class IndicatorRecord {
  const IndicatorRecord({
    required this.id,
    required this.type,
    required this.recordedAt,
    required this.value,
    this.diastolic,
  }) : assert(
         (type == IndicatorType.pressure) == (diastolic != null),
         'A diastólica existe somente na pressão arterial.',
       );

  final int id;
  final IndicatorType type;

  /// Data e hora da medição, no horário local.
  final DateTime recordedAt;

  /// Valor medido; na pressão arterial, a sistólica.
  final double value;

  /// Diastólica (somente na pressão arterial).
  final double? diastolic;

  /// Valor como exibido no card (ex.: "126/80", "36.5").
  String get formattedValue => type == IndicatorType.pressure
      ? '${formatMeasurement(value)}/${formatMeasurement(diastolic!)}'
      : formatMeasurement(value);
}

/// Dados de uma nova medição, já validados.
class IndicatorRecordDraft {
  const IndicatorRecordDraft({
    required this.type,
    required this.recordedAt,
    required this.value,
    this.diastolic,
  });

  final IndicatorType type;
  final DateTime recordedAt;
  final double value;
  final double? diastolic;
}

/// Períodos dos gráficos.
enum ChartPeriod {
  week(7, '7 dias'),
  month(30, '30 dias'),
  quarter(90, '90 dias');

  const ChartPeriod(this.days, this.label);

  final int days;
  final String label;

  /// Primeiro instante do período que termina em [today] (inclui hoje).
  DateTime start(DateTime today) =>
      DateTime(today.year, today.month, today.day - (days - 1));
}

/// Número com até 2 casas decimais e ponto, sem zeros à direita, como os
/// valores do protótipo ("109", "36.5").
String formatMeasurement(double value) {
  var text = value.toStringAsFixed(2);
  if (text.contains('.')) {
    text = text
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
  return text;
}

/// Medição mais recente de [type], ou `null` se não houver nenhuma.
IndicatorRecord? latestRecord(
  Iterable<IndicatorRecord> records,
  IndicatorType type,
) {
  IndicatorRecord? latest;
  for (final r in records) {
    if (r.type != type) continue;
    if (latest == null || !r.recordedAt.isBefore(latest.recordedAt)) {
      latest = r;
    }
  }
  return latest;
}

/// Medições de [type] dentro de [period] (terminando em [today]), da mais
/// antiga para a mais recente.
List<IndicatorRecord> recordsInPeriod(
  Iterable<IndicatorRecord> records,
  IndicatorType type,
  ChartPeriod period,
  DateTime today,
) {
  final start = period.start(today);
  return [
    for (final r in records)
      if (r.type == type && !r.recordedAt.isBefore(start)) r,
  ]..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
}
