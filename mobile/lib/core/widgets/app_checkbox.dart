import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'lucide_icon.dart';

/// Checkbox do protótipo (`ui/checkbox.tsx`) com o texto ao lado
/// (`flex items-center space-x-2` + `<label htmlFor>`):
/// - caixa de 16px com cantos de 4px, borda de 1px `border` e fundo
///   `input-background` (no escuro, `input/30`), com a sombra `shadow-xs`;
/// - marcada, fundo e borda `primary` com o check lucide de 14px em
///   `primary-foreground`;
/// - [label] a 8px da caixa; tocar na caixa ou no texto alterna o valor.
///
/// [richLabel], quando informado, é exibido no lugar de [label] (que segue
/// como rótulo da caixa para leitores de tela) e pode ter trechos
/// tocáveis próprios (ex.: links para os termos), que não alternam o valor.
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.labelStyle,
    this.richLabel,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  final TextStyle? labelStyle;
  final InlineSpan? richLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // `--input` escuro (rgba(255, 255, 255, 0.1)) a 30%.
    final uncheckedFill = isDark
        ? Colors.white.withValues(alpha: 0.03)
        : colors.inputBackground;

    void toggle() => onChanged(!value);

    final box = Container(
      width: 16,
      height: 16,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: value ? colors.primary : uncheckedFill,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: value ? colors.primary : colors.border),
        // `shadow-xs`: 0 1px 2px rgb(0 0 0 / 0.05).
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: value
          ? LucideIcon('check', size: 14, color: colors.primaryForeground)
          : null,
    );

    final text = richLabel;
    if (text == null) {
      return Semantics(
        checked: value,
        label: label,
        excludeSemantics: true,
        onTap: toggle,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: toggle,
          child: Row(
            children: [
              box,
              const SizedBox(width: 8),
              Expanded(child: Text(label, style: labelStyle)),
            ],
          ),
        ),
      );
    }

    // Com trechos tocáveis, a caixa é o nó "checkbox" e o texto fica
    // acessível à parte, para que os links possam ser ativados.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: toggle,
      child: Row(
        children: [
          Semantics(
            checked: value,
            label: label,
            excludeSemantics: true,
            onTap: toggle,
            child: box,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text.rich(text, style: labelStyle)),
        ],
      ),
    );
  }
}
