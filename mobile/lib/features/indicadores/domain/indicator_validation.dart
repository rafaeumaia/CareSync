import 'indicador.dart';

/// Erros do formulário "Adicionar Indicador", por campo (`null` = válido).
class IndicatorFormErrors {
  const IndicatorFormErrors({this.value, this.diastolic, this.dateTime});

  /// Campo "Valor" (ou "Sistólica", na pressão arterial).
  final String? value;
  final String? diastolic;
  final String? dateTime;

  bool get isValid => value == null && diastolic == null && dateTime == null;
}

/// Converte o texto digitado num número. Aceita apenas dígitos com, no
/// máximo, uma parte decimal separada por ponto ou vírgula (ex.: "36,5").
double? parseMeasurement(String text) {
  final normalized = text.trim().replaceAll(',', '.');
  if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(normalized)) return null;
  return double.tryParse(normalized);
}

/// Valida o formulário quanto à integridade e ao formato dos dados — sem
/// faixas clínicas:
/// - valores obrigatórios, numéricos e maiores que zero;
/// - na pressão arterial, sistólica e diastólica separadamente, e a
///   diastólica menor que a sistólica (por definição);
/// - data e hora obrigatória e não posterior a [now].
IndicatorFormErrors validateIndicatorForm({
  required IndicatorType type,
  required String valueText,
  required String diastolicText,
  required DateTime? dateTime,
  required DateTime now,
}) {
  final isPressure = type == IndicatorType.pressure;

  String? numberError(String text, String emptyMessage) {
    if (text.trim().isEmpty) return emptyMessage;
    final number = parseMeasurement(text);
    if (number == null) return 'Digite um número válido.';
    if (number <= 0) return 'O valor deve ser maior que zero.';
    return null;
  }

  final valueError = numberError(
    valueText,
    isPressure ? 'Informe a sistólica.' : 'Informe o valor.',
  );
  var diastolicError = isPressure
      ? numberError(diastolicText, 'Informe a diastólica.')
      : null;
  if (isPressure && valueError == null && diastolicError == null) {
    final systolic = parseMeasurement(valueText)!;
    final diastolic = parseMeasurement(diastolicText)!;
    if (diastolic >= systolic) {
      diastolicError = 'A diastólica deve ser menor que a sistólica.';
    }
  }

  String? dateTimeError;
  if (dateTime == null) {
    dateTimeError = 'Informe a data e hora.';
  } else if (dateTime.isAfter(now)) {
    dateTimeError = 'A data e hora não pode estar no futuro.';
  }

  return IndicatorFormErrors(
    value: valueError,
    diastolic: diastolicError,
    dateTime: dateTimeError,
  );
}
