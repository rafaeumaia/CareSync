import 'package:flutter/material.dart';

import 'lucide_icon.dart';

/// Padrão visual recorrente do protótipo (PROJECT_SPEC.md, seção 5.6): um
/// ícone lucide na cor do domínio dentro de um círculo com a mesma cor a
/// 10% de opacidade (ex.: `w-12 h-12 rounded-full bg-[#2F80ED]/10` com
/// ícone `w-6 h-6 text-[#2F80ED]`).
class TintedIconCircle extends StatelessWidget {
  const TintedIconCircle({
    super.key,
    required this.icon,
    required this.color,
    this.size = 48,
    this.iconSize = 24,
  });

  /// Nome do ícone lucide (ver [LucideIcon]).
  final String icon;
  final Color color;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: LucideIcon(icon, size: iconSize, color: color),
    );
  }
}
