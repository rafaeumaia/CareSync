import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/tinted_icon_circle.dart';
import '../../domain/indicador.dart';

/// Ícone lucide e cor semântica de cada indicador. As cores fixas do
/// protótipo viram tokens: `#EB5757` → `destructive`, `#2F80ED` →
/// `primary`, `#F2994A` → `warning`, `#27AE60` → `success`.
({String icon, Color color}) indicatorStyle(
  BuildContext context,
  IndicatorType type,
) {
  final colors = context.careSyncColors;
  return switch (type) {
    IndicatorType.pressure => (
      icon: 'heart_outline',
      color: colors.destructive,
    ),
    IndicatorType.glucose => (icon: 'droplet', color: colors.primary),
    IndicatorType.temperature => (icon: 'thermometer', color: colors.warning),
    IndicatorType.weight => (icon: 'weight', color: colors.success),
  };
}

/// Card de um indicador com a medição mais recente ([latest]), centralizado,
/// com padding de 16px: ícone de 24px num círculo de 48px na cor do
/// indicador a `${cor}15` (≈8%); 12px abaixo (`mb-3`), o nome (14px,
/// `muted-foreground`); 4px abaixo (`mb-1`), o valor (24px/600 na cor do
/// indicador) e a unidade (12px, `muted-foreground`). Sem medições, mostra
/// "--".
class IndicatorCard extends StatelessWidget {
  const IndicatorCard({super.key, required this.type, required this.latest});

  final IndicatorType type;
  final IndicatorRecord? latest;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    final style = indicatorStyle(context, type);
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TintedIconCircle(
            icon: style.icon,
            color: style.color,
            opacity: 0x15 / 255,
          ),
          const SizedBox(height: 12),
          Text(
            type.label,
            textAlign: TextAlign.center,
            style: AppTypography.inter(
              size: 14,
              lineHeight: 20,
              color: colors.mutedForeground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            latest?.formattedValue ?? '--',
            textAlign: TextAlign.center,
            style: AppTypography.inter(
              size: 24,
              lineHeight: 32,
              weight: FontWeight.w600,
              color: style.color,
            ),
          ),
          Text(
            type.unit,
            textAlign: TextAlign.center,
            style: AppTypography.inter(
              size: 12,
              lineHeight: 16,
              color: colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
