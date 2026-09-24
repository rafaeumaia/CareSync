import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'lucide_icon.dart';

/// Casca de navegação das 4 abas fixas do BottomNav (PROJECT_SPEC.md,
/// seção 4): Início, Agenda, Saúde, Relatórios.
///
/// Usada como `builder` de um `StatefulShellRoute.indexedStack` em
/// `core/router/app_router.dart`, preservando o estado de cada aba ao
/// alternar entre elas.
class BottomNavShell extends StatelessWidget {
  const BottomNavShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

/// BottomNav fiel a `BottomNav.tsx` do protótipo: fundo `card` com a sombra
/// padrão invertida, 4 colunas iguais (limitadas ao `app-container` de
/// 900px), cada item com ícone lucide de 24px, 4px de espaço e rótulo de
/// 12px (`text-xs`), com padding `py-3 px-2` — 68px de altura.
///
/// Item ativo: ícone e rótulo em `primary`, com o ícone preenchido em
/// `primary` a 20% (`fill-[#2F80ED]/20`). Inativo: `muted-foreground`.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const items = [
    (icon: 'house', label: 'Início'),
    (icon: 'calendar', label: 'Agenda'),
    (icon: 'heart_outline', label: 'Saúde'),
    (icon: 'file-text', label: 'Relatórios'),
  ];

  /// Altura do conteúdo do BottomNav, sem a área segura inferior.
  static const double height = 68;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        boxShadow: AppShadows.bottomNav,
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _BottomNavItem(
                      icon: items[i].icon,
                      label: items[i].label,
                      isActive: i == currentIndex,
                      onTap: () => onTap(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    final target = isActive ? colors.primary : colors.mutedForeground;

    return Semantics(
      button: true,
      selected: isActive,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          // `transition-colors` (150ms).
          child: TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: target),
            duration: const Duration(milliseconds: 150),
            curve: const Cubic(0.4, 0, 0.2, 1),
            builder: (context, color, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LucideIcon(
                  icon,
                  size: 24,
                  color: color,
                  fillColor:
                      isActive ? colors.primary.withValues(alpha: 0.2) : null,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.inter(
                    size: 12,
                    lineHeight: 16,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
