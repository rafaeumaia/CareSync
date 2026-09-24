import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

/// Badge do protótipo (`ui/badge.tsx`): etiqueta com cantos `rounded-md`,
/// borda transparente de 1px, padding `px-2 py-0.5` e texto 12px
/// (`text-xs`) com peso 500.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      // 1px de borda transparente + `px-2 py-0.5`.
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Text(
        label,
        maxLines: 1,
        style: AppTypography.inter(
          size: 12,
          lineHeight: 16,
          weight: FontWeight.w500,
          color: foregroundColor,
        ),
      ),
    );
  }
}
