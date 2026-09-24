import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';

/// Indicador de progresso (dots) do Onboarding.
///
/// Reproduz `OnboardingScreen.tsx`: pílulas de 8px de altura separadas por
/// 8px (`gap-2`); a ativa tem 32px de largura em `primary` (`w-8`), as
/// inativas 8px em cinza (`w-2 bg-gray-300`). A troca anima largura e cor
/// com o `transition-all` padrão do Tailwind (150ms,
/// `cubic-bezier(0.4, 0, 0.2, 1)`).
class OnboardingPageIndicator extends StatelessWidget {
  const OnboardingPageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  /// `gray-300` do Tailwind v4.1 (`oklch(87.2% 0.01 258.338)`). Não é um
  /// token do tema no protótipo, então é mantido igual em claro e escuro.
  static const inactiveColor = Color(0xFFD1D5DC);

  static const _duration = Duration(milliseconds: 150);
  static const _curve = Cubic(0.4, 0, 0.2, 1);

  @override
  Widget build(BuildContext context) {
    final primary = context.careSyncColors.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          AnimatedContainer(
            key: ValueKey('onboarding-dot-$i'),
            duration: _duration,
            curve: _curve,
            width: i == currentIndex ? 32 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == currentIndex ? primary : inactiveColor,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
        ],
      ],
    );
  }
}
