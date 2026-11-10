import 'package:flutter/services.dart';

/// Máscara de telefone brasileiro enquanto se digita: `(00) 0000-0000`
/// (fixo, 10 dígitos) ou `(00) 00000-0000` (celular, 11 dígitos). Aceita só
/// dígitos, até 11.
///
/// Apagar um caractere da máscara (ex.: o hífen) apaga o dígito anterior,
/// para que o backspace nunca "trave".
class BrazilianPhoneInputFormatter extends TextInputFormatter {
  const BrazilianPhoneInputFormatter();

  static const maxDigits = 11;

  static String _digits(String text) => text.replaceAll(RegExp(r'\D'), '');

  /// Formata [digits] (só dígitos) com a máscara.
  static String format(String digits) {
    final d = digits.length > maxDigits
        ? digits.substring(0, maxDigits)
        : digits;
    if (d.isEmpty) return '';
    if (d.length <= 2) return '($d';
    final ddd = d.substring(0, 2);
    final rest = d.substring(2);
    if (rest.length <= 4) return '($ddd) $rest';
    // Até 10 dígitos, 4 + 4; com 11, 5 + 4.
    final split = d.length == maxDigits ? 5 : 4;
    return '($ddd) ${rest.substring(0, split)}-${rest.substring(split)}';
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = _digits(newValue.text);
    final deletedMaskChar =
        newValue.text.length < oldValue.text.length &&
        digits == _digits(oldValue.text);
    if (deletedMaskChar && digits.isNotEmpty) {
      digits = digits.substring(0, digits.length - 1);
    }
    final text = format(digits);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
