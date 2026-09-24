const _weekdays = [
  'Segunda-feira',
  'Terça-feira',
  'Quarta-feira',
  'Quinta-feira',
  'Sexta-feira',
  'Sábado',
  'Domingo',
];

const _months = [
  'Janeiro',
  'Fevereiro',
  'Março',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro',
];

/// Data por extenso no formato do protótipo: "Segunda-feira, 27 de
/// Outubro".
String formatWeekdayDayMonth(DateTime date) =>
    '${_weekdays[date.weekday - 1]}, ${date.day} de ${_months[date.month - 1]}';
