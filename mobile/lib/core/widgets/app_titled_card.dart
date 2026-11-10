import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_card.dart';
import 'lucide_icon.dart';

/// Card com cabeçalho do protótipo (`Card` + `CardHeader` + `CardTitle
/// className="flex items-center gap-2"` + `CardContent`): ícone lucide de
/// 20px a 8px do título de 16px (`leading-none`), padding de 24px e 24px
/// entre o cabeçalho e o [child] (`gap-6`).
class AppTitledCard extends StatelessWidget {
  const AppTitledCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  final String icon;
  final Color iconColor;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              LucideIcon(icon, size: 20, color: iconColor),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: AppTypography.inter(
                    size: 16,
                    lineHeight: 16,
                    color: colors.cardForeground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}
