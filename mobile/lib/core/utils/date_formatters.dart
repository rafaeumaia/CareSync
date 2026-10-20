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

String _twoDigits(int n) => n.toString().padLeft(2, '0');

/// Data no formato `dd/mm/aaaa` (`toLocaleDateString('pt-BR', { day:
/// '2-digit', month: '2-digit', year: 'numeric' })` do protótipo).
String formatDdMmYyyy(DateTime date) =>
    '${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year}';

/// Horário no formato `HH:mm` (valor de um `<input type="time">`).
String formatHhMm(int hour, int minute) =>
    '${_twoDigits(hour)}:${_twoDigits(minute)}';
