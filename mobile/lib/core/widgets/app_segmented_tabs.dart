import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

/// Lista de abas do protótipo (`TabsList` + `TabsTrigger` de `ui/tabs.tsx`,
/// com `grid w-full grid-cols-N`): trilho `muted` de 36px (`h-9`), cantos
/// `rounded-xl` e 3px de padding; cada aba ocupa uma coluna igual, com
/// texto de 14px/500 em `foreground`, e a ativa ganha fundo `card`.
///
/// No escuro, as inativas usam `muted-foreground` e a ativa fica com fundo
/// `input/30` e borda de 1px `input` (`dark:data-[state=active]:...`).
class AppSegmentedTabs extends StatelessWidget {
  const AppSegmentedTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // `--input` do tema escuro: rgba(255, 255, 255, 0.1).
    const darkInput = Color(0x1AFFFFFF);
    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: i == selectedIndex,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(i),
                  child: Container(
                    // `h-[calc(100%-1px)]` do trilho de 30px internos.
                    height: 29,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: i != selectedIndex
                          ? null
                          : isDark
                          ? Colors.white.withValues(alpha: 0.03)
                          : colors.card,
                      border: Border.all(
                        color: isDark && i == selectedIndex
                            ? darkInput
                            : Colors.transparent,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                    ),
                    child: Text(
                      labels[i],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.inter(
                        size: 14,
                        lineHeight: 20,
                        weight: FontWeight.w500,
                        color: isDark && i != selectedIndex
                            ? colors.mutedForeground
                            : colors.foreground,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
