import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';

/// Card padrão do CareSync (`ui/card.tsx` do protótipo): fundo `card`, sem
/// borda, cantos `rounded-xl` (16px) e a sombra padrão.
///
/// Quando [onTap] é informado, o card é clicável e, enquanto pressionado,
/// ganha a sombra `shadow-lg` (`hover:shadow-lg transition-shadow`, 150ms).
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: const Cubic(0.4, 0, 0.2, 1),
      padding: widget.padding,
      decoration: BoxDecoration(
        color: context.careSyncColors.card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: _pressed ? AppShadows.lg : AppShadows.card,
      ),
      child: widget.child,
    );

    if (widget.onTap == null) return card;

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: card,
      ),
    );
  }
}
