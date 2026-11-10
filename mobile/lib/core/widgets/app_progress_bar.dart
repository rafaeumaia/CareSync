import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// Barra de progresso do protótipo (`ui/progress.tsx`): trilho `primary` a
/// 20% com cantos `rounded-full` e preenchimento `primary`, que anima a
/// mudança de valor em 150ms (`transition-all`).
///
/// [value] vai de 0 a 1; [height] padrão de 8px (`h-2`).
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.semanticLabel,
  });

  final double value;
  final double height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final primary = context.careSyncColors.primary;
    final clamped = value.clamp(0.0, 1.0);
    return Semantics(
      label: semanticLabel,
      value: '${(clamped * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Container(
          height: height,
          color: primary.withValues(alpha: 0.2),
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: clamped),
            duration: const Duration(milliseconds: 150),
            curve: const Cubic(0.4, 0, 0.2, 1),
            builder: (context, fraction, _) => FractionallySizedBox(
              widthFactor: fraction,
              heightFactor: 1,
              child: ColoredBox(color: primary),
            ),
          ),
        ),
      ),
    );
  }
}
