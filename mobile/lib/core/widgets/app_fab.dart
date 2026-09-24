import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import 'lucide_icon.dart';

/// Botão flutuante circular "+" do protótipo (PROJECT_SPEC.md, seção 4):
/// 56x56 (`w-14 h-14 rounded-full`), fundo `primary` (a 90% quando
/// pressionado), ícone `plus` branco de 24px e sombra `shadow-lg`.
///
/// No protótipo ele fica `fixed bottom-24 right-6`: 96px acima da borda da
/// tela e 24px da direita. Como o BottomNav mede 68px, use [AppFab.bottom]
/// para posicioná-lo acima do BottomNav.
class AppFab extends StatefulWidget {
  const AppFab({
    super.key,
    required this.onPressed,
    required this.semanticLabel,
    this.color,
  });

  /// Distância do FAB até o topo do BottomNav (96px - 68px).
  static const double bottom = 28;

  /// Distância do FAB até a borda direita (`right-6`).
  static const double right = 24;

  final VoidCallback onPressed;
  final String semanticLabel;

  /// Cor de fundo. Padrão: `primary`.
  final Color? color;

  @override
  State<AppFab> createState() => _AppFabState();
}

class _AppFabState extends State<AppFab> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    final background = widget.color ?? colors.primary;
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _pressed ? background.withValues(alpha: 0.9) : background,
            shape: BoxShape.circle,
            boxShadow: AppShadows.fab,
          ),
          child: LucideIcon(
            'plus',
            size: 24,
            color: colors.primaryForeground,
          ),
        ),
      ),
    );
  }
}
