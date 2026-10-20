import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'lucide_icon.dart';

/// Estado vazio de lista do protótipo (`text-center py-12`): ícone lucide
/// opcional de 64px em `muted-foreground`, 16px acima (`mb-4`) do texto
/// centralizado de 16px em `muted-foreground`.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({super.key, required this.message, this.icon});

  final String message;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            LucideIcon(icon!, size: 64, color: colors.mutedForeground),
            const SizedBox(height: 16),
          ],
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.inter(
              size: 16,
              lineHeight: 24,
              color: colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
