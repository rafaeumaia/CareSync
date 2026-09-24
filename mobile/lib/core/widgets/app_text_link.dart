import 'package:flutter/material.dart';

/// Link em texto do CareSync: botão sem fundo nem padding cujo texto ganha
/// sublinhado enquanto pressionado (`hover:underline` do protótipo).
///
/// O estilo (cor, tamanho, peso) vem de quem usa, pois varia entre as telas
/// — ex.: "Esqueci minha senha" (14px/400) e "Criar conta" (16px/500).
class AppTextLink extends StatefulWidget {
  const AppTextLink({
    super.key,
    required this.label,
    required this.style,
    this.onPressed,
  });

  final String label;
  final TextStyle? style;

  /// Pode ser nulo para links que, no protótipo, não têm ação — o toque
  /// continua mostrando o feedback visual, sem executar nada.
  final VoidCallback? onPressed;

  @override
  State<AppTextLink> createState() => _AppTextLinkState();
}

class _AppTextLinkState extends State<AppTextLink> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => _setPressed(true),
        onExit: (_) => _setPressed(false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: widget.onPressed ?? () {},
          child: Text(
            widget.label,
            style: widget.style?.copyWith(
              decoration:
                  _pressed ? TextDecoration.underline : TextDecoration.none,
              decorationColor: widget.style?.color,
            ),
          ),
        ),
      ),
    );
  }
}
