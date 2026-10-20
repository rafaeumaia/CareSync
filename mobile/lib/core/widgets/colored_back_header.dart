import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_typography.dart';
import 'lucide_icon.dart';

/// Header colorido das telas secundárias do protótipo (PROJECT_SPEC.md,
/// seção 4 — "Header colorido com voltar"), como em `MedicacoesScreen.tsx`:
/// bloco [color] com texto branco, padding `px-6 pt-8 pb-6`, cantos
/// inferiores `rounded-b-3xl` (24px) e a sombra padrão; seta de voltar de
/// 24px a 16px (`gap-4`) do título de 24px/600 (`text-2xl font-semibold`)
/// e, 16px abaixo (`mb-4`), o [subtitle] de 14px em branco a 90%.
class ColoredBackHeader extends StatelessWidget {
  const ColoredBackHeader({
    super.key,
    required this.color,
    required this.title,
    required this.onBack,
    this.subtitle,
  });

  final Color color;
  final String title;
  final String? subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppRadius.headerBottom),
        ),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Semantics(
                button: true,
                label: 'Voltar',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onBack,
                  child: const LucideIcon(
                    'arrow-left',
                    size: 24,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.inter(
                    size: 24,
                    lineHeight: 32,
                    weight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 16),
            Text(
              subtitle!,
              style: AppTypography.inter(
                size: 14,
                lineHeight: 20,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
