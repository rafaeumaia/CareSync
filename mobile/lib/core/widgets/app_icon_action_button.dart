import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import 'lucide_icon.dart';

/// Botão de ícone dos cards do protótipo (`p-2 hover:bg-secondary
/// rounded-lg transition-colors`, como editar/excluir em
/// `ConsultasScreen.tsx`): ícone lucide de 16px com 8px de padding, que
/// ganha fundo `secondary` enquanto pressionado.
class AppIconActionButton extends StatefulWidget {
  const AppIconActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.semanticLabel,
    required this.onTap,
  });

  final String icon;
  final Color color;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  State<AppIconActionButton> createState() => _AppIconActionButtonState();
}

class _AppIconActionButtonState extends State<AppIconActionButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final secondary = context.careSyncColors.secondary;
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _pressed ? secondary : secondary.withValues(alpha: 0),
            borderRadius: BorderRadius.circular(AppRadius.item),
          ),
          child: LucideIcon(widget.icon, size: 16, color: widget.color),
        ),
      ),
    );
  }
}
