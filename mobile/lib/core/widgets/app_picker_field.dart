import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_text_field.dart';
import 'lucide_icon.dart';

/// Campo de data ou horário: equivalente, em Flutter, ao `<Input
/// type="date">` / `<Input type="time">` do protótipo. Tem a mesma aparência
/// do `Input` padrão ([AppInputVariant.standard]) e abre o seletor nativo
/// ao ser tocado.
///
/// Sem valor, mostra o formato esperado (ex.: "dd/mm/aaaa", "--:--"), como
/// o navegador faz nesses campos, com o ícone correspondente à direita.
class AppPickerField extends StatefulWidget {
  const AppPickerField({
    super.key,
    required this.label,
    required this.emptyText,
    required this.icon,
    required this.onTap,
    this.value,
  });

  final String label;

  /// Texto formatado do valor atual; nulo quando vazio.
  final String? value;
  final String emptyText;

  /// Nome do ícone lucide exibido à direita.
  final String icon;

  /// Abre o seletor. O campo fica com a aparência de foco enquanto o
  /// `Future` não termina.
  final Future<void> Function() onTap;

  @override
  State<AppPickerField> createState() => _AppPickerFieldState();
}

class _AppPickerFieldState extends State<AppPickerField> {
  bool _active = false;

  Future<void> _open() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _active = true);
    try {
      await widget.onTap();
    } finally {
      if (mounted) setState(() => _active = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppFieldLabel(widget.label, onTap: _open),
        const SizedBox(height: 8),
        Semantics(
          button: true,
          label: widget.label,
          value: widget.value,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _open,
            child: AppInputBox(
              variant: AppInputVariant.standard,
              focused: _active,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.value ?? widget.emptyText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppInputBox.textStyle(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  LucideIcon(widget.icon, size: 16, color: colors.foreground),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
