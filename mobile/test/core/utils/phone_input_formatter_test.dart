import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:caresync/core/utils/phone_input_formatter.dart';

TextEditingValue _value(String text) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: text.length),
);

String _edit(String oldText, String newText) =>
    const BrazilianPhoneInputFormatter()
        .formatEditUpdate(_value(oldText), _value(newText))
        .text;

void main() {
  test('Formata enquanto digita', () {
    expect(BrazilianPhoneInputFormatter.format(''), '');
    expect(BrazilianPhoneInputFormatter.format('1'), '(1');
    expect(BrazilianPhoneInputFormatter.format('11'), '(11');
    expect(BrazilianPhoneInputFormatter.format('119'), '(11) 9');
    expect(BrazilianPhoneInputFormatter.format('119888'), '(11) 9888');
    expect(BrazilianPhoneInputFormatter.format('1198888'), '(11) 9888-8');
    expect(BrazilianPhoneInputFormatter.format('1133334444'), '(11) 3333-4444');
    expect(
      BrazilianPhoneInputFormatter.format('11988887777'),
      '(11) 98888-7777',
    );
  });

  test('Ignora o que não é dígito e limita a 11 dígitos', () {
    expect(_edit('', 'a1b1-9'), '(11) 9');
    expect(_edit('', '119888877776'), '(11) 98888-7777');
    expect(_edit('', '+55 (11) 98888-7777'), '(55) 11988-8877');
  });

  test('Apagar um caractere da máscara apaga o dígito anterior', () {
    // Backspace no hífen de "(11) 9888-8".
    expect(_edit('(11) 9888-8', '(11) 98888'), '(11) 9888');
    // Backspace no espaço de "(11) 9".
    expect(_edit('(11) 9', '(11)9'), '(11');
    expect(_edit('(1', '('), '');
  });
}
